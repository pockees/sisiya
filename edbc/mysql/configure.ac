dnl Process this file with autconf to produce a configure script
dnl Created by Erdal Mutlu 14.01.2014
AC_PREREQ(2.53)

dnl ------------------------------------------------
dnl Initialization and Versioning
dnl ------------------------------------------------
AC_INIT([libedbc_mysql], [__VERSION_MAJOR__.__VERSION_MINOR__], [erdal@sisiya.org])
#AM_INIT_AUTOMAKE($PACKAGE_NAME,$PACKAGE_VERSION)
AM_INIT_AUTOMAKE
AM_CONFIG_HEADER(include/config.h)

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

dnl MySQL
MYSQL_INC=-I/usr/include/mysql
MYSQL_LIB=-L/usr/lib/mysql
MYSQL_LFLAGS=-lmysqlclient

case "${host}" in
	*86-*-linux*)
		MYSQL_LIB=-L/usr/lib/mysql
		;;
	*86_64-*-linux*)
		MYSQL_LIB=-L/usr/lib64/mysql
		;;
esac

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


dnl EDBC
dnl LIB_NAME=libedbc_mysql
LIB_NAME=$PACKAGE_NAME
LIB_VER_MAJOR=__VERSION_MAJOR__
LIB_VER_MINOR=__VERSION_MINOR__

EDBC_INC=-I../include
EDBC_SRC=../src

EDBC_MYSQL_INC=-I./include
EDBC_MYSQL_SRC=./src

EDBC_UTILS_INC=-I../utils/include
EDBC_UTILS_SRC=../utils/src

dnl substitutes
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
AC_SUBST(MYSQL_INC)
AC_SUBST(MYSQL_LIB)
AC_SUBST(MYSQL_LFLAGS)
AC_SUBST(WARN_FLAGS)

dnl ### 
AC_OUTPUT(Makefile)
echo
echo "***********************************************************"
echo "*            Now run make                                 *"
echo "*                                                         *"
echo "*            Thank you for using SisIYA !                 *"
echo "*              <http://www.sisiya.org>                    *"
echo "***********************************************************"
echo
