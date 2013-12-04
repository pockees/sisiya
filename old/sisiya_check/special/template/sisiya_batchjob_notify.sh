#!/bin/bash
#
#    Copyright (C) 2003  Erdal Mutlu
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
if test $# -ne 4 ; then
	echo "Usage : $0 sisiya_client.conf expire status message"
	echo "expire must be specified in minutes. expire=0 means not to expire"
	echo "status=error,warning,ok,info"
	exit 1
fi

client_conf_file=$1
expire=$2
status=$3
org_message=$4
if test ! -f $client_conf_file ; then
	echo "$0 : SisIYA client configuration file $client_conf_file does not exist!"
	exit 1
fi

script_name=`basename $0`
sisiya_osname=`uname -s`
### source the config file
. $client_conf_file
#######################################################################################
### service id
serviceid=$serviceid_batchjob_notify  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_batchjob_notify is not defined! Exiting..."
	exit 1
fi
##########################################################################
##########################################################################

message_str=$org_message
case "$status" in
	"error")
		statusid=$status_error
	;;
	"warning")
		statusid=$status_warning
	;;
	"ok")
		statusid=$status_ok
	;;
	"info")
		statusid=$status_info
	;;
	*)
		statusid=$status_warning
		message_str="WARNING: The status=$status must be error, warning, ok or info! $org_message"
esac
data_message_str=""
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
#if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	sleep 1
	#exit $?
	### we must not disdurb NetBackup
	exit 0
#else
#	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
#fi
###################################################################################################
