#!/bin/bash
#
# This script gets information about the server.
#
#    Copyright (C) 2009  Erdal Mutlu
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
if test $# -ne 1 ; then
	echo "Usage : $0 sisiya_client.conf"
	exit 1
fi

client_conf_file=$1

if test ! -f $client_conf_file ; then
	echo "$0 : SISIYA client configuration file $client_conf_file does not exist!"
	exit 1
fi

script_name=`basename $0`
sisiya_osname=`uname -s`
### source the config file
. $client_conf_file
###
module_conf_file="${sisiya_host_dir}/`echo $script_name | awk -F. '{print $1}'`.conf"

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
#######################################################################################
### the default values
### HP management CLI for Linux
cli_prog="hpasmcli"
### end of the default values
########################################################################
### The output of the following command : hpasmcli -s "show server"
########################################################################
#System        : ProLiant DL380 G5
#Serial No.    : CZC7321M4B      
#ROM version   : P56 05/18/2009
#iLo present   : Yes
#Embedded NICs : 2
#	NIC1 MAC: 00:1b:78:96:72:a8
#	NIC2 MAC: 00:1b:78:96:72:a6
#
#Processor: 0
#	Name         : Intel Xeon
#	Stepping     : 6
#	Speed        : 2333 MHz
#	Bus          : 1333 MHz
#	Core         : 2
#	Thread       : 2
#	Socket       : 1
#	Level2 Cache : 4096 KBytes
#	Status       : Ok
#
#Processor: 1
#	Name         : Intel Xeon
#	Stepping     : 6
#	Speed        : 2333 MHz
#	Bus          : 1333 MHz
#	Core         : 2
#	Thread       : 2
#	Socket       : 2
#	Level2 Cache : 4096 KBytes
#	Status       : Ok
#
#Processor total  : 2
#
#Memory installed : 20480 MBytes
#ECC supported    : Yes
#
###############################################################################
### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi


#tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
$cli_prog -s "show server" | awk ' NR < 7 && NF > 0 {printf "%s ",$0 } END {printf "\n"}'|sed -e "s/   / /g" | sed -e "s/   / /g"

#cmd_str="show server"
#$hpasmcli_prog -s "show server" > $tmp_file
#retcode=$?
#if test $retcode -eq 0 ; then
#	system_str=`grep "^System" 		$tmp_file | cut -d ":" -f 2`
#	serial_no=`grep "^Serial No" 		$tmp_file | cut -d ":" -f 2`
#	rom_version_str=`grep "^ROM version" 	$tmp_file | cut -d ":" -f 2`
##	ilo_present_str=`grep "^iLo present" 	$tmp_file | cut -d ":" -f 2`
#	echo "System: ${system_str}, serial no=${serial_no}, ROM version=${rom_version_str}, iLO present=${ilo_present_str} "
#else
#	echo ""
#fi
###################################################################################################
