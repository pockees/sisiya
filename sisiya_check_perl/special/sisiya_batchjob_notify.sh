#!/bin/bash
#
#    Copyright (C) Erdal Mutlu
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

#client_conf_file="$1"
base_dir="/opt/sisiya-client-checks"
send_message_prog="$base_dir/bin/sisiya_send_message.pl"
client_conf_file="$1"
expire="$2"
status_str="$3"
org_message="$4"
service_str="batchjob_notify"
if test ! -f $send_message_prog ; then
	echo "$0 : SisIYA send message program $send_message_prog does not exist!"
	exit 1
fi

message_str="$org_message"
data_message_str=""
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
echo "perl -I$base_dir ${send_message_prog} $service_str $status_str $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
perl -I$base_dir ${send_message_prog} $service_str $status_str $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
sleep 1
exit 0
###################################################################################################
