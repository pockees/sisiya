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
#################################################################################
if test $# -ne 3 ; then
	echo "Usage   : $0 sisiya_server_checks.conf check_name expire"
	echo "Example : $0 sisiya_server_checks.conf http 10"
	echo "check_name : is the name of the remote check to run. In the case of check_name=http"
	echo "		there must be a corresponding script with the name sisiya_check_http_system.sh"
	echo "expire must be specified in minutes."
	exit 1
fi

conf_file=$1
check_name=$2
expire=$3
if test ! -f "$conf_file" ; then
	echo "$0 : configuration file $conf_file does not exist! exiting... "
	exit 1
fi

### source the config file
. $conf_file 
#################################################################################
for d in $sisiya_server_checks_dir
do
	if test ! -d "$d" ; then
		echo "$0 : Directory $d does not exist! Exiting..."
		exit 1
	fi
done 

a="sisiya_${check_name}_systems_file"
systems_file=${!a}
if test -z "$systems_file" ; then
	echo "$0 : The systems_file variable for $check_name is not set!"
	exit 1
fi

for f in $sisiya_client_conf_file $systems_file
do
	if test ! -f $f ; then
		echo "$0 : File $f does not exist! Exiting..."
		exit 1
	fi
done

### source the client config file
. $sisiya_client_conf_file 
##########################################################################
a="sisiya_${check_name}_check_script"
check_prog=${!a}
if test -z "$check_prog" ; then
	echo "$0 : The check_prog variable is not set!"
	exit 1
fi
if test ! -f $check_prog ; then
	echo "$0 : $check_prog check program does not exist! Exiting..."
	exit 1
fi
##########################################################################
lock_file="${sisiya_server_checks_dir}/lock_check_${check_name}.tmp"
pid=$$
#echo "check_name=$check_name $pid : lock_file=$lock_file"
if test -f $lock_file ; then
	#echo "$pid : A"
	pid=`cat $lock_file`
	str=`ps -ef | grep $pid`
	if test -z "$str" ; then
		#echo "$pid : A - if"
		rm -f $lock_file
	else
		#echo "$pid : A - else"
		echo "$0 is already running for ${check_name}!!!" | mail -s "SisIYA $0 is already running for ${check_name}!!! Exiting..." $admins_email
		echo "SisIYA $0 is already running for ${check_name}!!! Exiting..."
		exit 1
	fi
fi
echo "$$" > $lock_file
tmp_file=`mktemp /tmp/tmp_sisiya_check_${check_name}.XXXXXX`
touch $tmp_file

declare -i i
cat $systems_file | grep "<record>" | while read -r line
do	
#	echo "0: line=[$line]"
	isactive=`echo $line		| cut -d ">" -f 5	| cut -d "<" -f 1`
	if test "$isactive" = "f" ; then
		continue
	fi
#	echo "1: line=[$line]"
	line=`echo "$line" | sed -e "s/<record>//"  -e "s/<\/record>//" -e "s/<isactive>t<\/isactive>//"` 
#	echo "2: line=[$line]"
	n=`echo "$line" | tr ">" "\n" |wc -l`
       	n=`echo "$n / 2" | bc`
#	echo "Number of fields n=[$n - 1]"	
	###
	i=1
	str=""
	while test $i -le $n
	do
		c=`echo "$i * 2" | bc`
		f=`echo $line | cut -d ">" -f $c | cut -d "<" -f 1`
#		echo "i=$i f=[$f]"
		str="$str\"$f\" "
		i=i+1
	done
#	echo "str=[$str]"
	#echo "$check_prog $conf_file $str $expire $tmp_file"
	### there is a problem calling ssh for hpilo2 serially
	if test "$check_name" = "hpilo2" ; then
		$check_prog $conf_file $str $expire &
	else
		$check_prog $conf_file $str $expire $tmp_file
	fi
done
if test "$check_name" != "hpilo2" ; then
	if test -s $tmp_file ; then
		#echo "----------------tmp_file contents - start"
		#cat $tmp_file
		#echo "----------------tmp_file contents - end"
		${send_message2_prog} $sisiya_client_conf_file $tmp_file
	#else
		#echo "$pid : No messages to send for ${check_name}. The tmp_file is empty!"
	fi
fi
rm -f $lock_file $tmp_file
