#!/bin/bash
#
# This script is used to copy source SisIYA source packages to sourceforge.
#
#    Copyright (C) Erdal Mutlu
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
	echo "Usage: $0 version"
	echo "Example: $0 0.6.30"
	exit 1
fi
version_str=$1
server_str="emutlu@frs.sourceforge.net:/home/frs/project/sisiya/sisiya/$version_str"


for d in "deb" "pacman" "rpm"
do
	if test ! -d $d ; then
		echo "Directory $d does not exist. Exiting..."
		exit 1
	fi
done


for d in "dep" "pacman" "rpm"
do
	#In order to copy files to sourceforge.net :
	for f in $d/sisiya*${version}.tar.gz
	do
		echo "Copying $f to $server_str/$d ..."
		scp $f $server_str/$d/
	done
done
