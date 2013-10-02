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
max_argc=9
if test $# -lt $min_argc || test $# -gt $max_argc ; then
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name virtual_server file port expire"
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name virtual_server file port user password expire"
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name virtual_server file port expire output_file"
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name virtual_server file port user password expire output_file"
	echo "Example: $0 sisiya_server_checks.conf server1 www.example.org /index.html 443 10" 
	echo "Example: $0 sisiya_server_checks.conf server1 www.example.org /index.html 443 admin manager 10" 
	echo "Example: $0 sisiya_server_checks.conf server1 www.example.org /index.html 443 10 output_file" 
	echo "Example: $0 sisiya_server_checks.conf server1 www.example.org /index.html 443 admin manager 10 output_file" 
	echo "Example: $0 sisiya_server_checks.conf server1 www.example.org /index.html 443 10 output_file" 
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
	6)
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
serviceid=$serviceid_https  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_https is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="https"
check_prog=$wget_prog
if test ! -x $check_prog ; then
	echo "$service_name check program does not exist or is not executable! Exiting..."
	exit 1
fi
##########################################################################
script_name_prefix=`basename $0 .sh`
script_name=${script_name_prefix}.sh
wget_output_file=`mktemp -q /tmp/tmp_${script_name}_output.XXXXXX`
index_file=`mktemp -q /tmp/tmp_${script_name}_index.XXXXXX`

statusid=$status_ok
str=`$check_prog --timeout=10 --no-check-certificate --server-response -o $wget_output_file -O $index_file https://${virtual_host}:${port}$html_file`
retcode=$?

#echo "------------------------"
#cat $wget_output_file
#echo "------------------------"

str=`grep "^.*[ ]Server:" $wget_output_file | head -n1 | cut -d ":" -f 2`
message_str="OK: $str"
if test $retcode -ne 0 ; then
	http_status_code=`grep "^  HTTP/" $wget_output_file | head -n1 | awk '{print $2}'`
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
fi

rm -f $wget_output_file $index_file
#################################################################################
###echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
