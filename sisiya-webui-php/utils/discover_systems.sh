#!/bin/bash
#
#    Copyright (C) 2003 - __YEAR__  Erdal Mutlu
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
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
#
#################################################################################
if test $# -ne 2 ; then
	echo "Usage  : $0 target user_id"
	echo "Example: $0 10.10.10.1 5 [10.11.0.0/24]"
	exit 1
fi

target="$1"
user_id="$2"

dir_str="/var/www/html/sisiya/autodiscover"

#nmap_prog="./nmap_scan_info.sh"
nmap_prog="./nmap_scan_info.php"
pid_file="discover_${user_id}_pid.txt"
target_file="discover_${user_id}_target.txt"
results_file="discover_${user_id}_results.xml"
tmp_file="discover_${user_id}_tmp.xml"
error_file="error.log"

echo "target=$target user_id=$user_id"

cd $dir_str

touch $error_file

### save pid
echo $$ > $pid_file
### run scan
echo "$target" > $target_file
$nmap_prog "$target" 2>> $error_file > $tmp_file &
### wait for scan to finish
wait $!
mv $tmp_file $results_file
#cat $results_file
cat $results_file > a.xml
### remove pid file
rm -f $pid_file $target_file
###
if test ! -s $results_file ; then
	rm -f $results_file
fi
