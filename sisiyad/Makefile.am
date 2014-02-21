#######################################################################################
#    Copyright (C) Erdal Mutlu
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
#######################################################################################
install_root=$(DESTDIR)$(prefix)

bin_PROGRAMS=sisiyad

ALL_INC=$(EDBC_INC) $(EDBC_UTILS_INC) $(SISIYAD_INC)
ALL_LIBDIRS=$(EDBC_LIB)
ALL_LFLAGS=$(OPT_FLAGS) $(ALL_INC)
LIBS=$(SISIYAD_LFLAGS)

sisiyad_SOURCES=$(EDBC_UTILS_SRC)/trim.cpp $(EDBC_UTILS_SRC)/UpperLowerCase.cpp $(SISIYAD_SRC)/Semaphore.cpp $(SISIYAD_SRC)/misc.c $(SISIYAD_SRC)/esignal.cpp $(SISIYAD_SRC)/ConfFile.cpp $(SISIYAD_SRC)/SisIYAServer.cpp $(SISIYAD_SRC)/sisiyad.cpp
#sisiyad_LDFLAGS=$(WARN_FLAGS) $(ALL_LFLAGS) $(ALL_LIBDIRS)
sisiyad_LDFLAGS=$(ALL_LFLAGS) $(ALL_LIBDIRS)
AM_CXXFLAGS=$(WARN_FLAGS) $(OPT_FLAGS) $(ALL_INC)
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
	install -d -m 755 $(install_root)/etc/sisiya/sisiyad
#	install -d -m 755 $(install_root)/etc/init.d
	install -d -m 755 $(install_root)/usr/sbin
#	install -d -m 755 $(install_root)/usr/share/doc/sisiyad-$(VERSION)
	install -d -m 755 $(install_root)/usr/share/man/man5
	install -d -m 755 $(install_root)/usr/share/man/man8
#	install -m 600 ../etc/sisiyad_sysvinit $(install_root)/etc/init.d/sisiyad
#	install -m 644 AUTHORS ChangeLog NEWS README $(install_root)/usr/share/doc/sisiyad
	install -m 644 ../doc/sisiyad.conf.5 $(install_root)/usr/share/man/man5
	install -m 644 ../doc/sisiyad.8 $(install_root)/usr/share/man/man8
	gzip -9 $(install_root)/usr/share/man/man5/*
	gzip -9 $(install_root)/usr/share/man/man8/*
	install -m 600 sisiyad.conf $(install_root)/etc/sisiya/sisiyad
	install -m 700 sisiyad $(install_root)/usr/sbin
