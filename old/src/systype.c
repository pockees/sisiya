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

/*
  Error handling routines.
  
  The functions in this file are independent of any application variables,
  and may be used with any C program.
  Either of the names CLIENT or SERVER may be defined when compiling
  this function. If neither are defined, we assume CLIENT.
*/

#include"systype.h"

#ifdef CLIENT
 #ifdef SERVER
  cannot define both CLIENT and SERVER
 #endif
#endif

#ifndef CLEINT
 #ifndef SERVER
  #define CLEINT 1        /* default to cleint */
 #endif
#endif      
    
#ifndef NULL      
 #define NULL ((void *)0)
#endif 


extern char *pname;


extern int errno;           /* UNIX errno number */
/*extern int sys_nerr;*/        /* # of error message strings in sys table */
/*extern const char *const sys_errlist[];*/ /* the system error message table */

#ifdef SYS5
int t_errno;  /* in case caller is using TLI, these are "tentative
                 definitions"; else they're "definitions" */
int t_nerr;
char *t_errlist[1];                  

#endif




#ifdef CLIENT          /* these all output to stderr */

/*
  Fatal erorr. Print a message and terminate.
  Don't dump core and don't print the system's errno value.
  
  err_quit(str,arg1,arg2,...)
  
  The "sts" must spacify the conversion specification for any args.
*/
void
#if HAVE_STDARG_H
err_quit(const char *format,...)
#else
err_quit(format,VA_LIST)
        const char *format;
        va_dcl
#endif
{
 VA_LIST ap;

 VA_START(ap,format);

 if(pname != NULL)
    fprintf(stderr,"%s: ", pname);

 vfprintf(stderr,format,ap);
 fputc('\n',stderr);
 va_end(ap);
 exit(EXIT_FAILURE);
};


/*
  Fatal error related to a system call. Print a message and terminate.
  Don't dump core, but do print the system's errno value and
  its asocited message.

  err_sys(str,arg1,arg2,...)
  
  The string "str" must spacify the conversion specification for any args.
*/
void
#if HAVE_STDARG_H
err_sys(const char *format,...)
#else
err_sys(format,VA_LIST)
        const char *format;
        va_dcl
#endif
{
 VA_LIST ap;

 VA_START(ap,format);

 if(pname != NULL)
    fprintf(stderr,"%s: ", pname);

 vfprintf(stderr,format,ap);
 fputc('\n',stderr);
 va_end(ap);

 my_perror();
  
 exit(EXIT_FAILURE);   
};  


/*
  Recoverable error. Print a message and return to caller.

  err_ret(str,arg1,arg2,...)
  
  The string "str" must spacify the conversion specification for any args.
*/
void
#if HAVE_STDARG_H
err_ret(const char *format,...)
#else
err_ret(format,VA_LIST)
        const char *format;
        va_dcl
#endif
{
 VA_LIST ap;

 VA_START(ap,format);

 if(pname != NULL)
    fprintf(stderr,"%s: ", pname);

 vfprintf(stderr,format,ap);
 fputc('\n',stderr);
 va_end(ap);

 my_perror();
  
 fflush(stdout);
 fflush(stderr);
 
/* return;*/
};  


/*
  Fatal error. Print a message, dump core (for debugging) and terminate.

  err_dump(str,arg1,arg2,...)
  
  The string "str" must spacify the conversion specification for any args.
*/
void
#if HAVE_STDARG_H
err_dump(const char *format,...)
#else
err_dump(format,VA_LIST)
        const char *format;
        va_dcl
#endif
{
 VA_LIST ap;

 VA_START(ap,format);

 if(pname != NULL)
    fprintf(stderr,"%s: ", pname);

 vfprintf(stderr,format,ap);
 fputc('\n',stderr);
 va_end(ap);

 my_perror();
  
 fflush(stdout);  /* abort doesn't flush stdio buffers */
 fflush(stderr);
 
 abort();         /* dump core and terminate */
 exit(1);         /* shuldn't get here       */
};  

/* Print the UNIX errno value. */

void my_perror(void)
{
 char *sys_err_str();
 
 fprintf(stderr," %s\n",sys_err_str());
};


#endif    /* CLIENT */


#ifdef SERVER

#ifdef BSD

/*
  Under BSD, these server routines use the syslog(3) facility.
  They don't append a newline, for example.
*/

#include<syslog.h>

#else        /* not BSD */

/*
  Ther really ought to be better way to handle server logging 
  under System V.
*/

#define syslog(a,b)      fprintf(stderr,"%s\n",(b))
#define openlog(a,b,c)  fprintf(stderr,"%s\n",(a))

#endif   /* BSD */

char emesgstr[255]={0};   /* used by all server routines */

/*
  Identify ourself, for syslog() messages.
  LOG_PID is an option that says prepend each message with our pid.
  LOG_CONS is an option that says write to console if unable to send 
  the message to syslogd.
  LOG_DAEMON is our facility. 
*/

void err_init(char *ident)
{
 openlog(ident,(LOG_PID|LOG_CONS),LOG_DAEMON);
};  


/*
  Fatal error. Print a message and terminate.
  Don't print the system's errno value.
  
  err_quit(str,arg1,arg2,...)
  The string "str" must spacify the conversion specification for any args.
*/  

/* VARARGS1 */
void
#if HAVE_STDARG_H
err_quit(const char *format,...)
#else
err_quit(format,VA_LIST)
        const char *format;
        va_dcl
#endif
{
 VA_LIST ap;

 VA_START(ap,format);
 
 vsprintf(emesgstr,format,ap);
 va_end(ap);
 
 syslog(LOG_ERR,emesgstr);
 
 exit(EXIT_FAILURE);   
};  

/*
  Fatal error related to a system call. Print a message and terminate.
  Don't dump core, but do print the system's errno value and
  its asocited message.

  err_sys(str,arg1,arg2,...)
  
  The string "str" must spacify the conversion specification for any args.
*/

void
#if HAVE_STDARG_H
err_sys(const char *format,...)
#else
err_sys(format,VA_LIST)
        const char *format;
        va_dcl
#endif
{
 VA_LIST ap;

 VA_START(ap,format);
 vsprintf(emesgstr,format,ap);
 va_end(ap);
 
 my_perror();

 syslog(LOG_ERR,emesgstr);
   
 exit(EXIT_FAILURE);   
};  
  
/*
  Recoverable error. Print a message and return to caller.

  err_ret(str,arg1,arg2,...)
  
  The string "str" must spacify the conversion specification for any args.
*/
void
#if HAVE_STDARG_H
err_ret(const char *format,...)
#else
err_ret(format,VA_LIST)
        const char *format;
        va_dcl
#endif
{
 VA_LIST ap;

 VA_START(ap,format);

 vsprintf(emesgstr,format,ap);
 va_end(ap);
 
 my_perror();
 
 syslog(LOG_ERR,emesgstr);
  
/* return;*/
};  

/*
  Fatal error. Print a message, dump core (for debugging) and terminate.

  err_dump(str,arg1,arg2,...)
  
  The string "str" must spacify the conversion specification for any args.
*/
void
#if HAVE_STDARG_H
err_dump(const char *format,...)
#else
err_dump(format,VA_LIST)
        const char *format;
        va_dcl
#endif
{
 VA_LIST ap;

 VA_START(ap,format);

 vsprintf(emesgstr,format,ap);
 va_end(ap);
 
 my_perror();

 syslog(LOG_ERR,emesgstr);
  
 abort();         /* dump core and terminate */
 exit(EXIT_FAILURE);         /* shuldn't get here       */
};  

/* 
  Print the UNIX errno value. 
  We just append it to the end of emesgstr[] array.
*/

void my_perror(void)
{
 register int length;
 char *sys_err_str();
 
 length=strlen(emesgstr);
 sprintf(emesgstr+length," %s",sys_err_str());
};

#endif /* SERVER */

/*
  Return a string containing some additional operating system
  dependent information.
  Note that different versions of UNIX assign different meanings
  to the same value of "errno" (compare errno's starting with 35
  betweent System V and BSD, for example). This means that if an error
  condition is being sent to another UNIX system, we must interpret
  the errno value on the system that generated the error, and not just 
  send the decimal value of errno to the other system.
*/

char * sys_err_str(void)
{
 static char msgstr[200];
 
 if(errno != 0)
   {
    /*if(errno > 0 && errno < sys_nerr)*/
    if(errno > 0)
       /*sprintf(msgstr,"(%s)",sys_errlist[errno]);*/
       sprintf(msgstr,"(%s)",strerror(errno));
    else   
       sprintf(msgstr,"(errno = %d)", errno);
   }
 else      
   msgstr[0]='\0';

#ifdef SYS5
 if(t_errno != 0) 
   {
    char tmsgstr[100];
    
   /* if(t_errno > 0 && t_errno < sys_nerr)*/
    if(t_errno > 0)
       sprintf(tmsgstr,"(%s)",t_errlist[t_errno]);
    else   
       sprintf(tmsgstr,"(t_errno = %d)", t_errno);
    strcat(msgstr,tmsgstr); /* catenate strings */   
   }
#endif   

 return(msgstr);
};
