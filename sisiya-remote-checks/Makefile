#######################################################################################
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
#######################################################################################
package_name=sisiya-remote-checks
root_dir=$(DESTDIR)
dst_dir=$(root_dir)/usr/share/$(package_name)
dst_etc=$(root_dir)/etc
dst_cron=$(root_dir)/etc/cron.d
#dst_man=$(root_dir)/usr/share/man

install: 
	install -d		$(dst_cron)
	install -d		$(dst_etc)/sisiya/$(package_name)/conf.d
	install -d		$(root_dir)/usr/share/$(package_name)
	install -d		$(root_dir)/usr/share/doc/$(package_name)
	install -d -m 750	$(dst_dir)/conf.d
	install -d -m 700	$(dst_dir)/lib
	install -d -m 700	$(dst_dir)/misc
	install -d -m 700	$(dst_dir)/scripts
	install -d -m 700	$(dst_dir)/src
	install -d -m 700	$(dst_dir)/utils
	install -m 600 etc/sisiya/sisiya-remote-checks/SisIYA_Remote_Config*.*	$(dst_etc)/sisiya/$(package_name)
	install -m 600 etc/sisiya/sisiya-remote-checks/conf.d/*			$(dst_etc)/sisiya/$(package_name)/conf.d
	install -m 600 etc/cron.d/sisiya-remote-checks		$(dst_cron)
	install -m 600 lib/*		 			$(dst_dir)/lib
	install -m 600 misc/* 					$(dst_dir)/misc
	install -m 700 scripts/* 				$(dst_dir)/scripts
	install -m 600 src/*		 			$(dst_dir)/src
	install -m 644 changelog version.txt COPYING		$(root_dir)/usr/share/doc/$(package_name)
	install -m 700 utils/* 					$(dst_dir)/utils
