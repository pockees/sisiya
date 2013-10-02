#!/bin/bash
#
# This script is used to send a message to the SisIYA server
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
##################################################################################
if test $# -ne 6 ; then
	echo "Usage: $0 config_file system_name service_id statusid expire message_str"
	echo "statusid: 1-Info, 2-OK, 4-Warning, 8-Error, 16-No Report, 32-Unavailable"
	echo "expire must be given in minutes"
	echo "message is of format <msg>message string part</msg><datamsg>data message part</datamsg>"
	exit 1
fi

config_file="$1"
system_name="$2"
serviceid="$3"
statusid="$4"
expire="$5"
message_str="$6"

if test ! -f $config_file ; then
	echo "$0 : SISIYA config file $config_file does not exist."
	exit 1
fi

# source the config file
. $config_file


if test ! -f $sisiya_functions ; then
	echo "$0 : SISIYA functions file $sisiya_functions does not exist!"
	exit 1
fi
### source the functions file
. $sisiya_functions
if test ! -x "$sisiyac_prog" ; then
	echo "$0 : SISIYA client program $sisiyac_prog does not exist."
	exit 1
fi

date_str=`echo_sisiya_date`
xml_message_str="<?xml version=\"1.0\" encoding=\"utf-8\"?><sisiya_messages><timestamp>${date_str}</timestamp><system><name>${system_name}</name><message><serviceid>${serviceid}</serviceid><statusid>${statusid}</statusid><expire>${expire}</expire><data>${message_str}</data></message></system></sisiya_messages>"

### replace \n with the space character
xml_message_str=`echo $xml_message_str | tr "\n" " "`

########################################################################################
# program	| Server     	| Port 		| Message Data
########################################################################################
#echo "$xml_message_str"
${sisiyac_prog}   $SISIYA_SERVER $SISIYA_PORT "${xml_message_str}"
########################################################################################
