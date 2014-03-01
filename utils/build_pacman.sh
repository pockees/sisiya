#!/bin/bash
#
# This script is used to build SisIYA pacman packages.
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
release="1"
march=`uname -m`
echo $version
repo_dir=arch-repo.sisiya.org

package_list="sisiya-client-checks sisiya-remote-checks sisiya-webui-php sisiya-webui-images sisiya-edbc-libs sisiyad"
package_list_any="sisiya-client-checks sisiya-remote-checks sisiya-webui-php sisiya-webui-images"
package_list_binary="sisiyad sisiya-edbc-libs"

# create repository directory structure
for d in $repo_dir/os/any $repo_dir/os/i686 $repo_dir/os/x86_64
do
	mkdir -p $d
done

for f in $package_list
do
	echo "Building $f-${version}.tar.gz ..."
	rm -f PKGBUILD
	ln -s PKGBUILD-$f-${version} PKGBUILD
	makepkg -f 
	echo "---------------------"
done

for f in $package_list_any
do
	packaged_file=${f}-${version}-${release}-any.pkg.tar.xz
	repo-add $repo_dir/os/$march/sisiya.db.tar.gz ${f}-${version}-${release}-any.pkg.tar.xz
	cp -f $packaged_file $repo_dir/os/$march
done

for f in $package_list_binary
do
	packaged_file=${f}-${version}-${release}-${march}.pkg.tar.xz
	repo-add $repo_dir/os/$march/sisiya.db.tar.gz $packaged_file
	cp -f $packaged_file $repo_dir/os/$march
done

for f in $package_list
do
	ls -l $f-${version}-*pkg.tar.xz
done
