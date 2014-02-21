#!/bin/bash
#
#  This script is used to create language sql for the web interface.
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
language_strkeys_file="language_strkeys.xml"
if test ! -f $language_strkeys_file ; then
	echo "File $language_strkeys_file does not exist!"
	exit 1
fi

str=`ls language_??.xml 2> /dev/null`
if test  $? -ne 0 ; then
	echo "There are no language files (language_??.xml)!"
	exit 1
fi
lang_files=`echo $str | tr " " "\n" | grep -v language_en.xml | tr "\n" " "`

### number of languages
nlang=`ls -l language_??.xml | wc -l`
#echo "nlang=$nlang"


declare -i i=1 j k
cat $language_strkeys_file | grep "record" | while read line
do
	#<record><strkey>sisiya.records.status.info</strkey> <definition>Info record in the status table</definition></record>
	s1=`echo $line | cut -d ">" -f 3 | cut -d "<" -f 1`
	s2=`echo $line | cut -d ">" -f 5 | cut -d "<" -f 1`
	echo "insert into strkeys values($i,'$s1','$s2');"
	k=0
	### en is the default language
	f=language_en.xml
		str=`grep "^<record><strkey>${s1}</strkey>" $f`
		if test -z "$str" ; then
			echo "You must have : $s1 in the default language file: language_en.xml!"
			exit 1
			k=k+1
			continue
		fi
		#<record><strkey>sisiya.records.status.info</strkey> <value>Info</value></record>
		s=`echo $str | cut -d "<" -f 5 | cut -d ">" -f 2`
		if test "$s" = "" ; then
			k=k+1
			continue
		fi
		echo "insert into interface values($k,$i,'$s');"
	k=k+1

	for f in $lang_files
	do
		str=`grep "<record><strkey>${s1}</strkey>" $f`
		if test -z "$str" ; then
			k=k+1
			continue
		fi
		s=`echo $str | cut -d "<" -f 5 | cut -d ">" -f 2`
		if test "$s" == "" ; then
			k=k+1
			continue
		fi
		echo "insert into interface values($k,$i,'$s');"
		k=k+1
	done
	i=i+1
done
