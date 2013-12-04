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
serviceid=$serviceid_dmesg 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_dmesg is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
number_of_error_strings=7
error_strings[0]="error"
error_strings[1]="fail"
error_strings[2]="down"
error_strings[3]="crit"
error_strings[4]="promiscuous"
error_strings[5]="fault"
error_strings[6]="timed out"
number_of_warning_strings=4
warning_strings[0]="warn"
warning_strings[1]="notice"
warning_strings[2]="not responding"
warning_strings[3]="NIC Link is Up"
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`
for f in $tmp_ok_file $tmp_warning_file $tmp_error_file
do
	rm -f $f
	touch $f
done

if test $number_of_error_strings -lt 1 ; then
        echo "WARNING: The total number of error strings=$number_of_error_strings must be greater than 1!" >> $tmp_warning_file
fi
if test $number_of_warning_strings -lt 1 ; then
        echo "WARNING: The total number of warning strings=$number_of_warning_strings must be greater than 1!" >> $tmp_warning_file
fi

#declare -i i=0
i=0
while test $i -lt $number_of_error_strings
do
	error_str="${error_strings[${i}]}"
	if test "$sisiya_osname" = "AIX" ; then
		### AIX does not have dmesg command. I use alog instead. alog -L lists log types.
		#str=`alog -o -t console | head -n 1`
		### use the following command to clear the log file : errclear -i /var/adm/ras/errlog 0
		str=`errpt | head -n 1`
	else
		str=`dmesg | grep -i "$error_str" | head -n 1`
	fi
	if test -n "$str" ; then
		#str=`echo $str | tr -s "\n" " "`
		echo "ERROR: [$str] contains the string [$error_str]!" >> $tmp_error_file
	else
		echo "[$error_str]" >> $tmp_ok_file
	fi
	i=`expr $i + 1`
done

i=0
while test $i -lt $number_of_warning_strings
do
	warning_str="${warning_strings[${i}]}"
	if test "$sisiya_osname" = "AIX" ; then
		### AIX does not have dmesg command. I use alog instead. alog -L lists log types.
		#str=`alog -o -t console | grep -i "$warning_str" | head -n 1`
		### use the following command to clear the log file : errclear -i /var/adm/ras/errlog 0
		str=`errpt | grep -i "$warning_str" | head -n 1`
	else
		str=`dmesg | grep -i "$warning_str" | head -n 1`
	fi
	if test -n "$str" ; then
		#str=`echo $str | tr -s "\n" " "`
		echo "WARNING: [$str] contains the string [$warning_str]!" >> $tmp_warning_file
	else
		echo "[$warning_str]" >> $tmp_ok_file
	fi
	i=`expr $i + 1`
done

statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	message_str=`cat $tmp_error_file | tr -s "\n" " "` 
	statusid=$status_error
fi

if test -s $tmp_warning_file ; then
	message_str="$message_str`cat $tmp_warning_file | tr -s \"\\n\" \" \"`" 
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_ok_file ; then
	message_str="${message_str}OK: dmesg does not contain any of `cat $tmp_ok_file | tr -s \"\\n\" \" \"` strings."
fi

### replace the ' with whitespace
message_str=`echo $message_str | tr -s "'" " "`

for f in $tmp_ok_file $tmp_warning_file $tmp_error_file
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
