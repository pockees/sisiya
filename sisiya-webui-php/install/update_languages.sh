#!/bin/bash
#
#  This script is used to update language for the web interface.
#
#    Copyright (C) 2003 - __YEAR__  Erdal Mutlu
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
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
###############################################################################
if test $# -ne 1 ; then
	echo "Usage   : $0 db_conf_file"
	echo "Example : $0 db_MySQL.conf"
	exit 1
fi

db_conf_file=$1
if test ! -f $conf_file ; then
	echo "Database configuration file $conf_file does not exist!"
	exit 1
fi

#source db_conf_file
. $db_conf_file
exec_sql_prog=./exec_${dbtype}.sh
language_strkeys_file="language_strkeys.xml"
for f in $exec_prog $db_conf_file $language_strkeys_file
do
	if test ! -f $f ; then
		echo "$0: File $f does not exist!"
		exit 1
	fi
done

getStrkeyID()
{
	tmp_file=tmp.txt
	echo "select id from strkeys where keystr='$1'" > $tmp_file
	strkeyid=`$exec_sql_prog $tmp_file $dbuser $dbname $db_conf_file`
	rm -f $tmp_file
	echo $strkeyid
}


getNextID()
{
	table_name=$1
	tmp_file=tmp.txt
	echo "select max(id) from $table_name" > $tmp_file
	maxid=`$exec_sql_prog $tmp_file $dbuser $dbname $db_conf_file`
	rm -f $tmp_file
	echo $maxid
}

checkStrkeys()
{
	keystr="$1"
	tmp_file=tmp.txt
	echo "select id from strkeys where keystr='$keystr'" > $tmp_file
	str=`$exec_sql_prog $tmp_file $dbuser $dbname $db_conf_file`
	retcode=$?
	#echo "exec_sql_prog=[$exec_sql_prog] dbuser=[$dbuser] dbname=[$dbname] db_conf_file=[$db_conf_file]" 
	#echo "keystr=[$keystr] str=[$str]"
	rm -f $tmp_file
	if test $retcode -ne 0 ; then
		echo $retcode
		return
	fi
	if test "$str" != "" ; then
		echo "1"
	else
		echo "0"
	fi
}

echo_insert_or_update_language()
{
	declare -i k=0

	action=$1
	keystr=$2
	strkeyid=$3
	### en is the default language
	f=language_en.xml
	str=`grep "^<record><strkey>${keystr}</strkey>" $f`
	if test -z "$str" ; then
		echo "You must have : $keystr in the default language file: language_en.xml!"
		exit 1
	fi
	#<record><strkey>sisiya.records.status.info</strkey> <value>Info</value></record>
	s=`echo $str | cut -d "<" -f 5 | cut -d ">" -f 2`
	if test "$s" = "" ; then
		k=k+1
		continue
	fi
	if test "$action" = "insert" ; then
		echo "insert into interface values($k,$strkeyid,'$s');"
	else
		echo "update interface set str='$s' where languageid=$k and strkeyid=$strkeyid;"
	fi
	k=k+1

	for f in $lang_files
	do
		str=`grep "<record><strkey>${keystr}</strkey>" $f`
		if test -z "$str" ; then
			k=k+1
			continue
		fi
		s=`echo $str | cut -d "<" -f 5 | cut -d ">" -f 2`
		if test "$s" == "" ; then
			k=k+1
			continue
		fi
		if test "$action" = "insert" ; then
			echo "insert into interface values($k,$strkeyid,'$s');"
		else
			echo "update interface set str='$s' where languageid=$k and strkeyid=$strkeyid;"
		fi
		k=k+1
	done
}

str=`ls language_??.xml 2> /dev/null`
if test  $? -ne 0 ; then
	echo "There are no language files (language_??.xml)!"
	exit 1
fi
lang_files=`echo $str | tr " " "\n" | grep -v language_en.xml | tr "\n" " "`

### number of languages
nlang=`ls -l language_??.xml | wc -l`
#echo "nlang=$nlang"


maxid=`getNextID "strkeys"`
maxid_file=maxid.txt
echo $maxid > $maxid_file
cat $language_strkeys_file | grep "record" | while read line
do
	#<record><strkey>sisiya.records.status.info</strkey> <definition>Info record in the status table</definition></record>
	s1=`echo $line | cut -d ">" -f 3 | cut -d "<" -f 1`
	s2=`echo $line | cut -d ">" -f 5 | cut -d "<" -f 1`
	retcode=`checkStrkeys $s1`
	#echo "retcode=[$retcode]"
	#echo "s1=[$s1] s2=[$s2]" 1>&2
	if test "$retcode" = "1" ; then
		strkeyid=`getStrkeyID $s1`
		echo_insert_or_update_language "update" $s1 $strkeyid
	else
		maxid=`cat $maxid_file`
		maxid=`echo "$maxid + 1" | bc`
		echo $maxid > $maxid_file
		echo "insert into strkeys values($maxid,'$s1','$s2');"
		echo_insert_or_update_language "insert" $s1 $maxid
	fi
	i=i+1
done
rm -f $maxid_file
