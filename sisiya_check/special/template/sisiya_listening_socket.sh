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
serviceid=$serviceid_listening_socket 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_listening_socket is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="Listening Socket"
##########################################################################
### default values
netstat_prog=netstat
### This check uses netstat -nlp command 
### Interface must be numeric value 0.0.0.0 meaning all interfaces
### If the port number is 0 then it is not going to be checked
### The progname can be at most 13 characters long
number_of_sockets=2
socket_description[0]="My special server1"
socket_progname[0]="myserver"
#socket_onerror[0]="warn"
socket_port[0]=45566
socket_protocol[0]="tcp"
socket_interface[0]="0.0.0.0"
socket_description[1]="My udp server"
socket_progname[1]="myserver"
socket_port[1]=45566
socket_protocol[1]="udp"
socket_interface[1]="0.0.0.0"
### end of the default values
##########################################################################

if test ! -f $module_conf_file ; then
	statusid=$status_warning
	echo "$0 : Configuration file $module_conf_file does not exist!"
	exit 0
fi
### source the module conf
. $module_conf_file

if test $number_of_sockets -lt 1 ; then
	statusid=$status_warning
        echo "WARNING: The total number of sockets=$number_of_sockets must be greater than 1!"
	exit 0
fi

tmp_error_file=`maketemp /tmp/tmp_${script_name}_error.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_${script_name}_warning.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_${script_name}_ok.XXXXXX`
tmp_netstat_out=`maketemp /tmp/tmp_${script_name}_netstatout.XXXXXX`

$netstat_prog -nlp > $tmp_netstat_out 2> /dev/null

declare -i i=0
while test $i -lt $number_of_sockets
do
        description=${socket_description[${i}]}
        port=${socket_port[${i}]}
        protocol=${socket_protocol[${i}]}
        interface=${socket_interface[${i}]}
        progname=${socket_progname[${i}]}
	#echo "Checking listening socket description=$description protocol=$protocol port=$port interface=$interface ..."
	if test $port -eq 0 ;then 
		got_port=`grep "$progname" $tmp_netstat_out | grep "^$protocol" | grep "$interface" | awk '{print $4}' | awk -F: '{print $2}'`
		if test -z "$got_port" && test "$interface" = "0.0.0.0" ; then
			got_port=`grep "$progname" $tmp_netstat_out | grep "^$protocol" | grep ":::" | awk '{print $4}'|awk -F: '{print $4}'`
		fi
	else
		got_port=`grep "$progname" $tmp_netstat_out | grep "^$protocol" | grep "${interface}:$port " | awk '{print $4}'|awk -F: '{print $2}'`
		if test -z "$got_port" ; then
			if test "$interface" = "0.0.0.0" ; then
				got_port=`grep "$progname" $tmp_netstat_out | grep "^$protocol" | grep ":::$port " | awk '{print $4}'|awk -F: '{print $4}'`
			elif test "$interface" = "::ffff:127.0.0.1" ; then
				got_port=`grep "$progname" $tmp_netstat_out | grep "^$protocol" | grep "::ffff:127.0.0.1:$port " | awk '{print $4}'|awk -F: '{print $5}'`
			fi
		fi

	fi
	retcode=$?
	if test $retcode -ne 0 ; then
		if test -n "${socket_onerror[${i}]}" && test "${socket_onerror[${i}]}" = "warn" ; then
			echo "$description \(Nothing is listening on $protocol ${interface}:${port}\)!" >> $tmp_warning_file
		else
			echo "$description \(Nothing is listening on $protocol ${interface}:${port}\)!" >> $tmp_error_file
		fi
	else
		if test -z "$got_port" ; then
			if test -n "${socket_onerror[${i}]}" && test "${socket_onerror[${i}]}" = "warn" ; then
				echo "$description \(Nothing is listening on $protocol ${interface}:${port}\)!" >> $tmp_warning_file
			else
				echo "$description \(Nothing is listening on $protocol ${interface}:${port}\)!" >> $tmp_error_file
			fi
		else
			if test $port -ne 0 && test $port -ne $got_port ;then 
				if test -n "${socket_onerror[${i}]}" && test "${socket_onerror[${i}]}" = "warn" ; then
					echo "$description \(Nothing is listening on $protocol ${interface}:${port}\)!" >> $tmp_warning_file
				else
					echo "$description \(Nothing is listening on $protocol ${interface}:${port}\)!" >> $tmp_error_file
				fi
			else
				if test $port -eq 0 ; then
					echo "$description \($protocol ${interface}\)." >> $tmp_ok_file
				else
					echo "$description \($protocol ${interface}:${port}\)." >> $tmp_ok_file
				fi
			fi
		fi
	fi
        i=i+1
done

statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	statusid=$status_error
	message_str="ERROR: "`cat $tmp_error_file | tr "\n" " "`
fi
if test -s $tmp_warning_file ; then
	message_str="$message_str WARNING: "`cat $tmp_warning_file | tr "\n" " "`
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_ok_file ; then
	message_str="$message_str OK: `cat $tmp_ok_file | tr "\n" " "`"
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
