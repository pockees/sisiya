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

#ifndef _sisiyad_mysql_h
#define _sisiyad_mysql_h
#include<string.h>
#include<stdlib.h>
#include<mysql/mysql.h>
#include<mysql/errmsg.h>
#include"sisiyad1.h" 

extern char *pname;

int sisiyad_mysql_insert_message(char *host,char *user,char *password,char *db,char *message);

int mysql_db_connect(char *host,char *user,char *password,char *db);
void mysql_db_close(void);
void mysql_extract_fields(char *buffer,char *hostName);
int mysql_getSystemID(void);
int sisiya_mysql_insert_message(void);
int mysql_updateSystemStatus(int systemID);

/*
#ifndef MAX_STR
 #define MAX_STR 4096
#endif
*/


#ifndef TRUE
 #define TRUE  1
#endif

#ifndef FALSE
 #define FALSE 0
#endif


#endif
