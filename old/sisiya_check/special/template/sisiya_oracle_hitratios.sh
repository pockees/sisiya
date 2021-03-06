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
serviceid=$serviceid_oracle_hitratios  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_oracle_hitratios is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
from_dot_char=","
to_dot_char="."
warning_buffer_hitratio=95
error_buffer_hitratio=90
warning_library_hitratio=95
error_library_hitratio=90
warning_dictionary_hitratio=95
error_dictionary_hitratio=90
warning_sort_hitratio=95
error_sort_hitratio=90
warning_nowait_hitratio=95
error_nowait_hitratio=90
warning_buffer_pool_hitratio=95
error_buffer_pool_hitratio=90
db_name=TIGER
dba_user="system"
dba_password="manager"
### NLS_LANG is used for the comma seperator
NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P9
ORACLE_HOME=/DB/oracle/product/8.1.7
ORACLE_BIN=/DB/oracle/product/8.1.7/bin
### end of the default values
##########################################################################
### If there is a module conf file then override these default values
module_conf_file=${sisiya_host_dir}/`echo $script_name | awk -F. '{print $1}'`.conf
if test -f $module_conf_file ; then
	. $module_conf_file
fi

PATH=$PATH:$ORACLE_BIN
export PATH ORACLE_HOME NLS_LANG

# this did not help, that is why I used tr "," "." instead
#NLS_NUMERIC_CHARACTERS=". "
#export NLS_NUMERIC_CHARACTERS

export LC_NUMERIC="en_US.UTF-8"


sql_file=`maketemp /tmp/tmp_sisiya_oracle_hitratios_sql.XXXXXX`
### it is neede for some old sqlplus
mv $sql_file ${sql_file}.sql
sql_file="${sql_file}.sql"

echo "SET LINESIZE 200"	> $sql_file
echo "set heading off"	>> $sql_file
echo "set newpage none"	>> $sql_file
echo "set numwidth 16"	>> $sql_file
echo "SET FEEDBACK OFF"	>> $sql_file
echo "select (1-(sum(decode(name,'physical reads',value,0))/(sum(decode(name,'db block gets',value,0))+sum(decode(name,'consistent gets',value,0)))))*100  from v\$sysstat;" >> $sql_file
echo "exit" >> $sql_file
#buffer_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | awk '{print $1}' | awk -F. '{print $1}'`
#buffer_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | tr "," "." | awk '{print $1}'`
buffer_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | tr "$from_dot_char" "$to_dot_char" | awk '{print $1}'`
buffer_hitratio=`printf %.2f $buffer_hitratio`

### this is the v$ view, which gives the same buffer cache hit ratio as above (buffer_hitratio)
#echo "SET LINESIZE 200"	> $sql_file
#echo "set heading off"	>> $sql_file
#echo "set newpage none"	>> $sql_file
#echo "set numwidth 16"	>> $sql_file
#echo "SET FEEDBACK OFF"	>> $sql_file
#echo "select (1-(physical_reads/(db_block_gets+consistent_gets)))*100 from v\$buffer_pool_statistics;" >> $sql_file
#echo "exit" >> $sql_file
#buffer_pool_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | awk '{print $1}'`
#buffer_pool_hitratio=`printf %.2f $buffer_pool_hitratio`


echo "SET LINESIZE 200"	> $sql_file
echo "set heading off"	>> $sql_file
echo "set newpage none"	>> $sql_file
echo "set numwidth 16"	>> $sql_file
echo "SET FEEDBACK OFF"	>> $sql_file
echo "select (1-(sum(getmisses)/sum(gets)))*100 from v\$rowcache;" >> $sql_file
echo "exit" >> $sql_file
#dictionary_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | awk '{print $1}' | awk -F. '{print $1}'`
dictionary_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | tr "$from_dot_char" "$to_dot_char" | awk '{print $1}'`
dictionary_hitratio=`printf %.2f $dictionary_hitratio`

echo "SET LINESIZE 200"	> $sql_file
echo "set heading off"	>> $sql_file
echo "set newpage none"	>> $sql_file
echo "set numwidth 16"	>> $sql_file
echo "SET FEEDBACK OFF"	>> $sql_file
echo "select sum(Pins)/(sum(pins)+sum(Reloads))*100 from v\$librarycache;" >> $sql_file
echo "exit" >> $sql_file
#library_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | awk '{print $1}' | awk -F. '{print $1}'`
#library_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | tr "," "." | awk '{print $1}'`
library_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | tr "$from_dot_char" "$to_dot_char" | awk '{print $1}'`
library_hitratio=`printf %.2f $library_hitratio`

echo "SET LINESIZE 200"	> $sql_file
echo "set heading off"	>> $sql_file
echo "set newpage none"	>> $sql_file
echo "set numwidth 16"	>> $sql_file
echo "SET FEEDBACK OFF"	>> $sql_file
echo "select round((100*b.value)/decode((a.value+b.value),0,1,(a.value+b.value)),2) from v\$sysstat a, v\$sysstat b where a.name='sorts (disk)' and b.name='sorts (memory)';" >> $sql_file
echo "exit" >> $sql_file
sort_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | tr "$from_dot_char" "$to_dot_char" | awk '{print $1}'`
sort_hitratio=`printf %.2f $sort_hitratio`

echo "SET LINESIZE 200"	> $sql_file
echo "set heading off"	>> $sql_file
echo "set newpage none"	>> $sql_file
echo "set numwidth 16"	>> $sql_file
echo "SET FEEDBACK OFF"	>> $sql_file
echo "select ((sum(gets)-sum(waits))/sum(gets))*100 from v\$rollstat;" >> $sql_file
echo "exit" >> $sql_file
nowait_hitratio=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | tr "$from_dot_char" "$to_dot_char" | awk '{print $1}'`
nowait_hitratio=`printf %.2f $nowait_hitratio`

echo "SET LINESIZE 200"	> $sql_file
echo "set heading off"	>> $sql_file
echo "set newpage none"	>> $sql_file
echo "set numwidth 16"	>> $sql_file
echo "SET FEEDBACK OFF"	>> $sql_file
echo "select count(*) from v\$session where username is not null;" >> $sql_file
echo "exit" >> $sql_file
total_users=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | awk '{print $1}'`

echo "SET LINESIZE 200" > $sql_file
echo "set heading off"  >> $sql_file
echo "set newpage none" >> $sql_file
echo "set numwidth 16"  >> $sql_file
echo "SET FEEDBACK OFF" >> $sql_file
echo "select sum(value) from v\$sga;" >> $sql_file
echo "exit" >> $sql_file

sga_size=`sqlplus -S ${dba_user}/${dba_password}@${db_name} @$sql_file | tr "\n" " " | awk '{print $1}'`
sga_size_k=`(echo "$sga_size / 1024") | bc`
sga_size_str=`print_size_k $sga_size_k`

rm -f $sql_file

ok_str=""
warning_str=""
error_str=""
#echo "$buffer_hitratio"
if test `echo "$buffer_hitratio <= $error_buffer_hitratio" | bc` -eq 1 ; then
#if test `(echo "if($buffer_hitratio <= $error_buffer_hitratio) 1;if($buffer_hitratio > $error_buffer_hitratio) 0") | bc` -eq 1 ; then
	statusid=$status_error
	error_str="ERROR: Buffer cache hit ratio ${buffer_hitratio}% <= ${error_buffer_hitratio}%!"
elif test `(echo "if($buffer_hitratio <= $warning_buffer_hitratio) 1; if($buffer_hitratio > $warning_buffer_hitratio) 0") | bc` -eq 1 ; then
	statusid=$status_warning
	warning_str="WARNING: Buffer cache hit ratio ${buffer_hitratio}% <= ${warning_buffer_hitratio}%!"
else
	statusid=$status_ok
	ok_str="OK: Buffer cache hit ratio is ${buffer_hitratio}%."
fi

### the same as above (buffer_hitratio)
#if test `(echo "if($buffer_pool_hitratio <= $error_buffer_pool_hitratio) 1;if($buffer_pool_hitratio > $error_buffer_pool_hitratio) 0") | bc` -eq 1 ; then
#	statusid=$status_error
#	if test -n "$error_str" ; then
#		error_str="$error_str ERROR: Buffer pool hit ratio ${buffer_pool_hitratio}% <= ${error_buffer_pool_hitratio}%!"
#	else
#		error_str="ERROR: Buffer pool hit ratio ${buffer_pool_hitratio}% <= ${error_buffer_pool_hitratio}%!"
#	fi
#elif test `(echo "if($buffer_pool_hitratio <= $warning_buffer_pool_hitratio) 1;if($buffer_pool_hitratio > $warning_buffer_pool_hitratio) 0") | bc` -eq 1 ; then
#	if test $statusid -ne $status_error ; then
#		statusid=$status_warning
#	fi
#	if test -n "$warning_str" ; then
#		warning_str="$warning_str WARNING: Buffer pool hit ratio ${buffer_pool_hitratio}% <= ${warning_buffer_pool_hitratio}%!"
#	else
#		warning_str="WARNING: Buffer pool hit ratio ${buffer_pool_hitratio}% <= ${warning_buffer_pool_hitratio}%!"
#	fi
#else
#	if test -n "$ok_str" ; then
#		ok_str="$ok_str OK: Buffer pool hit ratio is ${buffer_pool_hitratio}%."
#	else
#		ok_str="OK: Buffer pool hit ratio is ${buffer_pool_hitratio}%."
#	fi
#fi

if test `(echo "if($dictionary_hitratio <= $error_dictionary_hitratio) 1;if($dictionary_hitratio > $error_dictionary_hitratio) 0") | bc` -eq 1 ; then
	statusid=$status_error
	if test -n "$error_str" ; then
		error_str="$error_str ERROR: Dictionary cache hit ratio ${dictionary_hitratio}% <= ${error_dictionary_hitratio}%!"
	else
		error_str="ERROR: Dictionary cache hit ratio ${dictionary_hitratio}% <= ${error_dictionary_hitratio}%!"
	fi
elif test `(echo "if($dictionary_hitratio <= $warning_dictionary_hitratio) 1;if($dictionary_hitratio > $warning_dictionary_hitratio) 0") | bc` -eq 1 ; then
	if test $statusid -ne $status_error ; then
		statusid=$status_warning
	fi
	if test -n "$warning_str" ; then
		warning_str="$warning_str WARNING: Dictionary cache hit ratio ${dictionary_hitratio}% <= ${warning_dictionary_hitratio}%!"
	else
		warning_str="WARNING: Dictionary cache hit ratio ${dictionary_hitratio}% <= ${warning_dictionary_hitratio}%!"
	fi
else
	if test -n "$ok_str" ; then
		ok_str="$ok_str OK: Dictionary cache hit ratio is ${dictionary_hitratio}%."
	else
		ok_str="OK: Dictionary cache hit ratio is ${dictionary_hitratio}%."
	fi
fi

if test `(echo "if($library_hitratio <= $error_library_hitratio) 1;if($library_hitratio > $error_library_hitratio) 0") | bc` -eq 1 ; then
	statusid=$status_error
	if test -n "$error_str" ; then
		error_str="$error_str ERROR: Library cache hit ratio ${library_hitratio}% <= ${error_library_hitratio}%!"
	else
		error_str="ERROR: Library cache hit ratio ${library_hitratio}% >= ${error_library_hitratio}%!"
	fi
elif test `(echo "if($library_hitratio <= $warning_library_hitratio) 1;if($library_hitratio > $warning_library_hitratio) 0") | bc` -eq 1 ; then
	if test $statusid -ne $status_error ; then
		statusid=$status_warning
	fi
	if test -n "$warning_str" ; then
		warning_str="$warning_str WARNING: Library cache hit ratio ${library_hitratio}% <= ${warning_library_hitratio}%!"
	else
		warning_str="WARNING: Library cache hit ratio ${library_hitratio}% >= ${warning_library_hitratio}%!"
	fi
else
	if test -n "$ok_str" ; then
		ok_str="$ok_str OK: Library cache hit ratio is ${library_hitratio}%."
	else
		ok_str="OK: Library cache hit ratio is ${library_hitratio}%."
	fi
fi

if test `(echo "if($sort_hitratio <= $error_sort_hitratio) 1;if($sort_hitratio > $error_sort_hitratio) 0") | bc` -eq 1 ; then
	statusid=$status_error
	if test -n "$error_str" ; then
		error_str="$error_str ERROR: Sort hit ratio ${sort_hitratio}% <= ${error_sort_hitratio}%!"
	else
		error_str="ERROR: Sort hit ratio ${sort_hitratio}% >= ${error_sort_hitratio}%!"
	fi
elif test `(echo "if($sort_hitratio <= $warning_sort_hitratio) 1;if($sort_hitratio > $warning_sort_hitratio) 0") | bc` -eq 1 ; then
	if test $statusid -ne $status_error ; then
		statusid=$status_warning
	fi
	if test -n "$warning_str" ; then
		warning_str="$warning_str WARNING: Sort hit ratio ${sort_hitratio}% <= ${warning_sort_hitratio}%!"
	else
		warning_str="WARNING: Sort hit ratio ${sort_hitratio}% >= ${warning_sort_hitratio}%!"
	fi
else
	if test -n "$ok_str" ; then
		ok_str="$ok_str OK: Sort hit ratio is ${sort_hitratio}%."
	else
		ok_str="OK: Sort hit ratio is ${sort_hitratio}%."
	fi
fi


if test `(echo "if($nowait_hitratio <= $error_nowait_hitratio) 1;if($nowait_hitratio > $error_nowait_hitratio) 0") | bc` -eq 1 ; then
	statusid=$status_error
	if test -n "$error_str" ; then
		error_str="$error_str ERROR: Nowait hit ratio ${nowait_hitratio}% <= ${error_nowait_hitratio}%!"
	else
		error_str="ERROR: Nowait hit ratio ${nowait_hitratio}% >= ${error_nowait_hitratio}%!"
	fi
elif test `(echo "if($nowait_hitratio <= $warning_nowait_hitratio) 1;if($nowait_hitratio > $warning_nowait_hitratio) 0") | bc` -eq 1 ; then
	if test $statusid -ne $status_error ; then
		statusid=$status_warning
	fi
	if test -n "$warning_str" ; then
		warning_str="$warning_str WARNING: Nowait hit ratio ${nowait_hitratio}% <= ${warning_nowait_hitratio}%!"
	else
		warning_str="WARNING: Nowait hit ratio ${nowait_hitratio}% >= ${warning_nowait_hitratio}%!"
	fi
else
	if test -n "$ok_str" ; then
		ok_str="$ok_str OK: Nowait hit ratio is ${nowait_hitratio}%."
	else
		ok_str="OK: Nowait hit ratio is ${nowait_hitratio}%."
	fi
fi


#message_str="$error_str $warning_str $ok_str"
message_str=""
if test -n "$error_str" ; then
	message_str=$error_str
fi
if test -n "$warning_str" ; then
	if test -n "$message_str" ; then
		message_str="$message_str $warning_str"
	else
		message_str="$warning_str"
	fi
fi
if test -n "$ok_str" ; then
	if test -n "$message_str" ; then
		message_str="$message_str $ok_str"
	else
		message_str="$ok_str"
	fi
fi
message_str="$message_str Number of active users is $total_users.  SGA size is $sga_size_str"
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
