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
serviceid=$serviceid_users 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_users is not defined! Exiting..."
	exit 1
fi
##########################################################################
tmp_file=`maketemp /tmp/tmp.${script_name}.XXXXXX`

### default values
exception_hosts=""
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

#
### <users>16</users>
#
if test "$sisiya_osname" = "HP-UX" ; then
	who -R | grep "root" > $tmp_file
else
	who | grep "root" > $tmp_file
fi

for s in $exception_hosts
do
	str=`cat $tmp_file | grep -v  "$s"`
	echo "$str" > $tmp_file
done
str=`cat $tmp_file`
> $tmp_file
if test -n "$str" ; then
	#statusid=$status_error
	statusid=$status_warning
	message_str="User root is loged in\!"
	echo "$str" | while read line
	do 
		tty=`echo $line | awk '{print $2}'`
		### check whether the terminal dead is or not
		case "$sisiya_osname" in
			"OpenBSD"|"FreeBSD")
				str2=""
			;;
			*)
				str2=`who -d | grep $tty | grep -v grep`
			;;
		esac
		if test -z "$str2" ; then
			(echo "Welcome root! I hope you know what you are doing!" ;
			echo "This session is monitoring by the admins.";
			echo "Did you ask for help from your admins? Who knows, maybe they can help you?") | write root $tty > /dev/null 2>&1
		fi
	done
else
	statusid=$status_info
fi

echo "$message_str User list:"  > $tmp_file

str=`who`
if test -n "$str" ; then
	who | while read  line
	do
		user=`echo $line 	| awk '{print $1}'`
		host_str=`echo $line 	| awk '{print $6}'`
		echo " $user $host_str" >> $tmp_file
	done
	message_str=`cat $tmp_file | tr "\n" " "`
else
	message_str="No users loged in."
fi

rm -f $tmp_file
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
