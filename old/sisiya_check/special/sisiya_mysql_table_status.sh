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
serviceid=$serviceid_mysql_table_status
if test -z "$serviceid" ; then
	echo "$0 : serviceid_mysql_table_status is not defined! Exiting..."
	exit 1
fi

###############################################################################
### table_check_types are the valid options for the MySQL check table command : quick, fast, changed, medium, extended
### QUICK   : Do not scan the rows to check for incorrect links.
### FAST    : Check only tables that have not been closed properly.
### CHANGED : Check only tables that have been changed since the last check or that have not been closed properly.
### MEDIUM  : Scan rows to verify that deleted links are valid. This also calculates a key checksum for the rows 
###           and verifies this with a calculated checksum for the keys.
### EXTENDED : Do a full key lookup for all keys for each row. This ensures that the table is 100% consistent, but takes a long time.
###############################################################################
mysql_prog="/usr/bin/mysql"
dba_user="mysql"
dba_password="password"
### this is the mysql's default database, used only to check the MySQL connectivity
dba_mysql_database="mysql"
number_of_databases=1
db_name[0]=mysql
db_table_check_type[0]=extended
### end of the example entries
###############################################################################
### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file	
fi

tmp_error_file=`maketemp /tmp/tmp_${script_name}_error.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_${script_name}_ok.XXXXXX`
tmp_ok_file=`maketemp /tmp/tmp_${script_name}_ok.XXXXXX`
if test $number_of_databases -lt 1 ; then
        echo "WARNING: The total number of databases=$number_of_databases must be greater than 1!" >> $tmp_warning_file
fi
declare -i i=0
### check the connection to MySQL
$mysql_prog -u $dba_user -p${dba_password} -D $dba_mysql_database -NBt -e "show tables" > /dev/null 2>&1
retcode=$?
if test $retcode -ne 0 ; then
        echo "ERROR: Could not connect to MySQL using $dba_user and the supplied password!" >> $tmp_error_file
else
	while test $i -lt $number_of_databases
	do
	        dbname=${db_name[${i}]}
		check_type=${db_table_check_type[${i}]}
#echo "dbname=[$dbname] check_type=[$check_type]" 1>&2
		sql_str="show tables;"
		$mysql_prog -u $dba_user -p${dba_password} -D $dbname -NBt -e "$sql_str" | grep -v "^+" | while read -r line
		do
			table_name=`echo $line | awk -F "|" '{print $2}' | awk '{print $1}'`
#echo "dbname=[$dbname] check_type=[$check_type] Checking table $table_name" 1>&2
			sql_str="check table \`$table_name\` $check_type"
			### I should find another way of getting MySQL errors
			$mysql_prog -u $dba_user -p${dba_password} -D $dbname -NBt -e "$sql_str" > /dev/null 2>&1
			retcode=$?
			if test $retcode -ne 0 ; then
				echo "Error occured while executing sql=\"$sql_str\"" >> $tmp_error_file
			else
				$mysql_prog -u $dba_user -p${dba_password} -D $dbname -NBt -e "$sql_str" | grep -v "^+" | while read -r line2
				do
					### we are interested in the Msg_type status row
					type_str=`echo $line2 | awk -F "|" '{print $4}' | awk '{print $1}'`
#echo "line2=[$line2] type_str=[$type_str]" 1>&2
					if test "$type_str" != "status" ; then
						if test "$type_str" = "error"; then
							if test -z "`grep "$dbname-$table_name" $tmp_error_file`" ; then
								echo "$dbname-$table_name" >> $tmp_error_file
							fi
						fi
						if test "$type_str" = "warning" ; then
							if test -z "`grep "$dbname-$table_name" $tmp_warning_file`" ; then
								echo "$dbname-$table_name" >> $tmp_warning_file
							fi
						fi
						continue
					fi
					result=`echo $line2 | awk -F "|" '{print $5}'`
#echo "result=[$result]" 1>&2
					if test "$result" != " OK " && test "$result" != " Table is already up to date " ; then
						echo "$dbname-$table_name" >> $tmp_error_file
					#else
					#	echo "$dbname-$table_name" >> $tmp_ok_file
					fi
				done
			fi
		done
		i=i+1
	done
fi
statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	statusid=$status_error
	message_str="ERROR: "`cat $tmp_error_file | tr "\n" " "`
fi
if test -s $tmp_warning_file ; then
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi
	message_str="$message_str WARNING: `cat $tmp_warning_file | tr "\n" " "`"
fi
#if test -s $tmp_ok_file ; then
#	message_str="$message_str OK: `cat $tmp_ok_file | tr "\n" " "`"
#fi
i=0
str=""
while test $i -lt $number_of_databases
do
        dbname=${db_name[${i}]}
	str="$str $dbname"
	i=i+1
done
if test $statusid -eq $status_error ; then
	message_str="$message_str OK: The rest of the tables of the following dbs are ok: $str"
else
	message_str="$message_str OK: All tables of the following dbs are ok: $str"
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
