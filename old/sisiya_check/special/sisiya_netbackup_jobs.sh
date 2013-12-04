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
serviceid=$serviceid_netbackup_jobs  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_netbackup_jobs is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
bpdbjobs_prog=/usr/openv/netbackup/bin/admincmd/bpdbjobs
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

if test ! -x $bpdbjobs_prog ; then
	statusid=$status_error
	message_str="ERROR: bpdbjobs program [$bpdbjobs_prog] does not exist or is not executable!"
	exit 0
fi

str=`$bpdbjobs_prog -summary -all_columns`
queued_jobs=`echo $str 		| awk -F, '{print $2}'	| awk -F= '{print $2}'`
requeued_jobs=`echo $str 	| awk -F, '{print $3}'	| awk -F= '{print $2}'`
active_jobs=`echo $str 		| awk -F, '{print $4}'	| awk -F= '{print $2}'`
ok_jobs=`echo $str 		| awk -F, '{print $5}'	| awk -F= '{print $2}'`
partially_ok_jobs=`echo $str 	| awk -F, '{print $6}'	| awk -F= '{print $2}'`
failed_jobs=`echo $str 		| awk -F, '{print $7}'	| awk -F= '{print $2}'`
incomplete_jobs=`echo $str 	| awk -F, '{print $8}'	| awk -F= '{print $2}'`
suspended_jobs=`echo $str 	| awk -F, '{print $9}'	| awk -F= '{print $2}'`
total_jobs=`echo $str 		| awk -F, '{print $10}'	| awk -F= '{print $2}'`

info_str="(total=${total_jobs} failed=${failed_jobs} suspended=${suspended_jobs} incomplete=${incomplete_jobs} successful=${ok_jobs} partially successful=${partially_ok_jobs} active=${active_jobs} requeued=${requeued_jobs} queued=${queued_jobs})"
statusid=$status_ok
message_str="OK: No failed jobs. $info_str"

if test $incomplete_jobs -gt 0 ;then
	statusid=$status_warning
	warning_str="WARNING: $incomplete_jobs backup jobs"
	if test $incomplete_jobs -eq 1 ; then
		warning_str="$warning_str is incomplete!" 
	else
		warning_str="$warning_str are incomplete!" 
	fi
	message_str="$warning_str $info_str"
fi
if test $failed_jobs -gt 0 ; then
	if test $statusid -eq $status_warning ; then	
		message_str="ERROR: $failed_jobs backup jobs had failed! $warning_str $info_str" 
	else
		message_str="ERROR: $failed_jobs backup jobs had failed! $info_str" 
	fi
	statusid=$status_error
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
