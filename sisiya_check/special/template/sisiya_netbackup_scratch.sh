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
serviceid=$serviceid_netbackup_scratch  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_netbackup_scratch is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
error_ntapes=4
warning_ntapes=5
vmpool_prog=/usr/openv/volmgr/bin/vmpool
vmquery_prog=/usr/openv/volmgr/bin/vmquery
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
str=$script_name
if test "$sisiya_osname" = "SunOS"  ; then
	str=`echo $str | awk -F. '{ print $1 }'`
else
	str=${str%.*}
fi

module_conf_file=${sisiya_host_dir}/${str}.conf
if test -f $module_conf_file ; then
	. $module_conf_file
fi

for f in $vmpool_prog $vmquery_prog
do
	if test ! -x $f ; then
		statusid=$status_error
		message_str="ERROR: $f program does not exist or is not executable!"
		exit 0
	fi
done

scratch_pool_name=`$vmpool_prog -listscratch | tail -n 1`
if test -z "$scratch_pool_name" ; then
		statusid=$status_error
		message_str="ERROR: There is no scratch pool!"
else
	scratch_pool_index=`$vmpool_prog -listall -bx | grep $scratch_pool_name | awk '{print $2}'`
	total_scratch_tapes=`$vmquery_prog -p $scratch_pool_index | grep "media ID" | wc -l`
	total_scratch_tapes_none=`$vmquery_prog -p $scratch_pool_index | grep "robot type" | grep "NONE" | wc -l`
	total_available_scratch_tapes=`(echo "$total_scratch_tapes - $total_scratch_tapes_none") | bc`

	available_s_str=""
	available_is_are_str="is"
	if test $total_available_scratch_tapes -gt 1 ; then	
		available_s_str="s"
		available_is_are_str="are"
	fi
	none_s_str=""
	none_is_are_str="is"
	if test $total_available_scratch_tapes -ne $total_scratch_tapes ; then
		if test $total_scratch_tapes_none -gt 1 ; then	
			none_s_str="s"
			none_is_are_str="are"
		fi
	fi

	if test $total_available_scratch_tapes -le $error_ntapes ;then
		statusid=$status_error
		message_str="ERROR: There $available_is_are_str $total_available_scratch_tapes (<= ${error_ntapes}) tape$available_s_str in the scratch pool ($scratch_pool_name)!"
	elif test $total_available_scratch_tapes -le $warning_ntapes ;then
		statusid=$status_warning
		message_str="WARNING: There are $total_available_scratch_tapes (<= ${warning_ntapes}) tapes in the scratch pool ($scratch_pool_name)!"
	else
		statusid=$status_ok
		message_str="OK: There are $total_available_scratch_tapes tapes in the scratch pool ($scratch_pool_name)."
	fi
	if test $total_available_scratch_tapes -ne $total_scratch_tapes ; then
		message_str="$message_str $total_scratch_tapes_none tape$none_s_str $none_is_are_str assigned to the scratch pool, but not in the library!"
	fi
fi
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
