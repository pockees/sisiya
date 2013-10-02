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
### service id
serviceid=$serviceid_raid
if test -z "$serviceid" ; then
	echo "$0 : serviceid_raid is not defined! Exiting..."
	exit 1
fi
##########################################################################
### LSI Logic MegaRAID configuration utility
### default values
raid_cli_prog="/usr/local/bin/megarc"
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi

tmp_log_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_info_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

for f in $tmp_log_file $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_info_file
do
	rm -f $f
	touch $f
done

declare -i i

echo "Info: "			>> $tmp_info_file
which $raid_cli_prog > /dev/null 2>&1
if test $? -ne 0 ; then
	echo -n "WARNING: $raid_cli_prog command not found! " >> $tmp_warning_file
else
	cmd_str="$raid_cli_prog -AllAdpInfo | grep AdapterNo -A20 | grep -v AdapterNo | wc -l"
	#nadapters=`$cmd_str`
	nadapters=`$raid_cli_prog -AllAdpInfo | grep AdapterNo -A20 | grep -v AdapterNo | wc -l`
	retcode=$?
	if test $retcode -eq 0 ; then
		echo "Number of MegaRAID adapters is ${nadapters}." >> $tmp_info_file 
	else
		echo "ERROR: There was a problem executing $cmd_str command!"  	>> $tmp_error_file
	fi

	i=0
	while test $i -lt $nadapters
	do
		### get controller info
		cmd_str="$raid_cli_prog -ctlrInfo -a${i} | grep -v \"\*\*\*\" |grep \"Information of Adapter\" -A20|grep -v \"Information of Adapter\""
		$raid_cli_prog -ctlrInfo -a${i} | grep -v "\*\*\*" |grep "Information of Adapter" -A20|grep -v "Information of Adapter" | tr "\n" " " >> $tmp_info_file

		$raid_cli_prog -ldInfo -a${i} -LAll | grep "Logical Drive : " >> $tmp_log_file
		total_logical_drive_count=`cat $tmp_log_file	| wc -l`
		faulty_logical_drive_count=`cat $tmp_log_file	| grep -v "OPTIMAL" | wc -l`
		if test $faulty_logical_drive_count -ne 0 ; then
			echo "ERROR: $faulty_logical_drive_count out of $total_logical_drive_count logical drives is not in state OPTIMAL!" >> $tmp_error_file
		else
			echo "OK: All $total_logical_drive_count logical drives are in OPTIMAL state." >> $tmp_ok_file
		fi

		### get logical drive count
		str=`$raid_cli_prog -LogPhysInfo -a${i} | grep "Logical drive"`
		#nlogical=`echo $str | grep "Logical drive" |cut -d ":" -f 2| awk '{print $2}'`
		nlogical=`$raid_cli_prog -LogPhysInfo -a${i} | grep "Total Logical Drive" | cut -d "-" -f 2`
		echo "Number of logical drives on cotnroller $i is $nlogical." >> $tmp_info_file
		declare -i j=0
		while test $j -lt $nlogical
		do
			str=`$raid_cli_prog -LogPhysInfo -a$i | grep "Logical drive"`
			ldrive_raid_level=`echo $str | grep "Logical drive" |cut -d ":" -f 2| awk '{print $2}'`
			ldrive_status=`$raid_cli_prog  -ldInfo -a$i -L$j | grep "Logical Drive :" |cut -d ":" -f 5 | tr -d " " | tr -d "\r"`
#echo "ldrive_status=[$ldrive_status]"
			case "$ldrive_status" in
				"OPTIMAL")
					echo "OK: The status of the logical drive $j RAID level $ldrive_raid_level on controller $i is OPTIMAL." >> $tmp_ok_file
				;;
				*)
					echo "ERROR: The status of the logical drive $j RAID level $ldrive_raid_level on controller $i is unknown=$ldrive_status." >> $tmp_error_file
				;;
			esac
			### check disk status
			$raid_cli_prog -ldInfo -a$i -L$j	| tr -d "\t"	| grep "^${j}" > $tmp_log_file
			total_physical_drive_count=`cat $tmp_log_file	| wc -l`
			faulty_physical_drive_count=`cat $tmp_log_file	| grep -v "ONLINE" | wc -l`
			if test $faulty_physical_drive_count -ne 0 ; then
				### find out which drives have problems and their location (bay number)
				cat $tmp_log_file | grep -v "ONLINE" | while read line
				do
					channel_str=`echo $line		| awk '{print $1}'`	
					target_str=`echo $line		| awk '{print $2}'`
					driver_status=`echo $line	| awk '{print $5}' | tr -d "\r"`
					#echo "channel_str=[$channel_str] target_str=[$target_str] status_str=[$status_str]"
					echo "ERROR: The hard disk on logical drive $j channel $channel_str and target $target_str has status ${driver_status}!" >> $tmp_error_file
				done
			else
				echo "OK: All $total_physical_drive_count physical drives for logical drive $j are ONLINE." >> $tmp_ok_file
			fi
			j=j+1
		done	
		i=i+1
	done
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

if test -s $tmp_info_file ; then
	message_str="$message_str`cat $tmp_info_file | tr "\n" " "`"
fi

for f in $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_info_file $tmp_log_file
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
