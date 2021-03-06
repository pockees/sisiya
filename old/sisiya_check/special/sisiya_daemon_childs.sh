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
serviceid=$serviceid_daemon_childs
if test -z "$serviceid" ; then
	echo "$0 : serviceid_daemon_childs is not defined! Exiting..."
	exit 1
fi

###############################################################################
### The format of error and warning eimes (elapsed time: The time how long a daeomon child is running) is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
### 3) warning_etime must be less than error_etime
###############################################################################
### There are no default values
### Example for sisiya_daemon_childs.conf file
###################################################################################
### Daemon(prog) name		warning elapsed time		error elapsed time
###################################################################################
#sshd				5:48				1:2:35
#vsftpd				0:30				1:38
### end of the example entries
###############################################################################
### There are no default values. The module conf file must exist.
if test ! -f $module_conf_file ; then
	statusid=$status_warning
	message_str="The configuration module file ($module_conf_file) for this service does not exist!"
else
	tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
	tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
	tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`
	tmp_error_count_file=`maketemp /tmp/tmp_error_count_${script_name}.XXXXXX`
	tmp_warning_count_file=`maketemp /tmp/tmp_warning_count_${script_name}.XXXXXX`

	for f in $tmp_file $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_error_count_file $tmp_warning_count_file
	do
		rm -f $f
		touch $f
	done

	cat $module_conf_file | grep -v "#" | while read -r line 
	do
		prog=`echo $line		| awk '{print $1}'`
		warning_etime=`echo $line	| awk '{print $2}'`
		error_etime=`echo $line		| awk '{print $3}'`

		str=`extract_datetime $error_etime`
		error_days=`echo $str		| awk '{print $1}'`
		error_hours=`echo $str		| awk '{print $2}'`
		error_minutes=`echo $str	| awk '{print $3}'`
		str=`extract_datetime $warning_etime`
		warning_days=`echo $str		| awk '{print $1}'`
		warning_hours=`echo $str	| awk '{print $2}'`
		warning_minutes=`echo $str	| awk '{print $3}'`

		error_in_minutes=`(echo "$error_days * 1440 + $error_hours * 60 + $error_minutes") | bc`
		warning_in_minutes=`(echo "$warning_days * 1440 + $warning_hours * 60 + $warning_minutes") | bc`

		prog_list_str=`ps -eo pid,ppid,etime,command | grep $prog`
		declare -i error_count=0 warning_count=0
		echo "$error_count"	> $tmp_error_count_file
		echo "$warning_count"	> $tmp_warning_count_file
		if test -n "$prog_list_str" ; then
			ps -eo pid,ppid,etime,command | grep "$prog" | grep -v grep | while read -r prog_line
			do
				pid=`echo $prog_line		| awk '{print $1}'`
				ppid=`echo $prog_line		| awk '{print $2}'`
				etime_str=`echo $prog_line	| awk '{print $3}'`
				c_prog=`echo $prog_line		| awk '{print $4}'`
				if test "$c_prog" != "$prog" ; then
					continue
				fi
				if test $ppid -eq 1 ; then
					continue
				fi
				str2=`extract_etime $etime_str`
				etime_days=`echo $str2		| awk '{print $1}'`
				etime_hours=`echo $str2		| awk '{print $2}'`
				etime_minutes=`echo $str2	| awk '{print $3}'`
				etime_in_minutes=`(echo "$etime_days * 1440 + $etime_hours * 60 + $etime_minutes") | bc`
				if test $etime_in_minutes -gt $error_in_minutes ; then
					error_count=error_count+1
					echo $error_count > $tmp_error_count_file
				elif test $etime_in_minutes -gt $warning_in_minutes ; then
					warning_count=warning_count+1
					echo $warning_count > $tmp_warning_count_file
				fi
			done
			error_count=`cat $tmp_error_count_file`
			warning_count=`cat $tmp_warning_count_file`
			if test $error_count -gt 0 ; then
				es_str=""
				if test $error_count -gt 1 ; then
					es_str="es"
				fi
				echo "ERROR: $prog : $error_count process$es_str running > `echo_datetime $error_days $error_hours $error_minutes`!" >> $tmp_error_file
			elif test $warning_count -gt 0 ; then
				es_str=""
				if test $warning_count -gt 1 ; then
					es_str="es"
				fi
				echo "WARNING: $prog : $warning_count process$es_str running > `echo_datetime $warning_days $warning_hours $warning_minutes`!" >> $tmp_warning_file
			else
				echo "OK: $prog." >> $tmp_ok_file
			fi
		fi
	done
	statusid=$status_ok
	message_str=""
	if test -s $tmp_error_file ; then
		message_str=`cat $tmp_error_file | tr "\n" " "` 
		statusid=$status_error
	fi
	
	if test -s $tmp_warning_file ; then
		message_str="$message_str`cat $tmp_warning_file | tr \"\n\" \" \"`" 
		if test $statusid -lt $status_warning ; then
			statusid=$status_warning
		fi 
	fi

	if test -s $tmp_ok_file ; then
		message_str="$message_str`cat $tmp_ok_file | tr \"\n\" \" \"`"
	fi
	
	for f in $tmp_file $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_error_count_file $tmp_warning_count_file
	do
		rm -f $f
	done
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
