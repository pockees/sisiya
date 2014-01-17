### directory definitions #################################################
root_dir=$(DSTDIR)
dst_dir=/opt
dst_sisiya_client_checks=$(root_dir)$(dst_dir)/sisiya-client-checks
dst_etc=$(root_dir)/etc
dst_cron=$(root_dir)/etc/cron.d
dst_man=$(root_dir)/usr/share/man
###########################################################################

install: install_sisiya_client_checks install_sisiya_client_systems

install_sisiya_client_checks:
	install -d $(dst_cron)
	install -m 600 etc/cron.d/sisiya-client-checks		$(dst_cron)
	install -m 700 -d $(dst_sisiya_client_checks)/misc
	install -m 700 -d $(dst_sisiya_client_checks)/common
	install -m 700 -d $(dst_sisiya_client_checks)/special
	install -m 700 -d $(dst_sisiya_client_checks)/utils
	install -m 600 SisIYA_Config.pm $(dst_sisiya_client_checks)/
	install -m 600 SisIYA_Config_local.pl $(dst_sisiya_client_checks)/
	install -m 600 version.txt $(dst_sisiya_client_checks)/
	install -m 700 common/* $(dst_sisiya_client_checks)/common
	install -m 600 misc/* $(dst_sisiya_client_checks)/misc
	install -m 700 special/* $(dst_sisiya_client_checks)/special
	install -m 700 utils/* $(dst_sisiya_client_checks)/utils
install_sisiya_client_systems:
	cp -af systems/ $(dst_sisiya_client_checks)
	chmod 700 $(dst_sisiya_client_checks)/systems
