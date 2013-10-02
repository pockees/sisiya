#!/bin/bash
#
# This script is used for adding a new message to the SMT system
# Created by Erdal Mutlu 05.12.2003
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

#############################################################################
### funcions
#############################################################################
echo_usage()
{
 echo "Usage : $0 db.conf message"
}

org_get_max_status()
{
 sql_str="select statusid from systemservicestatus where systemid=$1;"
 echo "$sql_str" > $tmp_sql_file
 str=`$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file`
 max_status=0
 if [ -n "$str" ]; then
  for sid in $str
  do
   if [ $sid -gt $max_status ]; then
    max_status=$sid 
   fi 
  done
 fi
}

get_max_status1()
{
 sql_str="select max(statusid) from systemservicestatus where systemid=$1;"
 echo "$sql_str" > $tmp_sql_file
 str=`$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file`
 max_status=$str
}



get_max_status()
{
 get_max_status1 $1
# echo "max_status=$max_status"
 if [ $max_status -gt 1 ]; then
 sql_str="select a.statusid,b.str,c.str from systemservicestatus a,services b,status c where a.serviceid=b.id and a.statusid=c.id and systemid=$1  and c.id > 1 order by statusid desc;"
  echo "$sql_str" > $tmp_sql_file

  rm -f $tmp_file
  local_str1=""
  $exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file | while read -r line
  do
  #echo "line=$line"
   sid=`echo $line | awk '{print $1}'`
   local_str2=`echo $line | awk '{print $2}'`
   status_str=`echo $line | awk '{print $3}'`
   local_str1="$local_str1 $local_str2($status_str)"
   echo -n "$local_str1" > $tmp_file
  done
  local_str1=`cat $tmp_file`
  echo "$max_status;$local_str1"
 else
  echo "$max_status;"
 fi 
}

get_systemid()
{
# echo "param=$1"
 s=`echo $1 | grep "\."`
# echo "s=$s"
 if [ -z "$s" ]; then
  sql_str="select id from systems where hostname='"$1"';"
 else 
  sql_str="select id from systems where fullhostname='"$1"';"
 fi
 echo "$sql_str" > $tmp_sql_file
 str=`$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file`
# echo "sql_str=$sql_str"

 if [ -n "$str" ]; then
  systemid=$str
 else
  systemid=-1
 fi
}
#############################################################################
### end of functions
#############################################################################

if [ $# -ne 2 ]; then
 echo_usage
 exit 1
fi

conf_file=$1
message_line="$2"

base_dir=/home/emutlu/erdal/devcvs/smt
#base_dir=/ev/erdal/erdal/cvs/dev/smt

conf_file=${base_dir}/db/$1
if [ ! -f $conf_file ]; then
 echo "$0 : Database configuration file $conf_file does not exist!"
 exit 1
fi
### source the conf file
. $conf_file

exec_sql_prog=${base_dir}/db/exec_${dbtype}.sh

if [ ! -x $exec_sql_prog ]; then
 echo "$0 : SQL script prog $exec_sql_prog does not exist!"
 exit 1
fi

tmp_file=/tmp/tmp_$$.tmp
tmp_sql_file=/tmp/tmp_sql_$$.tmp
touch $tmp_file $tmp_sql_file

#del="!"
#echo "message=$message_line"
### The first character must be the delimiter
del=${message_line:0:1}
serviceid=`echo $message_line	| cut -d "$del" -f 2`
statusid=`echo $message_line	| cut -d "$del" -f 3`
hostname=`echo $message_line	| cut -d "$del" -f 4`
date_str=`echo $message_line	| cut -d "$del" -f 5`
message=`echo $message_line	| cut -d "$del" -f 6`
#echo "del=$del, serviceid=$serviceid, statusid=$statusid, hostname=$hostname, date=$date_str, message=$message"

### Get systemid
get_systemid $hostname
if [ $systemid -eq -1 ]; then
 echo "$0 : Unknown system : $hostname"
 exit 1 
fi
#echo "systemid=$systemid serviceid=$serviceid statusid=$statusid"
#str=`get_max_status $systemid`
#max_status=`echo $str | awk -F ";" '{print $1}'`
#systemstatus_message=`echo $str | awk -F ";" '{print $2}'`
#echo "max_status=$max_status"
#echo "systemstatus_message=$systemstatus_message"
#exit

### Populate systemservice table
#sql_str="insert into systemservice values($systemid,$serviceid,1);"
#echo $sql_str > $tmp_sql_file
#$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file
#retcod=$?

### For systemihistorystatus table
#sql_str="insert into systemhistorystatus values('"$date_str"',$systemid,$serviceid,$statusid,now(),'"$message"');"
sql_str="insert into systemhistorystatus values(now(),$systemid,$serviceid,$statusid,now(),'"$message"');"
echo $sql_str > $tmp_sql_file
$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file
retcod=$?
#echo "after insert into systemhistorystatus retcod=$retcod"


### For systemservicestatus table
sql_str="select statusid from systemservicestatus where systemid=$systemid and serviceid=$serviceid;"
echo "$sql_str" > $tmp_sql_file
#echo "Results of : $sql_str"
str=`$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file`
#echo "str=$str"
if [ -n "$str" ]; then
 #echo "str is not null : update"
 old_status=$str
 if [ $statusid -ne $old_status ]; then
  sql_str="update systemservicestatus set statusid=$statusid,changetime=now(),updatetime=now(),str='"$message"' where systemid=$systemid and serviceid=$serviceid;"
 else
  sql_str="update systemservicestatus set updatetime=now(),str='"$message"' where systemid=$systemid and serviceid=$serviceid;"
 fi 
 #echo "sql=$sql_str"
 echo "$sql_str" > $tmp_sql_file
 $exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file
 retcod=$?
else
 #echo "str is null : insert"
 sql_str="insert into systemservicestatus values($systemid,$serviceid,$statusid,now(),now(),'"$message"');"
 echo $sql_str > $tmp_sql_file
 $exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file
 retcod=$?
fi

#echo "after systemservicestatus retcod=$retcod"

### For systemstatus table
sql_str="select statusid from systemstatus where systemid=$systemid;"
echo "$sql_str" > $tmp_sql_file
str=`$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file`

str1=`get_max_status $systemid`
max_status=`echo $str1 | awk -F ";" '{print $1}'`
systemstatus_message=`echo $str1 | awk -F ";" '{print $2}'`
## If max_status is Info or OK
if [ $max_status -lt 2 ]; then
 message="System is OK"
else
 message="$systemstatus_message"
fi
#echo "max_status=$max_status system_statusid=$str statusid=$statusid serviceid=$serviceid systemstatus_message=$systemstatus_message message=$message"

if [ -n "$str" ]; then
 system_statusid=$str
 if [ $max_status -ne $system_statusid ]; then
  if [ $statusid -eq $max_status ]; then
   sql_str="update systemstatus set statusid=$max_status,changetime=now(),updatetime=now(),str='"$message"' where systemid=$systemid;"
  else
   sql_str="update systemstatus set statusid=$max_status,updatetime=now(),str='"$message"' where systemid=$systemid;"
  fi
 else
  if [ $statusid -eq $system_statusid ]; then
   sql_str="update systemstatus set updatetime=now(),str='"$message"' where systemid=$systemid;"
  else
   sql_str="update systemstatus set updatetime=now() where systemid=$systemid;"
  fi
 fi 
 #echo "sql=$sql_str"
 echo "$sql_str" > $tmp_sql_file
 $exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file
 retcod=$?
else
 #echo "str is null : insert"
 sql_str="insert into systemstatus values($systemid,$max_status,now(),now(),'"$message"');"
 echo $sql_str > $tmp_sql_file
 $exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file
 retcod=$?
 #echo "sql=$sql_str"
fi
#echo "after systemstatus retcod=$retcod"
rm -f $tmp_file $tmp_sql_file
exit $retcod
