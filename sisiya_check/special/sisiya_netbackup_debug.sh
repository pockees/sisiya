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
serviceid=$serviceid_netbackup_debug 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_netbackup_debug is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
netbackup_log_dir=/usr/openv/netbackup/logs
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

if test ! -d $netbackup_log_dir ; then
	statusid=$status_error
	message_str="ERROR: NetBackup log directory [${netbackup_log_dir}] does not exist! Please check the default value in the $script_name or in the $module_conf_file"
else
	tmp_file=`maketemp /tmp/tmp_${script_name}_XXXXXX`
	touch $tmp_file

	cd $netbackup_log_dir
	find . -type d -maxdepth 1 | while read -r dir
	do
		dir=`echo $dir | awk -F/ '{print $2}'`
		if test "$dir" = "user_ops" ; then
			continue
		else
			echo -n "$dir " >> $tmp_file
		fi
	done
	dir_str=`cat $tmp_file`
	rm -f $tmp_file
	if test -z "$dir_str" || test "$dir_str" = " " ; then
		statusid=$status_ok
		message_str="OK: Debugging is not activated."
	else
		statusid=$status_warning
		message_str="WARNING: Debugging is for [${dirs_str}] activated! If you do not do any debugging deactivate them."
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
