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

#######################################################################################
#######################################################################################
### default values
# the thermal zone ACPI directory in the proc filesystem 
proc_acpi_dir="/proc/acpi/thermal_zone"
acpi_prog="/usr/bin/acpi"
#######################################################################################
### for temperature sensors
tsensors_error[0]=50
tsensors_warning[0]=45
tsensors_error[1]=25
tsensors_warning[1]=20
tsensors_error[2]=45
tsensors_warning[2]=40
tsensors_error[3]=45
tsensors_warning[3]=40
tsensors_error[4]=50
tsensors_warning[4]=45
tsensors_error[5]=45
tsensors_warning[5]=40
tsensors_error[6]=45
tsensors_warning[6]=40
### end of the default values
##########################################################################
# Since kernel 2.6.20.7, ACPI modules are all modularized to avoid ACPI issues that were reported on some machines.
# https://wiki.archlinux.org/index.php/ACPI_modules
#####
# acpi --thermal --details
# Thermal 0: ok, 25.0 degrees C
# Thermal 0: trip point 0 switches to mode critical at temperature 107.0 degrees C
#####################################################################################

use_acpi()
{
	$acpi_prog --thermal | while read line
	do
		thermal_name=`echo $line		 	| cut -d ":" -f 1 `
		state_info=`echo $line 				| sed -e "s/${thermal_name}://" `
		temperature_str=`echo $line 			| sed -e "s/${thermal_name}://" | cut -d "," -f 2 | awk '{print $1}'`
		thermal_info=`$acpi_prog --thermal --details	| grep "${thermal_name}:"	| tail -n 1`
		echo "thermal_info=[$thermal_info]"	 	
		echo "state_info=[$state_info]"	 	
		echo "temperature_str=[$temperature_str]"
		state_str=`echo $line	| cut -d ":" -f 2		| cut -d "," -f 1 | awk '{print $1}'`
		#echo "state_str=[$state_str]"
		if test "$state_str" != "ok" ; then
			echo "OK: The temperature of the sensor $thermal_name is $temperature_str degree celcius. The sensor state is : $state_info" >> $tmp_ok_file
		else
			echo "OK: The temperature of the sensor $thermal_name is $temperature_str degree celcius. The sensor state is ok." 	>> $tmp_ok_file
		fi
		echo "INFO: $thermal_name battery details: ${thermal_info}." 	>> $tmp_info_file
		
	done
}

use_proc()
{
	declare -i i=0 j
	cd $proc_acpi_dir 
	for d in *
	do
		if test "$d" = "*" ; then
			continue
		fi
		sensor_name="$d"
		state_str=`cat ${d}/state | grep "active\|ok" | cut -d ":" -f 2`
		if test -n "$state_str" ; then
			current_temperature=`cat ${d}/temperature | cut -d ":" -f 2 | awk '{print $1}'`
			echo "OK: The temperature of the sensor $sensor_name is ${current_temperature} degree celcius. The sensor state is ${state_str}." >> $tmp_ok_file
		fi
	done
}

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi

#
tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_info_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

if test ! -d "$proc_acpi_dir" ; then
	if test ! -f $acpi_prog ; then
		echo "INFO: Both program $acpi_prog and thermalzone ACPI proc directory $battery_dir does not exist! " >> $tmp_info_file
	else	
		use_acpi
	fi
else
	use_proc
fi


statusid=$status_info
message_str=""
if test -s $tmp_error_file ; then
	statusid=$status_error
	message_str=`cat $tmp_error_file | tr "\n" " "` 
fi
if test -s $tmp_warning_file ; then
	message_str="$message_str`cat $tmp_warning_file | tr "\n" " "`" 
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi
if test -s $tmp_ok_file ; then
	if test $statusid -lt $status_ok ; then
		$statusid=$status_ok
	fi
	message_str="$message_str`cat $tmp_ok_file | tr "\n" " "`"
fi
if test -s $tmp_info_file ; then
	message_str="$message_str`cat $tmp_info_file | tr "\n" " "`"
fi

### clean up
for f in $tmp_file $tmp_info_file $tmp_ok_file $tmp_warning_file $tmp_error_file
do
	rm -f $f
done
if test -z "$message_str" ; then
	exit 
fi
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
