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
min_argc=6
max_argc=8
if test $# -lt $min_argc || test $# -gt $max_argc ; then
	echo "Usage : sisiya_server_checks.conf check_system_name host_name number_of_packets timeout expire"
	echo "Usage : sisiya_server_checks.conf check_system_name host_name number_of_packets timeout expire output_file"
	echo "Example: $0 sisiya_server_checks.conf server1 www.example.com 3 3 10"
	echo "Example: $0 sisiya_server_checks.conf server1 www.example.com 3 3 10 output_file"
	echo "Without the output_file, the script will send the message directly to the SisIYA server."
	exit 1
fi

conf_file=`echo	$1	| tr -d "\""`
if test ! -f "$conf_file" ; then
	echo "$0  : Configuration file $conf_file does not exist! Exiting... "
	exit 1
fi
expire=`echo	$6	| tr -d "\""`
if test $# -eq 7 ; then
	output_file=`echo	$7 	|	tr -d "\""`	
	if test ! -f "$output_file" ; then
		echo "$0  : Output file $output_file does not exist! Exiting... "
		exit 1
	fi
fi

### source the config file
. $conf_file 
#################################################################################
check_system_name=`echo	$2	|	tr -d "\""`
host_name=`echo		$3	|	tr -d "\""`
ping_packets=`echo	$4	|	tr -d "\""`
ping_timeout=`echo	$5	|	tr -d "\""`

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
serviceid=$serviceid_ping 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ping is not defined! Exiting..."
	exit 1
fi
##########################################################################
check_prog=$sisiya_ping_check_prog
if test ! -f $check_prog ; then
	echo "$service_name check program does not exist! Exiting..."
	exit 1
fi
##########################################################################
statusid=$status_ok
str=`$check_prog -q -c $ping_packets -w $ping_timeout ${host_name} | grep "^${ping_packets} packets"`
retcode=$?
 
packet_loss=`echo "$str" 	| awk '{print $6}' | tr -d "%"`
response_time=`echo "$str" 	| awk '{print $10}'`
data_message_str="<packet_loss>$packet_loss</packet_loss><response_time>$response_time</response_time>"

message_str="OK: $str"
if test $retcode -eq 1 ; then
	statusid=$status_error
	message_str="ERROR: The system is unreachable! $str"
else
	tp=`echo "$str"	| awk '{print $1}'`
	rp=`echo "$str"	| awk '{print $4}'`
	if test "$tp" != "$rp" ; then
		statusid=$status_error
		message_str="ERROR: The system is unreachable! $str"
		if test $rp -ne 0 ; then
			statusid=$status_warning
			message_str="WARNING: The system has network problems! $str"
		fi
	fi
fi
#################################################################################
#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str data_mesage_str=$data_message_str"
if test $# -eq $min_argc ; then
	${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
