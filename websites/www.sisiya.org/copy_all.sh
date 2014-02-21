#!/bin/bash
#
#   This script is used to copy web interface files to SisIYA's web server.
#
#    Copyright (C) 2008  Erdal Mutlu
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
#######################################################################################
### for files use scp file_name emutlu,sisiya@frs.sourceforge.net:/home/frs/project/s/si/sisiya/sisiya/0.4/0.4-28/
####
# server 	: web.sourceforge.net
#			the server allows only sftp like emutlu,sisiya@web.sourceforge.net
##### document root : /home/groups/s/si/sisiya/htdocs
user=emutlu
project=sisiya
server=web.sourceforge.net
web_dir=/home/groups/s/si/sisiya/htdocs

for d in . docs downloads faq screenshots subversion
do
	#echo "d=[$d]"
	if test "$d" = "." ; then
		echo "index.html -> ${user},${project}@${server}:${web_dir}"
		scp index.html ${user},${project}@${server}:${web_dir}
	else
		echo "${d}/index.html -> ${user},${project}@${server}:${web_dir}/$d"
		scp ${d}/index.html ${user},${project}@${server}:${web_dir}/$d
	fi
done


scp style/style.css ${user}@${server}:${web_dir}/style
