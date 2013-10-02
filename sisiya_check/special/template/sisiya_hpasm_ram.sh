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
### Check for RAM's
#################################################################################
### service id
serviceid=$serviceid_ram
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ram is not defined! Exiting..."
	exit 1
fi

##########################################################################
service_name="RAM"
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
### Sample output of the hpasmcli -s "show dimm" command :
#DIMM Configuration
#------------------
#Cartridge #:                  0
#Module #:                     1
#Present:                      Yes
#Form Factor:                  fh
#Memory Type:                  14h
#Size:                         1024 MB
#Speed:                        667 MHz
#Supports Lock Step:           No
#Configured for Lock Step:     No
#Status:                       Ok
#
#Cartridge #:                  0
#Module #:                     2
#Present:                      Yes
#Form Factor:                  fh
#Memory Type:                  14h
#Size:                         1024 MB
#Speed:                        667 MHz
#Supports Lock Step:           No
#Configured for Lock Step:     No
#Status:                       Ok
#
##
#cat a.txt |grep "^Cartridge" -A 9 |grep -v "^--"
# number of cartidges: cat a.txt |grep "^Cartridge" |cut -d ":" -f 2|tr -d " "|sort|uniq|wc -l
##############################################################################################

tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_file2=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_info_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

declare -i i=1

cmd_str="show dimm"
$hpasmcli_prog -s "$cmd_str" > $tmp_file
retcode=$?
if test $retcode -eq 0 ; then
	##########################################################################################################################################################################################
	#Cartridge #:    0 |Processor #: 1 |Module #:       2 |Present:        Yes |Form Factor:    fh |Memory Type:    5h |Size:           8192 MB |Speed:          1333 MHz |Status:         N/A |                
	#Cartridge #:    0 |Processor #: 1 |Module #:       4 |Present:        Yes |Form Factor:    fh |Memory Type:    5h |Size:           8192 MB |Speed:          1333 MHz |Status:         N/A |                
	#Cartridge #:    0 |Processor #: 1 |Module #:       6 |Present:        Yes |Form Factor:    fh |Memory Type:    5h |Size:           8192 MB |Speed:          1333 MHz |Status:         N/A |                
	#Cartridge #:    0 |Processor #: 2 |Module #:       2 |Present:        Yes |Form Factor:    fh |Memory Type:    5h |Size:           8192 MB |Speed:          1333 MHz |Status:         N/A |                
	#Cartridge #:    0 |Processor #: 2 |Module #:       4 |Present:        Yes |Form Factor:    fh |Memory Type:    5h |Size:           8192 MB |Speed:          1333 MHz |Status:         N/A |
	#Cartridge #:    0 |Processor #: 2 |Module #:       6 |Present:        Yes |Form Factor:    fh |Memory Type:    5h |Size:           8192 MB |Speed:          1333 MHz |Status:         N/A |
	##########################################################################################################################################################################################

	### skip the first 3 rows and process only non empty lines
	#awk ' NR > 3 && NF > 0 {if($0 ~ /^Cartridge/) {printf "\n"};  printf "%s |",$0 } END {printf "\n"}' $tmp_file > $tmp_file2
	awk ' NR > 1 && NF > 0 {if($0 ~ /^Cartridge/) {printf "\n"};  printf "%s |",$0 } END {printf "\n"}' $tmp_file | grep "^Cartridge" > $tmp_file2
	cat $tmp_file2 | while read line
	do
		if test -z "$line" ; then
			continue
		fi
		#cartridge_str=`echo $line	| cut -d "|" -f 1 | cut -d ":" -f 2 | tr -d " "`
		#module_str=`echo $line		| cut -d "|" -f 2 | cut -d ":" -f 2 | tr -d " "`
		#is_present=`echo $line		| cut -d "|" -f 3 | cut -d ":" -f 2 | tr -d " "`
		#memory_type=`echo $line  	| cut -d "|" -f 5 | cut -d ":" -f 2 | tr -d " "`
		#memory_size=`echo $line  	| cut -d "|" -f 6 | cut -d ":" -f 2 | tr -d " "`
		#memory_speed=`echo $line  	| cut -d "|" -f 7 | cut -d ":" -f 2 | tr -d " "`
		#memory_status=`echo $line  	| cut -d "|" -f 10 | cut -d ":" -f 2 | tr -d " "`
		is_present=`echo "$line" | sed -e "s/Present/\n/" | tail -n 1 | cut -d "|" -f 1 | cut -d ":" -f 2 | tr -d " "`
		if test "$is_present" = "Yes" ; then
			### check status
			memory_status=`echo "$line" | sed -e "s/Status/\n/" | tail -n 1 | cut -d "|" -f 1 | cut -d ":" -f 2 | tr -d " " | tr -d "/"`
			if test "$memory_status" = "Ok" ; then
				#echo "OK: The status of RAM (Type=${memory_type}, size=${memory_size}, speed=${memory_speed}) in cartridge=$cartridge_str and module=$module_str is OK." >> $tmp_ok_file
				echo "OK: $line" | sed -e "s/  //g" | tr "|" "," >> $tmp_ok_file
			else
				#echo "ERROR: The status of RAM (Type=${memory_type}, size=${memory_size}, speed=${memory_speed}) in cartridge=$cartridge_str and module=$module_str is ${memory_status}!." >> $tmp_error_file
				#echo "memory_status=[$memory_status]"
				if test "$memory_status" = "NA" ; then
					echo "INFO: $line" | sed -e "s/  //g" | tr "|" "," >> $tmp_info_file
				else
					echo "ERROR: $line" | sed -e "s/  //g" | tr "|" "," >> $tmp_error_file
				fi
			fi
		else
			cartridge_str=`echo "$line" 	| sed -e "s/Status/\n/" | tail -n 1 | cut -d "|" -f 1 | cut -d ":" -f 2 | tr -d " "`
			module_str=`echo "$line" 	| sed -e "s/Status/\n/" | tail -n 1 | cut -d "|" -f 1 | cut -d ":" -f 2 | tr -d " "`
			echo "INFO: Not RAM in cartridge=$cartridge_str and module=$module_str." >> $tmp_info_file
		fi
	done
else
	echo "ERROR: Error executing hpasmcli command! retcode=$retcode" >> $tmp_error_file
fi

statusid=$status_info
message_str=""
if test -s $tmp_error_file ; then
	statusid=$status_error
	message_str=`cat $tmp_error_file | tr "\n" " "` 
fi

if test -s $tmp_ok_file ; then
	statusid=$status_ok
	message_str="$message_str`cat $tmp_ok_file | tr "\n" " "`"
fi

if test -s $tmp_ok_info ; then
	message_str="$message_str`cat $tmp_info_file | tr "\n" " "`"
fi


### clean up
for f in $tmp_file $tmp_file2 $tmp_info_file $tmp_ok_file $tmp_warning_file $tmp_error_file
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
