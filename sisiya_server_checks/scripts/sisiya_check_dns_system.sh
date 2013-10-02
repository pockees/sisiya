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
min_argc=9
max_argc=10
if test $# -lt $min_argc || test $# -gt $max_argc ; then
	echo "Usage : $0 sisiya_server_checks.conf check_system_name system_name name_to_query ip_to_query port timeout tries expire"
	echo "Usage : $0 sisiya_server_checks.conf check_system_name system_name name_to_query ip_to_query port timeout tries expire output_file"
	echo "Example: $0 sisiya_server_checks.conf system1.example.org www.example.org 10.10.10.1 53 2 1 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.org www.example.org 10.10.10.1 53 2 1 10 output_file" 
	echo "expire must be specified in minutes."
	echo "Without the output_file, the script will send the message directly to the SisIYA server."
	echo "timeout is the number of seconds to wait until the request times out"
	echo "tries is the number of tries per request"
	exit 1
fi

conf_file=$1
if test ! -f "$conf_file" ; then
	echo "$0  : Configuration file $conf_file does not exist! Exiting... "
	exit 1
fi
expire=$9
if test $# -eq $max_argc ; then
	output_file=${10}
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
name_to_query=`echo 	$4	| tr -d "\""`
ip_to_query=`echo 	$5	| tr -d "\""`
port=`echo 		$6	| tr -d "\""`
timeout=`echo 		$7	| tr -d "\""`
tries=`echo 		$8	| tr -d "\""`

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
serviceid=$serviceid_dns 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_dns is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="dns"
check_prog=$dig_prog
if test ! -x $check_prog ; then
	echo "$service_name check program does not exist or is not executable! Exiting..."
	exit 1
fi
##########################################################################
statusid=$status_ok
$check_prog -p $port +timeout=$timeout +tries=$tries $name_to_query @$check_system > /dev/null 2>&1
retcode=$?

message_str="OK: Checked $name_to_query on ${check_system}."
if test $retcode -ne 0 ; then
	statusid=$status_error
	message_str="ERROR: The $service_name server is not running! retcode=$retcode"
fi

$check_prog -p $port +timeout=$timeout +tries=$tries -x $ip_to_query @$check_system > /dev/null 2>&1
retcode=$?

if test $retcode -ne 0 ; then
	if test $statusid -eq $status_error ; then
		message_str="$message_str Could not query $ip_to_query on ${check_system}!"
	else
		statusid=$status_error
		message_str="ERROR: Could not query $ip_to_query on ${check_system}! $message_str"
	fi
else
	message_str="$message_str OK: Checked $ip_to_query on ${check_system}."
fi
data_message_str=""
#################################################################################################################################################################
#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire" 
#echo "str=$message_str data_message_str=$date_message_str"
if test $# -eq $min_argc ; then
	$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###############################################################################################################################################################
