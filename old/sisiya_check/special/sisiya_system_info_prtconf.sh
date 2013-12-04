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
cli_prog="prtconf"
### end of the default values
########################################################################
### The output of the following command : prtconf
########################################################################
#System Model: IBM,9111-520
#Machine Serial Number: 65FC5DE
#Processor Type: PowerPC_POWER5
#Number Of Processors: 1
#Processor Clock Speed: 1499 MHz
#CPU Type: 64-bit
#Kernel Type: 64-bit
#LPAR Info: 1 65-FC5DE
#Memory Size: 3792 MB
#Good Memory Size: 3792 MB
#Platform Firmware level: Not Available
#Firmware Version: IBM,SF235_185
#Console Login: enable
#Auto Restart: true
#Full Core: false
#...
#
###############################################################################
### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi


#tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
$cli_prog | awk ' NR < 12 && NF > 0 {printf "%s,",$0 } END {printf "\n"}'
###################################################################################################
