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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#######################################################################################
INSTALL_DIR=$(DESTDIR)$(prefix)
DEV_DIR=$(INSTALL_DIR)/sisiya_edbc
DOCS_DIR=$(INSTALL_DIR)/sisiya_edbc_docs
LIBS_DIR=$(INSTALL_DIR)/usr/lib


#all: edbc_lib mysql_lib postgresql_lib tests docs
#all: edbc_lib mysql_lib tests docs
#all: edbc_lib mysql_lib docs
#all: edbc_lib mysql_lib postgresql_lib docs
#all: edbc_lib mysql_lib postgresql_lib docs
all: edbc_lib mysql_lib postgresql_lib


clean: clean_edbc_lib clean_mysql_lib clean_postgresql_lib clean_docs

edbc_lib:
	(cd lib && ./bootstrap create && ./configure && make)
mysql_lib:
	(cd mysql && ./bootstrap create && ./configure && make)
postgresql_lib:
	(cd postgresql && ./bootstrap create && ./configure && make)
docs:
	doxygen

clean_edbc_lib:
	(cd lib && make clean)
clean_mysql_lib:
	(cd mysql && make clean && ./bootstrap clean)
clean_postgresql_lib:
	(cd postgresql && make clean && ./bootstrap clean)
clean_docs:
	rm -rf docs/*
tests:
	(cd examples && make)
install:
### DEVEL
#	install -d $(DEV_DIR)/include
#	install -d $(DEV_DIR)/lib
#	install -m 644 include/*.hpp $(DEV_DIR)/include
### devel package is not complete and it is not tested
###	install -m 644 utils/include/*.hpp $(DEV_DIR)/include
#	install -m 644 lib/*.a $(DEV_DIR)/lib
### DOCS
#	install -d $(DOCS_DIR)
#	cp -a doc/* $(DOCS_DIR)/
### LIBS
	install -d $(LIBS_DIR)
# 	install -m 755 lib/*.so.* $(LIBS_DIR) ; cd $(LIBS_DIR) && ln -sf libedbc.so.$(VERSION) libedbc.so
	if test -f mysql/libedbc_mysql.so.$(VERSION) ; then install -m 755 mysql/libedbc_mysql.so.$(VERSION) $(LIBS_DIR) ; cd $(LIBS_DIR) && ln -sf libedbc_mysql.so.$(VERSION) libedbc_mysql.so ; fi
	if test -f postgresql/libedbc_pgsql.so.$(VERSION) ; then install -m 755 postgresql/libedbc_pgsql.so.$(VERSION) $(LIBS_DIR) ; cd $(LIBS_DIR) && ln -sf libedbc_pgsql.so.$(VERSION) libedbc_pgsql.so ; fi
