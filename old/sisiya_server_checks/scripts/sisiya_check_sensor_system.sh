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
min_argc=5
max_argc=6
if test $# -lt $min_argc || test $# -gt $max_argc ; then
	echo "Usage : $0 sisiya_server_checks.conf check_system_name check_system snmp_version snmp_community snmp_username snmp_password expire"
	echo "Usage : $0 sisiya_server_checks.conf check_system_name check_system snmp_version snmp_community snmp_username snmp_password  expire output_file"
	echo "Example: $0 sisiya_server_checks.conf sensor01.example.com sensor01.example.com 2c \"\" \"\" public 10" 
	echo "Example: $0 sisiya_server_checks.conf sensor01.example.com sensor01.example.com 2c \"\" \"\" public 10 output_file" 
	echo "expire must be specified in minutes."
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
### server service id
serviceid=$serviceid_system  
##########################################################################
service_name="System"
check_prog=$snmpwalk_prog
if test ! -x $check_prog ; then
	echo "$service_name check program $check_prog does not exist or is not executable! Exiting..."
	exit 1
fi
##########################################################################
###############################################################################
### The format of error and warning uptimes is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
### 3) warning_uptime must be greater than error_uptime
###############################################################################
### default values
error_uptime=1
warning_uptime=3
### for temperature sensors
unit_str="Grad Celsius"
number_of_temperature_sensors=0
tsensors_name[0]="internal"
tsensors_mib[0]="SNMPv2-SMI::enterprises.21796.4.1.3.1.5.2"
tsensors_error_upper[0]=35
tsensors_warning_upper[0]=30
tsensors_warning_lower[0]=25
tsensors_error_lower[0]=20
tsensors_name[1]="external"
### for system fans
number_of_fans=0
fans_name[0]="fan1"
fans_mib[0]="1.3.6.1.4.1.207.8.17.1.6.2.1.4.1.1"
fans_error_upper[0]=6200
fans_error_lower[0]=6000
fans_warning_upper[0]=6150
fans_warning_lower[0]=6050
fans_name[1]="fan2"
fans_mib[1]="1.3.6.1.4.1.207.8.17.1.6.2.1.4.1.2"
fans_error_upper[1]=6200
fans_error_lower[1]=6000
fans_warning_upper[1]=6150
fans_warning_lower[1]=6050
### end of the default values

### One can override the default values in the $sisiya_server_checks_dir/$system_conf_file file
### Check if there is a configuration file for this system. 
system_conf_file="${sisiya_server_checks_dir}/${check_system_name}.conf"
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
str=`$check_prog -v 1 $check_system -c $snmp_comm system.sysDescr 2>&1`
retcode=$?

if test $retcode -eq 0 ; then
	sys_name=`echo $str | cut -d ":" -f 4`
	sys_location=`$check_prog 	-v $snmp_version $check_system -c $snmp_comm system.sysLocation|cut -d ":" -f 4 2>&1`
	str=`$check_prog 		-v $snmp_version $check_system -c $snmp_comm system.sysUpTime.0 2>&1`

	str2=`echo $str | grep day`
	if test -z "$str2" ; then
		up_days=0
		time_str=`echo $str 		| cut -d ")" -f 2 | cut -d " " -f 2`
		up_hours=`echo $time_str 	| cut -d ":" -f 1`
		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
	else
	#	str2=`echo $str | cut -d ":" -f 4|cut -d ")" -f 2|cut -d "," -f 1|cut -d " " -f 2`
		up_days=`echo $str 		| cut -d "," -f 1	| cut -d ")" -f 2| cut -d " " -f 2`
		time_str=`echo $str 		| cut -d "," -f 2	|cut -d " " -f 2`
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
	statusid=$status_error
	message_str="ERROR: Could not get information about the $sisiya_system! $str"
fi
data_message_str=""
#################################################################################
#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
#################################################################################

#################################################################################
### Check for temperature
#################################################################################
### service id
serviceid=$serviceid_temperature  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_temperature is not defined! Exiting..."
	exit 1
fi

##########################################################################
service_name="Temperature"
##########################################################################
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
declare -i i=0

#number_of_temperature_sensors=${#tsensors_name[0]}
while test $i -lt $number_of_temperature_sensors
do
	tsensors_name=${tsensors_name[${i}]}
	tsensors_mib=${tsensors_mib[${i}]}
	tsensors_error_upper=${tsensors_error_upper[${i}]}
	tsensors_error_upper_10=`echo "$tsensors_error_upper * 10"| bc`
	tsensors_warning_upper=${tsensors_warning_upper[${i}]}
	tsensors_warning_upper_10=`echo "$tsensors_warning_upper * 10"| bc`
	tsensors_error_lower=${tsensors_error_lower[${i}]}
	tsensors_error_lower_10=`echo "$tsensors_error_lower * 10"| bc`
	tsensors_warning_lower=${tsensors_warning_lower[${i}]}
	tsensors_warning_lower_10=`echo "$tsensors_warning_lower * 10"| bc`
	#echo "tsensors_name=$tsensors_name tsensors_mib=$tsensors_mib tsensors_error=$tsensors_error tsensors_warning=$tsensors_warning snmp_comm=$snmp_comm check_system=$check_system"
	str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $tsensors_mib 2>&1`
	retcode=$?

	if test $retcode -eq 0 ; then
		tsensors_value_10=`echo $str 			| sed -e "s/: /:/" | cut -d ":" -f 4 | cut -d "\"" -f 2`
		tsensors_value=`echo "$tsensors_value_10 / 10" 	| bc`
		#echo "name=$tsensors_name tsensors_value=[$tsensors_value]"
		#echo "tsensors_value_10=$tsensors_value_10 tsensors_error_upper_10=$tsensors_error_upper_10"

		if test $tsensors_value_10 -ge $tsensors_error_upper_10 ; then
			statusid=$status_error
			error_str="$error_str ERROR: The temperature for the sensor $tsensors_name is ${tsensors_value} (>= ${tsensors_error_upper} upper) Grad Celcius!"
		elif test $tsensors_value_10 -le $tsensors_error_lower_10 ; then
			statusid=$status_error
			error_str="$error_str ERROR: The temperature for the sensor $tsensors_name is ${tsensors_value} (<= ${tsensors_error_lower} lower) Grad Celcius!"
		elif test $tsensors_value_10 -ge $tsensors_warning_upper_10 ; then
			if test $statusid -lt $status_warning ; then
				statusid=$status_warning
			fi
			warning_str="$warning_str WARNING: The temperature for the sensor $tsensors_name is ${tsensors_value} (>= ${tsensors_warning_upper} lower) Grad Celcius!"
		elif test $tsensors_value_10 -le $tsensors_warning_lower_10 ; then
			if test $statusid -lt $status_warning ; then
				statusid=$status_warning
			fi
			warning_str="$warning_str WARNING: The temperature for the sensor $tsensors_name is ${tsensors_value} (<= ${tsensors_warning_lower} lower) Grad Celcius!"
		else
			ok_str="$ok_str OK: The temperature for the sensor $tsensors_name is ${tsensors_value} ${unit_str}."
		 fi
	else
		statusid=$status_error
		error_str="$error_str ERROR: Could not get any information about the sensor=${i}!"
	fi
	i=i+1
done
if test $number_of_temperature_sensors -gt 0 ; then
	message_str="$error_str $warning_str $ok_str"
	#################################################################################
	#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi
#################################################################################
### Check for fan speeds
#################################################################################
### service id
serviceid=$serviceid_fanspeed
if test -z "$serviceid" ; then
	echo "$0 : serviceid_fanspeed is not defined! Exiting..."
	exit 1
fi

##########################################################################
service_name="Fan speed"
##########################################################################
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
declare -i i=0

while test $i -lt $number_of_fans
do
	fan_name=${fans_name[${i}]}
	fan_mib=${fans_mib[${i}]}
	fan_error_upper=${fans_error_upper[${i}]}
	fan_error_lower=${fans_error_lower[${i}]}
	fan_warning_upper=${fans_warning_upper[${i}]}
	fan_warning_lower=${fans_warning_lower[${i}]}

	#echo "fan_name=$fan_name fan_mib=$fan_mib"
	#echo "fan_error_upper=$fan_error_upper fan_error_lower=$fan_error_lower fan_warning_upper=$fan_warning_upper fan_warning_lower=$fan_warning_lower"
	#echo "snmp_comm=$snmp_comm check_system=$check_system"

	str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $fan_mib 2>&1`
	retcode=$?

	if test $retcode -eq 0 ; then
		fan_status=`echo $str | cut -d ":" -f 4 | cut -d "\"" -f 2 | cut -d " " -f 1`
		#echo "name=$fan_name fan_status=[$fan_status]"

		if test $fan_status -ge $fan_error_upper ; then
			statusid=$status_error
			error_str="$error_str ERROR: The speed of for the $fan_name fan is ${fan_status} (>= ${fan_error_upper}) RPM!"
		elif test $fan_status -le $fan_error_lower ; then
			statusid=$status_error
			error_str="$error_str ERROR: The speed of for the $fan_name fan is ${fan_status} (<= ${fan_error_lower}) RPM!"
		elif test $fan_status -ge $fan_warning_upper ; then
			if test $statusid -lt $status_warning ; then
				statusid=$status_warning
			fi
			warning_str="$warning_str WARNING: The speed of the $fan_name fan is ${fan_status} (>= ${fan_warning_upper}) RPM"
		elif test $fan_status -le $fan_warning_lower ; then
			if test $statusid -lt $status_warning ; then
				statusid=$status_warning
			fi
			warning_str="$warning_str WARNING: The speed of the $fan_name fan is ${fan_status} (<= ${fan_warning_lower}) RPM"

		else
			ok_str="$ok_str OK: The speed of the $fan_name fan is ${fan_status} RPM."
		 fi
	else
		statusid=$status_error
		error_str="$error_str ERROR: Could not get any information about the fan=${i}!"
	fi
	i=i+1
done
if test $number_of_fans -gt 0 ; then
	message_str="$error_str $warning_str $ok_str"
	#################################################################################
	#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi
