### directory definitions #################################################
root_dir=$(DESTDIR)
dst_dir=/opt
dst_sisiya_client_checks=$(root_dir)$(dst_dir)/sisiya-client-checks
dst_etc=$(root_dir)/etc
dst_cron=$(root_dir)/etc/cron.d
dst_man=$(root_dir)/usr/share/man
###########################################################################

install: install_sisiya_client_checks install_sisiya_client_systems

install_sisiya_client_checks:
	install -d $(dst_cron)
	install -m 600 etc/cron.d/sisiya_client_checks		$(dst_cron)
	install -m 700 -d $(dst_sisiya_client_checks)/misc
#	cd $(install_root)$(dst_dir) && ln -sf sisiya_client_checks sisiya_checks
	install -m 700 -d $(dst_sisiya_client_checks)/common
	install -m 700 -d $(dst_sisiya_client_checks)/special
	install -m 700 -d $(dst_sisiya_client_checks)/utils
	install -m 600 SisIYA_Config.pm $(dst_sisiya_client_checks)/
	install -m 600 SisIYA_Config_local.pl $(dst_sisiya_client_checks)/
	install -m 600 version.txt $(dst_sisiya_client_checks)/
	install -m 700 common/sisiya_*.pl $(dst_sisiya_client_checks)/common
	install -m 600 misc/*.sql $(dst_sisiya_client_checks)/misc
	install -m 700 special/sisiya_*.pl $(dst_sisiya_client_checks)/special
	install -m 700 special/sisiya_*.sh $(dst_sisiya_client_checks)/special
	install -m 700 utils/*.pl $(dst_sisiya_client_checks)/utils
install_sisiya_client_systems:
	cp -af systems/ $(dst_sisiya_client_checks)
	chmod 700 $(dst_sisiya_client_checks)/systems
