#!/bin/bash
#
#    Copyright (C) 2003 -  2010  Erdal Mutlu
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
	echo "Usage   1 : $0 sisiya_server_checks.conf check_system_name virtual_server file port expire"
	echo "Usage   2 : $0 sisiya_server_checks.conf check_system_name virtual_server file port user password expire"
	echo "Usage   3 : $0 sisiya_server_checks.conf check_system_name virtual_server file port expire output_file"
	echo "Usage   4 : $0 sisiya_server_checks.conf check_system_name virtual_server file port user password expire output_file"
	echo "Example 1 : $0 sisiya_server_checks.conf server1 www.example.org /index.html 80 10" 
	echo "Example 2 : $0 sisiya_server_checks.conf server1 www.example.org /index.html 80 admin manager 10" 
	echo "Example 3 : $0 sisiya_server_checks.conf server1 www.example.org /index.html 80 10 output_file" 
	echo "Example 4 : $0 sisiya_server_checks.conf server1 www.example.org /index.html 80 admin manager 10 output_file" 
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
	;;
	7)
		expire=`echo 		$6	| tr -d "\""`
		output_file=`echo	$7	| tr -d "\""`
	;;
	8)
		user=`echo		$6	|	tr -d "\""`
		password=`echo		$7	|	tr -d "\""`
		expire=`echo		$8	|	tr -d "\""`
	;;

	9)
		user=`echo		$6	|	tr -d "\""`
		password=`echo		$7	|	tr -d "\""`
		expire=`echo		$8	|	tr -d "\""`
		output_file=`echo	$9	|	tr -d "\""`
	;;
esac
if test $# -eq 7 || test $# -eq 9 ; then
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
### http service id
serviceid=$serviceid_http  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_http is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="web"
check_prog=$curl_prog
if test ! -x $check_prog ; then
	echo "$service_name check program does not exist or is not executable! Exiting..."
	exit 1
fi
##########################################################################
script_name_prefix=`basename $0 .sh`
script_name=${script_name_prefix}.sh
tmp_output_file=`mktemp -q /tmp/tmp_${script_name}_output.XXXXXX`

statusid=$status_ok
### --timeout=10 does not work when it is run whithin a bash script
params=" --max-time 4 --include --output $tmp_output_file"
if test -n "$user" ; then
	params="$params --user ${user}:$password"
fi
#echo "[$check_prog $params http://${virtual_host}:${port}$html_file]"
str=`$check_prog $params http://${virtual_host}:${port}$html_file 2>/dev/null`
retcode=$?
#echo "$check_prog $params http://${virtual_host}:${port}$html_file"

#str=`grep "^.*[ ]Server:" $tmp_output_file | cut -d ":" -f 2 | head -n1`
str=`grep "^Server:" $tmp_output_file | cut -d ":" -f 2 | head -n1 | tr -d "\r"`
message_str="OK: $str"
# 18 : partial file
#if test $retcode -ne 0  && test $retcode -ne 18 ; then
if test $retcode -eq 0 ; then
	#echo ">>>>>>>>>>>>>>>>>>>>>>>>"
	#cat $tmp_output_file
	#echo "<<<<<<<<<<<<<<<<<<<<<<<<"
	http_status_code=`grep "^HTTP/" $tmp_output_file | head -n1 | awk '{print $2}'`
	#echo "http_status_code=[$http_status_code] str=[$str]"
	case "$http_status_code" in
		"200" | "302")
			statusid=$status_ok
			message_str="OK: $str"
		;;
		"404")
			statusid=$status_warning
			message_str="WARNING: $html_file could not be found! $str"
		;;
		"403")
			statusid=$status_warning
			message_str="WARNING: It is forbidden to get ${virtual_host}$html_file! $str"
		;;
		"401")
			statusid=$status_warning
			message_str="WARNING: Unauthorized access to ${virtual_host}$html_file! $str"
		;;
		*)
			http_status_str=""
			if test -z "$http_status_code" ; then
				http_status_code=`grep "Connecting" $tmp_output_file | tr "\n" " "`
				http_status_str="$http_status_code"
			else
				http_status_str="HTTP code = $http_status_code"
			fi
			statusid=$status_error
			message_str="ERROR: The $service_name server is not running! $str retcode=$retcode $http_status_str"
		;;
	esac
else
	statusid=$status_error
	message_str="ERROR: The $service_name server is not running! $str retcode=$retcode"
fi
rm -f $tmp_output_file
data_message_str=""
#################################################################################
#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
#if test $# -eq $min_argc ; then
if test $# -ne 7 && test $# -ne 9 ; then
	echo "${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire \"<msg>$message_str</msg><datamsg>$data_message_str</datamsg>\""
	${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
