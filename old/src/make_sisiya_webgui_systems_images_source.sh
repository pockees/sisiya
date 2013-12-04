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
if test $# -ne 1 ; then
	echo "Usage: $0 sisiya_dir"
	echo "Example: $0 /home/emutlu/sisiya"
	exit 1
fi

sisiya_dir=$1

package_str="sisiya-webgui-systems-images"

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
cp -a ${sisiya_dir}/sisiya_ui/systems_images/* ${package_str}${version}
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
################################################################################################################################################3
### 
################################################################################################################################################3
# clean up

rm -rf ${package_str}${version}
###
echo "In order to build the SisIYA packages one can use the following command:"
echo "rpmbuild -ta ${package_str}${version}.tar.gz"
