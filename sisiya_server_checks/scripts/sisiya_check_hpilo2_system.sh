#!/bin/bash
#
#
# This script is used to check HP ProLiant servers which have Integrated Lights-Out 2 module.
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
	echo "Usage : $0 sisiya_server_checks.conf check_system_name check_system_name username expire"
	echo "Usage : $0 sisiya_server_checks.conf check_system_name check_system_name username expire output_file"
	echo "Example: $0 sisiya_server_checks.conf system1.example.org system1.example.org admin 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.org system1.example.org admin 10 output_file" 
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
expire=$5
if test $# -eq $max_argc ; then
	output_file=$6
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
user_name=`echo 	$4	| tr -d "\""`

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
### for temperature sensors
#number_of_temperature_sensors=1
number_of_temperature_sensors=5
tsensors_name[0]="I/O Board Zone"
tsensors_id[0]="/system1/sensor3"
tsensors_error[0]=50
tsensors_warning[0]=45
tsensors_name[1]="Ambient Zone"
tsensors_id[1]="/system1/sensor4"
tsensors_error[1]=25
tsensors_warning[1]=20
tsensors_name[2]="CPU0"
tsensors_id[2]="/system1/sensor5"
tsensors_error[2]=45
tsensors_warning[2]=40
tsensors_name[3]="CPU1"
tsensors_id[3]="/system1/sensor5"
tsensors_error[3]=45
tsensors_warning[3]=40
tsensors_name[4]="Power Supply Zone"
tsensors_id[4]="/system1/sensor6"
tsensors_error[4]=45
tsensors_warning[4]=40
### for system fans
#number_of_fans=1
number_of_fans=6
fans_name[0]="I/O Board Zone 1"
fans_id[0]="system1/fan1"
fans_error_upper[0]=50
fans_error_lower[0]=35
fans_warning_upper[0]=48
fans_warning_lower[0]=38
fans_name[1]="I/O Board Zone 2"
fans_id[1]="system1/fan2"
fans_error_upper[1]=50
fans_error_lower[1]=35
fans_warning_upper[1]=48
fans_warning_lower[1]=38
fans_name[2]="CPU Zone 1"
fans_id[2]="system1/fan3"
fans_error_upper[2]=46
fans_error_lower[2]=35
fans_warning_upper[2]=44
fans_warning_lower[2]=38
fans_name[3]="CPU Zone 2"
fans_id[3]="system1/fan4"
fans_error_upper[3]=41
fans_error_lower[3]=31
fans_warning_upper[3]=39
fans_warning_lower[3]=33
fans_name[4]="CPU Zone 3"
fans_id[4]="system1/fan5"
fans_error_upper[4]=41
fans_error_lower[4]=31
fans_warning_upper[4]=39
fans_warning_lower[4]=33
fans_name[5]="CPU Zone 4"
fans_id[5]="system1/fan6"
fans_error_upper[5]=41
fans_error_lower[5]=31
fans_warning_upper[5]=39
fans_warning_lower[5]=33
### for system powersupplies
number_of_powersupplies=2
### end of the default values

### One can override the default values in the $sisiya_server_checks_dir/$system_conf_file file
### Check if there is a configuration file for this system. 
system_conf_file="${sisiya_server_checks_dir}/${check_system_name}.conf"
if test -f $system_conf_file ; then
	source $system_conf_file
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

tmp_file=`mktemp /tmp/tmp_${script_name}.XXXXXX`
#tmp_file=/tmp/tmp_.E26261
##########################################################################
service_name="Temperature"
##########################################################################
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
declare -i i=0

while test $i -lt $number_of_temperature_sensors
do
	tsensors_name=${tsensors_name[${i}]}
	tsensor_id=${tsensors_id[${i}]}
	tsensors_error=${tsensors_error[${i}]}
	tsensors_warning=${tsensors_warning[${i}]}
	#echo "tsensors_name=$tsensors_name tsensor_id=$tsensor_id tsensors_error=$tsensors_error tsensors_warning=$tsensors_warning check_system=$check_system check_system_name=$check_system_name"
	ssh ${user_name}@${check_system} "show $tsensor_id" | tr -d "\r" > $tmp_file &
	wait $!
	retcode=$?
	status_code=`grep "^status=" $tmp_file | cut -d "=" -f 2`

	if test $retcode -eq 0 ; then
		if test $status_code -eq 0 ; then
			tsensor_value=`grep "CurrentReading=" $tmp_file | cut -d "=" -f 2`
			if test $tsensor_value -ge $tsensors_error ; then
				statusid=$status_error
				error_str="$error_str ERROR: The temperature for the $tsensors_name sensor is ${tsensor_value} (>= ${tsensors_error}) Grad Celcius!"
			elif test $tsensor_value -ge $tsensors_warning ; then
				if test $statusid -lt $status_warning ; then
					statusid=$status_warning
				fi
				warning_str="$warning_str WARNING: The temperature for the $tsensors_name sensor is ${tsensor_value} (>= ${tsensors_warning}) Grad Celcius!"
			else
				ok_str="$ok_str OK: The temperature for the $tsensors_name sensor is ${tsensor_value} Grad Celcius."
			 fi
		else
			statusid=$status_error
			error_str="$error_str ERROR: Error executing show $tsensor_id command for sensor=${i}! status_code=$status_code"
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
		$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
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
	fan_id=${fans_id[${i}]}
	fan_error_upper=${fans_error_upper[${i}]}
	fan_error_lower=${fans_error_lower[${i}]}
	fan_warning_upper=${fans_warning_upper[${i}]}
	fan_warning_lower=${fans_warning_lower[${i}]}

	#echo "fan_name=$fan_name fan_id=$fan_id"
	#echo "fan_error_upper=$fan_error_upper fan_error_lower=$fan_error_lower fan_warning_upper=$fan_warning_upper fan_warning_lower=$fan_warning_lower"

	ssh ${user_name}@${check_system} "show $fan_id" | tr -d "\r" > $tmp_file &
	wait $!

	retcode=$?

	status_code=`grep "^status=" $tmp_file | cut -d "=" -f 2`

	if test $retcode -eq 0 ; then
		if test $status_code -eq 0 ; then
			fan_value=`grep "DesiredSpeed=" $tmp_file | cut -d "=" -f 2`

			if test $fan_value -ge $fan_error_upper ; then
				statusid=$status_error
				error_str="$error_str ERROR: The speed of for the $fan_name fan is ${fan_value} (>= ${fan_error_upper}) %!"
			elif test $fan_value -le $fan_error_lower ; then
				statusid=$status_error
				error_str="$error_str ERROR: The speed of for the $fan_name fan is ${fan_value} (<= ${fan_error_lower}) %!"
			elif test $fan_value -ge $fan_warning_upper ; then
				if test $statusid -lt $status_warning ; then
					statusid=$status_warning
				fi
				warning_str="$warning_str WARNING: The speed of the $fan_name fan is ${fan_value} (>= ${fan_warning_upper}) %"
			elif test $fan_value -le $fan_warning_lower ; then
				if test $statusid -lt $status_warning ; then
					statusid=$status_warning
				fi
				warning_str="$warning_str WARNING: The speed of the $fan_name fan is ${fan_value} (<= ${fan_warning_lower}) %"
	
			else
				ok_str="$ok_str OK: The speed of the $fan_name fan is ${fan_value} %."
			 fi
		else
			statusid=$status_error
			error_str="$error_str ERROR: Error executing show $fan_id command for sensor=${i}! status_code=$status_code"
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
		$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi

#################################################################################
### Check for powersupplies
#################################################################################
### service id
serviceid=$serviceid_powersupply
if test -z "$serviceid" ; then
	echo "$0 : serviceid_powersupply is not defined! Exiting..."
	exit 1
fi

##########################################################################
service_name="Powersupply"
##########################################################################
statusid=$status_ok  
error_str=""
warning_str=""
ok_str=""
declare -i i=0 j

while test $i -lt $number_of_powersupplies
do
	j=i+1
	cmd_str="show system1/powersupply${j}"
	#ssh ${user_name}@${check_system} "show system1/powersupply${i}" | tr -d "\r" > $tmp_file &
	ssh ${user_name}@${check_system} "${cmd_str}" | tr -d "\r" > $tmp_file &
	wait $!

	retcode=$?

	status_code=`grep "^status=" $tmp_file | cut -d "=" -f 2`

	if test $retcode -eq 0 ; then
		if test "$status_code" = "0" ; then
			powersupply_name=`grep "ElementName=" $tmp_file 	| cut -d "=" -f 2`
			health_state=`grep "HealthState=" $tmp_file 		| cut -d "=" -f 2`
			operational_status=`grep "OperationalStatus=" $tmp_file | cut -d "=" -f 2`
			if test "$operational_status" != "Ok" ; then
				statusid=$status_error
				error_str="$error_str ERROR: The operational status of $powersupply_name is not Ok (${operational_status})!"
			else
				ok_str="$ok_str OK: The operational status of $powersupply_name is Ok."
			fi
			if test "$health_state" != "Ok" ; then
				statusid=$status_error
				error_str="$error_str ERROR: The health state of $powersupply_name is not Ok (${health_state})!"
			else
				ok_str="$ok_str OK: The health state of $powersupply_name is Ok."
			fi
		else
			statusid=$status_error
			error_str="$error_str ERROR: Error executing $cmd_str command for ${powersupply_name}! status_code=$status_code"
		fi
	else
		statusid=$status_error
		error_str="$error_str ERROR: Could not get any information about the powersupply=${i}!"
	fi
	i=i+1
done

if test $number_of_powersupplies -gt 0 ; then
	message_str="$error_str $warning_str $ok_str"
	#################################################################################
	#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi

### clean up
rm -f $tmp_file
