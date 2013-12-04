#!/bin/bash
#
# This script is modiefed, but not tested!!!!!!!!!
# This script checks if there was an update for system within the
# specified interval of minutes. if there was not, then it sends a 
# message describing the error.
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
#
#################################################################################
if test $# -ne 1 ; then
	echo "Usage : $0 sisiya_server_checks.conf"
	exit 1
fi

conf_file=$1

if test ! -f "$conf_file" ; then
	echo "$0 : SisIYA server checks configuration file $conf_file does not exist!"
	exit 1
fi

### source the config file
. $conf_file

for f in "$sisiya_client_conf_file" "$sisiya_functions"
do
	if test ! -f $f ; then
		echo "$0 : File $f does not exist! Exiting..."
		exit 1
	fi
done

### source the client config file
. $sisiya_client_conf_file 

### source the functions file
. $sisiya_functions

tmp_file=`maketemp ${sisiya_server_checks_tmp_dir}/sisiya_check_expired_mysql.XXXXXX`
if test ! -f $tmp_file ; then
	echo "Cannot make a tmp file $tmp_file"
	exit 1
fi
data_message_str=""
##########################################################################
sql_str="select a.hostname,b.serviceid,b.statusid,b.updatetime,b.expires from systems as a left join systemservicestatus as b on a.id=b.systemid where a.active='t'"
psql -t -U $db_user -d $db_name  -c "$sql_str" | grep "|" | while read -r line
do
	#system=`echo $line | awk -F "|" '{print $1}'`
	#status=`echo $line | awk -F "|" '{print $3}' | awk '{print $2}'`
	system=`echo $line	| cut -d "|" -f 1 | tr -d " "`
	status=`echo $line	| cut -d "|" -f 3 | tr -d " "`
	if test -z "$status" ; then
		serviceid=$serviceid_system  
		statusid=$status_unavailable
		expire=0
		message_str="There is no response from this service!"
		#${send_message_prog} $client_conf_file $system $serviceid $statusid "$message_str"
		echo "$system $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $tmp_file
		continue
	fi
	serviceid=`echo $line	| awk -F "|" '{print $2}' | awk '{print $2}'`
	str=`echo $line 	| awk -F "|" '{print $4}'`
	str1=`echo $str 	| awk '{print $1}'`
	str2=`echo $str 	| awk '{print $2}'`
	str="$str1$str2"
	expire=`echo $line	| awk -F "|" '{print $5}' | awk '{print $2}'`
	if test $expires -eq 0 ; then
		message_str="This service=$serviceid never expires."
	else
		retcode=`is_expired $str $expire`
		if test $retcode -eq 0 ; then
			message_str="The service check is valid"
		else
			statusid=$status_unavailable
			message_str="The service check expired! It was valid for $expire minute"
			if test $expires -eq 1 ; then
				message_str="${message_str}."
			else
				message_str="${message_str}s."
			fi
			### set expires to 0 => do not expire
			expires=0
			#$send_message_prog $client_conf_file $system $serviceid $statusid $expire "$message_str"
			echo "$system $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $tmp_file
		fi
	fi
done
### now send all messages at once
${send_message2_prog} $sisiya_client_conf_file $tmp_file
rm -f $tmp_file
