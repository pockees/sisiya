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
min_argc=8
max_argc=9
if test $# -lt $min_argc || test $# -gt $max_argc ; then
	echo "Usage  : $0 sisiya_server_checks.conf check_system_name check_system snmp_version snmp_community snmp_username snmp_password expire"
	echo "Usage  : $0 sisiya_server_checks.conf check_system check_system_name snmp_comm expire output_file"
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 2c \"\" \"\" public 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 2c \"\" \"\" public 10 output_file" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 3 \"admin\" \"admin_password\" public 10" 
	echo "Example: $0 sisiya_server_checks.conf system1.example.com system1 3 \"admin\" \"admin_password\" public 10 output_file" 
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
snmp_version=`echo 	$4	| tr -d "\""`
snmp_comm=`echo 	$5	| tr -d "\""`
snmp_user=`echo 	$6	| tr -d "\""`
snmp_password=`echo 	$7	| tr -d "\""`

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
##########################################################################
service_name="System"
check_prog=$snmpwalk_prog
if test ! -x $check_prog ; then
	echo "$service_name check program $check_prog does not exist or is not executable! Exiting..."
	exit 1
fi
if test ! -x $snmpget_prog ; then
	echo "$service_name check program snmpget=$snmpget_prog does not exist or is not executable! Exiting..."
	exit 1
fi
###############################################################################
### The format of error and warning uptimes is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
### 3) warning_uptime must be greater than error_uptime
###############################################################################
### default values
error_uptime=0:30
warning_uptime=1:0
### end of the default values

function sendMessageAndExit()
{
	#################################################################################
	#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
	if test $# -eq $min_argc ; then
		${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	else
		echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
	fi
	#################################################################################
	exit
}

### One can override the default values in the $sisiya_server_checks_dir/$system_conf_file file
### Check if there is a configuration file for this system. 
system_conf_file="${sisiya_server_checks_dir}/${check_system_name}.conf"
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

statusid=$status_ok
#str=`$check_prog -v $snmp_version $check_system -c $snmp_comm system.sysDescr 2>&1`
#echo "$snmpget_prog -OvQ -v $snmp_version $check_system -c $snmp_comm system.sysDescr.0"
str=`$snmpget_prog -OvQ -v $snmp_version $check_system -c $snmp_comm system.sysDescr.0 2>&1`
retcode=$?
#echo "retcode=$retcode str=[$str]"
error=0
if test $retcode -eq 0 ; then
	#sys_name=`echo $str | cut -d ":" -f 4`
	#sys_location=`$check_prog 	-v $snmp_version $check_system -c $snmp_comm system.sysLocation			| cut -d ":" -f 4 	2>&1`
	#dev_name=`$check_prog 		-v $snmp_version $check_system -c $snmp_comm HOST-RESOURCES-MIB::hrDeviceDescr.1	| cut -d ":" -f 4 	2>&1`
	#str=`$check_prog 		-v $snmp_version $check_system -c $snmp_comm system.sysUpTime.0 						2>&1`
#	str2=`echo $str | grep day`
#	if test -z "$str2" ; then
#		up_days=0
#		time_str=`echo $str 		| cut -d ")" -f 2	| cut -d " " -f 2`
#		up_hours=`echo $time_str 	| cut -d ":" -f 1`
#		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
#	else
#	#	str2=`echo $str | cut -d ":" -f 4|cut -d ")" -f 2|cut -d "," -f 1|cut -d " " -f 2`
#		up_days=`echo $str 		| cut -d "," -f 1 	| cut -d ")" -f 2	| cut -d " " -f 2`
#		time_str=`echo $str 		| cut -d "," -f 2	|cut -d " " -f 2`
#		up_hours=`echo $time_str 	| cut -d ":" -f 1`
#		up_minutes=`echo $time_str 	| cut -d ":" -f 2`
#	fi


	sys_name=`echo $str | tr "\n" " "`
	sys_location=`$snmpget_prog 	-OvQ -v $snmp_version -c $snmp_comm $check_system system.sysLocation.0 			2>&1`
	if test $? -ne 0 ; then
		statusid=$status_error
		message_str="ERROR: Could not get location information! $str"
		sendMessageAndExit
	fi

	dev_name=`$snmpget_prog 	-OvQ -v $snmp_version -c $snmp_comm $check_system HOST-RESOURCES-MIB::hrDeviceDescr.1 	2>&1`
	if test $? -ne 0 ; then
		statusid=$status_error
		message_str="ERROR: Could not get device description information! $str"
		sendMessageAndExit
	fi
	#echo "$snmpget_prog              -OvQ -v $snmp_version -c $snmp_comm $check_system system.sysUpTime.0"
	str=`$snmpget_prog 		-OvQ -v $snmp_version -c $snmp_comm $check_system system.sysUpTime.0			2>&1`
	if test $? -ne 0 ; then
		statusid=$status_error
		message_str="ERROR: Could not get uptime information! $str"
		sendMessageAndExit
	fi

	up_days=`echo $str	| cut -d ":" -f 1`
	up_hours=`echo $str 	| cut -d ":" -f 2`
	up_minutes=`echo $str 	| cut -d ":" -f 3`


	#echo "system=$check_airport up_days=$up_days up_hours=$up_hours up_minutes=$up_minutes"
	
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
	message_str="${message_str} Description: $sys_name Location: $sys_location"
else
	error=1
	#echo "XXXXXXXXXXXXXXX: error=$error"
	statusid=$status_error
	#message_str="ERROR: Could not get information! $str"
	message_str="ERROR: Could not get information!"
	#echo "str=[$str]"
fi
#################################################################################
#echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
#################################################################################

#echo "WWWWWWWWWWWWW: error=$error"
### if there was an error no need to continue
if test $retcode -ne 0 ; then
	exit 0
fi

#################################################################################
### Check for printer status
#################################################################################
### service id
serviceid=$serviceid_printer
##########################################################################
service_name="Printer"
##########################################################################
### default values
### end of the default values
#device_status_mib="HOST-RESOURCES-MIB::hrDeviceStatus"
device_status_mib="iso.3.6.1.2.1.25.3.2.1.5.1"
#printer_status_mib="HOST-RESOURCES-MIB::hrPrinterStatus"
printer_status_mib="iso.3.6.1.2.1.25.3.5.1.1.1"
#printer_state_mib="HOST-RESOURCES-MIB::hrPrinterDetectedERRORState"
printer_state_mib="iso.3.6.1.2.1.25.3.5.1.2.1"
statusid=$status_ok
#str=`$check_prog -v 1 $check_system -c $snmp_comm $device_status_mib 2>&1`
str=`$snmpget_prog -OvQe -v $snmp_version -c $snmp_comm $check_system $device_status_mib 2>&1`
retcode=$?

########################################################################
#	lowPaper          0        warning(3)
#	noPaper           1        down(5)
#	lowToner          2        warning(3)
#       noToner           3        down(5)
#	doorOpen          4        down(5)
#	jammed            5        down(5)
#	offline           6        down(5)
#	serviceRequested  7        warning(3)
########################################################################
if test $retcode -eq 0 ; then
	#dev_status=`echo $str | cut -d ":" -f 4 | cut -d " " -f 2`
	dev_status=$str
	#pr_status=`$check_prog -v 1 $check_system -c $snmp_comm $printer_status_mib|cut -d ":" -f 4 | cut -d " " -f 2 2>&1`
	pr_status=`$snmpget_prog -OvQe -v $snmp_version -c $snmp_comm $check_system $printer_status_mib 2>&1`
	#state_status=`$check_prog -v 1 $check_system -c $snmp_comm $printer_state_mib|cut -d ":" -f 4 | cut -d " " -f 2 | cut -d "\"" -f 2 2>&1`
	#state_status=`$check_prog -v 1 $check_system -c $snmp_comm $printer_state_mib|cut -d ":" -f 4 | cut -d " " -f 2 2>&1`
	#state_status=`$check_prog -v 1 $check_system -c $snmp_comm $printer_state_mib|cut -d ":" -f 4 2>&1`
	state_status=`$snmpget_prog -OvQe -v $snmp_version -c $snmp_comm $check_system $printer_state_mib 2>&1`
	#echo "printer=[$check_system] dev_status=[$dev_status] pr_status=[$pr_status] state_status=[$state_status]"
	message_str=""
	case "$dev_status" in
		#"unknown(1)")	
		"1")	
			statusid=$status_warning
			message_str="WARNING: Device status is unknown!"
		;;
		#"running(2)")
		"2")
			statusid=$status_ok
			case "$pr_status" in
				#"other(1)")
				"1")
					message_str="OK: The device is in stanby status."
				;;	
				#"idle(3)")
				"3")
					message_str="OK: Device is idle."
				;;
				#"printing(4)")
				"4")
					message_str="OK: Device is printing."
				;;
				*)
					statusid=$status_warning
					message_str="WARNING: Unknown device status: dev_status=[$dev_status] pr_status=[$pr_status] state=[${state_status}]!"
				;;	
			esac
		;;
		#"warning(3)")
		"3")
			statusid=$status_warning
			case $state_status in
				" \" \"")
					message_str="WARNING: Low toner!"
				;;
#				" 00")
#					message_str="WARNING: Low toner!"
#				;;
				" 80 ")
					message_str="WARNING: No paper!"
				;;
				" A0 ")
					message_str="WARNING: Order toner!"
				;;
				*)
					message_str="WARNING: Unknown state=[$state_status]!"
				;;
			esac
			message_str="$message_str Device status is"
			case $pr_status in
				#"other(1)")
				"1")
					message_str="$message_str other."
				;;
				#"unknown(2)")
				"2")
					message_str="$message_str unknown."
				;;
				#"idle(3)")
				"3")
					#message_str="$message_str idle. Could be: low paper, low toner or service requested."
					message_str="$message_str idle."
				;;
				#"printing(4)")
				"4")
					#message_str="$message_str printing. Could be: low paper, low toner or service requested."
					message_str="$message_str printing."
				;;
				#"warmup(5)")
				"5")
					message_str="$message_str warmup."
				;;
				*)
					message_str="WARNING: Unknown printer status: dev_status=[$dev_status] pr_status=[$pr_status] state=[${state_status}]!"
				;;
			esac
		;;
		#"testing(4)")	
		"4")	
			statusid=$status_warning
			message_str="WARNING: Device is in testing status: dev_status=[$dev_status] pr_status=[$pr_status] state=[${state_status}]!"
		;;

		#"down(5)")
		"5")
			statusid=$status_error
############################################			
### for status down
# state=[ 01 ] warmup ?
# state=[ 02 ]
# state=[ 03 ]
# state=[ 0A }
# state=[ BA}
# state=["2"]
# state=[ C2 }
# state=[ 08 ] door open ?
# state=["@"] no paper
############################################			
			case "$state_status" in
				" \"@\"")
					message_str="ERROR: no paper!"
				;;
				"\"@\"")
					message_str="ERROR: no paper!"
				;;
				" 01 ")
					message_str="ERROR: warmup!"
				;;
### check the " 01 " state.
#				" 01 ")
#					message_str="ERROR: ?!"
#				;;
				" 01")
					message_str="ERROR: !"
				;;
				" 08 ")
					message_str="ERROR: cover or door is open!"
				;;
				" \"\"\"") ### ?
					message_str="ERROR: Toner is almost empty?!"
					;;
				*)
					#message_str="ERROR: unknown state=[${state}]!"
					statusid=$status_info
					message_str="INFO: unknown state=[${state}]!"
				;;
			esac
			message_str="$message_str Device status is"
			case $pr_status in
				#"other(1)")
				"1")
					message_str="$message_str other."
				;;
				#"unknown(2)")
				"2")
					message_str="$message_str unknown."
				;;
				#"idle(3)")
				"3")
					#message_str="$message_str idle. Could be: low paper, low toner or service requested."
					message_str="$message_str idle."
				;;
				#"printing(4)")
				"4")
					#message_str="$message_str printing. Could be: low paper, low toner or service requested."
					message_str="$message_str printing."
				;;
				#"warmup(5)")
				"5")
					message_str="$message_str warming up."
				;;
				*)
					message_str="ERROR: Unknown device status: dev_status=[$dev_status] pr_status=[$pr_status]!"
				;;
			esac
			#message_str="ERROR: Device is down! state=[$state_status] state_info=[$state_info] Could be: jammed, no paper, no toner, cover open or service requested."
			#message_str="ERROR: Device is down. Could be: jammed, no paper, no toner, cover open or service requested."
		;;
		*)	
			statusid=$status_warning
			message_str="WARNING: Undetermied device status=[$dev_status]!"
			### an empty device status ?!
			if test -z "$dev_status" ; then
				statusid=$status_ok
				message_str="OK: Device status could not be determined. It should be OK:)"
			fi
		;;
	esac
else
	statusid=$status_error
	message_str="ERROR: Could not get info about the printer $service_name (mib=$device_status_mib)"
fi
#################################################################################
####echo "conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
#################################################################################
#################################################################################
### Get printer page counts
#################################################################################
### service id
serviceid=$serviceid_printer_pagecounts
##########################################################################
service_name="Printer_PageCounts"
##########################################################################
### default values
### end of the default values
#################################################################################
### page count .1.3.6.1.2.1.43.10.2.1.4.1
#total_engine_page_count_oid=    ".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.5"
#duplex_page_count_oid=          ".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.22"
#pcl_total_page_count_oid=       ".1.3.6.1.4.1.11.2.3.9.4.2.1.3.3.3.5"
#postscript_total_page_count_oid=".1.3.6.1.4.1.11.2.3.9.4.2.1.3.3.4.5"
#total_color_page_count_oid=     ".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.7"
#total_mono_page_count_oid=      ".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.6"
#################################################################################
#pagecount_count_mib=".1.3.6.1.2.1.43.10.2.1.4.1"
pagecount_count_mib="1.3.6.1.2.1.43.10.2.1.4.1.1"
#total_engine_page_count_mib=".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.5"
total_engine_page_count_mib="1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.5.0"
duplex_page_count_mib=".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.22"
#pcl_total_page_count_mib=".1.3.6.1.4.1.11.2.3.9.4.2.1.3.3.3.5"
pcl_total_page_count_mib="1.3.6.1.4.1.11.2.3.9.4.2.1.3.3.3.5"
#postscript_total_page_count_mib=".1.3.6.1.4.1.11.2.3.9.4.2.1.3.3.4.5"
postscript_total_page_count_mib="1.3.6.1.4.1.11.2.3.9.4.2.1.3.3.4.5"
#total_color_page_count_mib=".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.7"
total_color_page_count_mib=".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.7.0"
#total_mono_page_count_mib=".1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.6"
total_mono_page_count_mib="1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.6.0"
#
number_of_mibs=7
page_count_mibs[0]=$total_engine_page_count_mib
page_name_mibs[0]="engine"
page_count_mibs[1]=$duplex_page_count_mib
page_name_mibs[1]="duplex"
page_count_mibs[2]=$pcl_total_page_count_mib
page_name_mibs[2]="pcl"
page_count_mibs[3]=$postscript_total_page_count_mib
page_name_mibs[3]="postscript"
page_count_mibs[4]=$total_color_page_count_mib
page_name_mibs[4]="color"
page_count_mibs[5]=$total_mono_page_count_mib
page_name_mibs[5]="mono"
page_count_mibs[6]=$pagecount_count_mib
page_name_mibs[6]="pagecount"

statusid=$status_info
info_str=""
error_str=""

declare -i i=0
overall_total_pages=0
while test $i -lt $number_of_mibs
do
        current_mib=${page_count_mibs[${i}]}
        current_name=${page_name_mibs[${i}]}

	#str=`$check_prog -v 1 $check_system -c $snmp_comm $current_mib 2>&1`
	str=`$snmpget_prog -OvQ -v $snmp_version -c $snmp_comm $check_system $current_mib 2>&1`
	retcode=$?
	if test $retcode -eq 0 ; then
		#echo "$check_system str=[$str]"
		str2=`echo $str | grep ^[[:alpha:]]`
		if test -z "$str2" ; then
			#total_pages=`echo $str | cut -d ":" -f 4 | cut -d " " -f 2 2>&1`
			total_pages=$str
			#echo "check_system=$check_system current_mib=$current_mib current_name=$current_name total_pages=$total_pages"
			if test -n "$total_pages" ; then
				info_str="$info_str Total number of $current_name pages is ${total_pages}."
				overall_total_pages=`(echo "$overall_total_pages + $total_pages") | bc`
			fi
		fi
	#else
	#	error_str="$error_str ERROR: Could not get info about mib=${current_mib}!"
	fi
	i=i+1
done

if test -z "$info_str" ; then
	info_str="Could not get page counts."	
fi
#else
#	info_str="INFO: The overall total number of pages is ${overall_total_pages}. $info_str"
#fi

if test -n "$error_str" ; then
	statusid=$status_error
	message_str="$error_str $info_str"
else
#	if test -z "$info_str" ; then
#		if test $statusid -lt $status_error ; then
#			statusid=$status_warning
#			message_str="WARNING: Could not get page counts!"	
#		else
#			message_str="$error_str WARNING: Could not get page counts!"	
#		fi
#	else
#		message_str="$info_str"
#	fi

	message_str="$info_str"
fi
#################################################################################
#echo "$0: conf_file=$sisiya_client_conf_file check_system_name=$check_system_name serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test $# -eq $min_argc ; then
	${send_message_prog} $sisiya_client_conf_file $check_system_name $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
else
	echo "$check_system_name $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
#################################################################################
