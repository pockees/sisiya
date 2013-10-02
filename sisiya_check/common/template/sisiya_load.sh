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
serviceid=$serviceid_load  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_load is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
### load is specified as A * 100
warning_load_avg=200
error_load_avg=500
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

warning_load_avg_str=`(echo "scale=2;$warning_load_avg / 100.00")|bc`
#s=${warning_load_avg_str:0:1}
str=`echo $warning_load_avg_str | cut -d "." -f 1`
#if test "$s" = "." ; then
if test -z "$str" ; then
	warning_load_avg_str="0$warning_load_avg_str"
fi

error_load_avg_str=`(echo "scale=2;$error_load_avg / 100.00")|bc`
#s=${error_load_avg_str:0:1}
str=`echo $error_load_avg_str | cut -d "." -f 1`
#if test "$s" = "." ; then
if test -z "$str" ; then
	error_load_avg_str="0$error_load_avg_str"
fi


statusid=$status_info
str=`uptime  | awk '{print $1}' | awk -F: '{print $3}'`
if test -z "$str" ; then
	str=`uptime  | awk -F: '{print $4}' | awk -F, '{print $2}'`
	if test -z "$str" ; then
		if test $sisiya_osname = "Darwin" ; then
			str=`uptime  | awk -F: '{print $4}' | awk '{print $2}'`
		else
			str=`uptime  | awk -F: '{print $3}' | awk -F, '{print $2}'`
		fi
		if test -z "$str" ; then
			str=`uptime  | awk -F: '{print $3}' | awk '{print $2}'`
		fi
	fi
else
	str=`uptime  | awk -F: '{print $5}' | awk -F, '{print $2}'`
	if test -z "$str" ; then
		str=`uptime  | awk -F: '{print $4}' | awk -F, '{print $2}'`
	fi
fi

a=`echo $str | awk -F. '{print $1}'`
b=`echo $str | awk -F. '{print $2}'`
load=`(echo "100 * $a + $b")|bc`
load_str="$a.$b"

### <cpu><name>CPU0</name><description>Into Cor 2 Duo</description><load>39</load></cpu>
### load is load in percent (0-100)
message_str="Load average for the past 5 minutes is $load_str"
if test $load -ge $error_load_avg ; then
	statusid=$status_error
	#message_str="ERROR: Load average for the past 5 minutes is $load_str >= $error_load_avg_str"
	message_str="ERROR: $message_str >= $error_load_avg_str"
elif test $load -ge $warning_load_avg ; then
	statusid=$status_warning
	#message_str="WARNING: Load average for the past 5 minutes is $load_str >= $warning_load_avg_str"
	message_str="WARNING: $message_str >= $warning_load_avg_str"
else
	statusid=$status_ok
	#message_str="OK: Load average for the past 5 minutes is $load_str"
	message_str="OK: $message_str"
fi
message_str="$message_str (`uptime`)."

### add CPU information
if test "$sisiya_osname" = "Linux"  ; then
	cpucount=`grep --count "^processor" /proc/cpuinfo`

	### I assume that all CPUs are of the same model. Actually this may not be the case.
	#model=`grep --max-count=1 "^model name" /proc/cpuinfo | awk -F: '{print $2}'`
	#cache_size=`grep --max-count=1 "^cache size" /proc/cpuinfo | awk -F: '{print $2}'`
	#vendor_id=`grep --max-count=1 "^vendor_id" /proc/cpuinfo | awk -F: '{print $2}'`
	model=`grep "^model name" /proc/cpuinfo		| head -n 1 | awk -F: '{print $2}'`
	cache_size=`grep "^cache size" /proc/cpuinfo	| head -n 1 | awk -F: '{print $2}'`
	vendor_id=`grep "^vendor_id" /proc/cpuinfo	| head -n 1 | awk -F: '{print $2}'`


	usage=`top -b -n 1 |grep -i "cpu[0-9,(]"|tr -s '\n' ' '`	
	message_str="$message_str CPU: ${cpucount} x${model} $vendor_id Cache size =$cache_size Usage =$usage"
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
