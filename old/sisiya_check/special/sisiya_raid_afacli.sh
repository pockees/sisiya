#!/bin/bash
#
#    Copyright (C) 2003 - 2010  Erdal Mutlu
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#######################################################################################
if test $# -lt 2 ; then
	echo "Usage : $0 sisiya_client.conf expire"
	echo "Usage : $0 sisiya_client.conf expire output_file"
	echo "The expire parameter must be given in minutes."
	exit 1
fi

client_conf_file=$1
expire=$2
output_file=""
if test $# -eq 3 ; then
	output_file=$3
	if test ! -f $output_file ; then
		echo "File $output_file does not exist! Exiting..."
		exit 1
	fi
fi

if test ! -f $client_conf_file ; then
	echo "$0 : SisIYA client configuration file $client_conf_file does not exist!"
	exit 1
fi

script_name=`basename $0`
sisiya_osname=`uname -s`
### source the config file
. $client_conf_file
###
module_conf_file="${sisiya_host_dir}/`echo $script_name | awk -F. '{print $1}'`.conf"

if test ! -f $sisiya_functions ; then
	echo "$0 : SisIYA functions file $sisiya_functions does not exist!"
	exit 1
fi
### source the functions file
. $sisiya_functions
### Solaris does not allow to change the PATH for root
if test "$sisiya_osname" = "SunOS" ; then
	PATH=$PATH:/usr/local/bin
	export PATH
fi
#######################################################################################
### service id
serviceid=$serviceid_raid
if test -z "$serviceid" ; then
	echo "$0 : serviceid_raid is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
# temperature values are in Celcius
controler_name=afa0
temperature_warning=35
temperature_error=38
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

### make afacli happy, when it is run via cronjob
export TERM=xterm

tmp_log_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_script_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_info_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`
for f in $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_info_file $tmp_log_file $tmp_script_file
do
	rm -f $f
	touch $f
done

which afacli > /dev/null 2>&1
if test $? -ne 0 ; then
	echo -n "WARNING: afacli command not found! " >> $tmp_warning_file
else
	### check RAIDs
	echo "open $controler_name"		> $tmp_script_file
	echo "logfile start \"$tmp_log_file\""	>> $tmp_script_file
	echo "container list"			>> $tmp_script_file
	echo "logfile end"			>> $tmp_script_file
	echo "close"				>> $tmp_script_file
	echo "exit"				>> $tmp_script_file
	(echo "@$tmp_script_file") | afacli > /dev/null
	if test -s $tmp_log_file ; then
		cat $tmp_log_file | grep "^ [0-9]" | while read line
		do
			str=`echo $line | grep "Valid"`
			if test -z "$str" ; then
				echo -n "ERROR: $line "  	>> $tmp_error_file
			else
				echo -n "OK: $line "  		>> $tmp_ok_file
			fi
			
		done
	else
		echo -n "ERROR: There was a problem executing afacli command! "  	>> $tmp_error_file
	fi

	### check temperature
	echo "open $controler_name"		> $tmp_script_file
	echo "logfile start \"$tmp_log_file\""	>> $tmp_script_file
	echo "enclosure show temperature"	>> $tmp_script_file
	echo "logfile end"			>> $tmp_script_file
	echo "close"				>> $tmp_script_file
	echo "exit"				>> $tmp_script_file
	(echo "@$tmp_script_file") | afacli > /dev/null
	if test -s $tmp_log_file ; then
		cat $tmp_log_file | grep "^ [0-9]" | while read line
		do
			id=`echo $line | awk '{print $2}'`
			sensor=`echo $line | awk '{print $3}'`
			current=`echo $line | awk '{print $4}'`
			ctemp=`echo "($current-32)*5/9" | bc`
			if test $ctemp -ge $temperature_error ; then
				echo -n "ERROR: $ctemp C (>=${temperature_error}) on $id sensor $sensor "  	>> $tmp_error_file
			elif test $ctemp -ge $temperature_warning ; then
				echo -n "WARNING: $ctemp C (>=${temperature_warning}) on $id sensor $sensor "  	>> $tmp_warning_file
			else
				echo -n "OK: $ctemp C on $id sensor $sensor "  		>> $tmp_ok_file
			fi
			
		done
	else
		echo -n "ERROR: There was a problem executing afacli command! "  	>> $tmp_error_file
	fi

fi

statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	message_str=`cat $tmp_error_file` 
	statusid=$status_error
fi

if test -s $tmp_warning_file ; then
	message_str="$message_str`cat $tmp_warning_file`" 
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_ok_file ; then
	message_str="$message_str`cat $tmp_ok_file`"
fi

if test -s $tmp_info_file ; then
	message_str="$message_str`cat $tmp_info_file`"
fi

for f in $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_info_file $tmp_log_file $tmp_script_file
do
	rm -f $f
done
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
