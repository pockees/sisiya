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
if test $# -ne 1 ; then
	echo "$0: Usage : $0 conf_file"
	exit 1
fi
conf_file=$1
if test ! -f $conf_file ; then
	echo "File $conf_file does not exist!"
	exit 1
fi

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
echo "<systems>"
cat $conf_file | grep -v "#" | while read x
do
	f1=`echo $x| awk '{print $1}'`
	f2=`echo $x| awk '{print $2}'`
	f3=`echo $x| awk '{print $3}'`
	f4=`echo $x| awk '{print $4}'`
	echo "<record><system_name>$f2</system_name><isactive>t</isactive><hostname>$f1</hostname><packets_to_send>$f3</packets_to_send><timeout_to_wait>$f4</timeout_to_wait></record>"
done
echo "</systems>"

