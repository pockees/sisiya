#!/bin/bash
#
# This script is used to send a message to the SISIYA server
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

if test $# -lt 6 ; then
	echo "Usage: $0 config_file host_name service_id statusid expire message_part1 message_part2 ... message_partN"
	echo "statusid: 0-Info, 1-OK, 2-Warning and 3-Error"
	echo "expire must be given in minutes"
	exit 1
fi

config_file=$1
host_name=$2
serviceid=$3
statusid=$4
expire=$5
shift; shift; shift; shift; shift;

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

message_str="${SP}${serviceid}${SP}${statusid}${SP}${host_name}${SP}`echo_sisiya_date`${SP}${expire}${SP}${1}"
shift
while [ -n "${1}" ]
do
	message_str="${message_str} ${1}"
	shift
done

### replace \n with the space character
message_str=`echo $message_str|tr "\n" " "`

########################################################################################
# prg 		| Server     	| Port 		| Message Data
########################################################################################
${sisiyac_prog}   $SISIYA_SERVER $SISIYA_PORT "${message_str}"
########################################################################################
