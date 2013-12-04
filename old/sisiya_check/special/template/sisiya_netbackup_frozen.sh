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
serviceid=$serviceid_netbackup_media
if test -z "$serviceid" ; then
	echo "$0 : serviceid_netbackup_media is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
### Error and warning values for the number of FROZEN or SUSPENDED tapes
error_ntapes=2
warning_ntapes=1
#
bpmedialist_prog=/usr/openv/netbackup/bin/admincmd/bpmedialist
### end of the default values
##########################################################################
printFrozenList()
{

	tmp_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
        $bpmedialist_prog | grep -B 1 "FROZEN" | grep -v "^--"| grep -v "FROZEN" | while read -r line
        do
               #echo "line=[$line]"
                id=`echo $line | awk '{print $1}'`
		echo "$id " >> $tmp_file
        done
	list_str=""
	if test -s $tmp_file ; then
		list_str=`cat $tmp_file | tr "\n" " "`
	fi
	rm -f $tmp_file
	echo "$list_str"
}


### If there is a module conf file then override these default values
module_conf_file=${sisiya_host_dir}/`echo $script_name | awk -F. '{ print $1 }'`.conf
if test -f $module_conf_file ; then
	. $module_conf_file
fi


if test ! -x $bpmedialist_prog ; then
	statusid=$status_error
	message_str="ERROR: $bpmedialist_prog program does not exist or is not executable!"
	exit 0
fi

total_frozen_tapes=`$bpmedialist_prog | grep "FROZEN" | wc -l`
retcode=$?
if test $retcode -eq 0 ; then

	if test $total_frozen_tapes -eq 0 ; then
		statusid=$status_ok
		message_str="There are no tapes that are in a FROZEN state."
	else
		#=`$bpmedialist_prog | grep -B 1 "FROZEN"|grep -v "^--"`
		s_str=""
		is_are_str="is"
		if test $total_frozen_tapes -gt 1 ; then	
			s_str="s"
			is_are_str="are"
		fi

		frozen_tapes=`printFrozenList`
		if test $error_ntapes -le $total_frozen_tapes ; then
			statusid=$status_error
			message_str="ERROR: $total_frozen_tapes (>= ${error_ntapes}) tape$s_str (${frozen_tapes}) $is_are_str FROZEN!"
		elif test $warning_ntapes -le $total_frozen_tapes ; then
			statusid=$status_warning
			message_str="WARNING: $total_frozen_tapes (>= ${warning_ntapes}) tape$s_str (${frozen_tapes}) $is_are_str FROZEN!"
		else
			statusid=$status_info
			message_str="INFO: There $is_are_str $total_frozen_tapes tape$s_str (${frozen_tapes}) in the FROZEN state."
		fi
	fi
else
		statusid=$status_error
		message_str="ERROR: There was a problem excecuting the command : $bpmedialist_prog !"
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
