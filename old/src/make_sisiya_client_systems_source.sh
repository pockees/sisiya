#!/bin/bash
#
# This script is used to generate SisIYA source for sisiya-client-checks package.
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
if test $# -lt 1 ; then
	echo "Usage: $0 sisiya_dir"
	echo "Usage: $0 version sisiya_dir local_confs_dir"
	echo "Example: $0 /home/emutlu/sisiya"
	echo "Example: $0 /home/emutlu/sisiya /home/emutlu/mydir"
	exit 1
fi

sisiya_dir=$1

package_str="sisiya-client-systems"

rpm_spec_file="${sisiya_dir}/packaging/rpmspec/${package_str}.spec"
if test ! -f $rpm_spec_file ; then
	echo "$0 : RPM Spec file $rpm_spec_file does not exist!"
	exit 1
fi
 
v1_str=`cat $rpm_spec_file | grep define | grep version | awk '{print $3}'`
v2_str=`cat $rpm_spec_file | grep define | grep release | awk '{print $3}'`

version="-${v1_str}-$v2_str"
if test "$version" = "--" ; then
	echo "$0 : Could not get version for the $package_str package!"
	exit 1
fi

if test ! -d $sisiya_dir ; then
	echo "Directory $sisiya_dir does not exist. Exiting..."
	exit 1
fi

rm -rf ${package_str}${version}
mkdir -p ${package_str}${version}
cp ${sisiya_dir}/sisiya_check/Makefile ${package_str}${version}
cp -a ${sisiya_dir}/sisiya_check/systems ${package_str}${version}

if test $# -eq 1 ; then
	echo "Creating source package for general usage..."
else
	echo "Creating source package for you..."
	### remove default files, this directory is owned by the sisiya-client-systems package
	rm -rf ${package_str}${version}/systems

	local_dir=$2
	if test $# -ne 2 ; then
		echo "$0 : Usage: $0 version sisiya_dir local_confs_dir"
		exit 1
	fi
 	if test ! -d $local_dir ; then
		echo "$0 : Local configuration directory (local_confs_dir) does not exist!"
		exit 1
	fi
	cp -a $local_dir/sisiya_check/systems ${package_str}${version}/
fi
cp $rpm_spec_file ${package_str}${version}

################################################################################################################################################3
### clean up the directory
################################################################################################################################################3
find ${package_str}${version} -type d -name template	| while read -r d; do  rm -r $d ; done
find ${package_str}${version} -type d -name CVS		| while read -r d; do  rm -r $d ; done
find ${package_str}${version} -type d -name .svn	| while read -r d; do  rm -r $d ; done
### now make a source package
tar cfz ${package_str}${version}.tar.gz ${package_str}${version}

################################################################################################################################################3
### create directory structure for Debian systems
################################################################################################################################################3
###
deb_dir="${package_str}${version}-debian"
rm -rf $deb_dir &&
mkdir -p $deb_dir/opt/${package_str} 
for f in systems
do
	cp -a ${package_str}${version}/$f ${deb_dir}/opt/${package_str}/ 
done
mkdir $deb_dir/DEBIAN 
cat $sisiya_dir/packaging/debian/${package_str}-control | sed -e "s/__VERSION__/${v1_str}-${v2_str}/" > $deb_dir/DEBIAN/control 
tar cfz ${deb_dir}.tar.gz $deb_dir 
rm -rf $deb_dir &&
echo "Debian packaging info:"
echo "${deb_dir}.tar.gz"
echo "In order to build Debian package use the ${deb_dir}.tar.gz archive file on a Debian system."
echo "Unpack the archive, move the directory to the same name removing the -debian extension and run the dpkg --build ${package_str} command."
echo "------"
################################################################################################################################################3
### 
################################################################################################################################################3
# clean up

rm -rf ${package_str}${version}
###
echo "In order to build the SisIYA packages one can use the following command:"
echo "rpmbuild -ta ${package_str}${version}.tar.gz"
