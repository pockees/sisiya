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

#ifndef _sisiyad_postgresql_h
#define _sisiyad_postgresql_h
#include<string.h>
#include<stdlib.h>
/*
#ifdef DARWIN
 #include<libpq-fe.h>
#else
 #include<pgsql/libpq-fe.h>
#endif
*/
#include<libpq-fe.h>
#include<ctype.h>
#include"sisiyad1.h" 

/*extern char *pname;*/

int sisiyad_postgresql_insert_message(char *host,char *user,char *password,char *db,char *message);
int sisiyad_postgresql_process_queue(char *host,char *user,char *password,char *db);

int postgresql_db_connect(char *host,char *user,char *password,char *db);
void postgresql_db_close(void);
void postgresql_extract_fields(char *buffer,char *hostName);
int postgresql_getSystemID(void);
int postgresql_begin_transaction(void);
int postgresql_commit_transaction(void);
int postgresql_rollback_transaction(void);
int sisiya_postgresql_insert_message(void);
int postgresql_updateSystemStatus(int systemID);

#ifndef TRUE
 #define TRUE  1
#endif

#ifndef FALSE
 #define FALSE 0
#endif

#endif
