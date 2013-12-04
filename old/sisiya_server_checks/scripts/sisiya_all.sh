#!/bin/bash
#
# This script executes all server checks.
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
#################################################################################
if test $# -ne 2 ; then
	echo "Usage : $0 sisiya_server_checks.conf expire"
	echo "expire must be specified in minutes."
	exit 1
fi

conf_file=$1
expire=$2

if test ! -f "$conf_file" ; then
	echo "$0 : SisIYA server checks configuration file $conf_file does not exist!"
	exit 1
fi

### source the config file
. $conf_file

for d in $sisiya_server_checks_dir $sisiya_server_checks_script_dir $sisiya_server_checks_conf_dir
do
	if test ! -d $d ; then
		echo "$0 : Directory $d does not exist!"
		exit 1
	fi
done

cd $sisiya_server_checks_script_dir 
if test $? -ne 0 ; then
	echo "$0 : Error : cd $sisiya_server_checks_script_dir"
	exit 1
fi
if test ! -x "$sisiya_remote_check_script" ; then
	echo "$0 : Error : The remote check script $sisiya_remote_check_script does not exist!"
	exit 1
fi

for f in sisiya_check_*_system.sh
do
	check_name=`echo $f | sed -e "s/sisiya_check_//" -e "s/_system.sh//"`
	#echo "$sisiya_remote_check_script $conf_file $check_name $expire"
	$sisiya_remote_check_script $conf_file $check_name $expire &
done
