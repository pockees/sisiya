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
serviceid=$serviceid_sun_cluster
if test -z "$serviceid" ; then
	echo "$0 : serviceid_sun_cluster is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
scstat_prog=/usr/cluster/bin/scstat
#scconf_prog=/usr/cluster/bin/scconf -p|grep -i "transport cable:"| awk '{print $3,$4,$5}'
#sccheck_prog=/usr/cluster/bin/sccheck Returns error messages or nothing
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi


if test ! -x $scstat_prog ; then
	statusid=$status_error
	message_str="ERROR: scstat program [$scstat_prog] does not exist or is not executable!"
	exit 0
fi

### get the number of nodes
total_node_count=`$scstat_prog -n |grep -i "Cluster node:" | wc -l | awk '{print $1}'`
PATH=$PATH:/usr/local/bin
export PATH
tmp_offline_nodes_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_online_nodes_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
for f in $tmp_offline_nodes_file $tmp_online_nodes_file 
do
        rm -f $f
        touch $f
done

offline_nodes=""
online_nodes=""
declare -i i=0 offline_node_count=0
$scstat_prog -n |grep -i "Cluster node:" | sort | while read line
do
	node_name=`echo $line	| awk '{print $3}'`
	node_state=`echo $line	| awk '{print $4}'`
	if test "$node_state" = "Offline" ; then
		offline_node_count=offline_node_count+1
		echo "$node_name" >> $tmp_offline_nodes_file
	else
		echo "$node_name" >> $tmp_online_nodes_file
	fi
#echo "node_name=[$node_name] node_state=[$node_state] offline_node_count=[$offline_node_count] offline_nodes=[$offline_nodes] online_nodes=[$online_nodes]"
	i=i+1
#echo "i=$i"
done

#echo " after node_name=[$node_name] node_state=[$node_state] offline_node_count=[$offline_node_count] offline_nodes=[$offline_nodes] online_nodes=[$online_nodes]"
offline_node_count=`cat $tmp_offline_nodes_file | wc -l`
online_node_count=`(echo "$total_node_count - $offline_node_count") | bc`
online_nodes=`cat $tmp_online_nodes_file | tr -d "\n" " "`
offline_nodes=`cat $tmp_offline_nodes_file | tr -d "\n" " "`
#echo "2 after node_name=[$node_name] node_state=[$node_state] offline_node_count=[$offline_node_count] offline_nodes=[$offline_nodes] online_nodes=[$online_nodes]"
if test $total_node_count -eq $offline_node_count ; then
	statusid=$status_error
	if test $total_node_count -eq 0 ; then
		message_str="ERROR: There are no online nodes!"
	else
		message_str="ERROR: $total_node_count $offline_nodes nodes are in offline state!"
	fi
elif test $offline_node_count = 0 ; then
	statusid=$status_ok
	if test $total_node_count -eq 0 ; then
		message_str="OK: The $online_nodes is in online state." 
	else
		message_str="OK: All $online_nodes nodes are in online state." 
	fi
else
	statusid=$status_warning
	message_str="WARNING: $offline_node_count ($offline_nodes) of total $total_node_count nodes" 
	if test $offline_node_count -eq 0 ; then
		message_str="$message_str is"
	else
		message_str="$message_str are"
	fi
	if test $online_node_count -eq 1 ; then
 		message_str="$message_str in offline state! OK: $online_nodes is online." 
	else
 		message_str="$message_str in offline state! OK: $online_nodes are online." 
	fi
fi
for f in $tmp_offline_nodes_file $tmp_online_nodes_file 
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
