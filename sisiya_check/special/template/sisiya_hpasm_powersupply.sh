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
#################################################################################
### Check for powersupplies
#################################################################################
### service id
serviceid=$serviceid_powersupply
if test -z "$serviceid" ; then
	echo "$0 : serviceid_powersupply is not defined! Exiting..."
	exit 1
fi

##########################################################################
service_name="Powersupply"
##########################################################################

#######################################################################################
#######################################################################################
### This script uses the hp-health tools (hpasmcli) for checking various HP serevers'
### components, such as temperature, fans etc.
#######################################################################################
#######################################################################################
### HP management CLI for Linux
### default values
hpasmcli_prog=/sbin/hpasmcli
### end of the default values
##########################################################################
### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi


##############################################################################################
### Sample output of the hpasmcli -s "show powersupply" command :
#Power supply #1
#        Present  : Yes
#        Redundant: Yes
#        Condition: Ok
#        Hotplug  : Supported
#Power supply #2
#        Present  : Yes
#        Redundant: Yes
#        Condition: Ok
#        Hotplug  : Supported
##############################################################################################

tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

declare -i i=1

cmd_str="show powermeter"
str=`$hpasmcli_prog -s "$cmd_str" | grep "Power Reading" | tr -d " "|tr -d "\t" | cut -d ":" -f 2`
retcode=$?
if test $retcode -eq 0 ; then
	echo "OK: The current power reading is $str Watts." >> $tmp_ok_file
else
	echo "ERROR: Error executing show powermeter command! retcode=$retcode" >> $tmp_error_file
fi

cmd_str="show powersupply"
$hpasmcli_prog -s "$cmd_str" | grep "Condition" | tr -d " "|tr -d "\t" | cut -d ":" -f 2 > $tmp_file
retcode=$?
if test $retcode -eq 0 ; then
	n=`cat $tmp_file | wc -l`
	while test $i -le $n
	do
		status_str=`head --lines=$i $tmp_file | tail --lines=1`
		if test "$status_str" != "Ok" ; then
			echo "ERROR: The condition of powersupply $i is not Ok (${status_str})!" >> $tmp_error_file
		else
			echo "OK: The condition of powersupply $i is Ok." >> $tmp_ok_file
		fi 
		i=i+1
	done
else
	echo "ERROR: Error executing show powersupply command! retcode=$retcode" >> $tmp_error_file
fi

statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	statusid=$status_error
	message_str=`cat $tmp_error_file | tr "\n" " "` 
fi

if test -s $tmp_ok_file ; then
	message_str="$message_str`cat $tmp_ok_file | tr "\n" " "`"
fi

### clean up
for f in $tmp_file $tmp_ok_file $tmp_error_file
do
	rm -f $f
done
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
