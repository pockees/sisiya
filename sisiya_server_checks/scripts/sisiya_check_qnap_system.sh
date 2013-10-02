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
#################################################################################
min_argc=8
max_argc=9
if test $# -lt $min_argc || test $# -gt $max_argc ; then
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name check_system snmp_version snmp_community snmp_username snmp_password expire"
	echo "Usage  : $0 sisiya_server_checks.conf check_system check_system_name snmp_version snmp_community snmp_username snmp_password expire output_file"
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 2c \"\" \"\" public 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 2c \"\" \"\" public 10 output_file" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 3 \"admin\" \"admin_password\" public 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 3 \"admin\" \"admin_password\" public 10 output_file" 
	echo "expire must be specified in minutes."
	echo "check_system is the IP or DNS hostname of the target system and check_system_name is its SisIYA's name."
	echo "Without the output_file, the script will send the message directly to the SisIYA server."
	exit 1
fi

conf_file=$1
if test ! -f "$conf_file" ; then
	echo "$0  : Configuration file $conf_file does not exist! Exiting... "
	exit 1
fi
expire=$8
if test $# -eq $max_argc ; then
	output_file=$9
	if test ! -f "$output_file" ; then
		echo "$0  : Output file $output_file does not exist! Exiting... "
		exit 1
	fi
fi

### source the config file
. $conf_file 
#################################################################################
check_system_name=`echo $2	| tr -d "\""`
check_system=`echo 	$3	| tr -d "\""`
snmp_version=`echo 	$4	| tr -d "\""`
snmp_comm=`echo 	$5	| tr -d "\""`
snmp_user=`echo 	$6	| tr -d "\""`
snmp_password=`echo 	$7	| tr -d "\""`

if test -z "$snmp_version" ; then
	snmp_version="2c"
fi

if test -z "$snmp_comm" ; then
	snmp_comm="public"
fi

for d in $sisiya_server_checks_dir
do
	if test ! -d "$d" ; then
		echo "Directory $d does not exist! Exiting..."
		exit 1
	fi
done 

if test ! -f "$sisiya_client_conf_file" ; then
	echo "File $sisiya_client_conf_file does not exist! Exiting..."
	exit 1
fi

### source the client config file
. $sisiya_client_conf_file

if test ! -f $sisiya_functions ; then
	echo "$0 : SISIYA functions file $sisiya_functions does not exist!"
	exit 1
fi
### source the functions file
. $sisiya_functions
##########################################################################
### service id
serviceid=$serviceid_system  
##########################################################################
service_name="System"
check_prog=$snmpwalk_prog
if test ! -x $check_prog ; then
	echo "$service_name check program $check_prog does not exist or is not executable! Exiting..."
	exit 1
fi
###############################################################################
### The format of error and warning uptimes is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
### 3) warning_uptime must be greater than error_uptime
###############################################################################
### default values
error_uptime=0:30
warning_uptime=1:0
### end of the default values

### One can override the default values in the $sisiya_server_checks_dir/$system_conf_file file
### Check if there is a configuration file for this system. 
sisiya_hostname=$check_system_name
system_conf_file="${sisiya_server_checks_dir}/${sisiya_hostname}.conf"
if test -f $system_conf_file ; then
	source $system_conf_file
fi


str=`extract_datetime $error_uptime`
error_days=`echo $str		| awk '{print $1}'`
error_hours=`echo $str		| awk '{print $2}'`
error_minutes=`echo $str	| awk '{print $3}'`
str=`extract_datetime $warning_uptime`
warning_days=`echo $str		| awk '{print $1}'`
warning_hours=`echo $str	| awk '{print $2}'`
warning_minutes=`echo $str	| awk '{print $3}'`

statusid=$status_ok
str=`$check_prog -v $snmp_version $check_system -c $snmp_comm system.sysDescr 2>&1`
retcode=$?

#echo "$0: $str"

error=0
if test $retcode -eq 0 ; then
	sys_name=`echo $str | cut -d ":" -f 4`
	sys_location=`$check_prog	-v $snmp_version $check_system -c $snmp_comm system.sysLocation				| cut -d ":" -f 4 	2>&1`
	dev_name=`$check_prog		-v $snmp_version $check_system -c $snmp_comm HOST-RESOURCES-MIB::hrDeviceDescr.1	| cut -d ":" -f 4 	2>&1`
	str=`$check_prog 		-v $snmp_version $check_system -c $snmp_comm system.sysUpTime.0 						2>&1`

	str2=`echo $str | grep day`
	if test -z "$str2" ; then
		up_days=0
		time_str=`echo $str 		| cut -d ")" -f 2	|cut -d " " -f 2`
		up_hours=`echo $time_str 	| cut -d ":" -f 1`
		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
	else
	#	str2=`echo $str | cut -d ":" -f 4|cut -d ")" -f 2|cut -d "," -f 1|cut -d " " -f 2`
		up_days=`echo $str 		| cut -d "," -f 1 	| cut -d ")" -f 2	| cut -d " " -f 2`
		time_str=`echo $str 		| cut -d "," -f 2	| cut -d " " -f 2`
		up_hours=`echo $time_str 	| cut -d ":" -f 1`
		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
	fi

	#echo "system=$check_airport up_days=$up_days up_hours=$up_hours up_minutes=$up_minutes"
	
	up_in_minutes=`(echo "$up_days * 1440 + $up_hours * 60 + $up_minutes") | bc`
	error_in_minutes=`(echo "$error_days * 1440 + $error_hours * 60 + $error_minutes") | bc`
	warning_in_minutes=`(echo "$warning_days * 1440 + $warning_hours * 60 + $warning_minutes") | bc`
	up_str=`echo_datetime $up_days $up_hours $up_minutes`
	if test $up_in_minutes -lt $error_in_minutes ; then
		statusid=$status_error  
		message_str="ERROR: The system was restarted $up_str (< `echo_datetime $error_days $error_hours $error_minutes`) ago!"
	elif test $up_in_minutes -lt $warning_in_minutes ; then
		statusid=$status_warning
		message_str="WARNING: The system was restarted $up_str (< `echo_datetime $warning_days $warning_hours $warning_minutes`) ago!"
	else
		statusid=$status_ok
		message_str="OK: The system is up since ${up_str}."
	fi
	message_str="${message_str} $sys_name$sys_location"
else
	error=1
	statusid=$status_error
	message_str="ERROR: Could not get information! $str"
fi
#################################################################################
####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi

### if there was an error no need to continue
if test $retcode -ne 0 ; then
	exit 0
fi
