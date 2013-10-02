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
serviceid=$serviceid_smart
if test -z "$serviceid" ; then
	echo "$0 : serviceid_smart is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
smartctl_prog=/usr/sbin/smartctl
number_of_disks=1
disk_name[0]="/dev/sda"
disk_warning[0]=31
disk_error[0]=34
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi
#################################################################################################################################################
# Return value:
#################################################################################################################################################
# Bit 0	: Command line did not parse.
# Bit 1	: Device open failed, device did not return an IDENTIFY DEVICE structure, or device is in a low-power mode (see '-n' option above).
# Bit 2	: Some SMART or other ATA command to the disk failed, or there was a checksum error in a SMART data structure (see '-b' option above).
# Bit 3	: SMART status check returned "DISK FAILING".
# Bit 4	: We found prefail Attributes <= threshold.
# Bit 5	: SMART status check returned "DISK OK" but we found that some (usage or prefail) Attributes have been <= threshold at some time in the past.
# Bit 6	: The device error log contains records of errors.
# Bit 7	: The device self-test log contains records of errors. [ATA only] Failed self-tests outdated by a newer successful extended self-test are ignored.
# To test within the shell for whether or not the different bits are turned on or off, you can use the following type of construction (this is bash syntax):
#
# smartstat=$(($? & 8))
# This looks at only at bit 3 of the exit status $? (since 8=2^3). The shell variable $smartstat will be nonzero if SMART status check returned "disk failing" 
# and zero otherwise. This bash script prints all status bits:
#
# status=$?
# for ((i=0; i<8; i++)); do
# 	echo "Bit $i: $((status & 2**i && 1))"
# done
#################################################################################################################################################

tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

str=`$smartctl_prog -h 2>/dev/null `
if test $? -ne 127 ; then
	declare -i i=0
	while test $i -lt $number_of_disks
	do
		#str=`$smartctl_prog -a -d ata ${disk_name[$i]} 2>/dev/null `
		str=`$smartctl_prog -H -d ata ${disk_name[$i]} 2>/dev/null `
		retcode=$?
		if test $retcode -eq 0 || test $retcode -eq 32 ; then
			temp=`$smartctl_prog -a -d ata ${disk_name[$i]}	| grep "Temperature_Celsius" | awk '{print $10}'`
			info_str=`$smartctl_prog -H ${disk_name[$i]} 		| grep "^SMART Health"`
			info_str="$info_str `$smartctl_prog -a -d ata ${disk_name[$i]} | grep "^Device Model:"`"
			info_str="$info_str `$smartctl_prog -a -d ata ${disk_name[$i]} | grep "^Serial Number:"`"
			info_str="$info_str `$smartctl_prog -a -d ata ${disk_name[$i]} | grep "^Firmware Version:"`"
			info_str="$info_str `$smartctl_prog -a -d ata ${disk_name[$i]} | grep "^User Capacity:"`"
			if test $temp -ge ${disk_error[$i]} ; then
				echo "ERROR: $temp C >= ${disk_error[$i]} C on ${disk_name[$i]} $info_str!" >> $tmp_error_file
			elif test $temp -ge ${disk_warning[$i]} ; then
				echo "WARNING: $temp C >= ${disk_warning[$i]} C on ${disk_name[$i]} $info_str!" >> $tmp_warning_file
			else
				echo "OK: $temp C on ${disk_name[$i]} $info_str." >> $tmp_ok_file
			fi
		else
			echo "ERROR: ${disk_name[$i]} : $str" >> $tmp_error_file
		fi
		i=i+1
	done
else
	echo "ERROR: Could find the $smartctl_prog command!" >> $tmp_error_file
fi
statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	message_str=`cat $tmp_error_file | tr "\n" " "` 
	statusid=$status_error
fi

if test -s $tmp_warning_file ; then
	message_str="$message_str`cat $tmp_warning_file | tr "\n" " "`" 
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_ok_file ; then
	message_str="$message_str`cat $tmp_ok_file | tr "\n" " "`"
fi

for f in $tmp_ok_file $tmp_warning_file $tmp_error_file
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
