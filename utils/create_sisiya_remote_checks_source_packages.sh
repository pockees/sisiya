#!/bin/bash
#
# This script is used to generate SisIYA source packages for the sisiya-remote-checks package.
# The source packages are created in their corresponding directories (ex rpm, debian pacman etc).
# It uses the version information from the RPM spec file.
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
if test $# -lt 1 ; then
	echo "Usage: $0 sisiya_dir"
	echo "Usage: $0 sisiya_dir local_confs_dir"
	echo "Example: $0 /home/emutlu/sisiya"
	echo "Example: $0 /home/emutlu/sisiya /home/emutlu/mydir"
	exit 1
fi

sisiya_dir=$1

package_str="sisiya-remote-checks"

version_file=${sisiya_dir}/$package_str/version.txt
if test ! -f $version_file ; then
	echo "$0: Version file $version_file does not exist!"
	exit 1
fi
str=`cat $version_file`
version_str=`echo $str | cut -d "-" -f 1`
release_str=`echo $str | cut -d "-" -f 2`

if test ! -d $sisiya_dir ; then
	echo "Directory $sisiya_dir does not exist. Exiting..."
	exit 1
fi

# create output directories
for d in "rpm" "deb" "pacman"
do
	mkdir -p $d
done

package_dir="${package_str}-${version_str}-$release_str"
rm -rf $package_dir
mkdir -p $package_dir
cp -a ${sisiya_dir}/$package_str/* $package_dir/
echo "${version_str}-$release_str" > $package_dir/version.txt

mkdir -p $package_dir/etc/cron.d
cp ${sisiya_dir}/etc/cron.d/$package_str $package_dir/etc/cron.d/
if test $# -eq 1 ; then
	echo "Creating source package for general usage..."
else
	echo "Creating source package for you..."

	local_dir=$2
 	if test ! -d $local_dir ; then
		echo "$0 : Local configuration directory (local_confs_dir) does not exist!"
		exit 1
	fi
	if test -f ${local_dir}/$package_str/conf/SisIYA_Remote_Config_local.pl ; then
		echo "I am using your own SisIYA_Remote_Config_local.pl file (${local_dir}/$package_str/SisIYA_Remote_Config_local.pl) ..."
		cp -f ${local_dir}/$package_str/conf/SisIYA_Remote_Config_local.pl $package_dir/conf/

	fi
fi
################################################################################################################################################3
### create RPM source package
################################################################################################################################################3
rpm_dir="rpm/$package_dir"
rm -rf $rpm_dir
cp -a $package_dir $rpm_dir
cat $sisiya_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_dir/${package_str}.spec 
(cd rpm ; tar cfz ${package_dir}.tar.gz $package_dir)
rm -rf $rpm_dir
echo "RPM packaging info :"
echo "In order to build the SisIYA packages one can use the following command:"
echo "rpmbuild -ta rpm/${package_dir}.tar.gz"
echo "------"
################################################################################################################################################3
### create Debian source package
################################################################################################################################################3
###
deb_dir="deb/$package_dir"
rm -rf $deb_dir 
mkdir -p $deb_dir/opt/${package_str} 
for f in conf misc scripts version.txt utils
do
	cp -a $package_dir/$f ${deb_dir}/opt/${package_str}/ 
done
mkdir $deb_dir/DEBIAN
cat $sisiya_dir/packaging/debian/${package_str}-control 	| sed -e "s/__VERSION__/${version_str}/" > $deb_dir/DEBIAN/control 
cat $sisiya_dir/packaging/debian/${package_str}-postinst 	| sed -e "s/__VERSION__/${version_str}/" > $deb_dir/DEBIAN/postinst 
chmod 755 $deb_dir/DEBIAN/postinst
cp -a $package_dir/etc $deb_dir/ 
(cd deb ; tar cfz ${package_dir}.tar.gz $package_dir) 
rm -rf $deb_dir 
echo "Debian packaging info:"
echo "In order to build Debian package use the deb/${package_dir}.tar.gz archive file on a Debian system."
echo "Unpack the archive, move the directory to the same name and run the dpkg --build ${package_str} command."
echo "------"
################################################################################################################################################3
### create directory structure for Arch systems
################################################################################################################################################3
###
pacman_dir="pacman/$package_dir"
rm -rf $pacman_dir 
cp -a $package_dir $pacman_dir
cp -a ${package_dir}/etc $pacman_dir 
(cd pacman ; tar cfz ${package_dir}.tar.gz $package_dir )
md5sum_str=`md5sum pacman/${package_dir}.tar.gz | cut -d " " -f 1`
cat $sisiya_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > pacman/PKGBUILD-$package_dir
rm -rf $pacman_dir &&
echo "Pacman packaging info:"
echo "In order to build Pacman package use the pacman/${pacman_dir}.tar.gz archive and the pacman/PKGBUILD-${package_dir} on a Pacman system (makepkg)."
echo "------"
################################################################################################################################################3
### 
################################################################################################################################################3
# clean up
rm -rf $package_dir
################################################################################################################################################3
###
################################################################################################################################################3
