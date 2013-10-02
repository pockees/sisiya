### directory definitions #################################################
dst_www=$(install_root)/var/www/html/sisiya
dst_apache_conf=$(install_root)/etc/httpd/conf.d
dst_etc=$(install_root)/etc
dst_cron=$(install_root)/etc/cron.d
sisiya_server_checks_dir=/opt/sisiya-server-checks
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

install: install_sisiya_webgui

install_sisiya_webgui:
	install -d 					$(dst_cron)
	install -m 600 etc/cron.d/sisiya_alerts		$(dst_cron)
	install -m 600 etc/cron.d/sisiya_archive	$(dst_cron)
	install -m 600 etc/cron.d/sisiya_check_expired	$(dst_cron)
	install -m 600 etc/cron.d/sisiya_rss		$(dst_cron)
	install -m 755 -d 				$(dst_apache_conf)
	install -m 644 etc/httpd/conf.d/sisiya.conf	$(dst_apache_conf)
	install -m 755 -d 				$(dst_www)/style
	install -m 644 style/*.css 			$(dst_www)/style
	install -m 755 -d 				$(dst_www)/javascript
	install -m 644 javascript/*.js 			$(dst_www)/javascript/
	install -m 755 -d 				$(dst_www)/XMPPHP
	install -m 644 favicon.ico	 		$(dst_www)
	install -m 644 sisiya_admin.php 		$(dst_www)
	install -m 644 sisiya_gui.php 			$(dst_www)
	install -m 644 sisiya_login.php 		$(dst_www)
	install -m 644 sisiya_alerts.php 		$(dst_www)
	install -m 644 sisiya_rss.php 			$(dst_www)
	install -m 644 sisiya_updatedb.php 		$(dst_www)
	cd $(dst_www) && ln -sf sisiya_gui.php index.php
	cd $(dst_www) && ln -sf ${sisiya_server_checks_dir}/conf	xmlconf
	install -m 755 -d 				$(dst_www)/conf
	install -m 644 conf/*.php 			$(dst_www)/conf/
	install -m 755 -d 				$(dst_www)/lib
	install -m 644 lib/*.php 			$(dst_www)/lib/
	install -m 755 -d 				$(dst_www)/images
	install -m 755 -d				$(dst_www)/images/links
	install -m 755 -d			 	$(dst_www)/images/sisiya
	install -m 755 -d 				$(dst_www)/images/systems
	install -m 755 -d 				$(dst_www)/images/tmp
	install -m 644 images/sisiya/*.gif 		$(dst_www)/images/sisiya/
	install -m 644 images/sisiya/*.png 		$(dst_www)/images/sisiya/
	install -m 755 -d				$(dst_www)/XMPPHP/
	install -m 644 XMPPHP/*.php			$(dst_www)/XMPPHP/
	install -m 755 -d 				$(dst_www)/autodiscover
	install -m 700 autodiscover/discover_systems.sh $(dst_www)/autodiscover/
	install -m 700 autodiscover/nmap_scan_info.php  $(dst_www)/autodiscover/
