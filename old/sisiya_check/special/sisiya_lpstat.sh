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
serviceid=$serviceid_lpstat 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_lpstat is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi

tmp_lpstat_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_lpstat_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_lpstat_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_lpstat_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

for f in $tmp_lpstat_file $tmp_lpstat_ok_file $tmp_lpstat_warning_file $tmp_lpstat_error_file
do
	rm -f $f
	touch $f
done

if test "$sisiya_osname" = "SunOS" ; then
	grep_prog="/usr/xpg4/bin/grep"
else
	grep_prog="grep"
fi

lpstat -p | $grep_prog ^printer | while read line
do
#	printer_name=`echo $line	| awk '{print $2}'`
#	printer_status=`echo $line	| awk '{print $4}' | tr -d "."`
##	echo "printer_name=[$printer_name] printer_status=[$printer_status]"
#	case "$printer_status" in
#		"idle")
#			echo "OK: Printer $printer_name is ${printer_status}. " >> $tmp_lpstat_ok_file
#			;;
#		*)
#			echo "ERROR: Printer $printer_name is ${printer_status}!" >> $tmp_lpstat_error_file
#		;;
#	esac
##		echo "WARNING: Printer $printer_name is ${printer_status}!" >> $tmp_lpstat_warning_file_
	printer_name=`echo $line        | awk '{print $2}'`
	str=`echo $line | grep "is idle."`
	if test -n "$str" ; then
		printer_status=`echo $line      | awk '{print $4}' | tr -d "."`
		echo "OK: Printer $printer_name is ${printer_status}. " >> $tmp_lpstat_ok_file
	else
		str=`echo $line | grep "now printing"`
		if test -n "$str" ; then
			echo "OK: Printer $printer_name is printing. " >> $tmp_lpstat_ok_file
		else
			printer_status=`echo $line      | awk '{print $3}'`
			echo "ERROR: Printer $printer_name is ${printer_status} line=[$line]!" >> $tmp_lpstat_error_file
		fi
	fi
done

statusid=$status_ok
message_str=""
if test -s $tmp_lpstat_error_file ; then
	message_str=`cat $tmp_lpstat_error_file | tr -s "\n" " "` 
	statusid=$status_error
fi

if test -s $tmp_lpstat_warning_file ; then
	message_str="$message_str`cat $tmp_lpstat_warning_file | tr -s \"\\n\" \" \"`" 
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_lpstat_ok_file ; then
	message_str="$message_str`cat $tmp_lpstat_ok_file | tr -s \"\\n\" \" \"`"
fi

for f in $tmp_lpstat_file $tmp_lpstat_ok_file $tmp_lpstat_warning_file $tmp_lpstat_error_file $exclude_file $exceptions_file
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
