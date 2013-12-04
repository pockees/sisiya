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
### Check for CPUs
#################################################################################
### service id
serviceid=$serviceid_cpu
if test -z "$serviceid" ; then
	echo "$0 : serviceid_cpu is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="CPU"
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
### Sample output of the hpasmcli -s "show server" command :
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
##############################################################################################

tmp_file=`mktemp /tmp/tmp_${script_name}.XXXXXX`
tmp_ok_file=`mktemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_error_file=`mktemp /tmp/tmp_error_${script_name}.XXXXXX`

declare -i i=1

#Processor: 0 |  Name         : Intel Xeon |     Stepping     : 2 |      Speed        : 2400 MHz |       Bus          : 532 MHz |        Core         : 4 |      Thread       : 8 |      Socket       : 1 |     Level2 Cache : 1024 KBytes |    Level3 Cache : 12288 KBytes |   Status       : Ok |
##Processor: 1 |  Name         : Intel Xeon |     Stepping     : 2 |      Speed        : 2400 MHz |       Bus          : 532 MHz |        Core         : 4 |      Thread       : 8 |      Socket       : 2 |     Level2 Cache : 1024 KBytes |    Level3 Cache : 12288 KBytes |   Status       : Ok |Processor total  : 2 |Memory installed : 49152 MBytes |ECC supported    : Yes |
#
##Processor: 0 |  Name         : Intel Xeon |     Stepping     : 6 |      Speed        : 2333 MHz |       Bus          : 1333 MHz |       Core         : 2 |      Thread       : 2 |      Socket       : 1 |     Level2 Cache : 4096 KBytes |    Status       : Ok |
##Processor: 1 |  Name         : Intel Xeon |     Stepping     : 6 |      Speed        : 2333 MHz |       Bus          : 1333 MHz |       Core         : 2 |      Thread       : 2 |      Socket       : 2 |     Level2 Cache : 4096 KBytes |    Status       : Ok |Processor total  : 2 |Memory installed : 12288 MBytes |ECC supported    : Yes |
#

cmd_str="show server"
$hpasmcli_prog -s "$cmd_str" | awk ' NR > 3 && NF > 0 {if($0 ~ /^Processor:/) {printf "\n"};  printf "%s |",$0 } END {printf "\n"}' |grep "^Processor" > $tmp_file
retcode=$?
if test $retcode -eq 0 ; then
	cat $tmp_file | while read line
	do
		#name_str=`echo $line		| cut -d "|" -f 2 	| cut -d ":" -f 2`
		#stepping_str=`echo $line	| cut -d "|" -f 3 	| cut -d ":" -f 2`
		#speed_str=`echo $line		| cut -d "|" -f 4 	| cut -d ":" -f 2`
		#bus_str=`echo $line		| cut -d "|" -f 5 	| cut -d ":" -f 2`
		#core_str=`echo $line		| cut -d "|" -f 6 	| cut -d ":" -f 2`
		#thread_str=`echo $line		| cut -d "|" -f 7 	| cut -d ":" -f 2`
		#socket_str=`echo $line		| cut -d "|" -f 8 	| cut -d ":" -f 2`
		#l2cache_str=`echo $line		| cut -d "|" -f 9 	| cut -d ":" -f 2`
		#status_str=`echo $line		| cut -d "|" -f 10 	| cut -d ":" -f 2 |tr -d " "`
		status_str=`echo "$line" | sed -e "s/Status/\n/" | tail -n 1 | cut -d "|" -f 1 | cut -d ":" -f 2 | tr -d " "`
		if test "$status_str" != "Ok" ; then
			#echo "ERROR: The status of CPU #$i (${name_str}, stepping=${stepping_str}, speed=${speed_str}, bus=${bus_str}, core=${core_str}, thread=${thread_str}, socket=${socket_str}, level2 cache=${l2cache_str}) is not Ok (${status_str})!" >> $tmp_error_file
			echo "ERROR: $line" | tr "|" "," >> $tmp_error_file
		else
			#echo "OK: The status of CPU #$i (${name_str}, stepping=${stepping_str}, speed=${speed_str}, bus=${bus_str}, core=${core_str}, thread=${thread_str}, socket=${socket_str}, level2 cache=${l2cache_str}) is Ok." >> $tmp_ok_file
			echo "OK: $line" | tr "|" "," >> $tmp_ok_file
		fi 
		i=i+1
	done
else
	echo "ERROR: Error executing show servercommand! retcode=$retcode" >> $tmp_error_file
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
