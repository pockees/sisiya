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
	echo "Usage : sisiya_server_checks_conf check_system_name check_system ftp_file ftp_mode transfer_mode user password expire"
	echo "Usage : sisiya_server_checks_conf check_system_name check_system ftp_file ftp_mode transfer_mode user password expire output_file"
	echo "Example: $0 sisiya_server_checks.conf system1.example.org ftp.example.org /pub/test.txt passive ascii guest guestpas 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.org ftp.example.org /pub/test.txt passive ascii guest guestpas 10 output_file" 
	echo "expire must be specified in minutes."
	echo "Without the output_file, the script will send the message directly to the SisIYA server."
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
ftp_file=`echo 		$4	| tr -d "\""`
ftp_mode=`echo 		$5	| tr -d "\""`
transfer_mode=`echo 	$6	| tr -d "\""`
ftp_user=`echo 		$7	| tr -d "\""`
ftp_password=`echo 	$8	| tr -d "\""`

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
serviceid=$serviceid_ftp  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ftp is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="FTP"
check_prog=$ftp_prog
if test ! -x $check_prog ; then
	echo "$ftp_prog program does not exist or is not executable! Exiting..."
	exit 1
fi
##########################################################################
statusid=$status_ok
### check params
if test ! $ftp_mode = "active" && test ! $ftp_mode = "passive" ; then
	echo "FTP mode =$ftp_mode is not known! Known modes are : active and passive ."
	exit 1
fi
if test ! $transfer_mode = "ascii" && test ! $transfer_mode = "binary" ; then
	echo "Transfer mode =$transfer_mode is not known! Known modes are : ascii and binary ."
	exit 1
fi

local_file=`mktemp /tmp/tmp_sisiya_check_ftp_systems_file.XXXXXX`
rm -f $local_file

ftp_output_file=`mktemp /tmp/tmp_sisiya_check_ftp_systems_output_file.XXXXXX`
if test $ftp_mode = "active" ; then 
$ftp_prog -iuv <<-FTP_END > $ftp_output_file
open $check_system
user $ftp_user $ftp_password
passive
$transfer_mode
get $ftp_file $local_file
bye
FTP_END
else
$ftp_prog -iuv <<-FTP_END > $ftp_output_file
open $check_system
user $ftp_user $ftp_password
passive
$transfer_mode
get $ftp_file $local_file
bye
FTP_END
fi

retcode=$?
#echo "retcode=$retcode"
#server_str=`grep "^220" $ftp_output_file | sed -e "s~220 ~~g"`
server_str=`grep "^220" $ftp_output_file | sort | tail -n 1 | tr -s "\'" " "`
login_str=`grep "^530" $ftp_output_file`
file_str=`grep "^550" $ftp_output_file`

#cat $ftp_output_file
#echo "server_str=[$server_str]"
#echo "login_str=[$login_str]"
#echo "file_str=[$file_str]"
#echo "------------- The output file --------------------------------"
#cat $ftp_output_file
rm -f $ftp_output_file
#echo "------------- END The output file --------------------------------"

#if test $retcode -ne 0 ; then
	#message_str="ERROR: The $service_name system is not running!"
if test -z "$server_str" ; then
	statusid=$status_error
	message_str="ERROR: The FTP server is not running!"
elif test -n "$login_str" ; then
	statusid=$status_warning
	message_str="WARNING: Login incorrect!"
elif test -n "$file_str" ; then
	statusid=$status_warning
	message_str="WARNING: Could not open the $ftp_file file!"
elif test ! -s $local_file ; then
	statusid=$status_warning
	message_str="WARNING: Could not get the $ftp_file file!"
else
	message_str="OK: The FTP server is running."
fi	
rm -f $local_file

#################################################################################################################################################################
#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire" 
#echo "str=$message_str data_message_str=$date_message_str"
if test $# -eq $min_argc ; then
	$send_message_prog $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###############################################################################################################################################################
