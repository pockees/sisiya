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
echo $version
repo_dir=arch-repo.sisiya.org

package_list="sisiya-client-checks sisiya-remote-checks sisiya-webui-php sisiya-webui-images sisiya-edbc-libs sisiyad"
package_list_any="sisiya-client-checks-${version}-any.pkg.tar.xz sisiya-remote-checks-${version}-any.pkg.tar.xz sisiya-webui-php-${version}-any.pkg.tar.xz sisiya-webui-images-${version}-any.pkg.tar.xz"
package_list_i686="sisiya-client-checks-${version}-any.pkg.tar.xz sisiya-remote-checks-${version}-any.pkg.tar.xz sisiya-webui-php-${version}-any.pkg.tar.xz sisiya-webui-images-${version}-any.pkg.tar.xz"
package_list_x86_64="sisiyad-${version}-x86_64.pkg.tar.xz sisiya-edbc-libs-${version}-x86_64.pkg.tar.xz sisiya-client-checks-${version}-any.pkg.tar.xz sisiya-remote-checks-${version}-any.pkg.tar.xz sisiya-webui-php-${version}-any.pkg.tar.xz sisiya-webui-images-${version}-any.pkg.tar.xz"

# create repository directory structure
for d in $repo_dir/os/any $repo_dir/os/i686 $repo_dir/os/x86_64
do
	mkdir -p $d
done

for f in $package_list_x86_64
do
	repo-add $repo_dir/os/x86_64/sisiya.db.tar.gz $f
	cp -f $f $repo_dir/os/x86_64/
done

for f in $package_list
do
	ls -l $f-${version}-*pkg.tar.xz
done
exit

for f in $package_list
do
	echo "Building $f-${version}.tar.gz ..."
	rm -f PKGBUILD
	ln -s PKGBUILD-$f-${version} PKGBUILD
	makepkg -f 
	echo "---------------------"
done
