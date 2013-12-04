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
### server service id
serviceid=$serviceid_progs  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_progs is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="Progs"

if test ! -f $module_conf_file ; then
	echo "$0 : module_conf_file=$module_conf_file does not exist!"
	exit 1
fi

ok_str=""
err_str=""
list_str=`grep -v "#"  $module_conf_file`
for line in $list_str
do
	prog=`echo $line | awk -F! '{print $1}'`  
	user=`echo $line | awk -F! '{print $2}'`  
	case "$sisiya_osname" in
		"HP-UX")
			UNIX95=""
			export UNIX95
			ps_command="ps -eo user,pid,comm"
		;;
		"OpenBSD")
			ps_command="ps -xeo user,pid,comm"
		;;
		"SunOS")
			ps_command="ps -eo user,pid,comm"
		;;
		*)
			ps_command="ps -Aeo user,pid,command"
		;;
	esac
	if test -n "$user" ; then
		case "$sisiya_osname" in
			"HP-UX")
				str=`$ps_command | grep "${prog}" | grep "${user}" | grep -v grep | grep -v $script_name`
			;;
			*)
				str=`$ps_command | grep "${prog}" | grep "${user}" | grep -vw grep | grep -vw $script_name`
			;;
		esac
	else 
		case "$sisiya_osname" in
			"HP-UX")
				str=`$ps_command | grep "${prog}" | grep -v grep | grep -v $script_name`
			;;
			*)
				str=`$ps_command | grep "${prog}" | grep -v grep | grep -vw $script_name`
			;;
		esac

	fi
	if test -n "$str" ; then
		statusid=$status_ok
		if test -n "$ok_str" ; then
			ok_str="$ok_str $prog" 
		else
			ok_str="$prog" 
		fi 
	else
		if test -n "$err_str" ; then
			err_str="$err_str $prog"
		else
			err_str="$prog"
		fi
		statusid=$status_error
	fi
done 

statusid=$status_ok
message_str=""
if test -n "$err_str" ; then
	statusid=$status_error
	message_str="ERROR: $err_str"
fi 

if test -n "$ok_str" ; then
	if test -n "$message_str" ; then
		message_str="$message_str OK: $ok_str"
	else
		message_str="OK: $ok_str"
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
