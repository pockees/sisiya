### directory definitions #################################################
root_dir=$(DESTDIR)
dst_dir=/usr/share
package_name=sisiya-client-checks
dst_sisiya_client_checks=$(root_dir)$(dst_dir)/sisiya-client-checks
dst_etc=$(root_dir)/etc
dst_cron=$(root_dir)/etc/cron.d
dst_man=$(root_dir)/usr/share/man
###########################################################################

install:
	install -d $(dst_cron)
	install -m 600 etc/cron.d/$(package_name)		$(dst_cron)
	install -d $(dst_etc)/sisiya/$(package_name)
	install -d $(dst_etc)/sisiya/$(package_name)/conf.d
	install -m 600 etc/sisiya/$(package_name)/SisIYA_Config.pm $(dst_etc)/sisiya/$(package_name)/
	install -m 600 etc/sisiya/$(package_name)/SisIYA_Config_local.pl $(dst_etc)/sisiya/$(package_name)/
	install -m 600 etc/sisiya/$(package_name)/conf.d/* $(dst_etc)/sisiya/$(package_name)/conf.d/
	install -m 700 -d $(dst_sisiya_client_checks)/misc
	install -m 700 -d $(dst_sisiya_client_checks)/scripts
	install -m 700 -d $(dst_sisiya_client_checks)/utils
	install -m 600 version.txt $(dst_sisiya_client_checks)/
	install -m 600 misc/* $(dst_sisiya_client_checks)/misc
	install -m 700 scripts/* $(dst_sisiya_client_checks)/scripts
	install -m 700 utils/* $(dst_sisiya_client_checks)/utils
