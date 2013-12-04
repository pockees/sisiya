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
serviceid=$serviceid_netbackup_robots 
if test -z "$serviceid" ; then
	echo "$0 : serviceid_netbackup_robots is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
vmcheckxxx_prog=/usr/openv/volmgr/bin/vmcheckxxx
number_of_robots=1
robot_type[0]=tld
robot_number[0]=0
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi


if test ! -x $tpconfig_prog ; then
	statusid=$status_error
	message_str="ERROR: tpconfig program [$tpconfig_prog] does not exist or is not executable!"
	exit 0
fi

tmp_error_file=`maketemp /tmp/tmp_${script_name}_error.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_${script_name}_ok.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_${script_name}_ok.XXXXXX`
if test $number_of_robots -lt 1 ; then
        echo "WARNING: The total number of robots=$number_of_robots must be greater than 1!" >> $tmp_warning_file
fi

declare -i i=0
while test $i -lt $number_of_robots
do
        type=${robot_type[${i}]}
        number=${robot_number[${i}]}
	#echo "Checking robot type=$type number=$number ..."
	$vmcheckxxx_prog -rt $type -rn $number >/dev/null 2>&1
	retcode=$?
	if test $retcode -ne 0 ; then
		statusid=$status_error
		if test $retcode -eq 204 ; then
			echo "$error_str ERROR: Could not initialize robot : $vmcheckxxx_prog -rt $tpe -rn $number !" >> $tmp_error_file
		else
			echo "$error_str ERROR: There was a problem excecuting the command : $vmcheckxxx_prog -rt $tpe -rn $number !" >> $tmp_error_file
		fi
		break
	fi
	str=`$vmcheckxxx_prog -rt $type -rn $number | awk '{print $6}' | grep "Yes"`
	if test -z "$str" ; then
		echo "$ok_str OK: Robot $number type=${type}." >> $tmp_ok_file
	else
		$vmcheckxxx_prog -rt $type -rn $number | while read -r line
		do
			missmatch=`echo $line | awk '{print $6}'`
			if test "$missmatch" = "Yes" ; then
				robot_content=`echo $line | awk '{print $3}'`
				volume_config=`echo $line | awk '{print $5}'`
				echo "ERROR: There is missmatch for the robot number=$number type=$type robot content=$robot_content volume config=$volume_config!" >> $tmp_error_file
			fi
		done
	fi
        i=i+1
done
statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	statusid=$status_error
	message_str=`cat $tmp_error_file | tr "\n" " "`
fi
if test -s $tmp_warning_file ; then
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi
	message_str="$message_str `cat $tmp_warning_file | tr "\n" " "`"
fi
if test -s $tmp_ok_file ; then
	message_str="$message_str `cat $tmp_ok_file | tr "\n" " "`"
fi
for f in $tmp_ok_file $tmp_warning_file $tmp_error_file
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
