#!/bin/bash
#
#    Copyright (C) 2009  Erdal Mutlu
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
if test $# -ne 2 ; then
	echo "Usage : $0 header.template footer.template"
	exit 1
fi

header_file=$1
footer_file=$2
for f in $header_file $footer_file
do
	if test ! -f $f ; then
		echo "File : $f does not exist."
		exit 1
	fi
done

extension_str=".ps1"

for file in sisiya_*.template
do
	echo $file
	file=${file%.*}
	if test -f ${file}${extension_str} ;then
		echo "File : ${file}${extension_str} exists. Removing..."
		echo "rm -f ${file}${extension_str}"
	fi
	if test -f "${file}.header" ; then
		cat ${file}.header >  ${file}${extension_str}
	else
		cat $header_file >  ${file}${extension_str}
	fi
	cat ${file}.template  >> ${file}${extension_str}
	if test -f "${file}.footer" ; then
		cat ${file}.footer >>  ${file}${extension_str}
	else
		cat $footer_file >> ${file}${extension_str}
	fi
	chmod 700 ${file}${extension_str}
done
