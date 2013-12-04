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
### Extracts and echoes days, hours and minutes (for telekutu's date and time format)
### The format of the argumnet is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form hh:mm, then it is hh hours mm minutes.
### 3) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
###   3:12pm  up 18:55,  1 user,  load average: 0.01, 0.03, 0.04
extract_datetime2()
{
	days=0
	hours=0
	minutes=0
	str=$1
	count=`echo $str | tr -s ":" "\n" | wc -l`
	if test $count -eq 1 ; then
		days=$str
	elif test $count -eq 2 ; then
		hours=`echo $str 	| cut -d ":" -f 1`
		minutes=`echo $str 	| cut -d ":" -f 2`
	else
		days=`echo $str 	| cut -d ":" -f 1`
		hours=`echo $str 	| cut -d ":" -f 2`
		minutes=`echo $str 	| cut -d ":" -f 3`
	fi

	if test $minutes -ge 60 ; then
		t=`(echo "$minutes / 60") | bc`
		minutes=`(echo "$minutes - $t * 60") | bc`
		hours=`(echo "$hours + $t") | bc`
	fi
	if test $hours -ge 24 ; then
		t=`(echo "$hours / 24") | bc`
		hours=`(echo "$hours - $t * 24") | bc`
		days=`(echo "$days + $t") | bc`
	fi
	#echo "$days $hours $minutes" 1>&2
	echo "$days $hours $minutes"
}
###########################################################################
min_argc=6
max_argc=9
if test $# -lt $min_argc || test $# -gt $max_argc ; then
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name virtual_server file port expire"
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name virtual_server file port expire output_file"
	echo "Example: $0 sisiya_server_checks.conf system1.example.org www.example.org /index.html 443 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.org www.example.org /index.html 443 10 output_file" 
	echo "expire must be specified in minutes."
	echo "Without the output_file, the script will send the message directly to the SisIYA server."
	exit 1
fi

conf_file=$1
if test ! -f "$conf_file" ; then
	echo "$0  : Configuration file $conf_file does not exist! Exiting... "
	exit 1
fi
case $# in
	7)
		expire=`echo 		$6	| tr -d "\""`
		output_file=`echo	$7	| tr -d "\""`
	;;
	9)
		user=`echo		$6	|	tr -d "\""`
		password=`echo		$7	|	tr -d "\""`
		expire=`echo		$8	|	tr -d "\""`
		output_file=`echo	$9	|	tr -d "\""`
	;;
esac
if test $# -gt 7 ; then
	if test ! -f "$output_file" ; then
		echo "$0  : Output file $output_file does not exist! Exiting... "
		exit 1
	fi
fi
### source the config file
. $conf_file 
#################################################################################
check_system_name=`echo	$2	|	tr -d "\""`
virtual_host=`echo	$3	|	tr -d "\""`
html_file=`echo		$4	|	tr -d "\""`
port=`echo		$5	|	tr -d "\""`

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
if test -z "$serviceid" ; then
	echo "$0 : serviceid_system is not defined! Exiting..."
	exit 1
fi
##########################################################################
script_name=`basename $0`
script_name_prefix=${script_name%.*}

service_name="System"
check_prog=$wget_prog
if test ! -x $check_prog ; then
	echo "$service_name check program does not exist or is not executable! Exiting..."
	exit 1
fi
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
system_conf_file="${sisiya_server_checks_dir}/${check_system}.conf"
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


##########################################################################
wget_output_file=`mktemp -q /tmp/tmp_${script_name}_output.XXXXXX`
index_file=`mktemp -q /tmp/tmp_${script_name}_index.XXXXXX`

statusid=$status_ok
params="--timeout=10 --server-response -o $wget_output_file -O $index_file"
if test $# -eq 9 ; then
	params="$params --user=$user --password=$password"
fi
str=`$check_prog $params http://${virtual_host}:${port}$html_file`
retcode=$?
#cat $wget_output_file

str=`grep "^.*[ ]Server:" $wget_output_file | cut -d ":" -f 2`
message_str="OK: $str"
if test $retcode -ne 0 ; then
	http_status_code=`grep "^  HTTP/" $wget_output_file | awk '{print $2}'`
	if test "$http_status_code" = "404" ; then
		statusid=$status_warning
		message_str="WARNING: $html_file could not be found! $str"
	elif test "$http_status_code" = "403" ; then
		statusid=$status_warning
		message_str="WARNING: It is forbidden to get ${virtual_host}$html_file! $str"
	else
		statusid=$status_error
		message_str="ERROR: The $service_name server is not running! $str HTTP code = $http_status_code"
	fi
else
	### get host name
	hostname_str=`grep "Host Name" $index_file | cut -d ":" -f 2 | cut -d ">" -f 3 | cut -d "<" -f 1`
#	echo "hostname_str=[$hostname_str]"

	### get product name 
	productname_str=`grep "Product Name" $index_file | cut -d ":" -f 2 | cut -d ">" -f 3 | cut -d "<" -f 1`
#	echo "product_name_str=[$productname_str]"
	
	### get software version 
	softwareversion_str=`grep "Software Version" $index_file | cut -d ":" -f 2 | cut -d ">" -f 3 | cut -d "<" -f 1`
#	echo "softwareversion_str=[$softwareversion_str]"
	
	### get serial number 
	sn_str=`grep "Serial Number" $index_file | cut -d ":" -f 3 | cut -d ">" -f 3 | cut -d "<" -f 1`
#	echo "sn_str=[$sn_str]"
	
	### get hardware version 
	hw_str=`grep "Hardware Version" $index_file | cut -d ":" -f 3 | cut -d ">" -f 3 | cut -d "<" -f 1`
#	echo "hw_str=[$hw_str]"
	
	### get user id 
	uid_str=`grep "User ID" $index_file | cut -d ":" -f 3 | cut -d ">" -f 3 | cut -d "<" -f 1`
#	echo "uid_str=[$uid_str]"

	### get elapsed time 
	str=`grep "Elapsed Time" $index_file | cut -d ">" -f 11 | cut -d "<" -f 1`
#str="9 days and 12:06:42"
#str="1 day and 12:06:42"
#echo "str=[$str]"
	str2=`echo $str | grep day`
	if test -z "$str2" ; then
		up_days=0
		time_str=$str
		up_hours=`echo $time_str 	| cut -d ":" -f 1`
		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
	else
		up_days=`echo $str		| awk '{print $1}'`
		time_str=`echo $str 		| awk '{print $4}'`
		up_hours=`echo $time_str 	| cut -d ":" -f 1`
		up_minutes=`echo $time_str	| cut -d ":" -f 2`
	fi
#echo "str2=[$str2] up_days=$up_days time_str=$time_str up_hours=$up_hours up_minutes=$up_minutes"

	message_str=""
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

	message_str="${message_str} Host Name: $hostname_str Product Name: $productname_str Software Version: $softwareversion_str Serial Number: $sn_str Hardware Version: $hw_str User ID: $uid_str" 
	#################################################################################
	###echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
	#################################################################################
	### Check for line status
	#################################################################################
	### service id
	serviceid=$serviceid_linestatus  
	
	### get line status
	### we get the first line's status, because the second one does not function
	linestatus_str=`grep "Registration State" $index_file | head -n 1 | cut -d ">" -f 11 | cut -d "<" -f 1 |tr "'" " "`
	#echo "linestatus_str=[$linestatus_str]"
	statusid=$status_ok
	message_str="OK: $linestatus_str"
	if test "$linestatus_str" != "Online" ; then
		statusid=$status_error
		message_str="ERROR: $linestatus_str"
	fi
	#################################################################################
	###echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
fi

rm -f $wget_output_file $index_file
