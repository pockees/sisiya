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


#if HAVE_CONFIG_H
  #include"config.h"
#endif

#include<stdio.h>

/*
#if STDC_HEADERS
 #include<stdlib.h>
 #include<string.h>
#elif HAVE_STRINGS_H
#  include <strings.h>
#endif 
*/

#if HAVE_UNISTD_H
 #ifdef DARWIN
  #include<sys/unistd.h>
 #else
  #include<unistd.h>
 #endif
#endif

/*
#if HAVE_ERRNO_H
#include<errno.h>
#endif 
#ifndef errno
*/
/* Some systems #define this! */
/*extern int errno;
#endif
*/

#ifdef HAVE_SYSLOG_H
 #include<syslog.h>
#endif

#include"systype.h"

#ifdef SERVER
 #include"esignal.h"
#endif
#include"misc.h"

#ifndef EXIT_SUCCESS
 #define EXIT_SUCCESS  0
 #define EXIT_FAILURE  1
#endif

#define MAX_STR    	4096
#define MAX_ID    	32

#define MESSAGE_INFO	0
#define MESSAGE_OK	1
#define MESSAGE_WARNING 2
#define MESSAGE_ERROR   3

#define LOGLEVEL 	0
#define IP		1
#define PORT		2
#define	DB_TYPE		3
#define	DB_SERVER	4
#define	DB_NAME		5
#define	DB_USER		6
#define	DB_PASSWORD	7
#define	SEMKEY		8
#define PID_FILE	9
#define QPID_FILE	10
#define SLEEP_SECONDS	11 

#define NUMCONFIGS 	12


#ifndef TRUE
 #define TRUE 1
#endif
#ifndef FALSE
 #define FALSE 0
#endif

/* global variables */
extern int loglevel;
extern long int port;
extern char configs[NUMCONFIGS][2][MAX_STR];
extern int loglevel; 	/* Levels ar 0 from 2. 0 is no log, 1 is normal logging and  2 is log everything. */
