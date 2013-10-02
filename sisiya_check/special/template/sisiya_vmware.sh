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
serviceid=$serviceid_vmware
if test -z "$serviceid" ; then
	echo "$0 : serviceid_vmware is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
cli_prog=vmrun
vmware_user="root"
vmware_password="test123098"
vmware_host="https://localhost:8333/sdk"
vmware_total_running=1
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi

tmp_log_file=`maketemp /tmp/tmp_log_${script_name}.XXXXXX`
tmp_info_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

for f in $tmp_log_file $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_info_file
do
	rm -f $f
	touch $f
done

which $cli_prog > /dev/null 2>&1
if test $? -ne 0 ; then
	echo -n "WARNING: $cli_prog command not found! " >> $tmp_warning_file
else
	cmd_str="$cli_prog -h $vmware_host -u $vmware_user -p $vmware_password list"
	$cli_prog -h "$vmware_host" -u "$vmware_user" -p "$vmware_password" list > $tmp_log_file
	retcode=$?
	if test $retcode -eq 0 ; then
#		cat $tmp_log_file 
#		total_vms=`cat $tmp_log_file | grep "Total running VMs" | cut -d ":" -f 2` 
#		cat $tmp_log_file | awk 'NR > 1 {printf "%s\n",$0}' | while read line
#		do
#			echo "line=[$line]"
#			vm_system_name=`echo $line | cut -d " " -f 2 | cut -d "/" -f 1`
#			vm_system_type=`echo $line | cut -d "[" -f 2 | cut -d "]" -f 1`
#			echo "vm_system_name=[$vm_system_name] type=[$vm_system_type]"
#		done
#		echo "OK: Total running VMs $total_vms." >> $tmp_ok_file
		total_vms=`cat $tmp_log_file | grep "Total running VMs" | cut -d ":" -f 2` 
		if test $total_vms -ne $vmware_total_running ; then
			echo "ERROR: The number of running systems is $total_vms < $vmware_total_running!" >> $tmp_error_file
		else
			echo "OK: The number of running systems is $total_vms." >> $tmp_ok_file
		fi
		echo "Info:" >> $tmp_info_file
		cat $tmp_log_file | tr "\n" " " >> $tmp_info_file
	else
		echo "ERROR: There was a problem executing $cmd_str command!"  	>> $tmp_error_file
	fi
fi

statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	message_str=`cat $tmp_error_file | tr "\n" " "` 
	statusid=$status_error
fi

if test -s $tmp_warning_file ; then
	message_str="$message_str`cat $tmp_warning_file | tr "\n" " "`" 
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_ok_file ; then
	message_str="$message_str`cat $tmp_ok_file | tr "\n" " "`"
fi

if test -s $tmp_info_file ; then
	message_str="$message_str`cat $tmp_info_file | tr "\n" " "`"
fi

for f in $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_info_file $tmp_log_file
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
