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
serviceid=$serviceid_ntpstat
if test -z "$serviceid" ; then
	echo "$0 : serviceid_ntpstat is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
ntpstat_prog=/usr/bin/ntpstat
ntpq_prog=/usr/sbin/ntpq
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi


str=`$ntpstat_prog 2>/dev/null`
retcode=$?
str="\("`echo "$str" | tr -s "\n" " "`"\)"
statusid=$status_error
case "$retcode" in
	"0")
		### but it must not be synchronized to its local clock
		str2=`echo $str | grep -v "to local net"`
		if test -z "$str2" ; then
			statusid=$status_error
			message_str="ERROR: The system clock is not synchronized! It is synchronized to its local clock! $str"
		else
			statusid=$status_ok
			message_str="OK: The system clock is synchronized. $str" 
		fi
	;;
	"1")
		message_str="ERROR: The system clock is not synchronized! $str" 
	;;
	"2")
		message_str="ERROR: The system clock is not synchronized! Could not contact the ntp daemon! $str" 
	;;
	"127")
		str=`$ntpq_prog -np 2>&1 | grep "Connection refused"`
		if test -n "$str" ; then
			message_str="ERROR: Time server (ntpd) is not running!" 
		else
			str=`$ntpq_prog -np | grep -v "=" | grep "*" | cut -d " " -f 1 | cut -d "*" -f 2 2>/dev/null`
			retcode=$?
			str=""`echo "$str" | tr -s "\n" " "`""
			message_str="$str" 
			case "$retcode" in
				"0")
					if test -n "$str" && test "$str" != " " ; then
						statusid=$status_ok
						ip_str=`echo $str | cut -d "." -f 1|grep 127`
						if test -z "$ip_str" ; then
							message_str="OK: This system clock is synchronized to $str." 
						else
							statusid=$status_warning
							message_str="WARNING: The system clock is synchronized to the localhost! $str" 
						fi
					else
						statusid=$status_warning
						message_str="WARNING: The system clock is not yet synchronized!" 
					fi
				;;
				*)
					message_str="ERROR: The system clock is not synchronized! Unknown return code $retcode!" 
				;;
			esac
		fi 

	;;
	*)
		message_str="ERROR: Unknown return code=$retcode from ntpstat! $str" 
	;;
esac
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
