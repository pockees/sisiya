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
serviceid=$serviceid_baan_users
if test -z "$serviceid" ; then
	echo "$0 : serviceid_baan_users is not defined! Exiting..."
	exit 1
fi
##########################################################################
service_name="Baan Connection"
##########################################################################
### default values
local_ip=localhost
port=512
error_count=30
warning_count=28
BSE_TMP=/usr2/baan/bse/tmp
BSE=/usr2/baan/bse
licmon=${BSE}/bin/licmon6.1
slm_server=localhost
slmcmd=/usr/slm/bin/SlmCmd
### end of the default values
##########################################################################

if test -f $module_conf_file ; then
	### source the module conf
	. $module_conf_file
fi

### 
export BSE_TMP
export BSE

### get the number of established connections to the Baan ip:port.
if test "$sisiya_osname" = "HP-UX" ; then
	netstat_count=`netstat -n | grep "${local_ip}.$port " | grep EST | grep -v grep | wc -l`
else
	netstat_count=`netstat -ntp | grep "${local_ip}:$port " | grep EST | grep -v grep | wc -l`
fi

slm_count=0
licmon_count=0
if test -x $licmon ; then
	### get the number of users reported by licmon, the licence monitor
	line=`$licmon -u | grep TOTAL`
	if test -n "$line" ; then
		a=`echo $line | awk '{print $3}'`
		b=`echo $line | awk '{print $4}'`
		licmon_count=`(echo "$a + $b") | bc`
	fi
else
	if test -x $slmcmd ; then
		#/usr/slm/bin/SlmCmd -mondts altin01|grep count|tr -d "\t"|tr -d " "|cut -d "\"" -f 2|grep -v "^0"
		#slm_count=`$slmcmd -mondts $slm_server | grep count | tr -d "\t" | tr -d " " | cut -d "\"" -f 2 | grep -v "^0" | awk 'BEGIN { sum=0 } {sum+=$i} END {printf "%s",sum}'`
		slm_count1=`$slmcmd -mondts $slm_server | grep "<concurrentLicense" -A 1 | grep count | tr -d "\t" | tr -d " " | cut -d "\"" -f 2 | grep -v "^0" | awk 'BEGIN { sum=0 } {sum+=$i} END {printf "%s",sum}'`
		slm_count2=`$slmcmd -mondts $slm_server | grep "<serverLicense" -A 1 | grep count | tr -d "\t" | tr -d " " | cut -d "\"" -f 2 | grep -v "^0" | awk 'BEGIN { sum=0 } {sum+=$i} END {printf "%s",sum}'`
		slm_count=`echo "$slm_count1 + $slm_count2" | bc`
	fi
fi
#echo "licmon_count=$licmon_count slm_count=$slm_count"
license_count=0
if test $license_count -eq 0 ; then
	license_count=$slm_count
fi
### get the number of working bshell's
grep_count=0
str=`ps -ef | grep -v grep | grep  bshell|wc -l`
if test -n "$str" ; then
	grep_count=$str
fi

statusid=$status_ok 
if test $license_count -ge $error_count ; then
	statusid=$status_error
	message_str="Too many Baan users $license_count (>= $error_count)!"
elif test $license_count -ge $warning_count ; then
	statusid=$status_warning  
	message_str="Too many Baan users $license_count (>= $warning_count)!"
fi


#if test $license_count -gt $grep_count ; then
#	if test $statusid -lt $status_warning ; then
#		statusid=$status_warning
#	fi
#	message_str="$message_str WARNING: licmon user count is $license_count < $grep_count (grep)!"
#else
	message_str="Number of active Baan users is $license_count (grep_count=$grep_count, netstat_count=$netstat_count)."
#fi

tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_users_file=`maketemp /tmp/tmp_users_${script_name}.XXXXXX`
tmp_count_file=`maketemp /tmp/tmp_count_${script_name}.XXXXXX`

ps -ef | grep -v grep | grep  $BSE/bin/bshell | sort > $tmp_file
cat $tmp_file | awk '{print $1}' | uniq > $tmp_users_file
#cat $tmp_file | while read line
#do
#	echo "line=[$line]"
#done

str=""
cat $tmp_users_file | while read user
do
	c=`grep $user $tmp_file| wc -l`
	str="$str $user($c)"
	echo $str > $tmp_count_file
done
str=`cat $tmp_count_file`
message_str="$message_str Users: $str"
#echo "str=[$str]"

rm -f $tmp_file $tmp_users_file $tmp_count_file

###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
