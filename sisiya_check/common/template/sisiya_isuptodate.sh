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
serviceid=$serviceid_isuptodate  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_isuptodate is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
apt_cache_prog=/usr/bin/apt-cache
apt_check_prog=/usr/lib/update-notifier/apt-check
pacman_prog=/usr/bin/pacman
yum_prog=/usr/bin/yum
zypper_prog=/usr/bin/zypper
### end of the default values
##########################################################################
### If there is no module conf file then exit with warning.
if test -f $module_conf_file ; then
	. $module_conf_file
fi

use_apt_check()
{
	n1=`$apt_check_prog 2>&1 | cut -d ";" -f 1`	
	n2=`$apt_check_prog 2>&1 | cut -d ";" -f 2`	
	n=`echo "$n1 + $n2" | bc`
	echo $n
}

use_pacman()
{
	#pacman --sync --refresh >/dev/null
	#pacman --query --upgrades
	$pacman_prog --sync --refresh >/dev/null
	n=`$pacman_prog --query --upgrades | wc -l`
	echo $n
}

use_yum()
{
	n=`$yum_prog -q list updates | grep -v "^Updated Packages" | grep -v "^Loaded plugins" | wc -l`
	echo $n
}

use_zypper()
{
	#n=`$zypper_prog --non-interactive list-updates | grep -v "Loading repository data" | grep -v "Reading installed packages" | grep -v "No updates found" |  wc -l`
	n=`$zypper_prog --non-interactive list-updates | grep "^v |" |  wc -l`
	echo $n
}

$yum_prog help update >/dev/null 2>&1
if test $? -eq 0 ; then
	n=`use_yum`
else
	$apt_cache_prog show apt >/dev/null 2>&1
	if test $? -eq 0 ; then
		n=`use_apt_check`
	else
		$zypper_prog --non-interactive help help >/dev/null 2>&1
		if test $? -eq 0 ; then
			n=`use_zypper`
		else
			$pacman_prog >/dev/null 2>&1
			if test $? -eq 0 ; then
				n=`use_pacman`
			else
				n=-1	
			fi
		fi
	fi
fi	

if test $n -eq -1 ; then
	statusid=$status_info
	message_str="INFO: Unsupported system for uptodate checking."
else
	if test $n -gt 0 ; then
		statusid=$status_warning
		message_str="WARNING: The system is out of date! There are $n available updates."
	else
		statusid=$status_ok
		message_str="OK: The system is uptodate."
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
