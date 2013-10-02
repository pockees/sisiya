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
serviceid=$serviceid_ipconntrack
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ipconntrack is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
ipconntrack_file=/proc/net/ip_conntrack
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

snapshot_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
ips_file=`maketemp /tmp/tmp_ips_${script_name}.XXXXXX`
ports_file=`maketemp /tmp/tmp_ports_${script_name}.XXXXXX`

if test ! -f $ipconntrack_file ; then
	statusid=$status_warning
	message_str="Connection tracking file $ipconntrack_file does not exist!"
else
	statusid=$status_info
	### get uniq IPs 
	grep "ESTABLISHED" $ipconntrack_file > $snapshot_file
	cat $snapshot_file | awk '{print $6}' | cut -d "=" -f 2 | while read ip
	do
		echo $ip >> $tmp_file
	done
	cat $tmp_file | sort | uniq > $ips_file

	### get uniq ports
	> $tmp_file
	cat $snapshot_file | awk '{print $8}' | cut -d "=" -f 2 | while read dport
	do
		echo $dport >> $tmp_file
	done
	cat $tmp_file | sort -n | uniq > $ports_file
	> $tmp_file
#	echo "--------- IP ---------------"
#	cat $ips_file
#	echo "--------- Ports ------------"
#	cat $ports_file
#	echo "---------------------------"
	cat $ips_file | while read ip
	do
		echo -n "${ip}:" >> $tmp_file
		cat $ports_file | while read port
		do
			count=`grep "dst=$ip" $snapshot_file | grep "dport=$port" | wc -l`
			if test -n "$count" && test $count -ne 0 ; then
				echo -n "${port}-${count}," >> $tmp_file
			fi
		done
		echo "" >> $tmp_file
	done	
fi
echo "]" >> $tmp_file
message_str=`cat $tmp_file | tr "\n" ";" | sed -e "s/,;/; /g" -e "s/; ]//"`

#cat $tmp_file
for f in $tmp_file $ips_file $ports_file $snapshot_file
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
