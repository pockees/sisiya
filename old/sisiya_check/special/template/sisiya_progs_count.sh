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
serviceid=$serviceid_progs_count  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_progs_count is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
### there are no default values for this check
#number_of_progs=2
#prog_name[0]="httpd"
#prog_warning_number[0]=70
#prog_error_number[0]=90
#prog_name[1]="mysqld"
#prog_warning_number[1]=40
#prog_error_number[1]=45
### end of the default values
##########################################################################

### If there is no module conf file then exit with warning.
if test ! -f $module_conf_file ; then
	statusid=$status_warning
	message_str="Configuration file $module_conf_file does not exist!"
	exit 0
fi
. $module_conf_file

tmp_error_file=`maketemp /tmp/tmp_${script_name}_error.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_${script_name}_ok.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_${script_name}_ok.XXXXXX`

declare -i i=0
while test $i -lt $number_of_progs
do
        prog=${prog_name[${i}]}
        error_number=${prog_error_number[${i}]}
        warning_number=${prog_warning_number[${i}]}
	n=`ps -ef|grep $prog | grep -v grep |wc -l`

	if test ${n} -ge $error_number ;then
		#echo "ERROR: The number of $prog processes exceeded the error number $n >= $error_number!" >> $tmp_error_file 
		echo "${prog}\($n >= ${error_number}\)" >> $tmp_error_file 
	elif test  ${n} -ge $warning_number ; then  
		#echo "WARNING: The number of $prog processes exceeded the warning number $n >= $warning_number!" >> $tmp_warning_file
		echo "${prog}\($n >= ${warning_number}\)" >> $tmp_warning_file
	else
		#echo "OK: The number of currently running $prog processes is $n." >> $tmp_ok_file
		echo "${prog}\(${n}\)" >> $tmp_ok_file
	fi
	i=i+1
done

statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	statusid=$status_error
	message_str="ERROR: "`cat $tmp_error_file | tr "\n" " "`"!"
fi
if test -s $tmp_warning_file ; then
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi
	message_str="$message_str WARNING: `cat $tmp_warning_file | tr "\n" " "`""!"
fi
if test -s $tmp_ok_file ; then
	message_str="$message_str OK: `cat $tmp_ok_file | tr "\n" " "`""."
fi
for f in $tmp_ok_file $tmp_warning_file $tmp_error_file $tmp_netstat_out
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
