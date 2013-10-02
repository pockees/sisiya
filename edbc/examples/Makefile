CC=g++
RM=rm -f
WARNINGS=-Wall -Wshadow -Woverloaded-virtual -Wsign-promo -Wfloat-equal 
OPT=$(WARNINGS) -rdynamic
DEBUG=-ggdb -DDEBUG
#DEBUG=
###
EDBC_INC=../include
EDBC_SRC=../src

EDBC_UTILS_INC=../utils/include
EDBC_UTILS_SRC=../utils/src

ALL_LIB=../lib 
ALL_LFLAGS=-ldl -ledbc
ALL_INC=-I$(EDBC_INC) -I$(EDBC_UTILS_INC)

all: test1 test2 test_db

test1: test1.o
	$(CC) $(DEBUG) $(OPT) $(ALL_INC) test1.o -L$(ALL_LIB) $(ALL_LFLAGS) -o test1
	rm -f *.o

test1.o: test1.cpp
	$(CC) $(DEBUG) $(OPT) -I$(EDBC_INC) -c test1.cpp -o test1.o

test2: parseURL.o test2.o
	$(CC) $(DEBUG) $(OPT) $(ALL_INC) parseURL.o test2.o -L$(ALL_LIB) $(ALL_LFLAGS) -o test2
	rm -f *.o
test2.o: test2.cpp
	$(CC) $(DEBUG) $(OPT) -I$(EDBC_INC) -I$(EDBC_UTILS_INC) -c test2.cpp -o test2.o

test_db: parseURL.o test_db.o
	$(CC) $(DEBUG) $(OPT) $(ALL_INC) parseURL.o test_db.o -L$(ALL_LIB) $(ALL_LFLAGS) -o test_db
	rm -f *.o

test_db.o: test_db.cpp
	$(CC) $(DEBUG) $(OPT) -I$(EDBC_INC) -I$(EDBC_UTILS_INC) -c test_db.cpp -o test_db.o

parseURL.o: $(EDBC_UTILS_SRC)/parseURL.cpp
	$(CC) $(DEBUG) $(OPT) -I$(EDBC_UTILS_INC) -c $(EDBC_UTILS_SRC)/parseURL.cpp -o parseURL.o

clean:
	$(RM) *.o
