dnl Process this file with autconf to produce a configure script
dnl Created by Erdal Mutlu 07.08.2005
AC_PREREQ(2.53)

dnl ------------------------------------------------
dnl Initialization and Versioning
dnl ------------------------------------------------
#AC_INIT([sisiyad], [0.6.30], [erdal@sisiya.org])
AC_INIT([sisiyad], m4_esyscmd(tr -d '\n' < version.txt), [erdal@sisiya.org])
AM_INIT_AUTOMAKE
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
AC_PROG_INSTALL
AC_PROG_LN_S

dnl --------------------------------------------------
dnl Set build flags based on environment
dnl --------------------------------------------------
AC_CANONICAL_HOST

dnl Set some target options

#cxxflags_save="$CXXFLAGS" $cxxflags_save
cxxflags_save=$cxxflags_save
LDFLAGS=""
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
#LDFLAGS="$LDFLAGS $ldflags_save"

dnl --------------------------------------------------
dnl Check for libraries
dnl --------------------------------------------------

dnl --------------------------------------------------
dnl Check for headers
dnl --------------------------------------------------
AC_HEADER_STDC
AC_HEADER_SYS_WAIT
AC_CHECK_HEADERS([sys/stat.h sys/types.h sys/wait.h signal.h stdarg.h varargs.h netdb.h arpa/inet.h errno.h netinet/in.h stdlib.h string.h strings.h sys/socket.h syslog.h unistd.h])

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_PID_T

dnl Checks for library functions.
AC_FUNC_FORK
AC_TYPE_SIGNAL
AC_FUNC_VPRINTF
AC_CHECK_FUNCS([bzero inet_ntoa socket strchr strerror])

dnl options
dnl change this after you include config.h file. -DHAVE_UNISTD -DHAVE_VARARGS
OPT_FLAGS="-rdynamic -DHAVE_UNISTD -DHAVE_VARARGS"

dnl Warning level
dnl WARN_FLAGS="-Wall -Wshadow -Woverloaded-virtual -Wsign-promo -Wfloat-equal -Wold-style-cast -Weffc++"
WARN_FLAGS="-Wall -Wshadow -Woverloaded-virtual -Wsign-promo -Wfloat-equal"

dnl Debug 
DEBUG=
dnl DEBUG="-ggdb -DDEBUG"

dnl sisiyad
SISIYAD_INC="-I./include"
SISIYAD_SRC="./src"
SISIYAD_LIBS="-ldl -ledbc"

dnl EDBC 
EDBC_DIR="../edbc"
EDBC_INC="-I$EDBC_DIR/include"
EDBC_LIB="-L$EDBC_DIR/lib"
EDBC_UTILS_INC="-I$EDBC_DIR/utils/include"
EDBC_UTILS_SRC="$EDBC_DIR/utils/src"

dnl substitutes
AC_SUBST(WARN_FLAGS)
AC_SUBST(OPT_FLAGS)
AC_SUBST(DEBUG)
AC_SUBST(SISIYAD_INC)
AC_SUBST(SISIYAD_LIBS)
AC_SUBST(SISIYAD_SRC)
AC_SUBST(EDBC_DIR)
AC_SUBST(EDBC_INC)
AC_SUBST(EDBC_SRC)
AC_SUBST(EDBC_LIB)
AC_SUBST(EDBC_UTILS_INC)
AC_SUBST(EDBC_UTILS_SRC)


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
