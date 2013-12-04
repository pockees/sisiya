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
#######################################################################################
### Check for fan speeds
#######################################################################################
### service id
#######################################################################################
serviceid=$serviceid_fanspeed
if test -z "$serviceid" ; then
	echo "$0 : serviceid_fanspeed is not defined! Exiting..."
	exit 1
fi

#######################################################################################
service_name="Fan speed"
#######################################################################################

#######################################################################################
#######################################################################################
### default values
### HP management CLI for Linux
hpasmcli_prog=/sbin/hpasmcli
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi

##############################################################################################
### Sample output of the hpasmcli -s "show fans" command :
#	  Fan  Location        Present Speed  of max  Redundant  Partner  Hot-pluggable
#	---  --------        ------- -----  ------  ---------  -------  -------------
#	#1   I/O_ZONE        Yes     NORMAL  45%     Yes        0        Yes
#	#2   I/O_ZONE        Yes     NORMAL  45%     Yes        0        Yes
#	#3   PROCESSOR_ZONE  Yes     NORMAL  41%     Yes        0        Yes
#	#4   PROCESSOR_ZONE  Yes     NORMAL  36%     Yes        0        Yes
#	#5   PROCESSOR_ZONE  Yes     NORMAL  36%     Yes        0        Yes
#	#6   PROCESSOR_ZONE  Yes     NORMAL  36%     Yes        0        Yes
#
##############################################################################################
### or another sample output with some fans which are not present
##############################################################################################
#	Fan  Location        Present Speed  of max  Redundant  Partner  Hot-pluggable
#	---  --------        ------- -----  ------  ---------  -------  -------------
#	#1   SYSTEM          Yes     NORMAL  35%     No         N/A      No
#	#2   SYSTEM          No      -       N/A     No         N/A      No
#	#3   SYSTEM          Yes     NORMAL  35%     No         N/A      No
#	#4   SYSTEM          No      -       N/A     No         N/A      No
#	#5   CPU#1           Yes     NORMAL  35%     N/A        N/A      No
#	#6   CPU#2           No      -       N/A     N/A        N/A      No
##############################################################################################

tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

cmd_str="show fans"
$hpasmcli_prog -s "$cmd_str" > $tmp_file
retcode=$?
if test $retcode -eq 0 ; then
	cat $tmp_file | grep "^#" | while read line
	do
		is_available=`echo $line | awk '{print $3}'`
		if test "$is_available" = "No" ; then
			i=i+1
			continue
		fi

		fan_name=`echo $line		| awk '{print $2}'`
		fan_number=`echo $line		| awk '{print $1}'`
		fan_speed_status=`echo $line	| awk '{print $4}'`
		fan_value=`echo $line		| awk '{print $5}' | cut -d "%" -f 1`

		if test "$fan_speed_status" != "NORMAL" ; then
			echo "ERROR: The speed of for the $fan_number $fan_name fan is ${fan_value}% and ${fan_speed_status} != NORMAL!" >> $tmp_error_file
		else
			echo "OK: The speed of the $fan_number $fan_name fan is ${fan_value} %." >> $tmp_ok_file
		fi
	done
else
	echo "$error_str ERROR: Error executing $hpasmcli_prog -s \"$cmd_str\" command retcode=$retcode!" >> $tmp_error_file
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
