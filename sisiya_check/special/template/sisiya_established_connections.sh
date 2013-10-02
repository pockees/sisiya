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
serviceid=$serviceid_established_connections 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_established_connections is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="Established connections"
##########################################################################
### default values
netstat_prog=netstat
### This check uses netstat -ntp command 
number_of_connections=2
connection_description[0]="My Special connection"
connection_address_type[0]="foreign"
connection_ip[0]="10.10.10.10"
connection_port[0]=8989
#connection_onerror[0]=warn
connection_description[1]="My Special connection 2"
connection_address_type[1]="local"
connection_ip[1]="192.168.3.1"
connection_port[1]=9887
### end of the default values
##########################################################################

if test ! -f $module_conf_file ; then
	statusid=$status_warning
	echo "$0 : Configuration file $module_conf_file does not exist!"
	exit 0
fi
### source the module conf
. $module_conf_file

if test $number_of_connections -lt 1 ; then
	statusid=$status_warning
        echo "WARNING: The total number of sockets=$number_of_connections must be greater than 1!"
	exit 0
fi

tmp_error_file=`maketemp /tmp/tmp_${script_name}_error.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_${script_name}_warning.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_${script_name}_ok.XXXXXX`
tmp_netstat_out=`maketemp /tmp/tmp_${script_name}_netstatout.XXXXXX`

$netstat_prog -ntp > $tmp_netstat_out

declare -i i=0
while test $i -lt $number_of_connections
do
        description=${connection_description[${i}]}
        addr_type=${connection_address_type[${i}]}
        ip=${connection_ip[${i}]}
        port=${connection_port[${i}]}
	#echo "Checking established connection description=$description addr_type=$addr_type protocol=$progname ip=$ip port=$port ..."
	case "$addr_type" in
		"local")
			str=`cat $tmp_netstat_out | grep "ESTABLISHED" | awk "{print $4}" | grep "${ip}:${port}"`
		;;
		"foreign")
			str=`cat $tmp_netstat_out | grep "ESTABLISHED" | awk "{print $5}" | grep "${ip}:${port}"`
		;;
		*)
			echo "$description (Wrong address type=$addr_type)!" >> $tmp_error_file
			i=i+1
			continue
		;;
	esac
	if test -z "$str" ; then
		if test -n "${connection_onerror[${i}]}" && test "${connection_onerror[${i}]}" = "warn" ; then
			echo "$description (No established connection to ${ip}:${port})!" >> $tmp_warning_file
		else
			echo "$description (No established connection to ${ip}:${port})!" >> $tmp_error_file
		fi
	else
		echo "$description (${ip}:${port})." >> $tmp_ok_file
	fi
        i=i+1
done

statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	statusid=$status_error
	message_str="<div id=\"error\" style=\"background: red\">ERROR:</div> "`cat $tmp_error_file | tr "\n" " "`
fi
if test -s $tmp_warning_file ; then
	message_str="$message_str <div id=\"error\" style=\"background: yellow\">WARNING:</div> "`cat $tmp_warning_file | tr "\n" " "`
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi
if test -s $tmp_ok_file ; then
	message_str="$message_str <div id=\"error\" style=\"background: green\">OK:</div> `cat $tmp_ok_file | tr "\n" " "`"
fi
for f in $tmp_ok_file $tmp_error_file $tmp_warning_file $tmp_netstat_out
do
	rm -f $f
done
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
