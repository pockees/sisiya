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
#######################################################################################
### service id
serviceid=$serviceid_oracle_tablespace  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_oracle_tablespace is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
warning_percent=85
error_percent=90
db_name=TIGER
dba_user="system"
dba_password="manager"
ORACLE_HOME=/DB/oracle/product/8.1.7
ORACLE_BIN=/DB/oracle/product/8.1.7/bin
### end of the default values
##########################################################################

print_formated_size()
{
	result=`(echo "$1 / $2") | bc`
	rest=`(echo "($1 % $2)") | bc`
	rest=`(echo "scale=2; $rest / $2") | bc`
	if test "$rest" = "0" ; then
		echo "${result}$3" 
	else
		echo "${result}${rest}$3" 
	fi
}

print_size_k()
{
	if test $1 -eq 0 ; then
		echo "0"
	elif test $1 -lt 1024 ; then
		echo "${1}KB"
	elif test $1 -lt 1048576 ; then
		print_formated_size $1 1024 MB
	elif test $1 -lt 1073741824 ; then
		print_formated_size $1 1048576 GB
	elif test $1 -lt 1099511627776 ; then
		print_formated_size $1 1073741824 TB
	elif test $1 -lt 1125899906842624 ; then
		print_formated_size $1 1099511627776 PB
	elif test $1 -lt 1152921504606846976 ; then
		print_formated_size $1 1125899906842624 EB
	else
		print_formated_size $1 1125899906842624 EB
	fi
}

### If there is a module conf file then override these default values
module_conf_file=${sisiya_host_dir}/`echo $script_name | awk -F. '{print $1}'`.conf
if test -f $module_conf_file ; then
	. $module_conf_file
fi


tmp_oracletbs_ok_file=`maketemp /tmp/tmp_sisiya_oracle_tablespace_ok.XXXXXX`
tmp_oracletbs_warning_file=`maketemp /tmp/tmp_sisiya_oracle_tablespace_warning.XXXXXX`
tmp_oracletbs_error_file=`maketemp /tmp/tmp_sisiya_oracle_tablespace_error.XXXXXX`
sql_file=`maketemp /tmp/tmp_sisiya_oracle_tablespace_sql.XXXXXX`

for f in $tmp_oracletbs_ok_file $tmp_oracletbs_warning_file $tmp_oracletbs_error_file $sql_file
do
	rm -f $f
	touch $f
done
### for some old sqlplus
mv $sql_file ${sql_file}.sql 
sql_file="${sql_file}.sql"

ostype_str=`uname -s`
echo "SET LINESIZE 200" 	 > $sql_file
echo "set heading off" 		>> $sql_file
echo "set newpage none" 	>> $sql_file
echo "set numwidth 16" 		>> $sql_file
echo "SET FEEDBACK OFF" 	>> $sql_file
echo "select a.TABLESPACE_NAME, a.BYTES bytes_used, b.BYTES bytes_free, b.largest, round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) percent_used from ( select TABLESPACE_NAME, sum(BYTES) BYTES from dba_data_files group by TABLESPACE_NAME) a, (select TABLESPACE_NAME, sum(BYTES) BYTES,max(BYTES) largest from dba_free_space group by TABLESPACE_NAME) b where  a.TABLESPACE_NAME=b.TABLESPACE_NAME order by ((a.BYTES-b.BYTES)/a.BYTES) desc;" >> $sql_file
echo "exit" >> $sql_file

PATH=$PATH:$ORACLE_BIN
export PATH ORACLE_HOME
sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | while read -r line
do
	tablespace=`echo $line	| awk '{print $1}'`
	total_size=`echo $line	| awk '{print $2}'`
	total_size=`(echo "$total_size / 1024") | bc`
	total_size_str=`print_size_k $total_size`
	free_size=`echo $line	| awk '{print $3}'`
	free_size=`(echo "$free_size / 1024") | bc`
	free_size_str=`print_size_k $free_size`
	percent=`echo $line	| awk '{print $5}' | tr "," "."  | awk -F. '{print $1}'`
	if test -z "$percent" ; then
		percent="0"
	fi

	if test ${percent} -ge $error_percent ;then
		echo "ERROR: ${tablespace} $percent% >= $error_percent% of $total_size_str is full. " >> $tmp_oracletbs_error_file
	elif test ${percent} -ge $warning_percent  ; then  
		echo "WARNING: ${tablespace} $percent% >= $warning_percent% of $total_size_str is full. " >> $tmp_oracletbs_warning_file
	else
		echo "OK: ${tablespace} $percent% of $total_size_str is full. " >> $tmp_oracletbs_ok_file
	fi
done

statusid=$status_ok
message_str=""
if test -s $tmp_oracletbs_error_file ; then
	message_str=`cat $tmp_oracletbs_error_file | tr "\n" " "` 
	statusid=$status_error
fi

if test -s $tmp_oracletbs_warning_file ; then
	message_str="$message_str"`cat $tmp_oracletbs_warning_file | tr "\n" " "`
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_oracletbs_ok_file ; then
	message_str="$message_str"`cat $tmp_oracletbs_ok_file | tr "\n" " "`
fi

for f in $tmp_oracletbs_ok_file $tmp_oracletbs_warning_file $tmp_oracletbs_error_file $sql_file
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
