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

package_name=sisiya-client-checks
root_dir=$(DESTDIR)
dst_dir=$(root_dir)/usr/share
dst_etc=$(root_dir)/etc
dst_cron=$(root_dir)/etc/cron.d
dst_man=$(root_dir)/usr/share/man

install:
	install -d		$(dst_cron)
	install -d		$(dst_etc)/sisiya/$(package_name)
	install -d		$(dst_etc)/sisiya/$(package_name)/conf.d
	install -m 700 -d	$(dst_dir)/$(package_name)/misc
	install -m 700 -d	$(dst_dir)/$(package_name)/scripts
	install -m 700 -d	$(dst_dir)/$(package_name)/utils
	install -m 600 etc/cron.d/$(package_name)				$(dst_cron)
	install -m 600 etc/sisiya/$(package_name)/SisIYA_Config.pm 		$(dst_etc)/sisiya/$(package_name)
	install -m 600 etc/sisiya/$(package_name)/SisIYA_Config_local.conf	$(dst_etc)/sisiya/$(package_name)
	install -m 600 etc/sisiya/$(package_name)/conf.d/* 			$(dst_etc)/sisiya/$(package_name)/conf.d
	install -m 600 version.txt 						$(dst_dir)/$(package_name)
	install -m 600 misc/* 							$(dst_dir)/$(package_name)/misc
	install -m 700 scripts/*						$(dst_dir)/$(package_name)/scripts
	install -m 700 utils/*							$(dst_dir)/$(package_name)/utils
