### directory definitions #################################################
install_root=$(DESTDIR)$(prefix)
web_dir=$(install_root)$(WEB_BASE_DIR)/sisiya-webui-php
dst_apache_conf=$(install_root)/etc/httpd/conf.d
dst_etc=$(install_root)/etc
cron_dir=$(install_root)/etc/cron.d
sisiya_remote_checks_dir=/opt/sisiya-remote-checks
###########################################################################
.PHONY: install
install:
	install -d 					$(cron_dir)
	install -m 600 etc/cron.d/sisiya_alerts		$(cron_dir)
	install -m 600 etc/cron.d/sisiya_archive	$(cron_dir)
	install -m 600 etc/cron.d/sisiya_check_expired	$(cron_dir)
	install -m 600 etc/cron.d/sisiya_rss		$(cron_dir)
	install -m 755 -d 				$(web_dir)/autodiscover
	install -m 700 autodiscover/discover_systems.sh $(web_dir)/autodiscover/
	install -m 700 autodiscover/nmap_scan_info.php  $(web_dir)/autodiscover/
	install -m 755 -d 				$(web_dir)/style
	install -m 644 style/*.css 			$(web_dir)/style
	install -m 755 -d 				$(web_dir)/javascript
	install -m 644 javascript/*.js 			$(web_dir)/javascript/
	install -m 755 -d 				$(web_dir)/XMPPHP
	install -m 644 favicon.ico	 		$(web_dir)
	install -m 644 sisiya_admin.php 		$(web_dir)
	install -m 644 sisiya_gui.php 			$(web_dir)
	install -m 644 sisiya_login.php 		$(web_dir)
	install -m 644 README.txt			$(web_dir)
	install -m 644 INSTALL.txt			$(web_dir)
	cd $(web_dir) && ln -sf sisiya_gui.php index.php
	cd $(web_dir) && ln -sf ${sisiya_remote_checks_dir}/conf	xmlconf
	install -m 755 -d 				$(web_dir)/conf
	install -m 644 conf/*.php 			$(web_dir)/conf/
	cat etc/sisiya_apache.conf | sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)'g"	> $(web_dir)/conf/sisiya_apache.conf
	cat etc/sisiya_nginx.conf  | sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)'g" > $(web_dir)/conf/sisiya_nginx.conf
	install -m 755 -d 				$(web_dir)/lib
	install -m 644 lib/*.php 			$(web_dir)/lib/
	install -m 755 -d 				$(web_dir)/images
	install -m 755 -d				$(web_dir)/images/links
	install -m 755 -d			 	$(web_dir)/images/sisiya
	install -m 755 -d 				$(web_dir)/images/systems
	install -m 755 -d 				$(web_dir)/images/tmp
	install -m 644 images/sisiya/*.gif 		$(web_dir)/images/sisiya/
	install -m 644 images/sisiya/*.png 		$(web_dir)/images/sisiya/
	install -m 755 -d 				$(web_dir)/install
	install install/* 				$(web_dir)/install/
	install -m 755 -d				$(web_dir)/XMPPHP/
	install -m 644 XMPPHP/*.php			$(web_dir)/XMPPHP/
	install -m 755 -d				$(web_dir)/utils
	cat utils/sisiya_alerts.php 		| sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)'g" > $(web_dir)/utils/sisiya_alerts.php
	cat utils/sisiya_check_expired.php	| sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)'g" > $(web_dir)/utils/sisiya_check_expired.php
	cat utils/sisiya_rss.php 		| sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)'g" > $(web_dir)/utils/sisiya_rss.php
	cat utils/sisiya_updatedb.php 		| sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)'g" > $(web_dir)/utils/sisiya_updatedb.php
