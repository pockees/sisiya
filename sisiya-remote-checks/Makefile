### directory definitions #################################################
root_dir=$(DSTDIR)
dst_dir=/opt
dst_sisiya_base=$(root_dir)$(dst_dir)/sisiya-remote-checks
dst_etc=$(root_dir)/etc
dst_cron=$(root_dir)/etc/cron.d
#dst_man=$(root_dir)/usr/share/man
###########################################################################

install: 
	install -d $(dst_cron)
	install -m 750 -d $(dst_sisiya_base)/conf
	install -m 700 -d $(dst_sisiya_base)/lib
	install -m 700 -d $(dst_sisiya_base)/misc
	install -m 700 -d $(dst_sisiya_base)/scripts
	install -m 700 -d $(dst_sisiya_base)/src
	install -m 700 -d $(dst_sisiya_base)/utils
	install -m 600 conf/*		 			$(dst_sisiya_base)/conf/
	install -m 600 etc/cron.d/sisiya-remote-checks		$(dst_cron)
	install -m 600 lib/*		 			$(dst_sisiya_base)/lib/
	install -m 600 misc/* 					$(dst_sisiya_base)/misc/
	install -m 700 scripts/* 				$(dst_sisiya_base)/scripts/
	install -m 600 src/*		 			$(dst_sisiya_base)/src/
	install -m 700 utils/* 					$(dst_sisiya_base)/utils/
	install -m 600 version.txt 				$(dst_sisiya_base)/
