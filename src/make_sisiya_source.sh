#!/bin/bash
#
# This script is used to generate SisIYA source package.
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
if test $# -lt 2 ; then
	echo "Usage: $0 version sisiya_dir"
	echo "Usage: $0 version sisiya_dir local_confs_dir"
	echo "Example: $0 0.4-17 /home/emutlu/sisiya"
	echo "Example: $0 0.4-17 /home/emutlu/sisiya /home/emutlu/mydir"
	exit 1
fi

major_version=`echo $1 | cut -d "-" -f 1`
version="-$1"
sisiya_dir=$2

main_version=`echo $1 | cut -d "-" -f 1`

if test ! -d $sisiya_dir ; then
	echo "Directory $sisiya_dir does not exist. Exiting..."
	exit 1
fi

rm -rf /tmp/emutlu_rpm_buildroot

rm -rf sisiya${version}
mkdir -p sisiya${version}
cp -a ${sisiya_dir}/* sisiya${version}

if test $# -eq 2 ; then
	echo "Creating source package for general usage..."
	### for the client-systems
	#cp -a ${sisiya_dir}/sisiya_check/systems  sisiya${version}/sisiya_check
	### for images
	cp -a ${sisiya_dir}/sisiya_ui/${main_version}/images/sisiya/*  sisiya${version}/sisiya_ui/${major_version}/images/sisiya/
	cp -a ${sisiya_dir}/sisiya_ui/${main_version}/images/systems/*  sisiya${version}/sisiya_ui/${major_version}/images/systems/
else
	echo "Creating source package for you..."
	### remove default files
	rm -rf sisiya${version}/sisiya_check/systems
	rm -rf sisiya${version}/sisiya_ui/${major_version}/images/systems/*
	#rm -f sisiya${version}/sisiya_server_checks/*.conf
	rm -f sisiya${version}/sisiya_server_checks/*.properties

	local_dir=$3
	if test $# -ne 3 ; then
		echo "$0 : Usage: $0 version sisiya_dir local_confs_dir"
		exit 1
	fi
 	if test ! -d $local_dir ; then
		echo "$0 : Local configuration directory (local_confs_dir) does not exist!"
		exit 1
	fi
	local_confs_file=${local_dir}/local_confs.conf
	if test ! -f $local_confs_file ; then
		echo "$0 : Local configuration file $local_confs_file does not exist!"
		echo "It must contain at least the following entries:"
		echo "###########################################"
		echo "sisiya_server=\"sisiya.example.org\""
		echo "admins_mail=\"sisiyaadmins@example.org\""
		echo "###########################################"
		echo "### sisiya_server is the name of the server where the SisIYA daemon runs."
		echo "### admins_mail contains the email address of the SisIYA admin or a comma separated list of SisIYA admins."
		exit 1
	fi
	### source the file
	. $local_confs_file
	script_name=`basename $0`
	tmp_file=`mktemp /tmp/${script_name}.XXXXXX`
	if test -f ${local_dir}/sisiya_check/sisiya_client.conf ; then
		echo "I am using your own sisiya_client.conf file (${local_dir}/sisiya_check/sisiya_client.conf) ..."
		cp -f ${local_dir}/sisiya_check/sisiya_client.conf sisiya${version}/sisiya_check/
	else
		echo "sisiya_server=$sisiya_server"
		sed "s/SISIYA_SERVER=127.0.0.1/SISIYA_SERVER=${sisiya_server}/" sisiya${version}/sisiya_check/sisiya_client.conf > $tmp_file
		mv -f $tmp_file sisiya${version}/sisiya_check/sisiya_client.conf
	fi
	ls ${local_dir}/db/* > /dev/null 2>&1
	retcode=$?
	if test $retcode -eq 0 ; then
		cp -af ${local_dir}/db/* sisiya${version}/db
	else
		echo "There are no files in the ${local_dir}/db directory. Skiping..."
	fi
	ls ${local_dir}/sisiya_ui/images/* > /dev/null 2>&1
	retcode=$?
	if test $retcode -eq 0 ; then
		cp -f ${local_dir}/sisiya_ui/images/systems/* sisiya${version}/sisiya_ui/${major_version}/images/systems/
	else
		echo "There are no image files in the ${local_dir}/sisiya_ui/${major_version}/images/systems directory. Skiping..."
	fi
	ls ${local_dir}/sisiya_server_checks/*.properties > /dev/null 2>&1
	retcode=$?
	if test $retcode -eq 0 ; then
		cp -af ${local_dir}/sisiya_server_checks/*.properties sisiya${version}/sisiya_server_checks
	else
		echo "There are no *.properties files in the ${local_dir}/sisiya_server_checks directory. Skiping..."
	fi
	ls ${local_dir}/sisiya_server_checks/*.conf > /dev/null 2>&1
	retcode=$?
	if test $retcode -eq 0 ; then
		cp -af ${local_dir}/sisiya_server_checks/*.conf sisiya${version}/sisiya_server_checks
	else
		sed "s/admins_email=admins@example.org/admins_email=${admins_mail}/" ${sisiya_dir}/sisiya_server_checks/sisiya_server_checks.conf > $tmp_file
		mv -f $tmp_file sisiya${version}/sisiya_server_checks/sisiya_server_checks.conf
		echo "There are no *.conf files in the ${local_dir}/sisiya_server_checks directory. Skiping..."
	fi
	ls ${local_dir}/sisiya_check/systems/* > /dev/null 2>&1
	retcode=$?
	if test $retcode -eq 0 ; then
		cp -af ${local_dir}/sisiya_check/systems sisiya${version}/sisiya_check
	else
		echo "There are no subdirectories in the ${local_dir}/sisiya_check/systems directory. Skiping..."
	fi

	rm -f $tmp_file
fi

### clean up
rm -f sisiya${version}/rpmspec/sisiya.spec.old
rm -f sisiya${version}/edbc/edbc.spec
find sisiya${version} -type d -name template	| while read -r d; do  rm -r $d ; done
find sisiya${version} -type d -name CVS		| while read -r d; do  rm -r $d ; done
find sisiya${version} -type d -name .svn	| while read -r d; do  rm -r $d ; done
### now make a source package
tar cfz sisiya${version}.tar.gz sisiya${version}
rm -rf sisiya${version}
###
echo "In order to build the SisIYA packages one can use the following command:"
echo "rpmbuild -ta sisiya${version}.tar.gz"
