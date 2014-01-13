#!/bin/bash
#
# This script is used to generate SisIYA source packages for all components.
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
	echo "Usage: $0 sisiya_dir"
	echo "Example: $0 /home/emutlu/sisiya"
	exit 1
fi
sisiya_dir=$1

if test ! -d $sisiya_dir ; then
	echo "Directory $sisiya_dir does not exist. Exiting..."
	exit 1
fi

version_file=${sisiya_dir}/packaging/version.txt
if test ! -f $version_file ; then
	echo "$0: Version file $version_file does not exist!"
	exit 1
fi
str=`cat $version_file`
version_str=`echo $str | cut -d "-" -f 1`
release_str=`echo $str | cut -d "-" -f 2`

source_name="sisiya-${version_str}-$release_str"
source_package="${source_name}.tar.gz"
source_dir="source-name"

# create output directories
for d in "rpm" "deb" "pacman" "src" "tmp"
do
	mkdir -p $d
done

cd tmp
rm -rf $source_dir
cp -a $sisiya_dir $source_dir
rm -rf $source_dir/.git
tar cfz $source_package $source_dir
mv -f $source_package ../src
echo "SisIYA source package $source_package is ready."
#create_sisiya_client_checks_source_packages.sh  create_sisiya_remote_checks_source_packages.sh
################################################################################################################################################
# clean up
###rm -rf $tmp_dir
################################################################################################################################################
