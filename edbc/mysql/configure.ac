dnl Process this file with autconf to produce a configure script
dnl Created by Erdal Mutlu 07.08.2005
AC_PREREQ(2.53)

dnl ------------------------------------------------
dnl Initialization and Versioning
dnl ------------------------------------------------
AC_INIT(libedbc_mysql,0.5.16-1,erdal@sisiya.org)
AM_INIT_AUTOMAKE(libedbc_mysql,0.5.16-1)
AM_CONFIG_HEADER(include/config.h)

dnl --------------------------------------------------  
dnl Check for programs
dnl --------------------------------------------------  
dnl AC_PROG_AWK
dnl save $CXXFLAGS since AC_PROG_CC likes to insert "-g -O2"
dnl if $CXXFLAGS is blank
cxxflags_save="$CXXFLAGS"
ldflags_save="$LDFLAGS"
CC=g++
AC_PROG_CXX
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_LN_S

dnl --------------------------------------------------
dnl Set build flags based on environment
dnl --------------------------------------------------
AC_CANONICAL_HOST

dnl Set some target options

#cxxflags_save="$CXXFLAGS" $cxxflags_save
cxxflags_save=$cxxflags_save
case "${host}" in
	*-*-darwin*)
		CXXFLAGS="-DDARWIN"
		;;
	*86-*-linux*)
		CXXFLAGS="-DLINUX -D_GNU_SOURCE" ### -D_GNU_SOURCE is used to get rid of the warning about the getpgid()
		;;
        sparc-sun-solaris2.6)
		CXXFLAGS="-DSOLARIS"
                LDFLAGS="-lsocket -lnsl"
                ;;
esac
CXXFLAGS="$CXXFLAGS $cxxflags_save"
LDFLAGS="$LDFLAGS $ldflags_save"

dnl --------------------------------------------------
dnl Check for libraries
dnl --------------------------------------------------

dnl --------------------------------------------------
dnl Check for headers
dnl --------------------------------------------------
dnl AC_HEADER_STDC
dnl AC_HEADER_SYS_WAIT
AC_CHECK_HEADERS([stdlib.h string.h])

dnl Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_INLINE

dnl Checks for library functions.
dnl AC_CHECK_FUNCS([strerror])

dnl options
dnl change this after you include config.h file. -DHAVE_UNISTD -DHAVE_VARARGS
dnl OPT_FLAGS="-rdynamic -DHAVE_UNISTD -DHAVE_VARARGS"

dnl Warning level
dnl WARN_FLAGS="-Wall -Wshadow -Woverloaded-virtual -Wsign-promo -Wfloat-equal -Wold-style-cast -Weffc++"
#WARN_FLAGS="-Wall -Wshadow -Woverloaded-virtual -Wsign-promo -Wfloat-equal"
WARN_FLAGS="-Wall"

dnl Debug 
DEBUG=
dnl DEBUG="-ggdb -DDEBUG"

dnl MySQL
MYSQL_INC=-I/usr/include/mysql
MYSQL_LIB=-L/usr/lib64/mysql
MYSQL_LFLAGS=-lmysqlclient

dnl EDBC
LIB_NAME=libedbc_mysql
LIB_VER_MAJOR=0
LIB_VER_MINOR=6.30

EDBC_INC=../include
EDBC_SRC=../src

EDBC_MYSQL_SRC=./src
EDBC_MYSQL_INC=./include

EDBC_UTILS_SRC=../utils/src
EDBC_UTILS_INC=../utils/include

dnl substitutes
AC_SUBST(WARN_FLAGS)
AC_SUBST(DEBUG)
AC_SUBST(EDBC_INC)
AC_SUBST(EDBC_SRC)
AC_SUBST(EDBC_MYSQL_INC)
AC_SUBST(EDBC_MYSQL_SRC)
AC_SUBST(EDBC_LIB_DIR)
AC_SUBST(EDBC_UTILS_INC)
AC_SUBST(EDBC_UTILS_SRC)
AC_SUBST(LIB_NAME)
AC_SUBST(LIB_VER_MAJOR)
AC_SUBST(LIB_VER_MINOR)

dnl ### 
AC_OUTPUT(Makefile)
echo
echo "***********************************************************"
echo "*            Now run make                                 *"
echo "*                                                         *"
echo "*            Thank you for using SisIYA !                 *"
echo "*          <http://sisiya.sourceforge.net>                *"
echo "***********************************************************"
echo
