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

for d in $sisiya_server_checks_dir
do
	if test ! -d "$d" ; then
		echo "Directory $d does not exist! Exiting..."
		exit 1
	fi
done 

if test -z "$snmp_version" ; then
	snmp_version="2c"
fi

if test -z "$snmp_comm" ; then
	snmp_comm="public"
fi

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
### system service id
serviceid=$serviceid_system  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_system is not defined! Exiting..."
	exit 1
fi
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
### for system
error_uptime=1
warning_uptime=3
### for battery capacity
error_battery=90
warning_battery=95
### for temperature sensors
number_of_temperature_sensors=1
tsensor_name[0]="battery"
tsensor_mib[0]="1.3.6.1.2.1.33.1.2.7"
tsensor_error[0]=27
tsensor_warning[0]=25
tsensor_name[1]="external"
tsensor_mib[1]="SNMPv2-SMI::enterprises.318.1.1.10.2.3.2.1.4.1"
tsensor_error[1]=35
tsensor_warning[1]=32
### for output looad
error_output_load=60
warning_output_load=55
### for output voltage
error_output_voltage_upper=240
error_output_voltage_lower=200
warning_output_voltage_upper=235
warning_output_voltage_lower=205
### for output frequency
error_output_frequency_upper=60
error_output_frequency_lower=40
warning_output_frequency_upper=53
warning_output_frequency_lower=47
### for time on battery in 100th of a secend (give the values as seccond*100)
### The elapsed time since the UPS has switched to battery power.
error_time_on_battery=12000	### 2 minutes
warning_time_on_battery=6000	### 1 minute
### end of the default values

### One can override the default values in the $sisiya_server_checks_dir/$system_conf_file file
### Check if there is a configuration file for this system. 
system_conf_file="${sisiya_server_checks_dir}/${check_system_name}.conf"
if test -f $system_conf_file ; then
	. $system_conf_file
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

if test $retcode -eq 0 ; then
	sys_name=`echo $str | cut -d ":" -f 4`
	sys_location=`$check_prog 	-v $snmp_version $check_system -c $snmp_comm system.sysLocation	| cut -d ":" -f 4 	2>&1`
	#DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (40100) 0:06:41.00
	#DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (63372400) 7 days, 8:02:04.00
	str=`$check_prog 		-v $snmp_version $check_system -c $snmp_comm system.sysUpTime	 			2>&1`
	str=`echo $str | sed -e "s/DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks://"`

	str2=`echo $str | grep day`
	#echo "str2=$str2"
	if test -z "$str2" ; then
		up_days=0
		time_str=`echo $str 		| cut -d ")" -f 2	|cut -d " " -f 2`
		up_hours=`echo $time_str 	| cut -d ":" -f 1`
		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
	else
		#(63388300) 7 days, 8:04:43.00
		#str2=`echo $str | cut -d ":" -f 4|cut -d ")" -f 2	| cut -d "," -f 1|cut -d " " -f 2`
		up_days=`echo $str 		| cut -d ")" -f 2	| cut -d "," -f 1 | cut -d " " -f 2`
		time_str=`echo $str		| cut -d "," -f 2	| cut -d " " -f 2`
		up_hours=`echo $time_str	| cut -d ":" -f 1`
		up_minutes=`echo $time_str	| cut -d ":" -f 2`
	fi

	#echo "system=$check_system up_days=$up_days up_hours=$up_hours up_minutes=$up_minutes"
	
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

### get system info
upsIdentManufacturer="1.3.6.1.2.1.33.1.1.1"
upsIdentModel="1.3.6.1.2.1.33.1.1.2"
upsIdentUPSSoftwareVersion="1.3.6.1.2.1.33.1.1.3"
upsIdentAgentSoftwareVersion="1.3.6.1.2.1.33.1.1.4"
upsIdentName="1.3.6.1.2.1.33.1.1.5"
upsIdentAttachedDevices="1.3.6.1.2.1.33.1.1.6"
##
upsIdent="1.3.6.1.2.1.33.1.1"
str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $upsIdent 2>&1`
retcode=$?

#if test $retcode -eq 0 ; then
#fi


#################################################################################
####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi

#################################################################################
### Check for battery
#################################################################################
### service id
serviceid=$serviceid_ups_battery  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ups_batter is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="UPS_Battery"
##########################################################################
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
###########################################################################
#upsMIB upsMIB   1.3.6.1.2.1.33          MODULE-IDENTITY
#upsObjects upsObjects   1.3.6.1.2.1.33.1        OBJECT IDENTIFIER
#upsIdent upsIdent       1.3.6.1.2.1.33.1.1      OBJECT IDENTIFIER
#upsIdentManufacturer upsIdentManufacturer       1.3.6.1.2.1.33.1.1.1    OBJECT-TYPE
#upsIdentModel upsIdentModel     1.3.6.1.2.1.33.1.1.2    OBJECT-TYPE
#upsIdentUPSSoftwareVersion upsIdentUPSSoftwareVersion   1.3.6.1.2.1.33.1.1.3    OBJECT-TYPE
#upsIdentAgentSoftwareVersion upsIdentAgentSoftwareVersion       1.3.6.1.2.1.33.1.1.4    OBJECT-TYPE
#upsIdentName upsIdentName       1.3.6.1.2.1.33.1.1.5    OBJECT-TYPE
#upsIdentAttachedDevices upsIdentAttachedDevices         1.3.6.1.2.1.33.1.1.6    OBJECT-TYPE
#upsBattery upsBattery   1.3.6.1.2.1.33.1.2      OBJECT IDENTIFIER
#upsBatteryStatus upsBatteryStatus       1.3.6.1.2.1.33.1.2.1    OBJECT-TYPE
#upsSecondsOnBattery upsSecondsOnBattery         1.3.6.1.2.1.33.1.2.2    OBJECT-TYPE
#upsEstimatedMinutesRemaining upsEstimatedMinutesRemaining       1.3.6.1.2.1.33.1.2.3    OBJECT-TYPE
#upsEstimatedChargeRemaining upsEstimatedChargeRemaining         1.3.6.1.2.1.33.1.2.4    OBJECT-TYPE
#upsBatteryVoltage upsBatteryVoltage     1.3.6.1.2.1.33.1.2.5    OBJECT-TYPE
#upsBatteryCurrent upsBatteryCurrent     1.3.6.1.2.1.33.1.2.6    OBJECT-TYPE
#upsBatteryTemperature upsBatteryTemperature     1.3.6.1.2.1.33.1.2.7    OBJECT-TYPE
###########################################################################
### check the battery capacity
#battery_mib=".1.3.6.1.4.1.318.1.1.1.2.2.1.0"
### 
battery_mib="1.3.6.1.2.1.33.1.2.4"
str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $battery_mib 2>&1`
retcode=$?

if test $retcode -eq 0 ; then
	battery_status=`echo $str | cut -d ":" -f 4 | awk '{print $1}'`
	#echo "battery_status=[$battery_status]"

	if test $battery_status -le $error_battery ; then
		statusid=$status_error
		error_str="ERROR: The total battery capacity is ${battery_status}% <= ${error_battery}%!"
	elif test $battery_status -le $warning_battery ; then
		statusid=$status_warning
		warning_str="WARNING: The total battery capacity is ${battery_status}% <= ${warning_battery}%!"
	else
		statusid=$status_ok
		ok_str="OK: The total battery capacity is ${battery_status}%."
	 fi
else
	statusid=$status_error
	error_str="$error_str ERROR: Could not get any information about the battery capacity!"
fi

### check the battery status
battery_mib="1.3.6.1.2.1.33.1.2.1"
str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $battery_mib 2>&1`
retcode=$?

if test $retcode -eq 0 ; then
	battery_status=`echo $str | cut -d ":" -f 4 | awk '{print $1}'`
	#echo "battery_status=[$battery_status]"
	case $battery_status in
		1)
			statusid=$status_error
			error_str="$error_str ERROR: The battery status is unknown!"
			;;
		2)
			ok_str="$ok_str OK: The battery status is normal."
			;;
		3)
			if test $statusid -lt $status_warning ; then
				statusid=$status_warning
			fi
			warning_str="$warning_str WARNING: The battery status is low!"
			;;
		*)
			statusid=$status_error
			error_str="$error_str ERROR: Unknown battery status code=$battery_status!"
			;;
	esac
else
	statusid=$status_error
	error_str="$error_str ERROR: Could not get any information about the battery status!"
fi

### check the battery replacement status
#battery_mib="1.3.6.1.4.1.318.1.1.1.2.2.4.0"
#str=`$check_prog -v 2c $check_ups -c $snmp_comm $battery_mib 2>&1`
#retcode=$?
#
#if test $retcode -eq 0 ; then
#	battery_status=`echo $str | cut -d ":" -f 4 | awk '{print $1}'`
#	#echo "battery_status=[$battery_status]"
#	case $battery_status in
#		1)
#			ok_str="$ok_str OK: The battery does not need replacement."
#			;;
#		2)
#			ok_str="$ok_str OK: The battery status is normal."
#			;;
#		3)
#			statusid=$status_error
#			error_str="$error_str WARNING: The battery needs replacement!"
#			;;
#		*)
#			statusid=$status_error
#			error_str="$error_str ERROR: Unknown battery replacement status code=$battery_status!"
#			;;
#	esac
#else
#	statusid=$status_error
#	error_str="$error_str ERROR: Could not get any information about the battery replacement status!"
#fi

message_str="$error_str $warning_str $ok_str"  
#################################################################################
####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi

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

if test $number_of_temperature_sensors -gt 0 ; then
	while test $i -lt $number_of_temperature_sensors
	do
		tsensor_name=${tsensor_name[${i}]}
		tsensor_mib=${tsensor_mib[${i}]}
		tsensor_error=${tsensor_error[${i}]}
		tsensor_warning=${tsensor_warning[${i}]}
		str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $tsensor_mib 2>&1`
		retcode=$?
	
		if test $retcode -eq 0 ; then
			tsensor_status=`echo $str | cut -d ":" -f 4 | awk '{print $1}'`
			#echo "name=$tsensor_name tsensor_status=[$tsensor_status]"
	
			if test $tsensor_status -ge $tsensor_error ; then
				statusid=$status_error
				error_str="$error_str ERROR: The temperature for the $tsensor_name sensor is ${tsensor_status} Grad Celcius >= ${tsensor_error} Grad Celcius!"
			elif test $tsensor_status -ge $tsensor_warning ; then
				if test $statusid -lt $status_warning ; then
					statusid=$status_warning
				fi
				warning_str="$warning_str WARNING: The temperature for the $tsensor_name sensor is ${tsensor_status} Grad Celcius >= ${tsensor_warning} Grad Celcius!"
			else
				ok_str="$ok_str OK: The temperature for the $tsensor_name sensor is ${tsensor_status} Grad Celcius."
			 fi
		else
			statusid=$status_error
			error_str="$error_str ERROR: Could not get any information about the sensor=${i}!"
		fi
		i=i+1
	done
	message_str="$error_str $warning_str $ok_str"
	#################################################################################
	####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi
#################################################################################
### Check for UPS status
#################################################################################
### service id
serviceid=$serviceid_ups_status  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ups_status is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="UPS_Status"
##########################################################################

statusid=$status_ok  
ups_status_mib="1.3.6.1.2.1.33.1.4.1"
#upsOutputSource
#other	(1)
#none	(2)
#normal	(3)
#bypass	(4)
#battery	(5)
#booster	(6)
#reducer	(7)

str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $ups_status_mib 2>&1`
retcode=$?

if test $retcode -eq 0 ; then
	ups_status=`echo $str | cut -d ":" -f 4 | awk '{print $1}'`
	#echo "ups_status=[$ups_status]"
	case $ups_status in
		1)
			statusid=$status_error
			message_str="ERROR: The UPS status is other!"
			;;
		2)
			statusid=$status_error
			message_str="ERROR: The UPS does not produce output!"
			;;
		3)
			statusid=$status_ok
			message_str="OK: The UPS is on line."
			;;
		4)
			statusid=$status_error
			message_str="ERROR: The UPS is on software bypass!"
			;;
		5)
			statusid=$status_warning
			message_str="WARNING: The UPS is on battery!"
			;;
		6)
			statusid=$status_error
			message_str="ERROR: The UPS is on booster!"
			;;
		7)
			statusid=$status_error
			message_str="ERROR: The UPS is off!"
			;;
		*)
			statusid=$status_error
			message_str="ERROR: The UPS status is unknown!"
			;;
	esac
else
	statusid=$status_error
	error_str="$error_str ERROR: Could not get any information about the UPS status!"
fi
#################################################################################
####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi

#################################################################################
### Check for UPS output
#################################################################################
### service id
serviceid=$serviceid_ups_output
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ups_output is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="UPS_Output"
##########################################################################
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
### check the output load
ups_output_load_mib="1.3.6.1.2.1.33.1.4.4.1.5"
str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $ups_output_load_mib 2>&1`
retcode=$?

if test $retcode -eq 0 ; then
	output_load=`echo $str | cut -d ":" -f 4 | awk '{print $1}'`
	#echo "output_load=[$output_load]"

	if test $output_load -ge $error_output_load ; then
		statusid=$status_error
		error_str="ERROR: The output load is ${output_load}% >= ${error_output_load}%!"
	elif test $output_load -ge $warning_output_load ; then
		statusid=$status_warning
		warning_str="WARNING: The output load is ${output_load}% >= ${warning_output_load}%!"
	else
		statusid=$status_ok
		ok_str="OK: The output load is ${output_load}%."
	 fi
else
	statusid=$status_error
	error_str="$error_str ERROR: Could not get any information about the output load!"
fi

### check the output voltage
### rewrite this part to take into account the number of outputlines
### upsOutputNumLines :The number of output lines utilized in this device.
#			This variable indicates the number of rows in theoutput table.
#
ups_output_voltage_mib="1.3.6.1.2.1.33.1.4.4.1.2"
str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $ups_output_voltage_mib 2>&1`
retcode=$?

#if test $retcode -eq 0 ; then
#	output_voltage=`echo $str | cut -d ":" -f 4 | awk '{print $1}'`
#	#echo "output_voltage=[$output_voltage]"
#	if test $output_voltage -ge $error_output_voltage_upper ; then
#		statusid=$status_error
#		error_str="$error_str ERROR: The output voltage is ${output_voltage}V >= ${error_output_voltage_upper}V!"
#	elif test $output_voltage -le $error_output_voltage_lower ; then
#		statusid=$status_error
#		error_str="$error_str ERROR: The output voltage is ${output_voltage}V <= ${error_output_voltage_lower}V!"
#	elif test $output_voltage -ge $warning_output_voltage_upper ; then
#		if test $statusid -lt $status_warning ; then
#			statusid=$status_warning
#		fi
#		warning_str="$warning_str WARNING: The output voltage is ${output_voltage}V >= ${warning_output_voltage_upper}V!"
#	elif test $output_voltage -le $warning_output_voltage_lower ; then
#		if test $statusid -lt $status_warning ; then
#			statusid=$status_warning
#		fi
#		warning_str="$warning_str WARNING: The output voltage is ${output_voltage}V <= ${warning_output_voltage_lower}V!"
#	else
#		ok_str="$ok_str OK: The output voltage is ${output_voltage}V."
#	 fi
#
#else
#	statusid=$status_error
#	error_str="$error_str ERROR: Could not get any information about the output voltage!"
#fi

### check the output frequency
ups_output_frequency_mib="1.3.6.1.2.1.33.1.4.2"
str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $ups_output_frequency_mib 2>&1`
retcode=$?

if test $retcode -eq 0 ; then
	output_frequency=`echo $str | cut -d ":" -f 4 | awk '{print $1}'`
	output_frequency=`echo "$output_frequency / 10" |bc`
	#echo "output_frequency=[$output_frequency]"
	if test $output_frequency -ge $error_output_frequency_upper ; then
		statusid=$status_error
		error_str="$error_str ERROR: The output frequency is ${output_frequency}Hz >= ${error_output_frequency_upper}Hz!"
	elif test $output_frequency -le $error_output_frequency_lower ; then
		statusid=$status_error
		error_str="$error_str ERROR: The output frequency is ${output_frequency}Hz <= ${error_output_frequency_lower}Hz!"
	elif test $output_frequency -ge $warning_output_frequency_upper ; then
		if test $statusid -lt $status_warning ; then
			statusid=$status_warning
		fi
		warning_str="$warning_str WARNING: The output frequency is ${output_frequency}Hz >= ${warning_output_frequency_upper}Hz!"
	elif test $output_frequency -le $warning_output_frequency_lower ; then
		if test $statusid -lt $status_warning ; then
			statusid=$status_warning
		fi
		warning_str="$warning_str WARNING: The output frequency is ${output_frequency}Hz <= ${warning_output_frequency_lower}Hz!"
	else
		ok_str="$ok_str OK: The output frequency is ${output_frequency}Hz."
	 fi

else
	statusid=$status_error
	error_str="$error_str ERROR: Could not get any information about the output frequency!"
fi
message_str="$error_str $warning_str $ok_str"  
#################################################################################
####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi

#################################################################################
### Check for UPS time on battery
### The elapsed time since the UPS has switched to battery power. This value is reported in 100ths of a second.
#################################################################################
### service id
serviceid=$serviceid_ups_timeonbattery
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ups_timeonbattery is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="UPS_TimeOnBattery"
##########################################################################

### check the output load
ups_time_on_battery_mib="1.3.6.1.2.1.33.1.2.2"
str=`$check_prog -v $snmp_version $check_system -c $snmp_comm $ups_time_on_battery_mib 2>&1`
retcode=$?

if test $retcode -eq 0 ; then
	time_on_battery=`echo $str | cut -d ":" -f 4 | awk '{print $1}' | cut -d "(" -f 2 | cut -d  ")" -f 1`
	#echo "time_on_battery=[$time_on_battery]"

	if test $time_on_battery -ge $error_time_on_battery ; then
		statusid=$status_error
		message_str="ERROR: The time spent on battery is ${time_on_battery} >= ${error_time_on_battery}!"
	elif test $time_on_battery -ge $warning_time_on_battery ; then
		statusid=$status_warning
		message_str="WARNING: The time spent on battery is ${time_on_battery} >= ${warning_time_on_battery}!"
	else
		statusid=$status_ok
		message_str="OK: The time spent on battery is ${time_on_battery}."
	 fi
else
	statusid=$status_error
	message_str="ERROR: Could not get any information about the time on battery!"
fi
#################################################################################
####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
