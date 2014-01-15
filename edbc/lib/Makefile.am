CC=g++
AR=ar
AR_OPT=crs
RM=rm -f
###

LIB_SRC=$(EDBC_SRC)/DriverManager.cpp
LIB_OBJ=DriverManager.o

LIB_INC=$(EDBC_INC)
LIB_OBJ_FLAGS=-fPIC -c $(WARN_FLAGS) $(DEBUG) 
#LIB_SO_FLAGS=$(MYSQL_LIB) $(MYSQL_LFLAGS) -rdynamic -shared -Wl,-soname
LIB_SO_FLAGS=-rdynamic -shared -Wl,-soname
DL=-ldl
LC=-lc
##################################################################################################################
all: lib.o shared_lib static_lib

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
	$(RM) *.o $(LIB_NAME).so* $(LIB_NAME).a
