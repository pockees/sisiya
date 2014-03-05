#!/bin/bash
#
# This script is used to build SisIYA debian packages.
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
	exit 1
fi
version="$1"
echo $version
machine_arch=`uname -m`

package_list_noarch="sisiya-client-checks sisiya-remote-checks sisiya-webui-php sisiya-webui-images"
#package_list="sisiya-client-checks sisiyad-${version} sisiya-edbc-libs-${version}"
package_list="sisiya-client-checks sisiya-remote-checks sisiya-webui-images sisiya-webui-php sisiyad"

for f in $package_list
do
	echo "Building ${f}_${version}.orig.tar.gz ..."
	tar xfz ${f}_${version}.orig.tar.gz
	#cd ${f}-${version} && debuild 
	cd ${f}-${version} && debuild -k7F640C1A
	cd ..
	echo "---------------------"
done

ls -l *${version}*.deb
