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
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name check_system protocol port username password expire"
	echo "Usage  : $0 sisiya_server_checks.conf check_system check_system_name protocol port username password expire output_file"
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 https 443 root test123 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 https 443 root test123 10 output_file" 
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
protocol=`echo 		$4	| tr -d "\""`
port=`echo 		$5	| tr -d "\""`
username=`echo 		$6	| tr -d "\""`
password=`echo 		$7	| tr -d "\""`

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

for f in "$vicfg_hostops_prog"
do
	if test ! -x "$f" ; then
	       echo "File $f does not exist"	
	       exit 1
       fi
done

### source the functions file
. $sisiya_functions
##########################################################################
### server service id
serviceid=$serviceid_system  
##########################################################################
service_name="System"

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
### end of the default values

### One can override the default values in the $sisiya_server_checks_dir/$system_conf_file file
### Check if there is a configuration file for this system. 
#check_system_name=$check_system_name
#system_conf_file="${sisiya_server_checks_conf_dir}/${check_system_name}.conf"
#if test -f $system_conf_file ; then
#	. $system_conf_file
#fi

tmp_file=`mktemp /tmp/tmp_sisiya_check_vmware.XXXXXX`
touch $tmp_file

#############################################################################################
#vicfg-hostops --server 10.11.0.227 --username root --password test123098 -o info
#=>
#Host Name            : dell.example.com
#Manufacturer         : Dell Inc.
#Model                : PowerEdge 2950
#Processor Type       : Intel(R) Xeon(R) CPU           L5420  @ 2.50GHz
#CPU Cores            : 8 CPUs x 2493 GHz
#Memory Capacity      : 16378.6328125 MB
#VMotion Enabled      : no
#In Maintenance Mode  : no
#Last Boot Time       : 2010-11-24T19:35:42.692504Z
#############################################################################################
 


statusid=$status_ok
$vicfg_hostops_prog --server $check_system --protocol $protocol --portnumber $port --username "$username" --password "$password" -o info > $tmp_file
retcode=$?
echo "-0-000-"
cat $tmp_file
echo "-0-000-"
if test $retcode -eq 0 ; then
	manufacturer_str=`cat $tmp_file 	| grep "^Manufacturer " 	| sed -e "s/ : /:/" | cut -d ":" -f 2`
	model_str=`cat $tmp_file 		| grep "^Model " 		| sed -e "s/ : /:/" | cut -d ":" -f 2`
	cpu_type_str=`cat $tmp_file 		| grep "^Processor Type " 	| sed -e "s/ : /:/" | cut -d ":" -f 2`
	cpu_cores_str=`cat $tmp_file 		| grep "^CPU Cores "	 	| sed -e "s/ : /:/" | cut -d ":" -f 2`
	in_maintenance_str=`cat $tmp_file	| grep "^In Maintenance Mode " 	| sed -e "s/ : /:/" | cut -d ":" -f 2`
	vmotion_str=`cat $tmp_file		| grep "^VMotion Enabled " 	| sed -e "s/ : /:/" | cut -d ":" -f 2`
	ram_capacity_str=`cat $tmp_file 	| grep "^Memory Capacity " 	| sed -e "s/ : /:/" | cut -d ":" -f 2`
	last_boot_time_str=`cat $tmp_file 	| grep "^Last Boot Time " 	| sed -e "s/ : /:/" | cut -d ":" -f 2,3,4`
	
	message_str="OK: manufacturer=[$manufacturer_str] model=[$model_str] cpu type=[$cpu_type_str] cpu cores=[$cpu_cores_str] RAM capacity=[$ram_capacity_str] VMotion enabled=]$vmotion_str] in maintenance mode=[$in_maintenance_str] last boot time=[$last_boot_time_str]"
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
rm -f $tmp_file
