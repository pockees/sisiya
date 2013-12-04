#!/bin/bash
#
#    Copyright (C) 2003 - 2010  Erdal Mutlu
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
#######################################################################################
if test $# -lt 2 ; then
	echo "Usage : $0 sisiya_client.conf expire"
	echo "Usage : $0 sisiya_client.conf expire output_file"
	echo "The expire parameter must be given in minutes."
	exit 1
fi

client_conf_file=$1
expire=$2
output_file=""
if test $# -eq 3 ; then
	output_file=$3
	if test ! -f $output_file ; then
		echo "File $output_file does not exist! Exiting..."
		exit 1
	fi
fi

if test ! -f $client_conf_file ; then
	echo "$0 : SisIYA client configuration file $client_conf_file does not exist!"
	exit 1
fi

script_name=`basename $0`
sisiya_osname=`uname -s`
### source the config file
. $client_conf_file
###
module_conf_file="${sisiya_host_dir}/`echo $script_name | awk -F. '{print $1}'`.conf"

if test ! -f $sisiya_functions ; then
	echo "$0 : SisIYA functions file $sisiya_functions does not exist!"
	exit 1
fi
### source the functions file
. $sisiya_functions
### Solaris does not allow to change the PATH for root
if test "$sisiya_osname" = "SunOS" ; then
	PATH=$PATH:/usr/local/bin
	export PATH
fi
#######################################################################################
### service id
serviceid=$serviceid_filesystem  
if test -z "$serviceid" ; then
	echo "$0 : serviceid_filesystem is not defined! Exiting..."
	exit 1
fi
##########################################################################
### default values
warning_percent=85
error_percent=90
### List of the mount points, for which the genereal error and warning values did not apply
### The format is as follows: 
#### exceptions_list="mount_point1:warning_percent:error_percent mount_point2:warning_percent:error_percent"
#exceptions_list="/:80:90 /boot:90:95"
exclude_list="/proc .img /dev/shm /media devtmpfs"
tune2fs_prog="/sbin/tune2fs"
### end of the default values

### If there is a module conf file then override these default values
if test -f $module_conf_file ; then
	. $module_conf_file
fi

tmp_fs_file=`maketemp /tmp/tmp_${script_name}.XXXXXX`
tmp_fs_ok_file=`maketemp /tmp/tmp_ok_${script_name}.XXXXXX`
tmp_fs_warning_file=`maketemp /tmp/tmp_warning_${script_name}.XXXXXX`
tmp_fs_error_file=`maketemp /tmp/tmp_error_${script_name}.XXXXXX`
exceptions_file=`maketemp /tmp/tmp_exceptions_list_${script_name}.XXXXXX`
exclude_file=`maketemp /tmp/tmp_exclude_list_${script_name}.XXXXXX`
for s in $exceptions_list
do
	echo "$s" >> $exceptions_file
done
for s in $exclude_list
do
	echo "$s" >> $exclude_file
done
for f in $tmp_fs_file $tmp_fs_ok_file $tmp_fs_warning_file $tmp_fs_error_file
do
	rm -f $f
	touch $f
done

grep_prog="grep"
case "$sisiya_osname" in
	"AIX")
		df_command="df -k" 
	;;
	"NetBSD"|"OpenBSD")
		df_command="df -Pk" 
	;;
	"SunOS")
		case "$sisiya_osrelease" in 
			"5.11")
				df_command="/usr/gnu/bin/df -TPk" 
				grep_prog="/usr/gnu/bin/grep"
			;;
			*)
				df_command="df -k" 
				grep_prog="/usr/xpg4/bin/grep"
		esac
	;;
	"HP-UX")
		df_command="df -Pk"
	;;
	*)
		df_command="df -TPk"
	;;
esac
#echo "df_command=[$df_command] grep_prog=[$grep_prog]"
#######################################################################
### OpenSolaris 5.11 (2009.06)
# df -TPk
#Filesystem    Type 1024-blocks      Used Available Capacity Mounted on
#rpool/ROOT/opensolaris zfs   3562422   2991983    570440      84% /
#swap         tmpfs      658504       372    658132       1% /etc/svc/volatile
#/usr/lib/libc/libc_hwcap1.so.1 lofs   3562422   2991983    570440      84% /lib/libc.so.1
#swap         tmpfs      658152        20    658132       1% /tmp
#swap         tmpfs      658216        84    658132       1% /var/run
#rpool/export   zfs      570461        21    570440       1% /export
#rpool/export/home zfs    570459        19    570440       1% /export/home
#rpool          zfs      570517        78    570440       1% /rpool
#######################################################################
### on OpenBSD
# df-Pk
#Filesystem  1024-blocks       Used   Available Capacity Mounted on
#/dev/sd0a        908184      39802      822974     5%   /
#/dev/sd0e        431490          2      409914     0%   /home
#/dev/sd0d       2523220     583064     1813996    24%   /usr
#######################################################################
### on NetBSD 
#df -Pk
#Filesystem 1024-blocks Used Available Capacity Mounted on
#/dev/sd0a 33030000 4870720 26507792 15% /
#kernfs 1 1 0 100% /kern
#ptyfs 1 1 0 100% /dev/pts
#procfs 4 4 0 100% /proc
#######################################################################
# on HP-UX
# Filesystem          1024-blocks  Used  Available Capacity Mounted on
# icserpln:/backup      1209713792 774085504 435628288    64%   /backup
# /dev/vg01/lvol2       12158948  8157614  4001334    68%   /apps
# /dev/vg03/lvol1       35430160 19787352 15642808    56%   /data
# /dev/vg04/lvol1       33263016 18000192 15262824    55%   /data2
# /dev/vg00/lvol9       500351   123155   377196    25%   /home
# /dev/vg05/lvol1       69212064 28835000 40377064    42%   /index
# /dev/vg02/lvol1       35034586 18950806 16083780    55%   /index2
# /dev/vg00/lvol4       1005272   351037   654235    35%   /opt
# /dev/vg00/lvol5       131072    62241    68831    48%   /tmp
# /dev/vg00/lvol6       1014661   505745   508916    50%   /usr
# /dev/vg01/lvol1       12118226  5112992  7005234    43%   /usr2
# /dev/vg00/lvol7       1038753   842327   196426    82%   /var
# /dev/vg00/lvol1       75359    39512    35847    53%   /stand
# /dev/vg00/lvol3       385866   273466   112400    71%   /
#######################################################################
### on Linux 
# df -TPk
#Filesystem    Type 1024-blocks      Used Available Capacity Mounted on
#/dev/sda2     ext3    58769060  49275840   6459748      89% /
#tmpfs        tmpfs     1297756         0   1297756       0% /dev/shm
#/dev/sda1     ext3    15116836  13100004   1248928      92% /data
#######################################################################

#declare -i i
#i=1
$df_command | $grep_prog "^/" | $grep_prog  -vFf $exclude_file | while read line
#$df_command | $grep_prog  -vFf $exclude_file | while read line
do
	#echo "line=[$line]"
	### skip the first (header) line
	#if test $i -eq 1 ; then
	#	i=`expr $i + 1`
	#	continue
	#fi
	#i=`expr $i + 1`


	mount_dev=`echo $line	| awk '{print $1}'`
	fs_type=`echo $line	| awk '{print $2}'`
	if test "$sisiya_osname" = "HP-UX" ; then
		fs_type=""
	fi
	case "$sisiya_osname" in
		"NetBSD"|"OpenBSD"|"HP-UX")
			size=`echo $line	| awk '{print $2}'`
			percent=`echo $line	| awk '{print $5}'`
			mount_point=`echo $line	| awk '{print $6}'`
		;;
#		"SunOS")
#			size=`echo $line	| awk '{print $2}'`
#			percent=`echo $line	| awk '{print $5}'`
#			mount_point=`echo $line	| awk '{print $6}'`
#		;;
		*)
			size=`echo $line	| awk '{print $3}'`
			percent=`echo $line	| awk '{print $6}'`
			mount_point=`echo $line	| awk '{print $7}'`
		;;
	esac
	percent=`echo $percent	| awk -F% '{print $1}'`
	size_str=`print_size_k $size`


	ep=$error_percent
	wp=$warning_percent
	### check if this mount point is an exception
	str=`$grep_prog "^${mount_point}:" $exceptions_file`
	if test -n "$str" ; then
		wp=`echo $str | awk -F: '{print $2}'`
		ep=`echo $str | awk -F: '{print $3}'`
	fi
	#echo "mount_point=[$mount_point] fs_type=[$fs_type] size=[$size] percent=[$percent]"
	fs_type_str=""
	if test -n "$fs_type" ; then
		fs_type_str=" (${fs_type})"
	fi
	### <volume><name>/home</name><label>Home dirs</label><unit>GB</init><capacity>100</capacity><used>20</used><available>80</available><percent>20</percent></volume>
	# 
	if test $percent -ge $ep ;then
		echo "ERROR: ${mount_point}${fs_type_str} ${percent}% \(>= ${ep}%\) of $size_str is full! " >> $tmp_fs_error_file
	elif test $percent -ge $wp ; then  
		echo "WARNING: ${mount_point}${fs_type_str} ${percent}% \(>= ${wp}%\) of $size_str is full! " >> $tmp_fs_warning_file
	else
		echo "OK: ${mount_point}${fs_type_str} ${percent}% of $size_str is used. " >> $tmp_fs_ok_file
	fi
	### check the filesystem state
	if test $sisiya_osname = "Linux" ; then
		case "$fs_type" in
			"reiserfs"|"vfat"|"tmpfs")
				continue
			;;
		esac
		$tune2fs_prog -l $mount_dev >/dev/null 2>&1
		if test $? -eq 0 ; then
			state=`$tune2fs_prog -l $mount_dev 2>/dev/null | $grep_prog "^Filesystem state" | awk -F: '{print $2}'`
			s1=`echo $state | awk '{print $1}'`
			s2=`echo $state | awk '{print $2}'`
			s3=`echo $state | awk '{print $3}'`
			state=$s1
			if test -n "$s2" ; then
				state="$state $s2"
			fi
			if test -n "$s3" ; then
				state="$state $s3"
			fi
			if test $? -ne 0 ; then
				echo "$0: Error executing $tune2fs_prog command"
			else
				if test "$state" != "clean"; then
					echo  "ERROR: The filesystem state for $mount_dev is $state \(!= clean\)! " >> $tmp_fs_error_file
				fi
			fi
		fi
	fi
done

statusid=$status_ok
message_str=""
if test -s $tmp_fs_error_file ; then
	message_str=`cat $tmp_fs_error_file | tr "\n" " "` 
	statusid=$status_error
fi

if test -s $tmp_fs_warning_file ; then
	message_str="$message_str"`cat $tmp_fs_warning_file | tr "\n" " "`
	if test $statusid -lt $status_warning ; then
		statusid=$status_warning
	fi 
fi

if test -s $tmp_fs_ok_file ; then
	message_str="$message_str"`cat $tmp_fs_ok_file | tr "\n" " "`
fi

for f in $tmp_fs_file $tmp_fs_ok_file $tmp_fs_warning_file $tmp_fs_error_file $exclude_file $exceptions_file
do
	rm -f $f
done
###################################################################################################
#echo "sisiya_hostname=$sisiya_hostname serviceid=$serviceid statusid=$statusid expire=$expire msg=$message_str datamsg=data_message_str"
if test -z "$output_file" ; then
	${send_message_prog} $client_conf_file $sisiya_hostname $serviceid $statusid $expire "<msg>$message_str</msg><datamsg>$data_message_str</datamsg>"
	exit $?
else
	echo "$sisiya_hostname $serviceid $statusid $expire <msg>$message_str</msg><datamsg>$data_message_str</datamsg>" >> $output_file
fi
###################################################################################################
