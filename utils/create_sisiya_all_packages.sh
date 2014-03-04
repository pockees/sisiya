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

create_webui_images()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5
	year_str=`date +%Y` 

	package_str="sisiya-webui-images"
	#package_name="${package_str}-${version_str}-$release_str"
	package_name="${package_str}-${version_str}"
	package_dir="$base_dir/tmp/${package_name}"
	version_major_str=`echo $version_str | cut -d "." -f 1,2`
	version_minor_str=`echo $version_str | cut -d "." -f 3`

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir -p $package_dir
	cp -a ${source_dir}/$package_str/* $package_dir/
	echo "${version_str}-$release_str" > $package_dir/version.txt
	cat ${source_dir}/$package_str/debian/copyright | sed -e "s/__YEAR__/${year_str}/"  > $package_dir/debian/copyright
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	echo -n "Creating ${rpm_root_dir}.tar.gz ..."
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	rm -rf $rpm_root_dir/debian
	cat $source_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec 
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "OK"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	echo -n "Creating $base_dir/deb/${package_str}_${version_str}.orig.tar.gz ..."
	rm -rf $deb_root_dir 
	mkdir -p $deb_root_dir/var/lib/${package_str} 
	for f in  debian version.txt
	do
		cp -a $package_dir/$f $deb_root_dir
	done
	cp -a $package_dir/*.png $deb_root_dir/var/lib/${package_str}
	(cd $base_dir/deb ; tar cfz ${package_str}_${version_str}.orig.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "OK"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	echo -n "Creating ${pacman_root_dir}.tar.gz ..."
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	rm -rf $pacman_root_dir/debian
	(cd $base_dir/pacman ; tar cfz ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	cp $source_dir/packaging/pacman/${package_str}.install $base_dir/pacman/
	rm -rf $pacman_root_dir &&
	echo "OK"
}

create_webui_php()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5
	year_str=`date +%Y` 

	package_str="sisiya-webui-php"
	#package_name="${package_str}-${version_str}-$release_str"
	package_name="${package_str}-${version_str}"
	package_dir="$base_dir/tmp/${package_name}"
	version_major_str=`echo $version_str | cut -d "." -f 1,2`
	version_minor_str=`echo $version_str | cut -d "." -f 3`

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir -p $package_dir
	cp -a ${source_dir}/$package_str/* $package_dir/
	echo "${version_str}-$release_str" > $package_dir/version.txt
	mkdir -p $package_dir/etc/cron.d
	for f in "sisiya-alerts" "sisiya-archive" "sisiya-check-expired" "sisiya-rss"
	do
		cp -a ${source_dir}/etc/cron.d/$f $package_dir/etc/cron.d/
	done
	mkdir -p $package_dir/etc/php/conf.d
	cp ${source_dir}/etc/sisiya_php_ini.conf $package_dir/etc/php/conf.d
	mkdir -p $package_dir/etc/sisiya
	cp -a $source_dir/etc/sisiya/$package_str $package_dir/etc/sisiya
	cp -a ${source_dir}/sisiya_ui/XMPPHP $package_dir/
	cat ${source_dir}/$package_str/debian/copyright | sed -e "s/__YEAR__/${year_str}/"  > $package_dir/debian/copyright
	cat $source_dir/etc/sisiya/$package_str/sisiya_common_conf.php | sed -e "s/__VERSION__/${version_str}/" -e "s/__YEAR__/${year_str}/"  > $package_dir/etc/sisiya/$package_str/sisiya_common_conf.php 
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	echo -n "Creating ${rpm_root_dir}.tar.gz ..."
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec 
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "OK"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	echo -n "Creating $base_dir/deb/${package_str}_${version_str}.orig.tar.gz ..."
	rm -rf $deb_root_dir 
	mkdir -p $deb_root_dir/usr/share/${package_str} 
	for f in etc debian version.txt
	do
		cp -a $package_dir/$f $deb_root_dir
	done

	cp -a $package_dir $deb_root_dir/usr/share/${package_str}/
	rm -rf $deb_root_dir/usr/share/${package_str}/debian
	(cd $base_dir/deb ; tar cfz ${package_str}_${version_str}.orig.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "OK"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	echo -n "Creating ${pacman_root_dir}.tar.gz ..."
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	(cd $base_dir/pacman ; tar cfz ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	cp $source_dir/packaging/pacman/${package_str}.install $base_dir/pacman/
	rm -rf $pacman_root_dir &&
	echo "OK"
}

create_sisiyad()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5

	package_str="sisiyad"
	#package_name="${package_str}-${version_str}-$release_str"
	package_name="${package_str}-${version_str}"
	package_dir="$base_dir/tmp/${package_name}"
	version_major_str=`echo $version_str | cut -d "." -f 1,2`
	version_minor_str=`echo $version_str | cut -d "." -f 3`
	year_str=`date +%Y` 

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
	mv $package_dir/$package_str/debian $package_dir/
	cat ${source_dir}/$package_str/debian/copyright | sed -e "s/__YEAR__/${year_str}/"  > $package_dir/debian/copyright
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	echo -n "Creating ${rpm_root_dir}.tar.gz ..."
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec 
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "OK"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	echo -n "Creating ${deb_root_dir}.tar.gz ..."
	rm -rf $deb_root_dir 
	cp -a $package_dir $deb_root_dir
	(cd $base_dir/deb ; tar cfz ${package_str}_${version_str}-${release_str}.orig.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "OK"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	echo -n "Creating ${pacman_root_dir}.tar.gz ..."
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	(cd $base_dir/pacman ; tar cfz ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	rm -rf $pacman_root_dir &&
	echo "OK"
}


create_edbc_libs()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5

	package_str="sisiya-edbc-libs"
	#package_name="${package_str}-${version_str}-$release_str"
	package_name="${package_str}-${version_str}"
	package_dir="$base_dir/tmp/${package_name}"
	version_major_str=`echo $version_str | cut -d "." -f 1,2`
	version_minor_str=`echo $version_str | cut -d "." -f 3`
	year_str=`date +%Y` 

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir -p $package_dir
	cp -a ${source_dir}/edbc/* $package_dir/
	echo "$version_str" > $package_dir/version.txt
	cat ${source_dir}/edbc/debian/copyright | sed -e "s/__YEAR__/${year_str}/"  > $package_dir/debian/copyright
	#sed -i -e "s/__VERSION_MAJOR__/$version_major_str/g" -e "s/__VERSION_MINOR__/$version_minor_str/g" -e "s/__VERSION__/$version_str/g" $package_dir/Makefile
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	echo -n "Creating ${rpm_root_dir}.tar.gz ..."
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec 
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "OK"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	echo -n "Creating ${deb_root_dir}.tar.gz ..."
	rm -rf $deb_root_dir 
	cp -a $package_dir $deb_root_dir
	(cd $base_dir/deb ; tar cfz ${package_str}_${version_str}-${release_str}.orig.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "OK"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	echo -n "Creating ${pacman_root_dir}.tar.gz ..."
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	(cd $base_dir/pacman ; tar cfz ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	rm -rf $pacman_root_dir &&
	echo "OK"
}

create_remote_checks()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5
	year_str=`date +%Y` 

	package_str="sisiya-remote-checks"
	#package_name="${package_str}-${version_str}-$release_str"
	package_name="${package_str}-${version_str}"
	package_dir="$base_dir/tmp/${package_name}"

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir -p $package_dir
	cp -a ${source_dir}/$package_str/* $package_dir/
	echo "${version_str}-$release_str" > $package_dir/version.txt

	mkdir -p $package_dir/etc/cron.d
	cp ${source_dir}/etc/cron.d/$package_str $package_dir/etc/cron.d
	mkdir -p $package_dir/etc/sisiya
	cp -a ${source_dir}/etc/sisiya/$package_str $package_dir/etc/sisiya
	cat ${source_dir}/$package_str/debian/copyright | sed -e "s/__YEAR__/${year_str}/"  > $package_dir/debian/copyright

	find $package_dir/ -type d -exec chmod 755 {} \;
	find $package_dir/ -type f -exec chmod 644 {} \;
	find $package_dir/ -name "*.pl" -exec chmod 755 {} \;
	find $package_dir/ -name "*.sh" -exec chmod 755 {} \;
	find $package_dir/etc -type f -exec chmod 644 {} \;
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	echo -n "Creating ${rpm_root_dir}.tar.gz ..."
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec 	| sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec 
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "OK"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	echo -n "Creating $base_dir/deb/${package_str}_${version_str}.orig.tar.gz ..."
	rm -rf $deb_root_dir 
	mkdir -p $deb_root_dir 
	mkdir -p $deb_root_dir/usr/share/${package_str} 
	mkdir -p $deb_root_dir/usr/share/doc/${package_str} 
	for f in etc debian version.txt
	do
		cp -a $package_dir/$f $deb_root_dir
	done
	for f in misc scripts utils
	do
		cp -a $package_dir/$f ${deb_root_dir}/usr/share/${package_str} 
	done
	(cd $base_dir/deb ; tar cfz ${package_str}_${version_str}.orig.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "OK"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	echo -n "Creating ${pacman_root_dir}.tar.gz ..."
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	cp -a ${package_dir}/etc $pacman_root_dir 
	(cd $base_dir/pacman ; tar cfz ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	rm -rf $pacman_root_dir &&
	echo "OK"
}

create_client_checks()
{
	source_dir=$1
	version_str=$2
	release_str=$3
	base_dir=$4
	local_dir=$5
	year_str=`date +%Y` 

	package_str="sisiya-client-checks"
	#package_name="${package_str}-${version_str}-$release_str"
	package_name="${package_str}-${version_str}"
	package_dir="$base_dir/tmp/${package_name}"

	### common package directory for all package types (rpm, deb, pacman ...)
	rm -rf $package_dir
	mkdir  $package_dir
	cp -a $source_dir/$package_str/* $package_dir/
	echo "${version_str}-$release_str" > $package_dir/version.txt
	mkdir -p $package_dir/etc/cron.d
	cp ${source_dir}/etc/cron.d/$package_str $package_dir/etc/cron.d/
	mkdir -p $package_dir/etc/sisiya
	cp -a ${source_dir}/etc/sisiya/$package_str/ $package_dir/etc/sisiya
	cat ${source_dir}/$package_str/debian/copyright | sed -e "s/__YEAR__/${year_str}/"  > $package_dir/debian/copyright

	find $package_dir/ -type d -exec chmod 755 {} \;
	find $package_dir/ -type f -exec chmod 644 {} \;
	find $package_dir/ -name "*.pl" -exec chmod 755 {} \;
	find $package_dir/ -name "*.sh" -exec chmod 755 {} \;
	find $package_dir/etc -type f -exec chmod 644 {} \;
	################################################################################################################################################
	### create RPM source package
	################################################################################################################################################
	rpm_root_dir="$base_dir/rpm/$package_name"
	echo -n "Creating ${rpm_root_dir}.tar.gz ..."
	rm -rf $rpm_root_dir
	cp -a $package_dir $rpm_root_dir
	cat $source_dir/packaging/rpmspec/${package_str}.spec   | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/"  > $rpm_root_dir/${package_str}.spec
	(cd $base_dir/rpm ; tar -cz -f ${package_name}.tar.gz $package_name)
	rm -rf $rpm_root_dir
	echo "OK"
	################################################################################################################################################
	### create Debian source package
	################################################################################################################################################
	###
	deb_root_dir="$base_dir/deb/$package_name"
	echo -n "Creating $base_dir/deb/${package_str}_${version_str}.orig.tar.gz ..."
	rm -rf $deb_root_dir 
	mkdir -p $deb_root_dir 
	for f in etc debian version.txt
	do
		cp -a $package_dir/$f $deb_root_dir
	done
	mkdir -p $deb_root_dir/usr/share/${package_str} 
	for f in misc scripts utils
	do
		cp -a $package_dir/$f ${deb_root_dir}/usr/share/${package_str}/ 
	done

	find $deb_root_dir/ -type d -exec chmod 755 {} \;
	find $deb_root_dir/ -type f -exec chmod 644 {} \;
	find $deb_root_dir/ -name "*.pl" -exec chmod 755 {} \;
	find $deb_root_dir/ -name "*.sh" -exec chmod 755 {} \;
	find $deb_root_dir/etc -type f -exec chmod 644 {} \;

	(cd $base_dir/deb ; tar cfz ${package_str}_${version_str}.orig.tar.gz $package_name) 
	rm -rf $deb_root_dir 
	echo "OK"
	################################################################################################################################################
	### create directory structure for Arch systems
	################################################################################################################################################
	###
	pacman_root_dir="$base_dir/pacman/$package_name"
	echo -n "Creating ${pacman_root_dir}.tar.gz ..."
	rm -rf $pacman_root_dir 
	cp -a $package_dir $pacman_root_dir
	cp -a ${package_dir}/etc $pacman_root_dir 
	(cd $base_dir/pacman ; tar czf ${package_name}.tar.gz $package_name )
	md5sum_str=`md5sum $base_dir/pacman/${package_name}.tar.gz | cut -d " " -f 1`
	cat $source_dir/packaging/pacman/PKGBUILD-${package_str} | sed -e "s/__VERSION__/${version_str}/" -e "s/__RELEASE__/${release_str}/" -e "s/__MD5SUM__/${md5sum_str}/" > $base_dir/pacman/PKGBUILD-$package_name
	rm -rf $pacman_root_dir &&
	echo "OK"
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

	#echo "SisIYA source package $tar_file is ready."
}

package_building_info()
{
	echo "-----------------------------------------------------------------------------------------------------------------------"
	echo "For RPM packages    : rpmbuild -ta rpm/package.tar.gz"
	echo "For DEB packages    : Unpack the deb/package.tar.gz and run the dpkg --build package command."
	echo "For Pacman packages : Use pacman/package.tar.gz and use it together with PKGBUILD-package and/or 
			package.install files on a Pacman system (makepkg)."
	echo "-----------------------------------------------------------------------------------------------------------------------"
}
################################################################################################################################################
base_dir=`pwd`
#source_name="sisiya-${version_str}-$release_str"
source_package_name="sisiya-${version_str}"
source_package_file="${source_name}.tar.gz"
source_dir="$base_dir/tmp/$source_package_name"

create_source_package $sisiya_dir $base_dir $source_package_name
#
create_client_checks $source_dir $version_str $release_str $base_dir
create_edbc_libs $source_dir $version_str $release_str $base_dir
create_remote_checks $source_dir $version_str $release_str $base_dir
create_sisiyad $source_dir $version_str $release_str $base_dir
create_webui_images $source_dir $version_str $release_str $base_dir
create_webui_php $source_dir $version_str $release_str $base_dir

package_building_info
# clean up
rm -rf $base_dir/tmp/
