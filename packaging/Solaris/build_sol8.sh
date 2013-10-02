#!/bin/bash
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
#################################################################################
if test $# -ne 4 ; then
	echo "Usage : $0 sisiya_version sisiya_release sisiya_client_version sisiya_client_systems_version"
	echo "Example : $0 0.4 12 6"
	exit 1
fi
version=$1
release=$2
client_release=$3
client_systems_release=$4
sisiya_dir=sisiya-${version}-$release
src_package=${sisiya_dir}.tar.gz
make_package=${sisiya_dir}/packaging/Solaris/make_solaris_package.sh

if test ! -f $src_package ; then
	echo "File $src_package does not exist. Exiting..."
	exit 1
fi
gunzip -c $src_package | tar -xf -
chown -R root:root $sisiya_dir
./$make_package /root/${sisiya_dir} ${version}.${client_release}-$release ${version}.${client_systems_release}-$release 
