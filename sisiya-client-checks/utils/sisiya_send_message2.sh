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
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
#
#######################################################################################
if test $# -ne 5 ; then
	echo "Usage : $0 system_name serviceid statusid expire message"
	echo "expire must be specified in minutes. expire=0 means not to expire"
	exit 1
fi

base_dir="/usr/share/sisiya-client-checks"
conf_dir="/etc/sisiya/sisiya-client-checks"
send_message_prog="$base_dir/utils/sisiya_send_message2.pl"
system_name="$1"
service_id="$2"
status_id="$3"
expire="$4"
org_message="$5"
if test ! -f $send_message_prog ; then
	echo "$0 : SisIYA send message program $send_message_prog does not exist!"
	exit 1
fi

message_str="$org_message"
data_message_str=""
###################################################################################################
perl -I$conf_dir ${send_message_prog} $system_name $service_id $status_id $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
sleep 1
exit 0
###################################################################################################
