#!/bin/sh
#
# This script is used to make symbolic links for hostnames.
# It uses the links.txt file as input. The file consist of lines containing
# name gif_file_name, where gif_file_name is the name of a file where
# name.gif is going to be linked. Lines containing # are ignored.
# 
#
#    Copyright (C) 2003  Erdal Mutlu
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

usage()
{
	echo "Usage : $0 links_file link|unlink"
}

remove_all_link_files()
{
	for f in *
	do
		if test -h $f ; then
			rm -f $f
		fi
	done
}

if test $# -ne 2 ; then 
	usage
	exit 1
fi

links_file=$1
par="$2"

if test ! -f $links_file ; then
	echo "$0 : Links file $links_file does not exist! Exiting..."
	exit 1
fi

if test "$par" != "link" -a "$par" != "unlink" ; then
	echo "$0 : Unknown option : $par"
	usage
	exit 1
fi 

remove_all_link_files

if test "$par" = "link" ; then
	cat $links_file | grep -v "#" | while read -r line
	do
		name=`echo $line	| awk '{print $1}'`
		gif_file=`echo $line	| awk '{print $2}'`
		ln -sf $gif_file ${name}.gif
	done
fi
exit 0
