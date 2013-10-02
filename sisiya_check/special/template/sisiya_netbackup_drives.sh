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
serviceid=$serviceid_netbackup_drives 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_netbackup_drives is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
tpconfig_prog=/usr/openv/volmgr/bin/tpconfig
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi


if test ! -x $tpconfig_prog ; then
	statusid=$status_error
	message_str="ERROR: tpconfig program [$tpconfig_prog] does not exist or is not executable!"
	exit 0
fi

### get the number of drives
total_drive_count=`$tpconfig_prog -dl |grep -i "drive name" | wc -l| awk '{print $1}'`
declare -i i=0 down_drive_count=0
while test $i -lt $total_drive_count
do
	state=`$tpconfig_prog -d | grep "^  ${i}" | awk '{print $6}'`
	if test "$state" = "DOWN" ; then
		down_drive_count=down_drive_count+1
	fi
	i=i+1
done


if test $total_drive_count -eq $down_drive_count ; then
	statusid=$status_error
	if test $total_drive_count -eq 0 ; then
		message_str="ERROR: The drive is in state DOWN!"
	else
		message_str="ERROR: All $total_drive_count drives are in state DOWN!"
	fi
elif test $down_drive_count = 0 ; then
	statusid=$status_ok
	if test $total_drive_count -eq 0 ; then
		message_str="OK: The drive is in state UP." 
	else
		message_str="OK: All $total_drive_count drives are in state UP." 
	fi
else
	statusid=$status_warning
	message_str="WARNING: $down_drive_count of total $total_drive_count drives" 
	if test $down_drive_count -eq 0 ; then
		message_str="$message_str is"
	else
		message_str="$message_str are"
	fi
 	message_str="$message_str in state DOWN!" 
fi
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
