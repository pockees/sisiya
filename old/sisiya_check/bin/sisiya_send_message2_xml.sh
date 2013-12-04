#!/bin/bash
#
# This script is used to send the messages from a file to the SISIYA server
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
#################################################################################
if test $# -lt 2 ; then
	echo "Usage: $0 config_file messages_file"
	echo "The messages_file contains the messages to be send."
	exit 1
fi

config_file=$1
messages_file=$2

for f in $config_file $messages_file 
do
	if test ! -f $f ; then
		echo "$0 : File $f does not exist. Exiting..."
		exit 1
	fi
done
# source the config file
. $config_file

if test ! -f $sisiya_functions ; then
	echo "$0 : SISIYA functions file $sisiya_functions does not exist!"
	exit 1
fi
### source the functions file
. $sisiya_functions
### Solaris does not allow to change the PATH for root
if test "$sisiya_osname" = "SunOS" ; then
	PATH=$PATH:/usr/local/bin
	export PATH
fi


if test ! -x "$sisiyac_prog" ; then
	echo "$0 : SISIYA client program $sisiyac_prog does not exist."
	exit 1
fi


date_str=`echo_sisiya_date`
tmp_file=`maketemp /tmp/sisiya_send_message_tmp_XXXXXX`
if test ! -f $tmp_file ; then
	echo "$0 : Cannot create tmp file $tmp_file ! Exiting..."
	exit 1
fi
echo '<?xml version="1.0" encoding="utf-8"?>'	>> $tmp_file
echo '<sisiya_messages>'			>> $tmp_file
echo "<timestamp>${date_str}</timestamp>"	>> $tmp_file
cat $messages_file | cut -d " " -f 1 | sort | uniq | while read system_name
do
	echo "<system><name>${system_name}</name>"	>> $tmp_file
	cat $messages_file | grep "^$system_name " | while read -r line
	do
		#system_name=`echo $line	| cut -d " " -f 1`
		serviceid=`echo $line	| cut -d " " -f 2`
		statusid=`echo $line	| cut -d " " -f 3`
		expire=`echo $line	| cut -d " " -f 4`
		str="$system_name $serviceid $statusid $expire"
		message_str=`echo $line	| sed -e "s/^$str //"`
		#str="${SP}${serviceid}${SP}${statusid}${SP}${system_name}${SP}${date_str}${SP}${expire}${SP}${message_str}"
	
		### what about <msg></msg> withing <data>   str="<message><serviceid>${serviceid}</serviceid><statusid>${statusid}</statusid><expire>${expire}</expire><data>${message_str}</data></message>"
		str="<message><serviceid>${serviceid}</serviceid><statusid>${statusid}</statusid><expire>${expire}</expire><data>${message_str}</data></message>"
		echo "$str" >> $tmp_file
	done
	echo '</system>'			>> $tmp_file
done
echo '</sisiya_messages>'			>> $tmp_file

########################################################################################
# prg 		| Server    	| Port 		| MessageDataFile
########################################################################################
${sisiyac_prog}  $SISIYA_SERVER $SISIYA_PORT $tmp_file
rm -f $tmp_file
########################################################################################
