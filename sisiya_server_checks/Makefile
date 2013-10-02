### directory definitions #################################################
dst_dir=/opt
dst_sisiya_client_checks=$(install_root)$(dst_dir)/sisiya-client-checks
dst_server_checks=$(install_root)$(dst_dir)/sisiya-server-checks
dst_server_checks_bin=$(dst_server_checks)/bin
dst_server_checks_conf=$(dst_server_checks)/conf
dst_server_checks_lib=$(dst_server_checks)/lib
dst_server_checks_scripts=$(dst_server_checks)/scripts
dst_server_checks_utils=$(dst_server_checks)/utils
dst_etc=$(install_root)/etc
dst_cron=$(install_root)/etc/cron.d
###########################################################################
# Java definitions
#VERBOSE=" -verbose "
VERBOSE=


all: SISIYACheckDB 

SISIYACheckDB: src/SISIYACheckDB.java
	javac $(VERBOSE) src/SISIYACheckDB.java
	mv src/SISIYACheckDB.class lib/
clean:
	rm -f *.class *~

install: SISIYACheckDB install_server_checks

install_sisiya_server_checks: SISIYACheckDB
	install -d $(dst_cron)
	install -d $(dst_server_checks)
	install -d $(dst_server_checks_bin)
	install -d $(dst_server_checks_conf)
	install -d $(dst_server_checks_lib)
	install -d $(dst_server_checks_scripts)
	install -d $(dst_server_checks_utils)
	install -m 600 etc/cron.d/sisiya_db_checks		$(dst_cron)
	install -m 600 etc/cron.d/sisiya_remote_checks		$(dst_cron)
#	install -m 700 src/sisiya_check_http 			$(dst_server_checks_bin)
#	install -m 700 src/sisiya_check_imap 			$(dst_server_checks_bin)
#	install -m 700 src/sisiya_check_pop3 			$(dst_server_checks_bin)
#	install -m 700 src/sisiya_check_ssh 			$(dst_server_checks_bin)
#	install -m 700 src/sisiya_check_smtp 			$(dst_server_checks_bin)
#	install -m 700 src/sisiya_check_telnet 			$(dst_server_checks_bin)
	install -m 600 conf/class_path 				$(dst_server_checks_conf)
	install -m 600 conf/*.conf				$(dst_server_checks_conf)
	install -m 600 conf/*.properties 			$(dst_server_checks_conf)
	install -m 640 conf/*.xml 				$(dst_server_checks_conf)
	install -m 600 lib/*.class 				$(dst_server_checks_lib)
	install -m 700 scripts/*.sh			 	$(dst_server_checks_scripts)
	install -m 700 utils/*.sh			 	$(dst_server_checks_utils)
