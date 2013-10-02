### Change this later, so that it can be configured throw the configure
### directory definitions #################################################
dst_dir=/opt
dst_server_checks=$(install_root)$(dst_dir)/sisiya_server_checks
dst_sisiya_check=$(install_root)$(dst_dir)/sisiya_check
dst_sbin=$(install_root)/usr/sbin
dst_etc=$(install_root)/etc
dst_init_dot_d=$(install_root)/etc/init.d
dst_man=$(install_root)/usr/share/man
dst_www=$(install_root)/var/www/html/sisiya
dst_db_scripts=$(install_root)/usr/local/sisiya_dbscripts
###########################################################################


bin_PROGRAMS=sisiyad

ALL_INC=-I$(EDBC_INC_DIR) -I$(EDBC_UTILS_INC_DIR) -I$(INC_DIR) -I$(OLD_DIR)
ALL_LIBDIRS=-L$(EDBC_LIB_DIR)
ALL_LFLAGS=$(OPT_FLAGS) $(ALL_INC)
ALL_LIBS=-ldl -ledbc

sisiyad_SOURCES=$(EDBC_UTILS_SRC_DIR)/trim.cpp $(EDBC_UTILS_SRC_DIR)/UpperLowerCase.cpp $(SRC_DIR)/Semaphore.cpp $(OLD_DIR)/misc.c $(SRC_DIR)/esignal.cpp $(SRC_DIR)/ConfFile.cpp $(SRC_DIR)/SisIYAServer.cpp $(SRC_DIR)/sisiyad.cpp
sisiyad_LDFLAGS=$(WARN_FLAGS) $(ALL_LFLAGS) $(ALL_LIBDIRS)
AM_CXXFLAGS=$(WARN_FLAGS) $(OPT_FLAGS) $(ALL_INC)
LIBS=$(ALL_LIBS)
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

install:
	install -m 600 sisiyad.conf $(install_root)/etc
	install -m 700 sisiyad $(install_root)/usr/sbin
