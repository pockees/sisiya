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

package_str="sisiya-webgui"
url_str="http://sisiya.example.org"

rpm_spec_file="${sisiya_dir}/packaging/rpmspec/${package_str}.spec"
if test ! -f $rpm_spec_file ; then
	echo "$0 : RPM Spec file $rpm_spec_file does not exist!"
	exit 1
fi
 
v1_str=`cat $rpm_spec_file | grep "define version" | awk '{print $3}'`
v2_str=`cat $rpm_spec_file | grep "define release" | awk '{print $3}'`

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
mkdir -p ${package_str}${version} ${package_str}${version}/etc/cron.d ${package_str}${version}/etc/httpd/conf.d
cp -a ${sisiya_dir}/sisiya_ui/0.5/* ${package_str}${version}
cp -a ${sisiya_dir}/sisiya_ui/XMPPHP ${package_str}${version}
cp ${sisiya_dir}/etc/sisiya.conf ${package_str}${version}/etc/httpd/conf.d/
for f in sisiya_alerts sisiya_archive sisiya_check_expired sisiya_rss 
do
	cp -a ${sisiya_dir}/etc/cron.d/$f ${package_str}${version}/etc/cron.d
done

################################################################################################################################################
### configuration
################################################################################################################################################
year_str=`date +'%Y'`
####
sed --in-place -e "s~__VERSION__~${v1_str}-${v2_str}~" -e "s~__URL__~${url_str}~" ${package_str}${version}/conf/sisiya_common_conf.php
find ${package_str}${version} -type f | while read f
do
	sed --in-place -e "s~__YEAR__~${year_str}~" $f
done
################################################################################################################################################
echo "Creating source package ..."
cp $rpm_spec_file ${package_str}${version}

################################################################################################################################################
### clean up the directory
################################################################################################################################################
find ${package_str}${version} -type d -name template	| while read -r d; do  rm -r $d ; done
find ${package_str}${version} -type d -name CVS		| while read -r d; do  rm -r $d ; done
find ${package_str}${version} -type d -name .svn	| while read -r d; do  rm -r $d ; done
### now make a source package
tar cfz ${package_str}${version}.tar.gz ${package_str}${version}

################################################################################################################################################
### create directory structure for Debian systems
################################################################################################################################################
################################################################################################################################################
### 
################################################################################################################################################
# clean up

rm -rf ${package_str}${version}
###
echo "In order to build the SisIYA packages one can use the following command:"
echo "rpmbuild -ta ${package_str}${version}.tar.gz"
