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
#######################################################################################
### service id
serviceid=$serviceid_raid
if test -z "$serviceid" ; then
	echo "$0 : serviceid_raid is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
check_metadb=1
check_metastat=1
check_metaset=1
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

tmp_info_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`
for f in $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_info_file
do
	rm -f $f
	touch $f
done

### check the metadb info
if test $check_metadb -eq 1 ; then
	metadb -i > /dev/null 2>&1
	if test $? -ne 0 ; then
		echo -n "WARNING: metadb command not found! " >> $tmp_warning_file
	else
		count=`metadb -i | grep "/dev" | awk '{print $1}' | grep -v "^a" | wc -l`
		if test $count -ne 0 ; then
			if test $count -lt 1 ; then
				echo -n "ERROR: There is $count replica, which had problem! "  	>> $tmp_error_file
			else
				echo -n "ERROR: There are $count replicas, which had problem! "	>> $tmp_error_file
			fi
		else
			echo -n "OK: All replicas are OK. "	>> $tmp_ok_file
		fi
	fi
fi

### check the metadevice status
if test $check_metastat -eq 1 ; then
	metastat > /dev/null 2>&1
	if test $? -ne 0 ; then
		echo -n "WARNING: metastat command not found! " >> $tmp_warning_file
	else
		count=`metastat | grep "State: " | grep -v "Okay" | wc -l`
		if test $count -ne 0 ; then
			if test $count -lt 1 ; then
				echo -n "ERROR: There is $count metadevice, which had problem! "  	>> $tmp_error_file
			else
				echo -n "ERROR: There are $count metadevices, which had problem! "	>> $tmp_error_file
			fi
		else
			echo -n "OK: All metadevices are OK. "	>> $tmp_ok_file
		fi
	fi
fi
### check the metaset device status
if test $check_metaset -eq 1 ; then
	metaset > /dev/null 2>&1
	if test $? -ne 0 ; then
		echo -n "WARNING: metaset command not found! " >> $tmp_warning_file
	else
		metaset | grep "Set name" | awk '{print $4}' | awk -F, '{print $1}' | while read setname
		do
			metaset -s $setname -o -h $HOSTNAME > /dev/null 2>&1
			if test $? -ne 0 ; then
				echo -n "INFO: I am not the owner of $setname metaset. "  >> $tmp_info_file
			else
				echo -n "INFO: I am the owner of $setname metaset. "  	>> $tmp_info_file
				if test $check_metadb -eq 1 ; then
					count=`metadb -s $setname -i | grep "/dev" | awk '{print $1}' | grep -v "^a" | wc -l`
					if test $count -ne 0 ; then
						if test $count -lt 1 ; then
							echo -n "ERROR: There is $count replica in the $setname metaset, which had problem! "  	>> $tmp_error_file
						else
							echo -n "ERROR: There are $count replicas in the $setname metaset, which had problem! "	>> $tmp_error_file
						fi
					else
						echo -n "OK: All replicas in the $setname metaset are OK. "	>> $tmp_ok_file
					fi
				fi
			fi
		done
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

for f in $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_info_file
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
