### directory definitions #################################################
root_dir=$(DESTDIR)
dst_dir=/opt
dst_sisiya_client_checks=$(root_dir)$(dst_dir)/sisiya-client-checks
dst_etc=$(root_dir)/etc
dst_cron=$(root_dir)/etc/cron.d
dst_man=$(root_dir)/usr/share/man
###########################################################################

####################################
check_sisiya:
	@echo "prefix = $(prefix)"
	@echo "exec_prefix = $(exec_prefix)"
	@echo "bindir = $(bindir)"
	@echo "sbindir = $(sbindir)"
	@echo "libexecdir = $(libexecdir)"
	@echo "datadir = $(datadir)"
	@echo "sysconfdir = $(sysconfdir)"
	@echo "sharedstatedir = $(sharedstatedir)"
	@echo "localstatedir = $(localstatedir)"
	@echo "libdir = $(libdir)"
	@echo "infodir = $(infodir)"
	@echo "mandir = $(mandir)"
	@echo "includedir = $(includedir)"
	@echo "oldincludedir = $(oldincludedir)"
	@echo "pkgdatadir = $(pkgdatadir)"
	@echo "pkglibdir = $(pkglibdir)"
	@echo "pkgincludedir = $(pkgincludedir)"
	@echo "top_builddir = $(top_builddir)"

install: install_sisiya_client_checks install_sisiya_client_systems

install_sisiya_client_checks:
	install -d $(dst_cron)
	install -m 600 etc/cron.d/sisiya_client_checks		$(dst_cron)
	install -m 700 -d $(dst_sisiya_client_checks)/bin
#	cd $(install_root)$(dst_dir) && ln -sf sisiya_client_checks sisiya_checks
	install -m 700 -d $(dst_sisiya_client_checks)/common
	install -m 700 -d $(dst_sisiya_client_checks)/special
	install -m 600 SisIYA_Config.pm $(dst_sisiya_client_checks)/
	install -m 600 SisIYA_Config_local.pl $(dst_sisiya_client_checks)/
	install -m 600 version.txt $(dst_sisiya_client_checks)/
	install -m 700 bin/*.pl $(dst_sisiya_client_checks)/bin
	install -m 700 common/sisiya_*.pl $(dst_sisiya_client_checks)/common
	install -m 700 special/sisiya_*.pl $(dst_sisiya_client_checks)/special
	install -m 700 special/sisiya_*.sh $(dst_sisiya_client_checks)/special
install_sisiya_client_systems:
	cp -af systems/ $(dst_sisiya_client_checks)
	chmod 700 $(dst_sisiya_client_checks)/systems
