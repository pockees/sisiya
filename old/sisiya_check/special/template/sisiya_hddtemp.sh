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
serviceid=$serviceid_hddtemp
if test -z "$serviceid" ; then
	echo "$0 : serviceid_hddtemp is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
number_of_disks=1
disk_name[0]="/dev/sda"
disk_warning[0]=31
disk_error[0]=34
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

str=`hddtemp ${disk_name[$i]} 2>/dev/null | grep "${disk_name[$i]}"`
if test $? -ne 127 ; then
	declare -i i=0
	while test $i -lt $number_of_disks
	do
		str=`hddtemp ${disk_name[$i]} 2>/dev/null | grep "${disk_name[$i]}"`
		retcode=$?
		if test $retcode -eq 0 ; then
			temp=`echo "$str"	| awk -F° '{print $1}' | awk -F: '{print $3}' | awk '{print $1}'`
			model=`echo "$str"	| awk -F° '{print $1}' | awk -F: '{print $2}'`
			if test $temp -ge ${disk_error[$i]} ; then
				echo "ERROR: $temp C >= ${disk_error[$i]} C on ${disk_name[$i]}$model!" >> $tmp_error_file
			elif test $temp -ge ${disk_warning[$i]} ; then
				echo "WARNING: $temp C >= ${disk_warning[$i]} C on ${disk_name[$i]}$model!" >> $tmp_warning_file
			else
				echo "OK: $temp C on ${disk_name[$i]}$model." >> $tmp_ok_file
			fi
		else
			echo "ERROR: $str" >> $tmp_error_file
		fi
		i=i+1
	done
else
	echo "ERROR: Could find the hddtemp command!" >> $tmp_error_file
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
