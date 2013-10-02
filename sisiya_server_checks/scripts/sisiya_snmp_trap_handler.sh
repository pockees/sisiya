#!/bin/bash
#
# General SNMP trap handler for SisIYA.
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
if test $# -lt 3 ; then
	echo "Usage : $0 sisiya_server_checks.conf expire status"
	echo "The expire parameter must be given in minutes."
	echo "status can be info, ok, warning or error"
	exit 1
fi

conf_file=$1
expire=$2
status_str=$3

if test ! -f "$conf_file" ; then
	echo "$0 : SisIYA server checks configuration file $conf_file does not exist!"
	exit 1
fi

### source the config file
. $conf_file

for d in $sisiya_server_checks_dir $sisiya_server_checks_script_dir $sisiya_server_checks_conf_dir
do
	if test ! -d $d ; then
		echo "$0 : Directory $d does not exist!"
		exit 1
	fi
done

if test ! -f "$sisiya_client_conf_file" ; then
	echo "$0 : SisIYA client configuration file $sisiya_client_conf_file does not exist!"
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

#######################################################################################
### service id
serviceid=$serviceid_snmptrap
if test -z "$serviceid" ; then
	echo "$0 : serviceid_snmptrap is not defined! Exiting..."
	exit 1
fi
##########################################################################
##########################################################################
### add the following line in the /etc/snmp/snmptrapd.conf file :
#traphandle default bash /opt/sisiya_server_checks/scripts/sisiya_snmp_trap_handler.sh /opt/sisiya_server_checks/conf/sisiya_server_checks.conf 0 info
##########################################################################

##########################################################################
### default values
### You must define an array of ips and system names in the $module_conf_file file
### timeout in secends
timeout=5
number_of_systems=0
#system_ip[0]="127.0.0.1"
#system_name[0]="system1.example.org"
### end of the default values
##########################################################################

script_name_prefix=`basename $0 .sh`
module_conf_file="${sisiya_server_checks_conf_dir}/${script_name_prefix}.conf"
### If there is a module conf file then override these default values
if test ! -f $module_conf_file ; then
	error "Module configuration file $module_conf_file does not exist!"
fi
### source the module configuration file
. $module_conf_file

### the first line is the host name
read -t $timeout hostname_str
### the second line contains the IP address
read -t $timeout ip_str
ip_str=`echo $ip_str | cut -d "[" -f 2 | cut -d "]" -f 1`
### the rest is SNMP OIDs with their values (elsewhere called a VARBIND or VarList)
vars_str=""
while read -t $timeout oid_str oid_value_str
do
	if test -z "$vars_str" ; then
		vars_str="${oid_str}=$oid_value_str"
	else
		vars_str="$vars_str, ${oid_str}=$oid_value_str"
	fi 
done

case "$status_str" in
	"info")
		statusid=$status_info
		message_str="Info: $vars_str"
		;;
	"ok")
		statusid=$status_ok
		message_str="OK: $vars_str"
		;;
	"warning")
		statusid=$status_warning
		message_str="WARNING: $vars_str"
		;;
	"error")
		statusid=$status_error
		message_str="ERROR: $vars_str"
		;;
	*)
		statusid=$status_warning
		message_str="WARNING: Unknown status string=[$status_str] $vars_str"
		;;
esac

### try to find out the system name
declare -i i
i=0
while test $i -lt $number_of_systems
do
	if test "${system_ip[${i}]}" == "$ip_str" ; then
		### override the client hostname, because this snmp trap usually is not for this host
		sisiya_hostname=${sisiya_system_name[${i}]}
	fi

	i=i+1	
done
if test $i -eq $number_of_systems ; then
	message_str="host=$ip_str $message_str"
fi
#echo "message_str=[$message_str]"
data_message_str=""
########################################################################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test -z "$output_file" ; then
	$send_message_prog $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
########################################################################################################################################################
