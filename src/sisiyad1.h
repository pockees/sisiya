#ifndef _sisiyad1_h
#define _sisiyad1_h

#if HAVE_CONFIG_H
  #include"config.h"
#endif

#include<time.h>
#include"systype.h"
#include"mesg.h"
#include"esem.h"
#include"misc.h"
#ifdef HAVE_MYSQL
 #include"sisiyad_mysql.h"
#endif
#ifdef HAVE_PGSQL
 #include"sisiyad_postgresql.h"
#endif
#include"sisiya.h"
#include"sisiyad_common.h"

/****************************************************************/
int get_function(char *string);
int server(int sockfd,int semid);
/****************************************************************/
#endif
