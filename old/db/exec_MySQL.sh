#!/bin/bash
#
# This script is used for varios DB operations, such as create user, drop etc.
# This is for MySQL's mysql client.
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
if [ $# -lt 1 ]; then
	echo "Usage   : $0 file.sql [db_user db_name db.conf]"
	echo "Default : $0 file.sql mysql mysql db_MySQL.conf"
	echo "Example : $0 file.sql"
	echo "Example : $0 file.sql mysql"
	echo "Example : $0 file.sql mysql mysql"
	echo "Example : $0 file.sql mysql mysql db_MySQL.conf"
	echo "Example : $0 file.sql sisiyauser sisiya db_MySQL.conf"
	exit 1
fi

sql_file=$1

if test ! -f $sql_file ; then 
	echo "File : $sql_file does not exist!"
	exit 1
fi

args="--batch --silent"
user="mysql"
if test $# -ge 2 ; then
	user="$2"
fi
args="$args --user $user"

if test $# -ge 3 ; then 
	args="$args $3"
else
	args="$args mysql"
fi 

if test $# -eq 4 ; then
	if test ! -f "$4" ; then
		echo "DB conf file $4 does not exist!"
		exit 1
	fi 
	### source the file
	. $4
	db_server="localhost"
	if test -n "$dbserver" ; then
		db_server="$dbserver"
	fi
	password=""
	if test "$2" = "$dbuser" ; then
		password="$dbpassword"
	elif test "$2" = "$dbauser" ; then
	password="$dbapassword"
	fi 
	if test -n "$password" ; then
		mysql --host $db_server --password=$password $args < $sql_file
	else
		mysql --host $db_server --password $args < $sql_file
	fi
else
	echo "Enter user    : $user"
	mysql --password $args < $sql_file
fi
