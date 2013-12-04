/*
    Copyright (C) 2003  Erdal Mutlu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef _systype_h
#define _systype_h

#if HAVE_CONFIG_H
  #include"config.h"
#endif

#include<stdio.h>
#include<string.h>
#include<strings.h>
#include<stdlib.h>

#if HAVE_STDARG_H
 #include<stdarg.h>
 #define VA_LIST                va_list
 #define VA_START(a, f)         va_start(a, f)
#else
 #if HAVE_VARARGS_H
  #include<varargs.h>
  #define VA_LIST               va_alist
  #define VA_START(a, f)        va_start(a)
 #endif
#endif

#ifndef VA_START
  error no variadic api
#endif


#include<errno.h>


/***********************************************************/
/*#define CLIENT*/ 
/***********************************************************/

/****************************************************************************/


#if HAVE_STDARG_H
void err_quit(const char *format,...);
void err_sys(const char *format,...);
void err_ret(const char *format,...);
void err_dump(const char *format,...);
#else
void err_quit(format,VA_LIST)
        const char *format;
        va_dcl;
void err_sys(format,VA_LIST)
        const char *format;
        va_dcl;
void err_ret(format,VA_LIST)
        const char *format;
        va_dcl;
void err_dump(format,VA_LIST)
        const char *format;
        va_dcl;
#endif



void my_perror(void);
void err_init(char *ident);
char *sys_err_str(void);
/****************************************************************************/
#endif   
