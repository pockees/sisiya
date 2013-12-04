#!/bin/bash
#
# This script is used for database checks. It executes SISIYACheckDB, which is
# at the moment a Java programm. 
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
	echo "usage : $0 sisiya_server_checks.conf expire"
	echo "expire must be specified in minutes."
	exit 1
fi

sisiya_server_checks_conf_file=$1
expire=$2
if test ! -f "$sisiya_server_checks_conf_file" ; then
	echo "$0  : Configuration file $sisiya_server_checks_conf_file does not exist! Exiting... "
	exit 1
fi

### source the config file
. $sisiya_server_checks_conf_file 
#################################################################################
for d in "$sisiya_server_checks_dir" "$sisiya_server_checks_conf_dir" "$sisiya_server_checks_tmp_dir" "$jre_dir"
do
	#echo "$0: Checking for : $d"
	if test ! -d "$d" ; then
		echo "Directory $d does not exist! Exiting..."
		exit 1
	fi
done 

class_file=${sisiya_server_checks_conf_dir}/class_path
checkdb_properties_file=${sisiya_server_checks_tmp_dir}/SISIYACheckDB.properties

for f in $sisiya_client_conf_file $class_file
do
	if test ! -f $f ; then
		echo "File $f does not exist! Exiting..."
		exit 1
	fi
done

##########################################################################
### include java to the path
PATH=$PATH:${jre_dir}/bin
export PATH

### check if there is a running process
#declare -i pid_next
#pid=$$
#pid_next=$pid+1
#str=`ps -eo pid,command | grep "$0" | grep -v $pid_next | grep -v $pid | grep -v grep`
#if test -n "$str" ; then
# echo "$0 is already running!!!" | mail -s "SISIYA $0 is already running!!! Exiting..." $admins_email
# echo "SISIYA $0 is already running!!! Exiting..."
# exit 1
#fi
lock_file=${sisiya_server_checks_tmp_dir}/lock_check_dbs.tmp
if test -f $lock_file ; then
	pid=`cat $lock_file`
	str=`ps -ef | grep $pid`
	if test -z "$str" ; then
		rm -f $lock_file
	else
		echo "$0 is already running!!!" | mail -s "SISIYA $0 is already running!!! Exiting..." $admins_email
		echo "SISIYA $0 is already running!!! Exiting..."
		exit 1
	fi
fi
echo "$$" > $lock_file
	

. $class_file
. $sisiya_client_conf_file

### generate the SISIYACheckDB.properties
grep "status_" $sisiya_client_conf_file | grep -v "#"		>  $checkdb_properties_file
echo "send_message_prog=$send_message_prog" 			>> $checkdb_properties_file
echo "sisiya_client_conf_file=${sisiya_client_conf_file}" 	>> $checkdb_properties_file
echo "sisiya_service_expire=${expire}"			 	>> $checkdb_properties_file
grep "serviceid_" $sisiya_client_conf_file | grep -v "#"	>> $checkdb_properties_file

#echo "CLASSPATH=$CLASSPATH"
cd $sisiya_server_checks_conf_dir &&
for file in *_SISIYACheckDB.properties
do
	server=`echo $file | sed 's/_SISIYACheckDB.properties//'`
	#echo "java SISIYACheckDB $server"
	java SISIYACheckDB $server 
done 

rm -f $lock_file
