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

LIB_SRC=$(EDBC_MYSQL_SRC)/MySQL_Connection.cpp $(EDBC_MYSQL_SRC)/MySQL_Statement.cpp $(EDBC_MYSQL_SRC)/MySQL_DatabaseMetaData.cpp $(EDBC_MYSQL_SRC)/MySQL_ResultSet.cpp $(EDBC_MYSQL_SRC)/MySQL_ResultSetMetaData.cpp $(EDBC_UTILS_SRC)/parseURL.cpp
LIB_OBJ=MySQL_Connection.o MySQL_Statement.o MySQL_DatabaseMetaData.o MySQL_ResultSet.o MySQL_ResultSetMetaData.o parseURL.o

LIB_INC=$(EDBC_INC) $(EDBC_UTILS_INC) $(EDBC_MYSQL_INC)
LIB_OBJ_FLAGS=-fPIC -c $(WARN_FLAGS) $(DEBUG) 
LIB_SO_FLAGS=$(MYSQL_LIB) $(MYSQL_LFLAGS) -rdynamic -shared -Wl,-soname
DL=-ldl
LC=-lc
#######################################################################################################
all: lib.o shared_lib

lib.o:
	@echo "Compiling ..."
#	@$(CC) $(LIB_INC) $(LIB_OBJ_FLAGS) $(LIB_SRC) 
	$(CC) $(WARN_FLAGS) $(LIB_INC) $(LIB_OBJ_FLAGS) $(LIB_SRC) 
shared_lib:
	@echo "Making the shared library $(LIB_NAME).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) ..."
#	@$(CC) $(LIB_INC) $(LIB_SO_FLAGS),$(LIB_NAME).so.$(LIB_VER_MAJOR) -o $(LIB_NAME).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) $(LIB_OBJ) $(LC)
	$(CC) $(WARN_FLAGS) $(LIB_INC) $(LIB_SO_FLAGS),$(LIB_NAME).so.$(LIB_VER_MAJOR) -o $(LIB_NAME).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) $(LIB_OBJ) $(LC)
static_lib:
	@echo "Making the static library $(LIB_NAME).a ..."
#	@$(AR) $(AR_OPT) $(LIB_NAME).a $(LIB_OBJ)
	$(AR) $(AR_OPT) $(LIB_NAME).a $(LIB_OBJ)

clean:
	@echo "Cleaning up ..."
#	@$(RM) *.o
	$(RM) *.o $(LIB_NAME).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) $(LIB_NAME).a
