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
serviceid=$serviceid_raid
if test -z "$serviceid" ; then
	echo "$0 : serviceid_raid is not defined! Exiting..."
	exit 1
fi
##########################################################################
### HP Array Configuration Utility Software
### default values
raid_cli_prog=/usr/sbin/hpacucli
### end of the default values

########################################################################################
### list physical drives
###hpacucli ctrl slot=1 physicaldrive all show detail
########################################################################################
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

which $raid_cli_prog > /dev/null 2>&1
if test $? -ne 0 ; then
	echo -n "WARNING: $raid_cli_prog command not found! " >> $tmp_warning_file
else
	### check RAID's general status and save the detailed information in the info file
	cmd_str="$raid_cli_prog ctrl all show status"
	$cmd_str > $tmp_log_file
	retcode=$?
	if test $retcode -eq 0 ; then
		number_of_ctrl=`grep "in Slot" $tmp_log_file			| wc -l`
		ctrl_ids=`cat $tmp_log_file | awk '{print $6}' | tr "\n" " "`
		for ctrl_id in $ctrl_ids
		do
			cmd_str="$raid_cli_prog ctrl slot=$ctrl_id show detail"
			$cmd_str > $tmp_log_file
			retcode=$?
			if test $retcode -eq 0 ; then
				if test -s $tmp_log_file ; then
					ctrl_status=`grep "Controller Status" $tmp_log_file		| cut -d ":" -f 2 | tr -d " "`
					cache_status=`grep "Cache Status" $tmp_log_file 		| cut -d ":" -f 2 | tr -d " "`
					battery_status=`grep "Battery/Capacitor Status" $tmp_log_file 	| cut -d ":" -f 2 | tr -d " "`
					if test "$ctrl_status" != "OK" ; then
						echo "ERROR: Controller status ($ctrl_status) for the controller in slot=${ctrl_id} is not OK." >> $tmp_error_file
					else
						echo "OK: Controller status for the controller in slot=${ctrl_id} is OK." >> $tmp_ok_file
					fi
					if test "$cache_status" != "OK" ; then
						echo "ERROR: Cache status ($cache_status) for the controller in slot=${ctrl_id} is not OK!" >> $tmp_error_file
					else
						echo "OK: Cache status for the controller in slot=${ctrl_id} is OK." >> $tmp_ok_file
					fi
					if test -n "$battery_status" ; then
						case "$battery_status" in
							"OK")
								echo "OK: Battery/Capasitor status for the controller in slot=${ctrl_id} is OK." >> $tmp_ok_file
							;;
							"Recharging")
								echo "WARNING: Battery/Capasitor status for the controller in slot=${ctrl_id} is Recharging!" >> $tmp_warning_file
							;;
							*)
								echo "ERROR: Battery/Capasitor status ($battery_status) for the controller in slot=${ctrl_id} is not OK!" >> $tmp_error_file
							;;
						esac
					fi
					echo "Info: "			>> $tmp_info_file
					cat $tmp_log_file | tr "\n" " " >> $tmp_info_file
					#echo ""			>> $tmp_info_file
				fi
			else
				echo "ERROR: There was a problem executing $cmd_str command!"  	>> $tmp_error_file
			fi
			total_logical_drives=`$raid_cli_prog ctrl slot=$ctrl_id logicaldrive all show |grep logicaldrive|wc -l `
			declare -i j=1
			while test $j -le $total_logical_drives
			do
				### check logical drive status
				$raid_cli_prog ctrl slot=$ctrl_id logicaldrive $j show > $tmp_log_file
				raid_level=`cat $tmp_log_file			| grep "Fault Tolerance"|cut -d ":" -f 2`
				logicaldrive_size=`cat $tmp_log_file		| grep "  Size"|cut -d ":" -f 2`
				logicaldrive_stripe_size=`cat $tmp_log_file	| grep "Stripe Size"|cut -d ":" -f 2`
				mount_points=`cat $tmp_log_file			| grep "Mount Points"|cut -d ":" -f 2`
				logicaldrive_status=`cat $tmp_log_file		| grep "  Status"|cut -d ":" -f 2|tr -d " "`
				multidomain_status=`cat $tmp_log_file		| grep "MultiDomain Status"|cut -d ":" -f 2|tr -d " "`
				if test "$logicaldrive_status" = "OK" ; then
					echo "OK: Logical drive $j (with RAID level=${raid_level}, size=${logicaldrive_size}, stripe size=${logicaldrive_stripe_size}, mount points=${mount_points}, multi domain status=$multidomain_status) in controller slot $ctrl_id is OK." >> $tmp_ok_file
				else
					str=`echo $logicaldrive_status | grep "Recovering"`
					if test -n "$str" ; then
						echo "WARNING: Logical drive $j (with RAID level=${raid_level}, size=${logicaldrive_size}, stripe size=${logicaldrive_stripe_size}, mount points=${mount_points},  multi domain status=$multidomain_status) in controller slot $ctrl_id has status $logicaldrive_status!" >> $tmp_warning_file
					else
						echo "ERROR: Logical drive $j (with RAID level=${raid_level}, size=${logicaldrive_size}, stripe size=${logicaldrive_stripe_size}, mount points=${mount_points},  multi domain status=$multidomain_status) in controller slot $ctrl_id has status $logicaldrive_status!" >> $tmp_error_file
					fi
				fi
				### check physical drive status on this logical drive 
				$raid_cli_prog ctrl slot=$ctrl_id logicaldrive $j show | grep "physicaldrive" > $tmp_log_file
				total_physical_drives=`cat $tmp_log_file | wc -l | tr -d " "`
				faulty_physical_drives=`cat $tmp_log_file | cut -d "," -f 4 | cut -d ")" -f 1 | tr -d " " | grep -v "OK" | wc -l`
				if test $faulty_physical_drives -ne 0 ; then
					### find out which drives have problems and their location (bay number)
					cat $tmp_log_file | grep -v "OK)" | while read line
					do
						driver_bay=`echo $line 		| cut -d "," -f 1 | cut -d ":" -f 5 | cut -d " " -f 2`
						driver_status=`echo $line 	| cut -d "," -f 4 | cut -d ")" -f 1 | tr -d " "`
						if test "$driver_status" = "Rebuilding" ; then
							echo "WARNING: The hard disk (controller in slot=${ctrl_id}, logical drive=${j}) in the $driver_bay bay has status ${driver_status}!" >> $tmp_warning_file
						else
							echo "ERROR: The hard disk (controller in slot=${ctrl_id}, logical drive=${j}) in the $driver_bay bay has status ${driver_status}!" >> $tmp_error_file
						fi
					done
					echo "ERROR: $faulty_physical_drives out of $total_physical_drives physical drives for controller in slot=$ctrl_dir are not OK!" >> $tmp_error_file
				else
					echo "OK: All $total_physical_drives physical drives in the controller slot=$ctrl_id and logical drive=$j are OK." >> $tmp_ok_file
				fi
				j=j+1
			done
		done
	else
		echo "ERROR: There was a problem executing $cmd_str command!"  	>> $tmp_error_file
	fi

	### check individual logical and physical drives
	$raid_cli_prog ctrl all show config > $tmp_log_file
	if test -s $tmp_log_file ; then
		total_logical_drives=`grep "logicaldrive" $tmp_log_file	| wc -l | tr -d " "`
		total_physical_drives=`grep "physicaldrive" $tmp_log_file	| wc -l | tr -d " "`
		faulty_logical_drive_count=`grep "logicaldrive" $tmp_log_file	| cut -d "," -f 3 | cut -d ")" -f 1 | tr -d " " | grep -v "OK" | wc -l`
		faulty_physical_drive_count=`grep "physicaldrive" $tmp_log_file	| cut -d "," -f 4 | cut -d ")" -f 1 | tr -d " " | grep -v "OK" | wc -l`
		if test $faulty_logical_drive_count -ne 0 ; then
			echo "ERROR: $faulty_logical_drive_count out of $total_logical_drives logical drives are not OK!" >> $tmp_error_file
		else
			echo "OK: All $total_logical_drives logical drives are OK." >> $tmp_ok_file
		fi

		if test $faulty_physical_drive_count -ne 0 ; then
			### find out which drives have problems and their location (bay number)
			cat $tmp_log_file | grep "physicaldrive" | grep -v "OK)" | while read line
			do
				driver_bay=`echo $line 		| cut -d "," -f 1 | cut -d ":" -f 5 | cut -d " " -f 2`
				driver_status=`echo $line 	| cut -d "," -f 4 | cut -d ")" -f 1 | tr -d " "`
echo "driver_status=[$driver_status]"
				if test "$driver_status" = "Rebuilding" ; then
					echo "WARNING: The hard disk in the $driver_bay bay has status ${driver_status}!" >> $tmp_warning_file
				else
					echo "ERROR: The hard disk in the $driver_bay bay has status ${driver_status}!" >> $tmp_error_file
				fi
			done

			echo "ERROR: $faulty_physical_drive_count out of $total_physical_drives physical drives are not OK!" >> $tmp_error_file
		else
			echo "OK: All $total_physical_drives physical drives are OK." >> $tmp_ok_file
		fi
	else
		echo "ERROR: There was a problem executing $raid_cli_prog command! "  	>> $tmp_error_file
	fi
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
