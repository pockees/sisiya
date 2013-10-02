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
### server service id
serviceid=$serviceid_baan_slm
if test -z "$serviceid" ; then
	echo "$0 : serviceid_baan_slm is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="ErpLn Solution Licence Manager (SLM)"
##########################################################################
### default values
SLMHOME=/infor/slm
BSE_TMP=/infor/erpln/bse/tmp
BSE=/infor/erpln/bse
slmcmd=/infor/slm/bin/SlmCmd
license_file=/infor/slm/license/1/6005/license.xml
number_of_slm_servers=1
slm_server[0]=localhost
slm_port[0]=6005
### end of the default values
##########################################################################

if test -f $module_conf_file ; then
	### source the module conf
	. $module_conf_file
fi

if test ! -f "$license_file" ; then
	echo "$0: The SLM license file $license_file does not exist!"
	exit 1
fi

tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_info_file=`maketemp /tmp/tmp_info_${script_name}.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`


### 
export BSE_TMP
export BSE
export SLMHOME


name_str=`cat $license_file 		| grep -A 1 "<customer"  	| tail -n 1 | cut -d "\"" -f 2`
code_str=`cat $license_file 		| grep -A 2 "<customer"  	| tail -n 1 | cut -d "\"" -f 2`
number_str=`cat $license_file 		| grep -A 3 "<customer"  	| tail -n 1 | cut -d "\"" -f 2`
edit_state_str=`cat $license_file 	| grep -A 4 "<customer"  	| tail -n 1 | cut -d "\"" -f 2`
echo "INFO: name=[$name_str] code=[$code_str] number=[$number_str] state=[$edit_state_str]" >> $tmp_info_file
### check if there are any desktop licenses
### check if there are any named user licenses
### check if there are any concurrent user licenses

### give info abount server licenses
str=`grep -n "serverLicense" $license_file | grep -v "serverLicense/" | tr -d "\n"`
if test -n "$str" ; then
	start_pos=`echo "$str" 	| cut -d ":" -f 1`
	end_pos=`echo "$str" 	| cut -d ":" -f 2 | cut -d ">" -f 2`
	line_count=`echo "$end_pos - $start_pos + 1" | bc`
	#echo "start_pos=$start_pos line_count=$line_count"
	str=`head -n $end_pos $license_file | tail -n $line_count | grep -v product | grep -v license | grep -v "/>" | grep -v "serverLicense" | tr -d "\"" | tr -d "\t" | tr -d ">" |  tr "\n" " "`
	echo "INFO: Server license : $str" >> $tmp_info_file
else
	echo "INFO: No server license." >> $tmp_info_file
fi

str=`grep -n "desktopLicense" $license_file | grep -v "desktopLicense/" | tr -d "\n" `
if test -n "$str" ; then
	start_pos=`echo "$str" 	| cut -d ":" -f 1`
	end_pos=`echo "$str" 	| cut -d ":" -f 2 | cut -d ">" -f 2`
	line_count=`echo "$end_pos - $start_pos + 1" | bc`
	#echo "start_pos=$start_pos line_count=$line_count"
	str=`head -n $end_pos $license_file | tail -n $line_count | grep -v product | grep -v license | grep -v "/>" | grep -v "desktopLicense" | tr -d "\"" | tr -d "\t" | tr -d ">" |  tr "\n" " " `
	echo "INFO: Desktop license : $str" >> $tmp_info_file
else
	echo "INFO: No desktop licenses." >> $tmp_info_file
fi

str=`grep -n "userLicense" $license_file | grep -v "userLicense/" | tr -d "\n" `
if test -n "$str" ; then
	start_pos=`echo "$str" 	| cut -d ":" -f 1`
	end_pos=`echo "$str" 	| cut -d ":" -f 2 | cut -d ">" -f 2`
	line_count=`echo "$end_pos - $start_pos + 1" | bc`
	#echo "start_pos=$start_pos line_count=$line_count"
	str=`head -n $end_pos $license_file | tail -n $line_count | grep -v product | grep -v license | grep -v "/>" | grep -v "userLicense" | tr -d "\"" | tr -d "\t" | tr -d ">" |  tr "\n" " " `
	echo "INFO: User license : $str" >> $tmp_info_file
else
	echo "INFO: No user licenses." >> $tmp_info_file
fi



str=`grep -n "concurrentLicense" $license_file | grep -v "concurrentLicense/" | tr -d "\n" `
if test -n "$str" ; then
	start_pos=`echo "$str" 	| cut -d ":" -f 1`
	end_pos=`echo "$str" 	| cut -d ":" -f 2 | cut -d ">" -f 2`
	line_count=`echo "$end_pos - $start_pos + 1" | bc`
	#echo "start_pos=$start_pos line_count=$line_count"
	str=`head -n $end_pos $license_file | tail -n $line_count | grep -v product | grep -v license | grep -v "/>" | grep -v "concurrentLicense" | tr -d "\"" | tr -d "\t" | tr -d ">" |  tr "\n" " "`
	echo "INFO: Concurrent license : $str" >> $tmp_info_file
else
	echo "INFO: No concurrent license." >> $tmp_info_file
fi



declare -i i=0
while test $i -lt $number_of_slm_servers
do
        server_str=${slm_server[${i}]}
	#echo "slm server $server_str"
	$slmcmd -montts $server_str > $tmp_file	

	host_str=`cat $tmp_file 		| grep "host=\"" 	| cut -d "=" -f 2	| cut -d "\"" -f 2`
	port_str=`cat $tmp_file 		| grep "port=\"" 	| cut -d "=" -f 2	| cut -d "\"" -f 2`
	udp_port_str=`cat $tmp_file 		| grep "udpPort=\"" 	| cut -d "=" -f 2	| cut -d "\"" -f 2`
	mode_str=`cat $tmp_file 		| grep "mode=\"" 	| cut -d "=" -f 2	| cut -d "\"" -f 2`

	#license_10996_count=`cat $tmp_file	| grep -A 1 "10996"	| tail -n 1 		| cut -d "\"" -f 2 | tr -d "\t"`
	#if test "$license_10996_count" = "/>" ; then
	#	license_10996_count=0
	#fi

	product_licenses_str=`cat $tmp_file | tr -d "\n" | tr -d "\t" | sed -e "s/<productid/\\n<productid/g" | grep "\"count=" | cut -d "/" -f 1 | sed -e "s/<productid=\"//" | sed -e "s/\"count=/:/" | tr -d "\"" | tr "\n" " " `
	#echo "Host=[$host_str] Port=[$port_str] UDP Port=[$udp_port_str] Mode=[$mode_str] License usage: $product_licenses_str"
	echo "OK: Host=[$host_str] Port=[$port_str] UDP Port=[$udp_port_str] Mode=[$mode_str] License usage: $product_licenses_str" >> $tmp_ok_file


	i=i+1
done
statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	message_str=`cat $tmp_error_file | tr "\n" " "` 
	statusid=$status_error
fi

if test -s $tmp_warning_file ; then
	message_str="$message_str"`cat $tmp_warning_file | tr "\n" " "`
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_ok_file ; then
	message_str="$message_str"`cat $tmp_ok_file | tr "\n" " "`
fi

if test -s $tmp_info_file ; then
	message_str="$message_str"`cat $tmp_info_file | tr "\n" " "`
fi

for f in $tmp_file $tmp_info_file $tmp_ok_file $tmp_warning_file $tmp_error_file 
do
	rm -f $f
done

data_message_str=""
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
