#!/bin/bash
#
#  This script is used to create language sql for the web interface.
#
#    Copyright (C) 2008  Erdal Mutlu
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
###############################################################################
if test ! -f language_descriptions.txt ; then
	echo "File language_descriptions.txt does not exist!"
	exit 1
fi

str=`ls language_??.txt 2> /dev/null`
if test  $? -ne 0 ; then
	echo "There are no language files (language_??.txt)!"
	exit 1
fi
lang_files=`echo $str | tr " " "\n" | grep -v language_en.txt | tr "\n" " "`

### number of languages
nlang=`ls -l language_??.txt | wc -l`
#echo "nlang=$nlang"


declare -i i=1 j k
cat language_descriptions.txt | while read line
do
	s1=`echo $line | cut -d "'" -f 2`
	s2=`echo $line | cut -d "'" -f 4`
	echo "insert into strkeys values($i,'$s1','$s2');"
	k=0
	### en is the default language
	f=language_en.txt
		str=`grep "^'${s1}'" $f`
		if test -z "$str" ; then
			echo "You must have : $s1 in the default language file: language_en.txt!"
			exit 1
			k=k+1
			continue
		fi
		s=`echo $str | cut -d "'" -f 4`
		if test "$s" = "" ; then
			k=k+1
			continue
		fi
		echo "insert into interface values($k,$i,'$s');"
	k=k+1

	for f in $lang_files
	do
		str=`grep "^'${s1}'" $f`
		if test -z "$str" ; then
			k=k+1
			continue
		fi
		s=`echo $str | cut -d "'" -f 4`
		if test "$s" == "" ; then
			k=k+1
			continue
		fi
		echo "insert into interface values($k,$i,'$s');"
		k=k+1
	done
	i=i+1
done
