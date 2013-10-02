CC=g++
AR=ar
AR_OPT=crs
RM=rm -f
OPT=-Wall
#DEBUG=-ggdb -DDEBUG
DEBUG=
###
LIB=libedbc_mysql
LIB_VER_MAJOR=0
LIB_VER_MINOR=1.3

###
MYSQL_INC=-I/usr/include/mysql
MYSQL_LIB=-L/usr/lib/mysql
MYSQL_LFLAGS=-lmysqlclient

EDBC_INC=../include
EDBC_SRC=../src

EDBC_MYSQL_SRC=./src
EDBC_MYSQL_INC=./include

EDBC_UTILS_SRC=../utils/src
EDBC_UTILS_INC=../utils/include

LIB_SRC=$(EDBC_MYSQL_SRC)/MySQL_Connection.cpp $(EDBC_MYSQL_SRC)/MySQL_Statement.cpp $(EDBC_MYSQL_SRC)/MySQL_DatabaseMetaData.cpp $(EDBC_MYSQL_SRC)/MySQL_ResultSet.cpp $(EDBC_MYSQL_SRC)/MySQL_ResultSetMetaData.cpp $(EDBC_UTILS_SRC)/parseURL.cpp
LIB_OBJ=MySQL_Connection.o MySQL_Statement.o MySQL_DatabaseMetaData.o MySQL_ResultSet.o MySQL_ResultSetMetaData.o parseURL.o

LIB_INC=-I$(EDBC_INC) -I$(EDBC_UTILS_INC) -I$(EDBC_MYSQL_INC)
LIB_OBJ_FLAGS=-fPIC -c $(OPT) $(DEBUG) 
LIB_SO_FLAGS=$(MYSQL_LIB) $(MYSQL_LFLAGS) -rdynamic -shared -Wl,-soname
DL=-ldl
LC=-lc
##################################################################################################################
all: lib.o shared_lib

lib.o:
	@echo "Compiling ..."
#	@$(CC) $(LIB_INC) $(LIB_OBJ_FLAGS) $(LIB_SRC) 
	$(CC) $(OPT) $(LIB_INC) $(LIB_OBJ_FLAGS) $(LIB_SRC) 
shared_lib:
	@echo "Making the shared library $(LIB).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) ..."
#	@$(CC) $(LIB_INC) $(LIB_SO_FLAGS),$(LIB).so.$(LIB_VER_MAJOR) -o $(LIB).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) $(LIB_OBJ) $(LC)
	$(CC) $(OPT) $(LIB_INC) $(LIB_SO_FLAGS),$(LIB).so.$(LIB_VER_MAJOR) -o $(LIB).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) $(LIB_OBJ) $(LC)
static_lib:
	@echo "Making the static library $(LIB).a ..."
#	@$(AR) $(AR_OPT) $(LIB).a $(LIB_OBJ)
	$(AR) $(AR_OPT) $(LIB).a $(LIB_OBJ)

clean:
	@echo "Cleaning up ..."
#	@$(RM) *.o
	$(RM) *.o $(LIB).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) $(LIB).a
