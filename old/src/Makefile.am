### Change this later, so that it can be configured throw the configure. Do not forget to change or genarete
### the etc/init.d/sisiyad and etc/sisiyad.conf files.
### directory definitions #################################################
SISIYA_VERSION=0.5
dst_dir=/opt
dst_server_checks=$(install_root)$(dst_dir)/sisiya_server_checks
dst_server_checks_bin=$(install_root)$(dst_dir)/sisiya_server_checks/bin
dst_server_checks_conf=$(install_root)$(dst_dir)/sisiya_server_checks/conf
dst_server_checks_lib=$(install_root)$(dst_dir)/sisiya_server_checks/lib
dst_server_checks_scripts=$(install_root)$(dst_dir)/sisiya_server_checks/scripts
dst_server_checks_utils=$(install_root)$(dst_dir)/sisiya_server_checks/utils
dst_sisiya_client_checks=$(install_root)$(dst_dir)/sisiya_client_checks
dst_sbin=$(install_root)/usr/sbin
dst_etc=$(install_root)/etc
dst_cron=$(install_root)/etc/cron.d
dst_apache_conf=$(install_root)/etc/httpd/conf.d
dst_init_dot_d=$(install_root)/etc/init.d
dst_man=$(install_root)/usr/share/man
dst_www=$(install_root)/var/www/html/sisiya
dst_db_scripts=$(install_root)${dst_dir}/sisiya_dbscripts
src_db_scripts=../sisiya_ui/$(SISIYA_VERSION)/db
###########################################################################
#bin_PROGRAMS=sisiya_check_telnet sisiya_check_pop3 sisiya_check_imap sisiya_check_smtp sisiya_check_ssh sisiya_check_http sisiyac sisiyac_xml sisiyaconnect
bin_PROGRAMS=sisiya_check_telnet sisiya_check_pop3 sisiya_check_imap sisiya_check_smtp sisiya_check_ssh sisiya_check_http sisiyac sisiyaconnect
sisiyaconnect_SOURCES=sisiyaconnect.c misc.c resolve.c
sisiyac_SOURCES=systype.c misc.c resolve.c mesg.c sisiyac.c sisiyac1.c
#sisiyac_xml_SOURCES=systype.c misc.c resolve.c mesg.c sisiyac_xml.c sisiyac1_xml.c
sisiya_check_http_SOURCES=systype.c misc.c resolve.c mesg.c sisiya_check_http.c
sisiya_check_ssh_SOURCES=systype.c misc.c resolve.c mesg.c esignal.c sisiya_check_ssh.c
sisiya_check_smtp_SOURCES=systype.c misc.c resolve.c mesg.c esignal.c sisiya_check_smtp.c
sisiya_check_imap_SOURCES=systype.c misc.c resolve.c mesg.c sisiya_check_imap.c
sisiya_check_pop3_SOURCES=systype.c misc.c resolve.c mesg.c sisiya_check_pop3.c
sisiya_check_telnet_SOURCES=systype.c misc.c resolve.c mesg.c esignal.c sisiya_check_telnet.c
#if SISIYAD_WITH_MYSQL
#sisiyad_SOURCES=sisiyad_mysql.c esem.c systype.c misc.c mesg.c resolve.c sisiya_conf.c sisiyad_common.c sisiyad.c sisiyad1.c
#sisiyad_LDFLAGS=$(MYSQL_LFLAGS)
#sisiyad_CFLAGS=-DSERVER $(MYSQL_INCLUDE)
#endif

#if SISIYAD_WITH_PGSQL
#sisiyad_SOURCES=sisiyad_postgresql.c esem.c systype.c misc.c mesg.c resolve.c sisiya_conf.c sisiyad_common.c sisiyad.c sisiyad1.c
#sisiyad_LDFLAGS=$(PGSQL_LFLAGS)
#sisiyad_CFLAGS=-DSERVER $(PGSQL_INCLUDE)
#endif


####################################
### This does not work in old auto tools
sisiyac_CFLAGS=-DCLIENT
sisiyac_xml_CFLAGS=-DCLIENT
sisiya_check_http_CFLAGS=-DCLIENT
sisiya_check_ssh_CFLAGS=-DCLIENT
sisiya_check_smtp_CFLAGS=-DCLIENT
sisiya_check_imap_CFLAGS=-DCLIENT
sisiya_check_pop3_CFLAGS=-DCLIENT
sisiya_check_telnet_CFLAGS=-DCLIENT
####################################


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

install: make_java install_server install_server_checks install_client install_client_systems install_php install_dbscripts

### correct this later. It should be in the build part
make_java:
	(cd ../sisiya_server_checks && make && cd ../src)
install_server:
	install -d $(dst_etc)
	install -m 600 ../etc/sisiyad.conf $(dst_etc)
#	install -m 600 ../etc/sisiyaqd.conf $(dst_etc)
	install -d $(dst_init_dot_d)
	install -m 700 ../etc/sisiyad $(dst_init_dot_d)
#	install -m 700 ../etc/sisiyaqd $(dst_init_dot_d)
	install -d $(dst_sbin)
#	install -m 700 sisiyad $(dst_sbin)
#	install -m 700 sisiyaqd $(dst_sbin)
	install -d $(dst_man)/man5
	install -d $(dst_man)/man8
	install -m 644 ../doc/sisiyad.8 $(dst_man)/man8
	gzip $(dst_man)/man8/sisiyad.8
#	install -m 644 ../doc/sisiyaqd.8 $(dst_man)/man8
#	gzip $(dst_man)/man8/sisiyaqd.8
	install -m 644 ../doc/sisiyad.conf.5 $(dst_man)/man5
	gzip $(dst_man)/man5/sisiyad.conf.5
#	install -m 644 ../doc/sisiyaqd.conf.5 $(dst_man)/man5
#	gzip $(dst_man)/man5/sisiyaqd.conf.5


install_server_checks:
	install -d $(dst_cron)
	install -d $(dst_server_checks)
	install -d $(dst_server_checks_bin)
	install -d $(dst_server_checks_conf)
	install -d $(dst_server_checks_lib)
	install -d $(dst_server_checks_scripts)
	install -d $(dst_server_checks_utils)
	install -m 600 ../etc/cron.d/sisiya_remote_checks		$(dst_cron)
	install -m 600 ../etc/cron.d/sisiya_db_checks			$(dst_cron)
	install -m 700 sisiya_check_http 				$(dst_server_checks_bin)
	install -m 700 sisiya_check_imap 				$(dst_server_checks_bin)
	install -m 700 sisiya_check_pop3 				$(dst_server_checks_bin)
	install -m 700 sisiya_check_ssh 				$(dst_server_checks_bin)
	install -m 700 sisiya_check_smtp 				$(dst_server_checks_bin)
	install -m 700 sisiya_check_telnet 				$(dst_server_checks_bin)
	install -m 600 ../sisiya_server_checks/conf/class_path 		$(dst_server_checks_conf)
	install -m 600 ../sisiya_server_checks/conf/*.conf		$(dst_server_checks_conf)
	install -m 600 ../sisiya_server_checks/conf/*.properties 	$(dst_server_checks_conf)
	install -m 640 ../sisiya_server_checks/conf/*.xml 		$(dst_server_checks_conf)
	install -m 600 ../sisiya_server_checks/lib/*.class 		$(dst_server_checks_lib)
	install -m 700 ../sisiya_server_checks/scripts/*.sh	 	$(dst_server_checks_scripts)
	install -m 700 ../sisiya_server_checks/utils/*.sh	 	$(dst_server_checks_utils)
install_client:
	install -d $(dst_cron)
	install -m 600 ../etc/cron.d/sisiya_client_checks		$(dst_cron)
	install -m 700 -d $(dst_sisiya_client_checks)/bin
#	cd $(install_root)$(dst_dir) && ln -sf sisiya_client_checks sisiya_checks
	install -m 700 -d $(dst_sisiya_client_checks)/common
	install -m 700 -d $(dst_sisiya_client_checks)/special
	install -m 600 ../sisiya_check/sisiya_client.conf $(dst_sisiya_client_checks)/
	install -m 700 ../sisiya_check/bin/*.pl $(dst_sisiya_client_checks)/bin
	install -m 700 ../sisiya_check/bin/*.sh $(dst_sisiya_client_checks)/bin
	install -m 700 ../sisiya_check/common/sisiya_*.sh $(dst_sisiya_client_checks)/common
	install -m 700 ../sisiya_check/special/sisiya_*.sh $(dst_sisiya_client_checks)/special
install_client_systems:
	install -m 700 -d $(dst_sisiya_client_checks)/systems
	cp -a ../sisiya_check/systems/* $(dst_sisiya_client_checks)/systems
	rm -rf $(dst_sisiya_client_checks)/systems/CVS
	rm -rf $(dst_sisiya_client_checks)/systems/*/CVS
install_php:
	install -d $(dst_cron)
	install -m 600 ../etc/cron.d/sisiya_alerts		$(dst_cron)
	install -m 600 ../etc/cron.d/sisiya_archive		$(dst_cron)
	install -m 600 ../etc/cron.d/sisiya_check_expired	$(dst_cron)
	install -m 600 ../etc/cron.d/sisiya_rss			$(dst_cron)
	install -m 755 -d $(dst_apache_conf)
	install -m 644  ../etc/sisiya.conf $(dst_apache_conf)
	install -m 755 -d $(dst_www)/style
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/style/*.css $(dst_www)/style
	install -m 755 -d $(dst_www)/javascript
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/javascript/*.js $(dst_www)/javascript/
	install -m 755 -d $(dst_www)/XMPPHP
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/sisiya_admin.php $(dst_www)
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/sisiya_gui.php $(dst_www)
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/sisiya_login.php $(dst_www)
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/sisiya_alerts.php $(dst_www)
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/sisiya_rss.php $(dst_www)
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/sisiya_updatedb.php $(dst_www)
	cd $(dst_www) && ln -sf sisiya_gui.php index.php
	install -m 755 -d $(dst_www)/conf
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/conf/*.php $(dst_www)/conf/
	install -m 755 -d $(dst_www)/lib
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/lib/*.php $(dst_www)/lib/
	install -m 755 -d $(dst_www)/images
	install -m 755 -d $(dst_www)/images/links
	install -m 755 -d $(dst_www)/images/sisiya
	install -m 755 -d $(dst_www)/images/systems
	install -m 755 -d $(dst_www)/images/tmp
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/images/sisiya/*.gif $(dst_www)/images/sisiya/
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/images/sisiya/*.png $(dst_www)/images/sisiya/
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/images/sisiya/*.ico $(dst_www)/images/sisiya/
	install -m 644 ../sisiya_ui/$(SISIYA_VERSION)/images/systems/*.gif $(dst_www)/images/systems/
	install -m 644 ../sisiya_ui/XMPPHP/*.php $(dst_www)/XMPPHP/
	install -m 755 -d $(dst_www)/autodiscover
	install -m 700 ../sisiya_ui/$(SISIYA_VERSION)/autodiscover/discover_systems.sh $(dst_www)/autodiscover/
	install -m 700 ../sisiya_ui/$(SISIYA_VERSION)/autodiscover/nmap_scan_info.php  $(dst_www)/autodiscover/
install_dbscripts:
	install -m 700 -d $(dst_db_scripts)
	install -m 700 $(src_db_scripts)/dbscript.sh $(dst_db_scripts)
	install -m 700 $(src_db_scripts)/exec_MySQL.sh $(dst_db_scripts)
	install -m 700 $(src_db_scripts)/exec_PostgreSQL.sh $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/INSTALL $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/README $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/Makefile $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/db_MySQL.conf $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/db_PostgreSQL.conf $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/create_tables.sql $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/drop_tables.sql $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/populate_db.sql $(dst_db_scripts)
	install -m 700 $(src_db_scripts)/language.sh $(dst_db_scripts)
	install -m 700 $(src_db_scripts)/update_languages.sh $(dst_db_scripts)
	install -m 600 $(src_db_scripts)/language_*.xml $(dst_db_scripts)
