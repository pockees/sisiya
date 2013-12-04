#!/bin/bash
#
# This script executes all client checks.
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
if test $# -ne 2 ; then
	echo "Usage : $0 sisiya_client.conf expire"
	echo "expire must be specified in minutes."
	exit 1
fi

client_conf_file=$1
expire=$2

if test ! -f "$client_conf_file" ; then
	echo "$0 : SisIYA client configuration file $client_conf_file does not exist!"
	exit 1
fi

### source the config file
. $client_conf_file

if test ! -f $sisiya_functions ; then
	echo "$0 : SISIYA functions file $sisiya_functions does not exist!"
	exit 1
fi
### source the functions file
. $sisiya_functions

sisiya_osname=`uname -s`
### Solaris does not allow to change the PATH for root
if test "$sisiya_osname" = "SunOS" ; then
	PATH=$PATH:/usr/local/bin
	export PATH
fi

if test ! -x "$send_message2_prog" ; then
	echo "$0 : SISIYA send_message program $send_message2_prog does not exist."
	exit 1
fi
#################################################################################
for d in $sisiya_base_dir ${sisiya_base_dir}/common ${sisiya_base_dir}/special
do
	if test ! -d "${d}" ; then
		echo "$0 : Directory $d does not exist!"
		exit 1
	fi 
done

tmp_file=`maketemp /tmp/sisiya_all_tmp_XXXXXX`
if test ! -f $tmp_file ; then
	echo "Cannot make a tmp file $tmp_file"
	exit 1
fi

cd ${sisiya_base_dir}/common &&
for s in sisiya_*.sh
do
	./$s $client_conf_file $expire $tmp_file
done

if test -d ${sisiya_base_dir}/systems/$sisiya_hostname || test -L ${sisiya_base_dir}/systems/$sisiya_hostname ; then
	cd ${sisiya_base_dir}/systems/$sisiya_hostname &&
	ls sisiya_*.sh > /dev/null 2>&1
	if test $? -eq 0 ; then
		for s in sisiya_*.sh
		do
			./$s $client_conf_file $expire $tmp_file
		done
	fi
fi

### now send all messages at once
${send_message2_prog} $client_conf_file $tmp_file
rm -f $tmp_file
exit $?
