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
serviceid=$serviceid_sshattack
if test -z "$serviceid" ; then
	echo "$0 : serviceid_sshattack is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
log_file=/var/log/secure
number_of_strings=4
strings[0]="illegal"
strings[1]="Invalid user"
strings[2]="failed password for"
strings[3]="POSSIBLE BREAKIN ATTEMPT"
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
ips_file=`maketemp /tmp/tmp_ips_${script_name}.XXXXXX`

if test ! -f $log_file ; then
	statusid=$status_warning
	message_str="SSH log file$log_file does not exist!"
else
	statusid=$status_ok
	cat $log_file | while read line
	do
		declare -i i=0
		whil test $i -lt $number_of_strings
		do	
			str=`echo $line | grep -i "${strings[$i]}"`
			if test -n "$str" ; then
				### try our best to get the IP address of the client
				client_ip=`echo $line | cut -d ":" -f 7 | awk '{print $1}'`
				str=`echo $line | grep  "Failed"`
				if test -z "$str" ; then
					user_name=`echo $line | awk '{print $8}'`
				else
					user_name=`echo $line | awk '{print $11}'`
				fi
				str=`echo $client_ip | grep ":"`
				if test -n "$str" ; then
					client_ip=`echo $str | cut -d ":" -f 4`
				fi
				count=`echo $client_ip | tr "." "\n" | wc -l|awk '{print $1}'`
				if test -z "$count" || test $count -ne 4 ; then
					echo "UNKNOWN" >> $tmp_file
				else
					echo "$client_ip" >> $tmp_file
				fi

			fi
		done
	done
fi

if -s $tmp_file ; then
	statusid=$status_error
	message_str="This server is under attack from the following IPs : "`sort $tmp_file | uniq | tr "\n" " "` 
else
	statusid=$status_ok
	message_str="As far as I know this server is not under attack."
fi

#cat $tmp_file
for f in $tmp_file $ips_file
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
