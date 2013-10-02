#!/bin/bash
#
# This script is used for varios DB operations, such as create user, drop etc.
# This is for PostgreSQL's psql client.
#
#    Copyright (C) 2003 - __YEAR__ Erdal Mutlu
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
if test $# -lt 1 ; then
 echo "Usage   : $0 file.sql [dbuser dbname db.conf]"
 echo "Default : $0 file.sql postgres template1 db_PostgreSQL.conf"
 echo "Example : $0 file.sql"
 echo "Example : $0 file.sql postgres"
 echo "Example : $0 file.sql postgres template1"
 echo "Example : $0 file.sql postgres template1 db_PostgreSQL.conf"
 echo "Example : $0 file.sql sisiyauser sisiya db_PostgreSQL.conf"
 exit 1
fi

sql_file=$1

if test ! -f $sql_file ; then 
 echo "File : $sql_file does not exist!"
 exit 1
fi

args="-q --file $sql_file"
user="postgres"
if test -n "$2" ; then
 user="$2"
fi 
args="$args --user $user"

if test $# -ge 3 ; then
 args="$args --dbname $3"
else
 args="$args --dbname template1"
fi 

if test $# -eq 4 ; then
 if test ! -f "$4" ; then
  echo "DB conf file $4 does not exist!"
  exit 1
 fi 
 source $4
 db_server="localhost"
 if test -n "$dbserver" ; then
  db_server="$dbserver"
 fi
 password=""
 #if test "$2" = "$dbuser" ; then
 # password="$dbpassword"
 #elif test "$2" = "$dbauser" ; then
 # password="$dbapassword"
 #fi 
 echo "User    : $user"
 if test -n "$password" ; then
  psql --host $db_server $args --password=$password 
 else
  psql --host $db_server $args --password
 fi
else
 echo "User    : $user"
 psql $args 
fi 
