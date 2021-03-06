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
### service id
serviceid=$serviceid_system
if test -z "$serviceid" ; then
	echo "$0 : serviceid_system is not defined! Exiting..."
	exit 1
fi
###############################################################################
### The format of error and warning uptimes is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
### 3) warning_uptime must be greater than error_uptime
###############################################################################
### the default values
error_uptime=1
warning_uptime=3
### to get information about the server
info_prog=""
#info_prog="${sisiya_base_dir}/special/sisiya_system_info_hpasm.sh"
### end of the default values
###############################################################################
### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

str=`extract_datetime $error_uptime`
error_days=`echo $str		| awk '{print $1}'`
error_hours=`echo $str		| awk '{print $2}'`
error_minutes=`echo $str	| awk '{print $3}'`
str=`extract_datetime $warning_uptime`
warning_days=`echo $str		| awk '{print $1}'`
warning_hours=`echo $str	| awk '{print $2}'`
warning_minutes=`echo $str	| awk '{print $3}'`
str=`get_uptime $up_uptime`
up_days=`echo $str	| awk '{print $1}'`
up_hours=`echo $str	| awk '{print $2}'`
up_minutes=`echo $str	| awk '{print $3}'`

#echo "up_days=$up_days up_hours=$up_hours up_minutes=$up_minutes"
#echo "error_uptime=$error_uptime warning_uptime=$warning_uptime"
#echo "error_days=$error_days error_hours=$error_hours error_minutes=$error_minutes"
#echo "warning_days=$warning_days warning_hours=$warning_hours warning_minutes=$warning_minutes"
#echo_datetime $error_days $error_hours $error_minutes
#echo_datetime $warning_days $warning_hours $warning_minutes


up_in_minutes=`(echo "$up_days * 1440 + $up_hours * 60 + $up_minutes") | bc`
error_in_minutes=`(echo "$error_days * 1440 + $error_hours * 60 + $error_minutes") | bc`
warning_in_minutes=`(echo "$warning_days * 1440 + $warning_hours * 60 + $warning_minutes") | bc`
up_str=`echo_datetime $up_days $up_hours $up_minutes`
if test $up_in_minutes -lt $error_in_minutes ; then
	statusid=$status_error  
	message_str="ERROR: The system was restarted $up_str (&lt; `echo_datetime $error_days $error_hours $error_minutes`) ago!"
elif test $up_in_minutes -lt $warning_in_minutes ; then
	statusid=$status_warning
	message_str="WARNING: The system was restarted $up_str (&lt; `echo_datetime $warning_days $warning_hours $warning_minutes`) ago!"
else
	statusid=$status_ok
	message_str="OK: The system is up since ${up_str}."
fi
if test "$sisiya_osname" = "HP-UX" ; then
	message_str="$message_str Info: `uname -srm`"
else
	message_str="$message_str Info: `uname -srmp`"
fi
### add system version
if test "$sisiya_osname" = "Linux" ; then
	if test -f /etc/issue.net ; then
		message_str="$message_str OS: `cat /etc/issue.net | tr "\n" " " `"
	fi
fi
### add SisIYA version
if test -f ${sisiya_base_dir}/version.txt ; then
	message_str="$message_str SisIYA: `cat ${sisiya_base_dir}/version.txt`"
fi

if test -n "$info_prog" ; then
	if test -f $info_prog ; then
		info_str=`$info_prog $client_conf_file`
		message_str="$message_str $info_str"
	fi
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
