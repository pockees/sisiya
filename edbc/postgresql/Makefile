CC=g++
AR=ar
AR_OPT=crs
RM=rm -f
OPT=-Wall
#DEBUG=-ggdb -DDEBUG
DEBUG=
###
LIB=libedbc_pgsql
LIB_VER_MAJOR=0
LIB_VER_MINOR=1.3

###
ifeq "$(shell test -d /usr/include/pgsql  && echo YES )" "YES"
	PGSQL_INC=/usr/include/pgsql
else 
	ifeq "$(shell test -d /usr/include/postgresql  && echo YES )" "YES"
		PGSQL_INC=/usr/include/postgresql
	else	
		ifeq "$(shell test -d /usr/local/pgsql/include  && echo YES )" "YES"
			PGSQL_INC=/usr/local/pgsql/include
		else 
			PGSQL_INC=
		endif
	endif	
endif

PGSQL_LIB=
PGSQL_LFLAGS=-lpq

EDBC_INC=../include
EDBC_SRC=../src

EDBC_PGSQL_SRC=./src
EDBC_PGSQL_INC=./include

EDBC_UTILS_SRC=../utils/src
EDBC_UTILS_INC=../utils/include

LIB_SRC=$(EDBC_PGSQL_SRC)/PostgreSQL_Connection.cpp $(EDBC_PGSQL_SRC)/PostgreSQL_Statement.cpp $(EDBC_PGSQL_SRC)/PostgreSQL_DatabaseMetaData.cpp $(EDBC_PGSQL_SRC)/PostgreSQL_ResultSet.cpp $(EDBC_PGSQL_SRC)/PostgreSQL_ResultSetMetaData.cpp $(EDBC_UTILS_SRC)/parseURL.cpp
LIB_OBJ=PostgreSQL_Connection.o PostgreSQL_Statement.o PostgreSQL_DatabaseMetaData.o PostgreSQL_ResultSet.o PostgreSQL_ResultSetMetaData.o parseURL.o

LIB_INC=-I$(EDBC_INC) -I$(EDBC_UTILS_INC) -I$(EDBC_PGSQL_INC) -I$(PGSQL_INC)
LIB_OBJ_FLAGS=-fPIC -c $(OPT) $(DEBUG) 
LIB_SO_FLAGS=$(PGSQL_LIB) $(PGSQL_LFLAGS) -rdynamic -shared -Wl,-soname
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
	$(RM) *.o $(LIB).so.$(LIB_VER_MAJOR).$(LIB_VER_MINOR) $(LIB).a
