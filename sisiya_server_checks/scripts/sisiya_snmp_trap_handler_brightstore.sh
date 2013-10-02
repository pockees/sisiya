#!/bin/bash
#
# General SNMP trap handler for SisIYA.
#
#    Copyright (C) 2008  Erdal Mutlu
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
	echo "Usage : $0 sisiya_client.conf expire status"
	echo "The expire parameter must be given in minutes."
	echo "status can be info, ok, warning or error"
	exit 1
fi

client_conf_file=$1
expire=$2
status_str=$3

if test ! -f $client_conf_file ; then
	echo "$0 : SISIYA client configuration file $client_conf_file does not exist!"
	exit 1
fi

script_name=`basename $0`
script_name_prefix=`basename $0 .sh`
pwd_str=`echo $0 | sed -e "s/$script_name//"`
### source the config file
. $client_conf_file
###

#module_conf_file="${pwd_str}${script_name_prefix}.conf"
module_conf_file="${pwd_str}sisiya_snmp_trap_handler.conf"

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
### put this line in the /etc/snmp/snmptrapd.conf file:
###traphandle SNMPv2-SMI::enterprises.46   bash /opt/sisiya_server_checks/sisiya_snmp_trap_handler_brightstore.sh /opt/sisiya_client_checks/sisiya_client.conf 0 info 
############################################################################################
### default values
### You must define an array of ips and system names in the $module_conf_file file
number_of_systems=0
#system_ip[0]="127.0.0.1"
#system_name[0]="system1.example.org"
### end of the default values

### If there is a module conf file then override these default values
if test ! -f $module_conf_file ; then
	error "Module configuration file $module_conf_file does not exist!"
fi
. $module_conf_file

### timeout in secends
timeout=5
### the first line is the host name
read -t $timeout hostname_str
### the second line contains the IP address
read -t $timeout ip_str
ip_str=`echo $ip_str | cut -d "[" -f 2 | cut -d "]" -f 1`
### the rest is SNMP OIDs with their values (elsewhere called a VARBIND or VarList)
vars_str=""
while read -t $timeout oid_str oid_value_str
do
	case $oid_str in
		"SNMPv2-SMI::enterprises.46.877.5.0" | "SNMPv2-SMI::enterprises.46.879.5.0")
			str=`echo $oid_value_str | grep "Operation Successful"`
			if test -n "$str" ; then
				status_str="ok"
			else
				str=`echo $oid_value_str | grep "Operation Failed"`
				if test -n "$str" ; then
					status_str="error"
				else
					status_str="info"
				fi
			fi
		;;
	esac

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
	message_str="host=$ip_str $message_str (from CA Brightstore)"
fi
#echo "message_str=[$message_str]"
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "$message_str"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire $message_str" >> $output_file
fi
###################################################################################################
