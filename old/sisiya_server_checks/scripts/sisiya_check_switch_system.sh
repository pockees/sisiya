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
### server service id
serviceid=$serviceid_system  
##########################################################################
service_name="System"
check_prog=$snmpwalk_prog
if test ! -x $check_prog ; then
	echo "$service_name check program $check_prog does not exist or is not executable! Exiting..."
	exit 1
fi
if test ! -x $snmpget_prog ; then
	echo "$service_name check program snmpget_prog=$snmpget_prog does not exist or is not executable! Exiting..."
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
### for ram used percentage
error_ram_used_percent=90
warning_ram_used_percent=85
### for process count
process_count_error=500
process_count_warning=350
### for cpu load
cpu_load_error=90
cpu_load_warning=85
### for temperature sensors
number_of_temperature_sensors=0
tsensors_name[0]="internal"
tsensors_mib[0]="enterprises.207.8.17.1.6.1.1.2.1"
tsensors_error[0]=35
tsensors_warning[0]=30
tsensors_name[1]="external"
tsensors_mib[1]="SNMPv2-SMI::enterprises.318.1.1.10.2.3.2.1.4.1"
tsensors_error[1]=35
tsensors_warning[1]=32
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
check_system_name=$check_system_name
system_conf_file="${sisiya_server_checks_conf_dir}/${check_system_name}.conf"
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
#str=`$check_prog -v $snmp_version $check_system -c $snmp_comm system.sysDescr.0 2>&1`
str=`$snmpget_prog -OvQ -v $snmp_version $check_system -c $snmp_comm system.sysDescr.0 2>&1`
retcode=$?

str2=`echo $str | grep "No Such Object available"`
str3=`echo $str | grep "No more variables"`
if test $retcode -eq 0 && test -z "$str2" && test -z "$str3" ; then
	#sys_name=`echo $str | cut -d ":" -f 4`
	sys_name=`echo $str | tr "\n" " "`
	#sys_location=`$snmpget_prog 	-v $snmp_version $check_system -c $snmp_comm system.sysLocation.0	| cut -d ":" -f 4 	2>&1`
	#str=`$snmpget_prog 		-v $snmp_version $check_system -c $snmp_comm system.sysUpTime.0 				2>&1`
	sys_location=`$snmpget_prog 	-OvQ -v $snmp_version $check_system -c $snmp_comm system.sysLocation.0	2>&1`
	str=`$snmpget_prog 		-OvQ -v $snmp_version $check_system -c $snmp_comm system.sysUpTime.0 				2>&1`
#echo "str=[$str]"
#	str2=`echo $str | grep day`
#	if test -z "$str2" ; then
#		up_days=0
#		time_str=`echo $str 		| cut -d ")" -f 2	| cut -d " " -f 2`
#		up_hours=`echo $time_str 	| cut -d ":" -f 1`
#		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
#	else
#	#	str2=`echo $str | cut -d ":" -f 4|cut -d ")" -f 2|cut -d "," -f 1|cut -d " " -f 2`
#		up_days=`echo $str 		| cut -d "," -f 1 	| cut -d ")" -f 2	| cut -d " " -f 2`
#		time_str=`echo $str 		| cut -d "," -f 2	| cut -d " " -f 2`
#		up_hours=`echo $time_str 	| cut -d ":" -f 1`
#		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
#	fi

	up_days=`echo $str	| cut -d ":" -f 1`
	up_hours=`echo $str 	| cut -d ":" -f 2`
	up_minutes=`echo $str 	| cut -d ":" -f 3`

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
	message_str="${message_str} Description:$sys_name Location:$sys_location"
	#################################################################################
	####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
#else
#	statusid=$status_error
#	message_str="ERROR: Could not get information about the $sisiya_system! $str"
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
	tsensors_error=${tsensors_error[${i}]}
	tsensors_warning=${tsensors_warning[${i}]}
	#echo "tsensors_name=$tsensors_name tsensors_mib=$tsensors_mib tsensors_error=$tsensors_error tsensors_warning=$tsensors_warning snmp_comm=$snmp_comm check_system=$check_system"
	#str=`$check_prog $check_system -v $snmp_version $check_system -c $snmp_comm $tsensors_mib 2>&1`
	str=`$snmpget_prog -OvQ -v $snmp_version -c $snmp_comm $check_system $tsensors_mib 2>&1`
	retcode=$?

	if test $retcode -eq 0 ; then
		#tsensors_status=`echo $str | cut -d ":" -f 4 | cut -d "\"" -f 2`
		tsensors_status=`echo $str | tr -d "\""`
		#echo "name=$tsensors_name tsensors_status=[$tsensors_status]"

		if test $tsensors_status -ge $tsensors_error ; then
			statusid=$status_error
			error_str="$error_str ERROR: The temperature for the $tsensors_name sensor is ${tsensors_status} (>= ${tsensors_error}) Grad Celcius!"
		elif test $tsensors_status -ge $tsensors_warning ; then
			if test $statusid -lt $status_warning ; then
				statusid=$status_warning
			fi
			warning_str="$warning_str WARNING: The temperature for the $tsensors_name sensor is ${tsensors_status} (>= ${tsensors_warning}) Grad Celcius!"
		else
			ok_str="$ok_str OK: The temperature for the $tsensors_name sensor is ${tsensors_status} Grad Celcius."
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
	####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq 4 ; then
		#$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "$message_str"
		${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		#echo "${SP}${serviceid}${SP}${statusid}${SP}${check_system_name}${SP}`echo_sisiya_date`${SP}${expire}${SP}${message_str}" >> $output_file
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

	#str=`$check_prog -v $version -c $snmp_comm $check_system $fan_mib 2>&1`
	str=`$snmpget_prog -OvQ -v $snmp_version -c $snmp_comm $check_system $fan_mib 2>&1`
	retcode=$?

	if test $retcode -eq 0 ; then
		#fan_status=`echo $str | cut -d ":" -f 4 | cut -d "\"" -f 2 | cut -d " " -f 1`
		fan_status=`echo $str | tr -d "\"" | cut -d " " -f 1`
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
	####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		#$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "$message_str"
		${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		#echo "${SP}${serviceid}${SP}${statusid}${SP}${check_system_name}${SP}`echo_sisiya_date`${SP}${expire}${SP}${message_str}" >> $output_file
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi

##########################################################################
service_name="CPU Load"
##########################################################################
### service id
serviceid=$serviceid_load  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_load is not defined! Exiting..."
	exit 1
fi
#
#
#CPU
#
#1.3.6.1.4.1.9.9.109.1.1.1.1 : cpmCPUTotalEntry
#1 : index
#2 : phys index
#3 : total 5s
#4 : total 1m
#5 : total 5m
#6 : total 5s (new)
#7 : total 1m (new)
#8 : total 5m (new)
#
#
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
#cpmCPUTotal5minRev, percent, 0 - 100, 
#cpu_load_oid="1.3.6.1.4.1.9.9.109.1.1.1.1.8"
cpu_load_oid="SNMPv2-SMI::enterprises.9.9.109.1.1.1.1.8.1"
#str=`$check_prog -v 2c $check_system -c $snmp_comm "$cpu_load_oid" 2>&1`
str=`$snmpget_prog -OvQ -v $snmp_version $check_system -c $snmp_comm "$cpu_load_oid" 2>&1`
retcode=$?
str2=`echo $str | grep "No Such Object available"`
str3=`echo $str | grep "No more variables"`
if test $retcode -eq 0 && test -z "$str2" && test -z "$str3" ; then
	#cpu_load_str=`echo $str | sed -e "s/: /:/g" | cut -d ":" -f 4`
	cpu_load_str=$str
	if test $cpu_load_str -ge $cpu_load_error ; then
		statusid=$status_error
		message_str="ERROR: CPU load is ${cpu_load_str}% (>= ${cpu_load_error}%)!"
	elif test $cpu_load_str -ge $cpu_load_warning ; then
		statusid=$status_warning
		message_str="WARNING: CPU load is ${cpu_load_str}% (>= ${cpu_load_warning}%)!"
	else
		statusid=$status_ok
		message_str="OK: CPU load is ${cpu_load_str}%."
	fi

	if test $# -eq $min_argc ; then
		#$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "$message_str"
		$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		#echo "${SP}${serviceid}${SP}${statusid}${SP}${check_system_name}${SP}`echo_sisiya_date`${SP}${expire}${SP}${message_str}" >> $output_file
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi
##########################################################################
service_name="Process count"
##########################################################################
### service id
serviceid=$serviceid_process_count 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_process_count is not defined! Exiting..."
	exit 1
fi
#
#
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
process_count_oid="1.3.6.1.4.1.9.9.109.1.2.1.1.1.1"
str=`$snmpwalk_prog -v $snmp_version $check_system -c $snmp_comm "$process_count_oid" 2>&1`
retcode=$?
#echo "retcode=$retcode check_system=$check_system"
str2=`echo $str | grep "No Such Object available"`
str3=`echo $str | grep "No more variables"`
if test $retcode -eq 0 && test -z "$str2" && test -z "$str3" ; then
	n=`$snmpwalk_prog -v $snmp_version $check_system -c $snmp_comm "$process_count_oid" | wc -l 2>&1`
	### if n == 1 =>  No Such Object available
	if test $retcode -eq 0 && test $n -ne 1 ; then
		if test $n -ge $process_count_error ; then
			statusid=$status_error
			message_str="ERROR: There are $n (>= ${process_count_error}) running process!"
		elif test $n -ge $process_count_warning ; then
			statusid=$status_warning
			message_str="WARNING: There are $n (>= ${process_count_warning}) running process!"
		else
			statusid=$status_ok
			message_str="OK: There are $n running process."
		fi
	
		if test $# -eq $min_argc ; then
			#$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "$message_str"
			${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
		else
			#echo "${SP}${serviceid}${SP}${statusid}${SP}${check_system_name}${SP}`echo_sisiya_date`${SP}${expire}${SP}${message_str}" >> $output_file
			echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
		fi
	fi
fi
##########################################################################

##########################################################################
### service id
serviceid=$serviceid_ram  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ram is not defined! Exiting..."
	exit 1
fi

# CISCO
#Memory :
#
#1.3.6.1.4.1.9.9.48.1 : cisco memory pool
#1.3.6.1.4.1.9.9.48.1.1.1 : pool table.poolentry
#
#.1 : type
#.2 : name
#.3 : alternate
#.4 : valid
#.5 : used
#.6 : free
#.7 : max free
#
#/usr/bin/snmpwalk -v 2c 10.11.254.100 -c public 1.3.6.1.4.1.9.9.48.1
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.2.1 = STRING: "Processor"
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.2.2 = STRING: "I/O"
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.3.1 = INTEGER: 2
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.3.2 = INTEGER: 0
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.4.1 = INTEGER: 1
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.4.2 = INTEGER: 1
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.5.1 = Gauge32: 2781420
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.5.2 = Gauge32: 1342308
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.6.1 = Gauge32: 2258292
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.6.2 = Gauge32: 1530332
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.7.1 = Gauge32: 1999456
#SNMPv2-SMI::enterprises.9.9.48.1.1.1.7.2 = Gauge32: 1501276
#
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
ram_oid="1.3.6.1.4.1.9.9.48.1.1.1"

str=`$snmpwalk_prog -OvQ -v $snmp_version $check_system -c $snmp_comm "$ram_oid" 2>&1`
retcode=$?
#echo "checking for ram: retcode=$retcode check_system=$check_system str=[$str]"
str2=`echo $str | grep "No Such Object available"`
str3=`echo $str | grep "No more variables"`
if test $retcode -eq 0 && test -z "$str2" && test -z "$str3" ; then
	n=`$snmpwalk_prog -v $snmp_version $check_system -c $snmp_comm "${ram_oid}.2" | wc -l`
	i=0
	#echo "n=$n"
	while test $i -lt $n
	do
		i=i+1
		#name_str=`$snmpget_prog -v $snmp_version $check_system -c $snmp_comm "${ram_oid}.2.$i" 	| sed -e "s/: /:/g" | cut -d ":" -f 4 |tr -d "\""`
		name_str=`$snmpget_prog -OvQ -v $snmp_version $check_system -c $snmp_comm "${ram_oid}.2.$i" 	| tr -d "\""`
		#ram_is_valid=`$check_prog -v 2c $check_system -c $snmp_comm "${ram_oid}.4.$i" 	| sed -e "s/: /:/g" | cut -d ":" -f 4`
		ram_is_valid=`$snmpget_prog -OvQ -v $snmp_version $check_system -c $snmp_comm "${ram_oid}.4.$i"`
		#ram_used=`$check_prog -v 2c $check_system -c $snmp_comm "${ram_oid}.5.$i" 	| sed -e "s/: /:/g" | cut -d ":" -f 4`
		ram_used=`$check_prog -OvQ -v $snmp_version $check_system -c $snmp_comm "${ram_oid}.5.$i"`
		#ram_free=`$check_prog -v 2c $check_system -c $snmp_comm "${ram_oid}.6.$i" 	| sed -e "s/: /:/g" | cut -d ":" -f 4`
		ram_free=`$check_prog -OvQ -v $snmp_version $check_system -c $snmp_comm "${ram_oid}.6.$i"`
		#ram_max_free=`$check_prog -v 2c $check_system -c $snmp_comm "${ram_oid}.7.$i" 	| sed -e "s/: /:/g" | cut -d ":" -f 4`
		ram_max_free=`$check_prog -OvQ -v $snmp_version $check_system -c $snmp_comm "${ram_oid}.7.$i"`
		ram_total=`echo "$ram_used + $ram_free" | bc`
		used_percent=`echo "100 * $ram_used / $ram_total" | bc`
		ram_free_str=`print_formated_size $ram_free 1048576 MB`
		ram_total_str=`print_formated_size $ram_total 1048576 MB`
		#echo "used_percent=[$used_percent] i=$i"
		if test $used_percent -ge $error_ram_used_percent ; then
			statusid=$status_error
			error_str="$error_str ERROR: RAM usage for $name_str is ${used_percent}% (>= ${error_ram_used_percent}%)!"
		elif test $used_percent -ge $warning_ram_used_percent ; then
			if test $statusid -lt $status_warning ; then
				statusid=$status_warning
			fi
			warning_str="$warning_str WARNING: RAM usage for $name_str is ${used_percent}% (>= ${warning_ram_used_percent}%)!"
		else
			ok_str="$ok_str OK: RAM usage for $name_str is ${used_percent}%. (total=${ram_total_str}, free=${ram_free_str})"
		fi

	message_str="$error_str $warning_str $ok_str"
	done
	#echo "message_str=[$message_str]"
	if test $# -eq $min_argc ; then
		${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi
