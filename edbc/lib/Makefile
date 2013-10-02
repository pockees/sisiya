CC=g++
AR=ar
AR_OPT=crs
RM=rm -f
OPT=-Wall
#DEBUG=-ggdb -DDEBUG
DEBUG=
###
LIB=libedbc
LIB_VER_MAJOR=0
LIB_VER_MINOR=1.0

###
EDBC_INC=../include
EDBC_SRC=../src

LIB_SRC=$(EDBC_SRC)/DriverManager.cpp
LIB_OBJ=DriverManager.o

LIB_INC=-I$(EDBC_INC)
LIB_OBJ_FLAGS=-fPIC -c $(OPT) $(DEBUG) 
LIB_SO_FLAGS=$(MYSQL_LIB) $(MYSQL_LFLAGS) -rdynamic -shared -Wl,-soname
DL=-ldl
LC=-lc
##################################################################################################################
all: lib.o shared_lib static_lib

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
	$(RM) *.o $(LIB).so* $(LIB).a
