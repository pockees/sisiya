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
release_str="1"

create_sisiyad()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5

	package_str="sisiyad"
	package_name="${package_str}-${version_str}-$release_str"
	package_dir="$base_dir/tmp/${package_name}"
	version_major_str=`echo $version_str | cut -d "." -f 1,2`
	version_minor_str=`echo $version_str | cut -d "." -f 3`

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir -p $package_dir
	cp -a ${source_dir}/doc $package_dir/
	cp -a ${source_dir}/edbc $package_dir/
	cp -a ${source_dir}/etc $package_dir/
	for f in "AUTHORS" "ChangeLog" "COPYING" "INSTALL" "Makefile.am" "bootstrap"  "configure.ac" "NEWS" "README"
	do
		cp -a ${source_dir}/$f $package_dir/
	done
	cp -a ${source_dir}/$package_str $package_dir/
	echo "$version_str" > $package_dir/version.txt
	echo "$version_str" > $package_dir/edbc/version.txt
	echo "$version_str" > $package_dir/$package_str/version.txt
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec 
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "RPM packaging info :"
	echo "In order to build the SisIYA packages one can use the following command:"
	echo "rpmbuild -ta $base_dir/rpm/${package_name}.tar.gz"
	echo "------"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	rm -rf $deb_root_dir 
	cp -a $package_dir $deb_root_dir
	mkdir $deb_root_dir/DEBIAN
	cat $source_dir/packaging/debian/${package_str}-control 	| sed -e "s/__VERSION__/${version_str}/" > $deb_root_dir/DEBIAN/control 
	cat $source_dir/packaging/debian/${package_str}-postinst 	| sed -e "s/__VERSION__/${version_str}/" > $deb_root_dir/DEBIAN/postinst 
	chmod 755 $deb_root_dir/DEBIAN/postinst
	(cd $base_dir/deb ; tar cfz ${package_name}.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "Debian packaging info:"
	echo "In order to build Debian package use the $deb_root_dir/${package_name}.tar.gz archive file on a Debian system."
	echo "Unpack the archive, move the directory to the same name and run the dpkg --build ${package_name} command."
	echo "------"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	(cd $base_dir/pacman ; tar cfz ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	rm -rf $pacman_root_dir &&
	echo "Pacman packaging info:"
	echo "In order to build Pacman package use the $base_dir/pacman/${package_name}.tar.gz archive and the $base_dir/pacman/PKGBUILD-${package_name} on a Pacman system (makepkg)."
	echo "------"
}


create_edbc_libs()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5

	package_str="sisiya-edbc-libs"
	package_name="${package_str}-${version_str}-$release_str"
	package_dir="$base_dir/tmp/${package_name}"
	version_major_str=`echo $version_str | cut -d "." -f 1,2`
	version_minor_str=`echo $version_str | cut -d "." -f 3`

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir -p $package_dir
	cp -a ${source_dir}/edbc/* $package_dir/
	echo "$version_str" > $package_dir/version.txt
	#sed -i -e "s/__VERSION_MAJOR__/$version_major_str/g" -e "s/__VERSION_MINOR__/$version_minor_str/g" -e "s/__VERSION__/$version_str/g" $package_dir/Makefile
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec 
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "RPM packaging info :"
	echo "In order to build the SisIYA packages one can use the following command:"
	echo "rpmbuild -ta $base_dir/rpm/${package_name}.tar.gz"
	echo "------"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	rm -rf $deb_root_dir 
	cp -a $package_dir $deb_root_dir
	mkdir $deb_root_dir/DEBIAN
	cat $source_dir/packaging/debian/${package_str}-control 	| sed -e "s/__VERSION__/${version_str}/" > $deb_root_dir/DEBIAN/control 
	cat $source_dir/packaging/debian/${package_str}-postinst 	| sed -e "s/__VERSION__/${version_str}/" > $deb_root_dir/DEBIAN/postinst 
	chmod 755 $deb_root_dir/DEBIAN/postinst
	(cd $base_dir/deb ; tar cfz ${package_name}.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "Debian packaging info:"
	echo "In order to build Debian package use the $deb_root_dir/${package_name}.tar.gz archive file on a Debian system."
	echo "Unpack the archive, move the directory to the same name and run the dpkg --build ${package_name} command."
	echo "------"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	(cd $base_dir/pacman ; tar cfz ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	rm -rf $pacman_root_dir &&
	echo "Pacman packaging info:"
	echo "In order to build Pacman package use the $base_dir/pacman/${package_name}.tar.gz archive and the $base_dir/pacman/PKGBUILD-${package_name} on a Pacman system (makepkg)."
	echo "------"
}

create_remote_checks()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5

	package_str="sisiya-remote-checks"
	package_name="${package_str}-${version_str}-$release_str"
	package_dir="$base_dir/tmp/${package_name}"

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir -p $package_dir
	cp -a ${source_dir}/$package_str/* $package_dir/
	echo "${version_str}-$release_str" > $package_dir/version.txt

	mkdir -p $package_dir/etc/cron.d
	cp ${source_dir}/etc/cron.d/$package_str $package_dir/etc/cron.d/
	if test -z "$local_dir" ; then
		echo "Creating source package for general usage..."
	else
		echo "Creating source package for you..."

	 	if test ! -d $local_dir ; then
			echo "$0 : Local configuration directory (local_confs_dir) does not exist!"
			exit 1
		fi
		if test -f ${local_dir}/$package_str/conf/SisIYA_Remote_Config_local.pl ; then
			echo "I am using your own SisIYA_Remote_Config_local.pl file (${local_dir}/$package_str/SisIYA_Remote_Config_local.pl) ..."
			cp -f ${local_dir}/$package_str/conf/SisIYA_Remote_Config_local.pl $package_dir/conf/
		fi
	fi
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec 
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "RPM packaging info :"
	echo "In order to build the SisIYA packages one can use the following command:"
	echo "rpmbuild -ta $base_dir/rpm/${package_dir}.tar.gz"
	echo "------"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	rm -rf $deb_root_dir 
	mkdir -p $deb_root_dir/opt/${package_str} 
	for f in conf misc scripts version.txt utils
	do
		cp -a $package_dir/$f ${deb_root_dir}/opt/${package_str}/ 
	done
	mkdir $deb_root_dir/DEBIAN
	cat $source_dir/packaging/debian/${package_str}-control 	| sed -e "s/__VERSION__/${version_str}/" > $deb_root_dir/DEBIAN/control 
	cat $source_dir/packaging/debian/${package_str}-postinst 	| sed -e "s/__VERSION__/${version_str}/" > $deb_root_dir/DEBIAN/postinst 
	chmod 755 $deb_root_dir/DEBIAN/postinst
	cp -a $package_dir/etc $deb_root_dir/ 
	(cd $base_dir/deb ; tar cfz ${package_name}.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "Debian packaging info:"
	echo "In order to build Debian package use the $deb_root_dir/${package_name}.tar.gz archive file on a Debian system."
	echo "Unpack the archive, move the directory to the same name and run the dpkg --build ${package_name} command."
	echo "------"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	cp -a ${package_dir}/etc $pacman_root_dir 
	(cd $base_dir/pacman ; tar cfz ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	rm -rf $pacman_root_dir &&
	echo "Pacman packaging info:"
	echo "In order to build Pacman package use the $base_dir/pacman/${package_name}.tar.gz archive and the $base_dir/pacman/PKGBUILD-${package_name} on a Pacman system (makepkg)."
	echo "------"
}

create_client_checks()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5

	package_str="sisiya-client-checks"
	package_name="${package_str}-${version_str}-$release_str"
	package_dir="$base_dir/tmp/${package_name}"

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir -p $package_dir/systems
	cp -a $source_dir/$package_str/* $package_dir/
	echo "${version_str}-$release_str" > $package_dir/version.txt

	mkdir -p $package_dir/etc/cron.d
	cp ${source_dir}/etc/cron.d/$package_str $package_dir/etc/cron.d/
	if test -z "$local_dir" ; then
		echo "Creating source package for general usage..."
	else
		echo "Creating source package for you..."
		### remove default files, this directory is owned by the sisiya-client-systems package
		rm -rf $package_dir/systems/*

	 	if test ! -d $local_dir ; then
			echo "$0 : Local configuration directory (local_confs_dir) does not exist!"
			exit 1
		fi
		if test -f ${local_dir}/$package_str/SisIYA_Config_local.pl ; then
			echo "I am using your own SisIYA_Config_local.pl file (${local_dir}/sisiya-client-checks/SisIYA_Config_local.pl) ..."
			cp -f ${local_dir}/$package_str/SisIYA_Config_local.pl $package_dir/
		fi
	fi
	### end of common package directory for all package types (rpm, deb, pacman ...)
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec   | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "RPM packaging info :"
	echo "In order to build the SisIYA packages one can use the following command:"
	echo "rpmbuild -ta $base_dir/rpm/${package_str}.tar.gz"
	echo "------"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	rm -rf $deb_root_dir 
	mkdir -p $deb_root_dir/opt/${package_str} 
	for f in common misc special version.txt SisIYA_Config.pm SisIYA_Config_local.pl utils
	do
		cp -a $package_dir/$f ${deb_root_dir}/opt/${package_str}/ 
	done
	mkdir $deb_root_dir/DEBIAN ${deb_root_dir}/opt/${package_str}/systems 
	cat $source_dir/packaging/debian/${package_str}-control 	| sed -e "s/__VERSION__/${version_str}/" > $deb_root_dir/DEBIAN/control 
	cat $source_dir/packaging/debian/${package_str}-postinst 	| sed -e "s/__VERSION__/${version_str}/" > $deb_root_dir/DEBIAN/postinst 
	chmod 755 $deb_root_dir/DEBIAN/postinst
	cp -a $package_dir/etc $deb_root_dir/ 
	(cd $base_dir/deb ; tar czf ${package_name}.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "Debian packaging info:"
	echo "In order to build Debian package use the $deb_root_dir/${package_str}.tar.gz archive file on a Debian system."
	echo "Unpack the archive, move the directory to the same name and run the dpkg --build ${package_str} command."
	echo "------"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	cp -a ${package_dir}/etc $pacman_root_dir 
	(cd $base_dir/pacman ; tar czf ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	rm -rf $pacman_root_dir &&
	echo "Pacman packaging info:"
	echo "In order to build Pacman package use the $base_dir/pacman/${package_name}.tar.gz archive and the $base_dir/pacman/PKGBUILD-${package_name} on a Pacman system (makepkg)."
	echo "------"
}

# create the SisIYA source package and put it under the $base_dir/src directory
create_source_package()
{
	source_dir=$1
	base_dir=$2
	source_package_name=$3

	dst_dir="$source_package_name"
	tar_file="${source_package_name}.tar.gz"

	cd $base_dir &&
	# create output directories
	for d in "rpm" "deb" "pacman" "src" "tmp"
	do
		mkdir -p $d
	done

	cd tmp &&
	rm -rf $dst_dir &&
	mkdir $dst_dir &&
	cp -a $source_dir/* $dst_dir/ &&

	### clean up
	for d in ".git" "old" "windows"
	do
		#echo "Removing $dst_dir/$d ..."
		rm -rf $dst_dir/$d
	done
	#
	tar -cz -f $tar_file $dst_dir
	mv -f $tar_file $base_dir/src

	echo "SisIYA source package $tar_file is ready."
}
################################################################################################################################################
base_dir=`pwd`
#source_name="sisiya-${version_str}-$release_str"
source_package_name="sisiya-${version_str}"
source_package_file="${source_name}.tar.gz"
source_dir="$base_dir/tmp/$source_package_name"

create_source_package $sisiya_dir $base_dir $source_package_name
create_client_checks $source_dir $version_str $release_str $base_dir
create_remote_checks $source_dir $version_str $release_str $base_dir
create_edbc_libs $source_dir $version_str $release_str $base_dir
create_sisiyad $source_dir $version_str $release_str $base_dir

# clean up
rm -rf $base_dir/tmp/
