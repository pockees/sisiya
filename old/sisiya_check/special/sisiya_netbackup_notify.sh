#!/bin/bash
#
#    Copyright (C) 2003  Erdal Mutlu
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
if test $# -lt 6 ; then
	echo "Usage : $0 sisiya_client.conf expire n p1 p2 ... pn"
	echo "expire must be specified in minutes. expire=0 means not to expire"
	echo "n : 1=start, 2=end"
	echo "p1,p2,... are the other parameters. Those params are strictly defined for the n values"
	echo "If n=1 => start notify, then p1=CLIENTNAME p2=POLICYNAME p3=SCHEDNAME p4=SCHEDTYPE"
	echo "If n=2 => end notify,   then p1=CLIENTNAME p2=POLICYNAME p3=SCHEDNAME p4=SCHEDTYPE p5=STATUS"
	echo "If n=3 => successfull backup notify, then p1=CLIENT p2=the name of the program performing the backup p3=backup image name"
	echo "If n=4 => diskfull notify, then p1=the name of the program p2=file p3=path"
	exit 1
fi

#######################################################################################################################
### For n=1 bpstart_notify
### Put the following code at the end of the /usr/openv/netbackup/bin/bpstart_notify scripts
### The expire time in minutes after which the check expires. expire=0 means not to expire
#expire=0
#/opt/sisiya_check/special/sisiya_netbackup_notify.sh /opt/sisiya_check/sisiya_client.conf $expire 1 $1 $2 $3 $4 &
#exit 0
#######################################################################################################################

#######################################################################################################################
### For n=2 backup_exit_notify 
### Put the following code at the end of the /usr/openv/netbackup/bin/backup_exit_notify script
### The expire time in minutes after which the check expires. expire=0 means not to expire
#expire=0
#/opt/sisiya_check/special/sisiya_netbackup_notify.sh /opt/sisiya_check/sisiya_client.conf $expire 2 $1 $2 $3 $4 $5 &
#######################################################################################################################


#######################################################################################################################
### For n=3 backup_notify 
### Put the following code at the end of the /usr/openv/netbackup/bin/backup_notify script on the media servers
### The expire time in minutes after which the check expires. expire=0 means not to expire
#expire=0
### I have added PROG=$1 above
#/opt/sisiya_check/special/sisiya_netbackup_notify.sh /opt/sisiya_check/sisiya_client.conf $expire 3 $CLIENT $PROG $IMAGE &
#######################################################################################################################

#######################################################################################################################
### For n=4 diskfull_notify 
### The expire time in minutes after which the check expires. expire=0 means not to expire
#expire=0
#/opt/sisiya_check/special/sisiya_netbackup_notify.sh /opt/sisiya_check/sisiya_client.conf $expire 4 $1 $2 $thedir &
#######################################################################################################################

client_conf_file=$1
expire=$2
n=$3
case $n in
	1)
		### start notify
		status=""
		client_name=$4
		policy_name=$5
		schedule_name=$6
		schedule_type=$7

	;;
	2)
		### end notify
		client_name=$4
		policy_name=$5
		schedule_name=$6
		schedule_type=$7
		status=$8
	;;
	3)
		### Successfull backup notify
		client_name=$4
		backup_prog_name=$5
		backup_image_name=$6
	;;
	4)
		### Successfull backup notify
		diskfull_prog_name=$4
		diskfull_file=$5
		diskfull_path=$6
	;;
	*)
		echo "$0 : n=$n is not defined!"
		exit 1
	;;
esac

if test ! -f $client_conf_file ; then
	echo "$0 : SisIYA client configuration file $client_conf_file does not exist!"
	exit 1
fi

script_name=`basename $0`
sisiya_osname=`uname -s`
### source the config file
. $client_conf_file
#######################################################################################
### service id
serviceid=$serviceid_netbackup_notify  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_netbackup_notify is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
module_conf_file=${sisiya_host_dir}/`echo $script_name | awk -F. '{ print $1 }'`.conf
if test -f $module_conf_file ; then
	. $module_conf_file
fi

case $n in
	1)
		### start notify
		status=""
		statusid=$status_info
		case "$schedule_type" in
			"FULL")
				message_str="Full"
			;;
			"INCR")
				message_str="Differential incremental"
			;;
			"CINC")
				message_str="Cumulative incremental"
			;;
			*)
				message_str="$schedule_type"
			;;
		esac
		message_str="INFO: $message_str backup started on $client_name - policy $policy_name schedule ${schedule_name}."
	;;
	2)
		### end notify
		case "$schedule_type" in
			"FULL")
				message_str="Full"
			;;
			"INCR")
				message_str="Differential incremental"
			;;
			"CINC")
				message_str="Cumulative incremental"
			;;
			*)
				message_str="$schedule_type"
			;;
		esac
		case "$status" in
			"0")
				statusid=$status_ok
				message_str="OK: $message_str backup successfuly finished on $client_name - policy $policy_name schedule ${schedule_name}."
			;;
			"1")
				statusid=$status_warning
				message_str="WARNING: $message_str backup partial successfully finished on $client_name - policy $policy_name schedule ${schedule_name}!"
			;;
			*)
				statusid=$status_error
				message_str="ERROR: $message_str $schedule_type backup failed with status=$status on $client_name - policy $policy_name schedule ${schedule_name}!"
			;;
		esac
	;;
	3)
		statusid=$status_ok
		message_str="OK: Backup successfully finished on $client_name by $backup_prog_name on image ${backup_image_name}."
	;;
	4)
		statusid=$status_error
		message_str="OK: The $diskfull_prog_name could not write $diskfull_file in the $diskfull_path directory!"
	;;
	*)
		statusid=$status_error
		message_str="ERROR: Unknown option n=$n is given to the SisIYA check script!"
	;;

esac
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire str=$message_str"
#if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "$message_str"
	#exit $?
	### we must not disdurb NetBackup
	exit 0
#else
#	echo "$sisiya_hostname $serviceid $statusid $expire $message_str" >> $output_file
#fi
###################################################################################################
