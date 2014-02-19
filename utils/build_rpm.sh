#!/bin/bash
#
# This script is used to build SisIYA RPM packages.
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
repo_dir=arch-repo.sisiya.org
rpms_dir=../RPMS

package_list="sisiya-client-checks sisiya-remote-checks sisiya-webui-php sisiya-webui-images sisiya-edbc-libs sisiyad"
package_list_any="sisiya-client-checks-${version}.noacrh.rpm sisiya-remote-checks-${version}.noarch.rpm sisiya-webui-php-${version}.noarch.rpm sisiya-webui-images-${version}.noarch.rpm"
package_list_x86_64="sisiyad-${version}.i686.rpm sisiya-edbc-libs-${version}.i686.rpm"
package_list_x86_64="sisiyad-${version}.x86_64.rpm sisiya-edbc-libs-${version}.x86_64.rpm"

## create repository directory structure
#for d in $repo_dir/os/any $repo_dir/os/i686 $repo_dir/os/x86_64
#do
#	mkdir -p $d
#done

for f in $package_list
do
	echo "Building $f-${version}.tar.gz ..."
	rpmbuild -ta rpm/$f-${version}.tar.gz
	echo "---------------------"
done

for f in $package_list_any
do
	ls -l $rpms_dir/noarch/$f
done
for f in $package_list_x86_64
do
	ls -l $rpms_dir/noarch/$f
done
