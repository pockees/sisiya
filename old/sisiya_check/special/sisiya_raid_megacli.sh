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
### LSI Logic MegaRAID megacli configuration utility
### default values
raid_cli_prog="/opt/MegaRAID/MegaCli/MegaCli64"
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

which $raid_cli_prog > /dev/null 2>&1
if test $? -ne 0 ; then
	echo -n "WARNING: $raid_cli_prog command not found! " >> $tmp_warning_file
else
	cmd_str="$raid_cli_prog -adpCount"
	str=`$raid_cli_prog -adpCount`
	retcode=$?
	### interestingly this command returned 1 instead of zero ????
	if test $retcode -eq 0 || test $retcode -eq 1 ; then
		nadapters=`echo $str | grep "Controller Count:" | cut -d ":" -f 2 | cut -d "." -f 1`
		echo "INFO: Number of MegaRAID adapters is ${nadapters}."	>> $tmp_info_file 
	else
		echo "ERROR: There was a problem executing $cmd_str command!"	>> $tmp_error_file
	fi

	i=0
	while test $i -lt $nadapters
	do
		### get controller info
		#cmd_str="$raid_cli_prog -AdpAllInfo -a$i | grep \"Product Name\" -A18 | grep -v \"==\""
		$raid_cli_prog -AdpAllInfo -a$i | grep "Product Name" -A18 | grep -v "==" | tr "\n" " " >> $tmp_info_file

		### get memory error counters
		$raid_cli_prog -AdpAllInfo -a$i > $tmp_log_file

		memory_uncorrectable_errors=`cat $tmp_log_file	| grep "^Memory Uncorrectable Errors"	| sed -e "s/: /:/" | cut -d ":" -f 2`
		memory_correctable_errors=`cat $tmp_log_file	| grep "^Memory Correctable Errors"	| sed -e "s/: /:/" | cut -d ":" -f 2`
		if test $memory_uncorrectable_errors -ne 0 ; then
			is_are="is"
			s=""
			if test $memory_uncorrectable_errors -gt 1 ; then
				s="s"
				is_are="are"
			fi
			echo "ERROR: The number of uncorrectable memory error${s} $is_are $memory_uncorrectable_errors!" >> $tmp_error_file
		else
			echo "OK: There are no uncorrectable memory errors." >> $tmp_ok_file
		fi
		if test $memory_correctable_errors -ne 0 ; then
			is_are="is"
			s=""
			if test $memory_correctable_errors -gt 1 ; then
				s="s"
				is_are="are"
			fi
			echo "ERROR: The number of correctable memory error${s} $is_are $memory_correctable_errors!" >> $tmp_error_file
		else
			echo "OK: There are no correctable memory errors." >> $tmp_ok_file
		fi


		###
		$raid_cli_prog -LDInfo -Lall -a$i  > $tmp_log_file
		total_logical_drive_count=`cat $tmp_log_file	| grep "^Virtual Disk:" 			| wc -l`
		faulty_logical_drive_count=`cat $tmp_log_file	| grep "^State" 	| grep -v "Optimal"	| wc -l`
		if test $faulty_logical_drive_count -ne 0 ; then
			echo "ERROR: $faulty_logical_drive_count out of $total_logical_drive_count logical drives is not in state Optimal!" >> $tmp_error_file
		else
			echo "OK: All $total_logical_drive_count logical drives are in Optimal state." >> $tmp_ok_file
		fi

		declare -i j=0
		while test $j -lt $total_logical_drive_count
		do
			$raid_cli_prog -LDInfo -L$j -a$i  > $tmp_log_file
			ldrive_status=`cat $tmp_log_file 	| grep "^State:"	| sed -e "s/: /:/" | cut -d ":" -f 2`
			ldrive_raid_level=`cat $tmp_log_file	| grep "^RAID Level:"	| sed -e "s/: /:/" | cut -d ":" -f 2`
			ldrive_size=`cat $tmp_log_file		| grep "^Size:"		| sed -e "s/: /:/" | cut -d ":" -f 2`
			ldrive_stripe_size=`cat $tmp_log_file	| grep "^Stripe Size:"	| sed -e "s/: /:/" | cut -d ":" -f 2`
			#echo "ldrive_status=[$ldrive_status] ldrive_raid_level=[$ldrive_raid_level] ldrive_size=[$ldrive_size] ldrive_stripe_size=[$ldrive_stripe_size]"
			case "$ldrive_status" in
				"Optimal")
					echo "OK: The status of the logical drive $j (with RAID level: ${ldrive_raid_level},size=${ldrive_size}, strip size=${ldrive_stripe_size}) on controller $i is Optimal." >> $tmp_ok_file
				;;
				*)
					echo "ERROR: The status of the logical drive $j (with RAID level: ${ldrive_raid_level},size=${ldrive_size}, strip size=${ldrive_stripe_size}) on controller $i is unknown=$ldrive_status." >> $tmp_error_file
				;;
			esac
			$raid_cli_prog -LdPdInfo -a$i > $tmp_log_file
#			$raid_cli_prog -LdPdInfo -a$i | awk ' NR > 0 && NF > 0 {if($0 ~ /^PD:/) {printf "\n"};  printf "%s |",$0 } END {printf "\n"}' > $tmp_log_file
			nspans=`cat $tmp_log_file | grep "^Number of Spans:" | sed -e "s/: /:/" | cut -d ":" -f 2`
			ndrives_per_span=`cat $tmp_log_file | grep "^Number Of Drives per span:" | sed -e "s/: /:/" | cut -d ":" -f 2`
			#echo "nspans=[$nspans] ndrives_per_span=[$ndrives_per_span]"

			$raid_cli_prog -LdPdInfo -a$i | awk ' NR > 0 && NF > 0 {if($0 ~ /^PD:/) {printf "\n"};  printf "%s |",$0 } END {printf "\n"}' | grep -v "Number of Virtual Disks" > $tmp_log_file
			### check disk status
			total_physical_drive_count=`cat $tmp_log_file	| wc -l`
			faulty_physical_drive_count=`cat $tmp_log_file	| grep -v "Firmware state: Online" | wc -l`
#Media Error Count: 0
#Other Error Count: 0
#Predictive Failure Count: 0
			declare -i error_drive_count=0
			cat $tmp_log_file | while read line
			do
				enclosure_device_id=`echo $line		| cut -d "|" -f 2 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
				slot_number=`echo $line			| cut -d "|" -f 3 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
				device_id=`echo $line			| cut -d "|" -f 4 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
				media_error_count=`echo $line		| cut -d "|" -f 6 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
				other_error_count=`echo $line		| cut -d "|" -f 7 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
				predictive_error_count=`echo $line	| cut -d "|" -f 8 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
				drive_type=`echo $line	| cut -d "|" -f 10 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
				drive_size=`echo $line	| cut -d "|" -f 11 | sed -e "s/: /:/" | cut -d ":" -f 2 | cut -d "[" -f 1`
				drive_name=`echo $line	| cut -d "|" -f 18 | sed -e "s/: /:/" | cut -d ":" -f 2`
				info_str="(enclosure device id=${enclosure_device_id}, slot_number=${slot_number}, device id=${device_id}, type=${drive_type}, size=${drive_size}, name=${drive_name})"
				#echo "controller=$i logical drive=$j enclosure_device_id=[$enclosure_device_id] slot_number=[$slot_number] device_id=[$device_id] media_error_count=[$media_error_count] other_error_count=[$other_error_count] predictive_error_count=[$predictive_error_count]"
				if test $media_error_count -ne 0 ; then
					echo "ERROR: The hard disk on logical drive $j ${info_str} has media erros (${media_error_count} > 0)!" >> $tmp_error_file
				fi
				if test $other_error_count -ne 0; then
					echo "ERROR: The hard disk on logical drive $j ${info_str} has other errors (${other_error_count}>0)!" >> $tmp_error_file
				fi
				if test $predictive_error_count -ne 0 ; then
					echo "ERROR: The hard disk on logical drive $j ${info_str} has predictive errors (${predictive_error_count}>0)!" >> $tmp_error_file
				fi
				### this variable does not work outside the loop
				#if test $media_error_count -ne 0 || test $other_error_count -ne 0 || test $predictive_error_count -ne 0 ; then
				#	error_drive_count=error_drive_count+1
				#fi
				#echo "W error_drive_count=[$error_drive_count]"
			done
			#echo "error_drive_count=[$error_drive_count]"

			if test $faulty_physical_drive_count -ne 0 ; then
				### find out which drives have problems and their location (bay number)
				cat $tmp_log_file | grep -v "Firmware state: Online" | while read line
				do
					enclosure_device_id=`echo $line	| cut -d "|" -f 2 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
					slot_number=`echo $line		| cut -d "|" -f 3 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
					device_id=`echo $line		| cut -d "|" -f 4 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
					media_error_count=`echo $line	| cut -d "|" -f 6 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
					other_error_count=`echo $line	| cut -d "|" -f 7 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
					predictive_error_count=`echo $line | cut -d "|" -f 8 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
					drive_type=`echo $line	| cut -d "|" -f 10 | sed -e "s/: /:/" | cut -d ":" -f 2 | tr -d " "`
					drive_size=`echo $line	| cut -d "|" -f 11 | sed -e "s/: /:/" | cut -d ":" -f 2 | cut -d "[" -f 1`
					drive_name=`echo $line	| cut -d "|" -f 18 | sed -e "s/: /:/" | cut -d ":" -f 2`
					info_str="(enclosure device id=${enclosure_device_id}, slot_number=${slot_number}, device id=${device_id}, type=${drive_type}, size=${drive_size}, name=${drive_name})"

					firmware_state=`echo $line	| cut -d "|" -f 14 | sed -e "s/: /:/" | cut -d ":" -f 2`
					echo "ERROR: The hard disk on logical drive $j ${info_str} has firmware state ${firmware_state} (!=Online)!" >> $tmp_error_file
				done
			else
				echo "OK: All $total_physical_drive_count physical drives for logical drive $j have firmware state Online." >> $tmp_ok_file
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

######################################################################################################
### sample output of the following command: $raid_cli_prog -AdpAllInfo -aALL
######################################################################################################
#
#Adapter #0
#
#==============================================================================
#Versions
#================
#Product Name    : PERC 6/i Integrated
#Serial No       : 1122334455667788
#FW Package Build: 6.1.1-0047
#
#Mfg. Data
#================
#Mfg. Date       : 06/24/08
#Rework Date     : 06/24/08
#Revision No     :
#Battery FRU     : N/A
#
#Image Versions in Flash:
#================
#FW Version         : 1.21.02-0528
#BIOS Version       : 2.01.00
#WebBIOS Version    : 1.1-46-e_15-Rel
#Ctrl-R Version     : 1.02-014B
#Preboot CLI Version: 01.00-020:#%00004
#Boot Block Version : 1.00.00.01-0011
#
#Pending Images in Flash
#================
#None
#
#PCI Info
#================
#Vendor Id       : 1000
#Device Id       : 0060
#SubVendorId     : 1028
#SubDeviceId     : 1f0c
#
#Host Interface  : PCIE
#
#Number of Frontend Port: 0
#Device Interface  : PCIE
#
#Number of Backend Port: 8
#Port  :  Address
#0        5000c50005ccb2bd
#1        5000c50005cc6f85
#2        5000c50005cd4a69
#3        5000c50005cd4491
#4        0000000000000000
#5        0000000000000000
#6        0000000000000000
#7        0000000000000000
#
#HW Configuration
#================
#SAS Address     : 50022190a3d43400
#BBU             : Present
#Alarm           : Absent
#NVRAM           : Present
#Serial Debugger : Present
#Memory          : Present
#Flash           : Present
#Memory Size     : 256MB
#TPM             : Absent
#
#Settings
#================
#Current Time                     : 22:10:22 1/13, 2010
#Predictive Fail Poll Interval    : 300sec
#Interrupt Throttle Active Count  : 16
#Interrupt Throttle Completion    : 50us
#Rebuild Rate                     : 30%
#PR Rate                          : 30%
#Resynch Rate                     : 30%
#Check Consistency Rate           : 30%
#Reconstruction Rate              : 30%
#Cache Flush Interval             : 4s
#Max Drives to Spinup at One Time : 2
#Delay Among Spinup Groups        : 12s
#Physical Drive Coercion Mode     : 128MB
#Cluster Mode                     : Disabled
#Alarm                            : Disabled
#Auto Rebuild                     : Enabled
#Battery Warning                  : Enabled
#Ecc Bucket Size                  : 15
#Ecc Bucket Leak Rate             : 1440 Minutes
#Restore HotSpare on Insertion    : Disabled
#Expose Enclosure Devices         : Disabled
#Maintain PD Fail History         : Disabled
#Host Request Reordering          : Enabled
#Auto Detect BackPlane Enabled    : SGPIO/i2c SEP
#Load Balance Mode                : Auto
#Use FDE Only                     : No
#Security Key Assigned            : No
#Security Key Failed              : No
#Security Key Not Backedup        : No
#
#Any Offline VD Cache Preserved   : No
#
#Capabilities
#================
#RAID Level Supported             : RAID0, RAID1, RAID5, RAID6, RAID10, RAID50, RAID60, PRL 11, PRL 11 with spanning, SRL 3 supported
#Supported Drives                 : SAS, SATA
#
#Allowed Mixing:
#
#Mix in Enclosure Allowed
#
#Status
#================
#ECC Bucket Count                 : 0
#
#Limitations
#================
#Max Arms Per VD         : 32
#Max Spans Per VD        : 8
#Max Arrays              : 128
#Max Number of VDs       : 64
#Max Parallel Commands   : 1008
#Max SGE Count           : 80
#Max Data Transfer Size  : 8192 sectors
#Max Strips PerIO        : 42
#Min Stripe Size         : 8 KB
#Max Stripe Size         : 1.0 MB
#
#Device Present
#================
#Virtual Drives    : 1
#Degraded        : 0
#Offline         : 0
#Physical Devices  : 5
#Disks           : 4
#Critical Disks  : 0
#Failed Disks    : 0
#
#Supported Adapter Operations
#================
#Rebuild Rate                    : Yes
#CC Rate                         : Yes
#BGI Rate                        : Yes
#Reconstruct Rate                : Yes
#Patrol Read Rate                : Yes
#Alarm Control                   : Yes
#Cluster Support                 : No
#BBU                             : Yes
#Spanning                        : Yes
#Dedicated Hot Spare             : Yes
#Revertible Hot Spares           : Yes
#Foreign Config Import           : Yes
#Self Diagnostic                 : Yes
#Allow Mixed Redundancy on Array : No
#Global Hot Spares               : Yes
#Deny SCSI Passthrough           : No
#Deny SMP Passthrough            : No
#Deny STP Passthrough            : No
#Support Security                : No
#
#Supported VD Operations
#================
#Read Policy          : Yes
#Write Policy         : Yes
#IO Policy            : Yes
#Access Policy        : Yes
#Disk Cache Policy    : Yes
#Reconstruction       : Yes
#Deny Locate          : No
#Deny CC              : No
#Allow Ctrl Encryption: No
#
#Supported PD Operations
#================
#Force Online                            : Yes
#Force Offline                           : Yes
#Force Rebuild                           : Yes
#Deny Force Failed                       : No
#Deny Force Good/Bad                     : No
#Deny Missing Replace                    : No
#Deny Clear                              : No
#Deny Locate                             : No
#Disable Copyback                        : No
#Enable Copyback on SMART                : No
#Enable Copyback to SSD on SMART Error   : No
#Enable SSD Patrol Read                  : No
#
#Error Counters
#================
#Memory Correctable Errors   : 0
#Memory Uncorrectable Errors : 0
#
#Cluster Information
#================
#Cluster Permitted     : No
#Cluster Active        : No
#
#Default Settings
#================
#Phy Polarity                     : 0
#Phy PolaritySplit                : 0
#Background Rate                  : 30
#Stripe Size                      : 64kB
#Flush Time                       : 4 seconds
#Write Policy                     : WB
#Read Policy                      : None
#Cache When BBU Bad               : Disabled
#Cached IO                        : No
#SMART Mode                       : Mode 6
#Alarm Disable                    : No
#Coercion Mode                    : 128MB
#ZCR Config                       : Unknown
#Dirty LED Shows Drive Activity   : No
#BIOS Continue on Error           : No
#Spin Down Mode                   : None
#Allowed Device Type              : SAS/SATA Mix
#Allow Mix in Enclosure           : Yes
#Allow HDD SAS/SATA Mix in VD     : No
#Allow SSD SAS/SATA Mix in VD     : No
#Allow HDD/SSD Mix in VD          : No
#Allow SATA in Cluster            : No
#Max Chained Enclosures           : 1
#Disable Ctrl-R                   : No
#Enable Web BIOS                  : No
#Direct PD Mapping                : Yes
#BIOS Enumerate VDs               : Yes
#Restore Hot Spare on Insertion   : No
#Expose Enclosure Devices         : No
#Maintain PD Fail History         : No
#Disable Puncturing               : No
#Zero Based Enclosure Enumeration : Yes
#PreBoot CLI Enabled              : No
#LED Show Drive Activity          : No
#Cluster Disable                  : Yes
#SAS Disable                      : No
#Auto Detect BackPlane Enable     : SGPIO/i2c SEP
#Use FDE Only                     : No
#Enable Led Header                : No
#Delay during POST                : 0
#
#Exit Code: 0x00
######################################################################################################
#MegaCli64 -LDInfo -Lall -a0
#MegaCli64 -LDInfo -L0 -a0
#
#
#Adapter 0 -- Virtual Drive Information:
#Virtual Disk: 0 (Target Id: 0)
#Name:Virtual Disk 0
#RAID Level: Primary-1, Secondary-3, RAID Level Qualifier-0
#Size:557.75 GB
#State: Optimal
#Stripe Size: 64 KB
#Number Of Drives per span:2
#Span Depth:2
#Default Cache Policy: WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU
#Current Cache Policy: WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU
#Access Policy: Read/Write
#Disk Cache Policy: Disk's Default
#Encryption Type: None
#
#Exit Code: 0x00
######################################################################################################
#MegaCli64 -EncInfo -aALL
#
#    Number of enclosures on adapter 0 -- 1
#
#    Enclosure 0:
#    Device ID                     : 32
#    Number of Slots               : 8
#    Number of Power Supplies      : 0
#    Number of Fans                : 0
#    Number of Temperature Sensors : 0
#    Number of Alarms              : 0
#    Number of SIM Modules         : 0
#    Number of Physical Drives     : 4
#    Status                        : Normal
#    Position                      : Unavailable
#    Connector Name                : Unavailable
#    Partner Device Id             : 65535
#
#
#Exit Code: 0x00
######################################################################################################
###MegaCli64 -LdPdInfo -a0
#
#Adapter #0
#
#Number of Virtual Disks: 1
#Virtual Disk: 0 (Target Id: 0)
#Name:Virtual Disk 0
#RAID Level: Primary-1, Secondary-3, RAID Level Qualifier-0
#Size:557.75 GB
#State: Optimal
#Stripe Size: 64 KB
#Number Of Drives per span:2
#Span Depth:2
#Default Cache Policy: WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU
#Current Cache Policy: WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU
#Access Policy: Read/Write
#Disk Cache Policy: Disk's Default
#Encryption Type: None
#Number of Spans: 2
#Span: 0 - Number of PDs: 2
#PD: 0 Information
#Enclosure Device ID: 32
#Slot Number: 0
#Device Id: 0
#Sequence Number: 2
#Media Error Count: 0
#Other Error Count: 0
#Predictive Failure Count: 0
#Last Predictive Failure Event Seq Number: 0
#PD Type: SAS
#Raw Size: 279.396 GB [0x22ecb25c Sectors]
#Non Coerced Size: 278.896 GB [0x22dcb25c Sectors]
#Coerced Size: 278.875 GB [0x22dc0000 Sectors]
#Firmware state: Online
#SAS Address(0): 0x5000c50005ccb2bd
#SAS Address(1): 0x0
#Connected Port Number: 0(path0)
#Inquiry Data: SEAGATE ST9300603SS     FS023SE06H62
#FDE Capable: Not Capable
#FDE Enable: Disable
#Secured: Unsecured
#Locked: Unlocked
#Foreign State: None
#Device Speed: Unknown
#Link Speed: Unknown
#Media Type: Hard Disk Device
#
#PD: 1 Information
#Enclosure Device ID: 32
#Slot Number: 1
#Device Id: 1
#Sequence Number: 2
#Media Error Count: 0
#Other Error Count: 0
#Predictive Failure Count: 0
#Last Predictive Failure Event Seq Number: 0
#PD Type: SAS
#Raw Size: 279.396 GB [0x22ecb25c Sectors]
#Non Coerced Size: 278.896 GB [0x22dcb25c Sectors]
#Coerced Size: 278.875 GB [0x22dc0000 Sectors]
#Firmware state: Online
#SAS Address(0): 0x5000c50005cc6f85
#SAS Address(1): 0x0
#Connected Port Number: 1(path0)
#Inquiry Data: SEAGATE ST9300603SS     FS023SE06KZ1
#FDE Capable: Not Capable
#FDE Enable: Disable
#Secured: Unsecured
#Locked: Unlocked
#Foreign State: None
#Device Speed: Unknown
#Link Speed: Unknown
#Media Type: Hard Disk Device
#
#Span: 1 - Number of PDs: 2
#PD: 0 Information
#Enclosure Device ID: 32
#Slot Number: 2
#Device Id: 2
#Sequence Number: 2
#Media Error Count: 0
#Other Error Count: 0
#Predictive Failure Count: 0
#Last Predictive Failure Event Seq Number: 0
#PD Type: SAS
#Raw Size: 279.396 GB [0x22ecb25c Sectors]
#Non Coerced Size: 278.896 GB [0x22dcb25c Sectors]
#Coerced Size: 278.875 GB [0x22dc0000 Sectors]
#Firmware state: Online
#SAS Address(0): 0x5000c50005cd4a69
#SAS Address(1): 0x0
#Connected Port Number: 2(path0)
#Inquiry Data: SEAGATE ST9300603SS     FS023SE0704W
#FDE Capable: Not Capable
#FDE Enable: Disable
#Secured: Unsecured
#Locked: Unlocked
#Foreign State: None
#Device Speed: Unknown
#Link Speed: Unknown
#Media Type: Hard Disk Device
#
#PD: 1 Information
#Enclosure Device ID: 32
#Slot Number: 3
#Device Id: 3
#Sequence Number: 2
#Media Error Count: 0
#Other Error Count: 0
#Predictive Failure Count: 0
#Last Predictive Failure Event Seq Number: 0
#PD Type: SAS
#Raw Size: 279.396 GB [0x22ecb25c Sectors]
#Non Coerced Size: 278.896 GB [0x22dcb25c Sectors]
#Coerced Size: 278.875 GB [0x22dc0000 Sectors]
#Firmware state: Online
#SAS Address(0): 0x5000c50005cd4491
#SAS Address(1): 0x0
#Connected Port Number: 3(path0)
#Inquiry Data: SEAGATE ST9300603SS     FS023SE0705X
#FDE Capable: Not Capable
#FDE Enable: Disable
#Secured: Unsecured
#Locked: Unlocked
#Foreign State: None
#Device Speed: Unknown
#Link Speed: Unknown
#Media Type: Hard Disk Device
#
#
#Exit Code: 0x00
######################################################################################################
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
