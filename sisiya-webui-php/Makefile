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
	cat etc/cron.d/sisiya-alerts 			| sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)/sisiya-webui-php'g" > $(cron_dir)/sisiya-alerts
	cat etc/cron.d/sisiya-archive 			| sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)/sisiya-webui-php'g" > $(cron_dir)/sisiya-archive
	cat etc/cron.d/sisiya-check-expired	 	| sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)/sisiya-webui-php'g" > $(cron_dir)/sisiya-check-expired
	cat etc/cron.d/sisiya-rss			| sed "s'__WEB_BASE_DIR__'$(WEB_BASE_DIR)/sisiya-webui-php'g" > $(cron_dir)/sisiya-rss
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
	install -m 644 utils/*.php 			$(web_dir)/utils
