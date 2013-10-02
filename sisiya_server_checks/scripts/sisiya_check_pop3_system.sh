#!/bin/bash
#
# This script is used to check POP3 connections.
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
	echo "Usage : sisiya_server_checks.conf check_system_name check_system port expire"
	echo "Usage : sisiya_server_checks.conf check_system_name check_system port expire output_file"
	echo "Example: $0 sisiya_server_checks.conf pop3.example.com pop3.example.com 110 10" 
	echo "Example: $0 sisiya_server_checks.conf pop3.example.com pop3.example.com 110 10 output_file" 
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
port=`echo 		$4	| tr -d "\""`

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
serviceid=$serviceid_pop3
if test -z "$serviceid" ; then
	echo "$0 : serviceid_pop3 is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="pop3"
check_prog=$sisiya_pop3_check_prog
if test ! -x $check_prog ; then
	echo "$service_name check program does not exist or is not executable! Exiting..."
	exit 1
fi
##########################################################################
statusid=$status_ok
str=`$check_prog $check_system $port 2>&1`
retcode=$?
 
message_str="OK: $str"
if test $retcode -eq 1 ; then
	statusid=$status_error
	message_str="ERROR: The $service_name server is not running! $str"
fi

#################################################################################
data_message_str=""
#################################################################################
####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
