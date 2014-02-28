### directory definitions #################################################
package_name=sisiya-webui-php
install_root=$(DESTDIR)$(prefix)
etc_dir=$(install_root)/etc
web_dir=$(install_root)/usr/share/sisiya-webui-php
web_tmp_dir=$(install_root)/var/tmp/sisiya-webui-php
systems_images_dir=$(install_root)/var/lib/sisiya-webui-images
dst_apache_conf=$(install_root)/etc/httpd/conf.d
dst_etc=$(install_root)/etc
cron_dir=$(etc_dir)/cron.d
#sisiya_remote_checks_dir=/etc/sisiya/sisiya-remote-checks/conf.d
###########################################################################
.PHONY: install
install:
	install -d 					$(cron_dir)
	install -m 644 etc/cron.d/sisiya-alerts		$(cron_dir)
	install -m 644 etc/cron.d/sisiya-archive 	$(cron_dir)
	install -m 644 etc/cron.d/sisiya-check-expired 	$(cron_dir)
	install -m 644 etc/cron.d/sisiya-rss		$(cron_dir)
	install -m 755 -d 				$(web_dir)/style
	install -m 644 style/*.css 			$(web_dir)/style
	install -m 755 -d 				$(web_dir)/javascript
	install -m 644 javascript/*.js 			$(web_dir)/javascript
	install -m 755 -d 				$(web_dir)/XMPPHP
	install -m 644 favicon.ico	 		$(web_dir)
	install -m 644 sisiya_admin.php 		$(web_dir)
	install -m 644 sisiya_gui.php 			$(web_dir)
	install -m 644 sisiya_login.php 		$(web_dir)
	install -m 644 README.txt			$(web_dir)
	install -m 644 INSTALL.txt			$(web_dir)
	cd $(web_dir) && ln -sf sisiya_gui.php index.php
#	cd $(web_dir) && ln -sf ${sisiya_remote_checks_dir}	xmlconf
	install -m 755 -d 					$(etc_dir)/sisiya/$(package_name)
	install -m 644 etc/sisiya/$(package_name)/*.php		$(etc_dir)/sisiya/$(package_name)
	install -m 644 etc/sisiya/$(package_name)/*.conf	$(etc_dir)/sisiya/$(package_name)
	install -m 755 -d 				$(web_dir)/lib
	install -m 644 lib/*.php 			$(web_dir)/lib/
	install -m 755 -d 				$(web_dir)/images
	install -m 755 -d				$(web_dir)/images/links
	install -m 755 -d			 	$(web_dir)/images/sisiya
	install -m 644 images/sisiya/*.* 		$(web_dir)/images/sisiya/
	install -m 755 -d 				$(web_dir)/install
	install install/* 				$(web_dir)/install/
	install -m 755 -d				$(web_dir)/XMPPHP/
	install -m 644 XMPPHP/*.php			$(web_dir)/XMPPHP/
	install -m 755 -d				$(web_dir)/utils
	install -m 644 utils/*.php 			$(web_dir)/utils
	install -m 755 utils/*.sh 			$(web_dir)/utils
	install -d 					$(web_tmp_dir)
	# this directory belongs to sisiya-webui-images package, I create it here to make the packaging software happy
	mkdir -p 					$(systems_images_dir)
	# make links
	cd $(web_dir)/images && ln -sf $(web_tmp_dir) tmp
	cd $(web_dir)/images && ln -sf $(systems_images_dir) systems
