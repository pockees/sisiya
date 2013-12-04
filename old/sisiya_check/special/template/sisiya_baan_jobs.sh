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
serviceid=$serviceid_baan_jobs
if test -z "$serviceid" ; then
	echo "$0 : serviceid_baan_jobs is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
### Oracle definitions
dbuser=system
dbpassword=manager
PATH=$PATH:/apps/oracle/product/10.2.0/db_1/bin
ORACLE_SID=BAAN 
tablespace_name=baan
ORACLE_HOME=/apps/oracle/product/10.2.0/db_1
NLS_LANG=american_america.WE8ISO8859P9 
NLS_NUMERIC_CHARACTERS=., 
### Baan definitions
baan_companyid=715
### end of the default values
##########################################################################

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	source $module_conf_file
fi

PATH=$PATH:$ORACLE_BIN
export PATH ORACLE_HOME ORACLE_SID NLS_LANG NLS_NUMERIC_CHARACTERS 

db_name=$ORACLE_SID

sql_file=`maketemp /tmp/${script_name}_sql.XXXXXX`
rm -f $sql_file

echo "SET LINESIZE 2000"	> $sql_file
echo "set colsep \"|\""		>> $sql_file
echo "set heading off"		>> $sql_file
echo "set newpage none"		>> $sql_file
echo "set numwidth 16"		>> $sql_file
echo "SET FEEDBACK OFF"		>> $sql_file
echo "select t\$cjob,t\$jsta from ${tablespace_name}.tttaad500${baan_companyid};" >> $sql_file
echo "exit" >> $sql_file

#cat $sql_file


sql_output_file=`maketemp /tmp/tmp_output_${script_name}.XXXXXX`

sqlplus -S ${dbuser}/${dbpassword}@${db_name} @$sql_file  > $sql_output_file
rm -f $sql_file

tmp_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`

cat $sql_output_file | while read line
do
	#echo "line=[$line]"
	job=`echo $line	| cut -d "|" -f 1`
	job_status=`echo $line	| cut -d "|" -f 2 | cut -d " " -f 2`
	case $job_status in
		"1")
			echo "OK: $job is free." 			>> $tmp_ok_file
			;;
		"2")
			echo "OK: $job is waiting." 			>> $tmp_ok_file
			;;
		"3")
			echo "OK: $job is running." 			>> $tmp_ok_file
			;;
		"4")
			echo "WARNING: $job is canceled."		>> $tmp_warning_file
			;;
		"5")
			echo "ERROR: $job has got runtime error!" 	>> $tmp_error_file
			;;
		"6")
			echo "OK: $job is in queue." 			>> $tmp_ok_file
			;;
		"7")
			echo "ERROR: $job is blocked!" 			>> $tmp_error_file
			;;
		*)
			echo "ERROR: $job has unknown status=$job_status!" >> $tmp_error_file
			;;
	esac
	#echo "job=[$job] job_status=[$job_status]"
done
	
statusid=$status_ok
message_str=""
if test -s $tmp_error_file ; then
	message_str=`cat $tmp_error_file | tr -s "\n" " "` 
	statusid=$status_error
fi

if test -s $tmp_warning_file ; then
	message_str="$message_str`cat $tmp_warning_file | tr -s "\n" " "`" 
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_ok_file ; then
	message_str="$message_str`cat $tmp_ok_file | tr -s "\n" " "`"
fi

for f in $sql_output_file $tmp_ok_file $tmp_warning_file $tmp_error_file
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
