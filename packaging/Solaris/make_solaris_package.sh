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
if test $# -ne 3 ; then
	echo "Usage : $0 sisiya_src_dir client_version client_systems_version"
	echo "Example: $0 /tmp/sisiya-0.4-16 0.4.15-16 0.4.6-16"
	exit 0
fi

error()
{
	echo "$0 : Error : $1 "
        #echo "$0 : Error : $1 " | mail -s "$0 : Error!!!!!" admin@example.com
        exit 1
}

sisiya_src_dir=$1
client_version=$2
client_systems_version=$3

sisiya_checks_dir=${sisiya_src_dir}/sisiya_check
dst_root_dir=/opt
dst_dir=${dst_root_dir}/sisiya_client_checks
tmp_dir=/tmp
pkginfo_file=${tmp_dir}/pkginfo
prototype_file=${tmp_dir}/Prototype

target_platform="sol8-sparc"
client_package="sisiya-client-checks"
client_solaris_package=${tmp_dir}/${client_package}-${client_version}.${target_platform}
client_systems_package="sisiya-client-systems"
client_systems_solaris_package=${tmp_dir}/${client_systems_package}-${client_systems_version}.${target_platform}
client_systems_solaris_pkg=${tmp_dir}/${client_systems_package}-${client_systems_version}.${target_platform}
author="Erdal Mutlu"
email="emutlu@users.sourceforge.net"
pstamp=`date '+%d'`th`date '+%B%Y'`

for d in $sisiya_src_dir $tmp_dir $sisiya_checks_dir
do
	if test ! -d $d ; then
		echo "$0 : Directory $d does not exist. Exiting..."
		exit 1
	fi
done

cp ${sisiya_src_dir}/packaging/Solaris/checkinstall $tmp_dir || error "cp ${sisiya_src_dir}/packaging/Solaris/checkinstall $tmp_dir"
#########################################################################################
### sisiya-client package
#########################################################################################
### generating pkginfo file
> $pkginfo_file

echo "PKG=\"${client_package}\""				>> $pkginfo_file
echo "NAME=\"SisIYA client $version SPARC Solaris 8\"" 		>> $pkginfo_file
echo "VERSION=\"${client_version}\""				>> $pkginfo_file
echo "ARCH=\"sparc\""						>> $pkginfo_file
echo "CLASSES=\"none\""						>> $pkginfo_file
echo "CATEGORY=\"utility\""					>> $pkginfo_file
echo "VENDOR=\"${author}\""					>> $pkginfo_file
echo "PSTAMP=\"${pstamp}\""					>> $pkginfo_file
echo "EMAIL=\"${email}\""					>> $pkginfo_file
echo "ISTATES=\"S s 1 2 3\""					>> $pkginfo_file
echo "RSTATES=\"S s 1 2 3\""					>> $pkginfo_file
echo "BASEDIR=\"/\""						>> $pkginfo_file
#########################################################################################
### 
rm -rf ${tmp_dir}$dst_root_dir			|| error "rm -rf ${tmp_dir}$dst_root_dir"
mkdir -p ${tmp_dir}$dst_dir			|| error "mkdir -p ${tmp_dir}$dst_dir"
mv ${sisiya_checks_dir}/* ${tmp_dir}$dst_dir	|| error "mv ${sisiya_checks_dir}/* ${tmp_dir}$dst_dir"
#########################################################################################
### make a symbolic link for sisiyac
pwd_dir=`pwd`
cd ${tmp_dir}${dst_dir}/bin				|| error "cd ${tmp_dir}${dst_dir}/bin"
rm -f sisiyac						|| error "rm -f sisiyac"
ln -s sisiyac_`uname -p`_`uname -s`_`uname -r` sisiyac	|| error "ln -s sisiyac_`uname -p`_`uname -s`_`uname -r` sisiyac"
cd $pwd_dir						|| error  "cd $pwd_dir"
#########################################################################################
#########################################################################################
echo "Generating $prototype_file ... "
### generating prototype file
> $prototype_file
echo "i pkginfo"			>> $prototype_file
echo "i checkinstall"			>> $prototype_file
find ${tmp_dir}$dst_dir | grep -v "${tmp_dir}${dst_dir}/systems" | pkgproto | sed "s'${tmp_dir}''g" >> $prototype_file
#########################################################################################
### create the package
echo "Executing pkgmk ..."
pkgmk -o -r $tmp_dir -d $tmp_dir -f $prototype_file 2> /dev/null || error "pkgmk -o -r / -d $tmp_dir -f $prototype_file"
echo "Executing pkgtrans ..."
pkgtrans -s $tmp_dir $client_solaris_package $client_package 2> /dev/null	|| error "pkgtrans -s $tmp_dir $client_solaris_package $client_package"
rm -f ${client_solaris_package}.gz	|| error "rm -f ${client_solaris_package}.gz"
gzip $client_solaris_package		|| error "gzip $client_solaris_package"
#########################################################################################
#### sisiya-client-systems package
#########################################################################################
### generating pkginfo file
> $pkginfo_file

echo "PKG=\"${client_systems_package}\""			>> $pkginfo_file
echo "NAME=\"SisIYA client-systems $version SPARC Solaris 8\""	>> $pkginfo_file
echo "VERSION=\"${client_systems_version}\""			>> $pkginfo_file
echo "ARCH=\"sparc\""						>> $pkginfo_file
echo "CLASSES=\"none\""						>> $pkginfo_file
echo "CATEGORY=\"utility\""					>> $pkginfo_file
echo "VENDOR=\"${author}\""					>> $pkginfo_file
echo "PSTAMP=\"${pstamp}\""					>> $pkginfo_file
echo "EMAIL=\"${email}\""					>> $pkginfo_file
echo "ISTATES=\"S s 1 2 3\""					>> $pkginfo_file
echo "RSTATES=\"S s 1 2 3\""					>> $pkginfo_file
echo "BASEDIR=\"/\""						>> $pkginfo_file
#########################################################################################
### clean up
rm -rf ${tmp_dir}${dst_dir}/sisiya_client.conf	|| error "rm -rf ${tmp_dir}${dst_dir}/sisiya_client.conf"
rm -rf ${tmp_dir}${dst_dir}/bin			|| error "rm -rf ${tmp_dir}${dst_dir}/bin"
rm -rf ${tmp_dir}${dst_dir}/common		|| error "rm -rf ${tmp_dir}${dst_dir}/common"
rm -rf ${tmp_dir}${dst_dir}/special		|| error "rm -rf ${tmp_dir}${dst_dir}/special"
#########################################################################################
echo "Generating $prototype_file ... "
### generating prototype file
> $prototype_file
echo "i pkginfo"						>> $prototype_file
echo "i checkinstall"						>> $prototype_file
find ${tmp_dir}$dst_dir | pkgproto | sed "s'${tmp_dir}''g" 	>> $prototype_file
#########################################################################################
### create the package
echo "Executing pkgmk ..."
pkgmk -o -r $tmp_dir -d $tmp_dir -f $prototype_file 2> /dev/null || error "pkgmk -o -r / -d $tmp_dir -f $prototype_file"
echo "Executing pkgtrans ..."
pkgtrans -s $tmp_dir $client_systems_solaris_package $client_systems_package 2> /dev/null	|| error "pkgtrans -s $tmp_dir $client_systems_solaris_package $client_systems_package"
rm -f ${client_systems_solaris_package}.gz	|| error "rm -f ${client_systems_solaris_package}.gz"
gzip $client_systems_solaris_package		|| error "gzip $client_systems_solaris_package"
### clean up
rm -rf ${tmp_dir}/$client_package		|| error "rm -rf ${tmp_dir}/$client_package"
rm -rf ${tmp_dir}/$client_systems_package	|| error "rm -rf ${tmp_dir}/$client_systems_package"
rm -f $pkginfo_file				|| error "rm -f $pkginfo_file"
rm -f $prototype_file				|| error "rm -f $prototype_file"
rm -f ${tmp_dir}/checkinstall			|| error "rm -f ${tmp_dir}/checkinstall"
rm -rf ${tmp_dir}$dst_root_dir			|| error "rm -rf ${tmp_dir}$dst_root_dir"
