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

#include"sisiyad_mysql.h"

static void getTimestamp(char *buff);
static int db_init(MYSQL *mysql);
static void db_close(MYSQL *mysql);
static int db_connect(MYSQL *mysql,char *host,char *user,char *password,char *db);
static void sisiya_extract_fields(char *msg,int *serviceID,int *statusID,char *hostName,char *str,char *sendTimestamp);
static int getIntValue(MYSQL *mysql,char *sql_str);
static void getErrorWarningMessage(MYSQL *mysql,int systemID,char *buffer);
static int getSystemUpdateChangeTimes(MYSQL *mysql,int systemID,char *updateTime,char *changeTime);
static int getSystemID(MYSQL *mysql,char *hostName);
/*static int isSystemActive(MYSQL *mysql,int systemID);*/
static int db_query(MYSQL *mysql,char *sql);
static int db_insert(MYSQL *mysql,char *sql);
static int db_update(MYSQL *mysql,char *sql);
/*static int sisiya_insert_message(MYSQL *mysql,char *message);*/

/* ------------------------------------------------------------------------------------------------*/
/*static char db_server[MAX_STR+1],db_user[MAX_STR+1],db_password[MAX_STR+1],db_name[MAX_STR+1];*/
static char g_message[MAX_STR+1],g_sendTimestamp[MAX_STR+1],g_hostName[MAX_STR+1];
static int g_systemID,g_serviceID,g_statusID;
static MYSQL g_mysql;	 

int mysql_db_connect(char *host,char *user,char *password,char *db);
void mysql_db_close(void);
void mysql_extract_fields(char *buffer,char *hostName);
int mysql_getSystemID(void);
/*
I do not use transaction in MySQL yet. May be in the future:)
int mysql_begin_transaction(void);
int mysql_commit_transaction(void);
int mysql_rollback_transaction(void);
*/
int sisiya_mysql_insert_message(void);
int mysql_updateSystemStatus(int systemID);
/* ------------------------------------------------------------------------------------------------*/
                                                                                                                            
/* ------------------------------------------------------------------------------------------------*/
/*
	Returns :	TRUE on success
			FALSE on failure
*/
int mysql_db_connect(char *host,char *user,char *password,char *db)
{
	if(db_init(&g_mysql) != TRUE) {
		syslog(LOG_ERR,"Error : failed to initialize MYSQL object!");	  
		return(FALSE);
	}	 

	if(db_connect(&g_mysql,host,user,password,db) != TRUE) {
		syslog(LOG_ERR,"Failed to connect to database %s! MySQL error : %s",db,mysql_error(&g_mysql));
		return(FALSE);  
	}
	return(TRUE);
}
	
void mysql_db_close(void)
{
	db_close(&g_mysql);
}


void mysql_extract_fields(char *buffer,char *hostName)
{
	sisiya_extract_fields(buffer,&g_serviceID,&g_statusID,g_hostName,g_message,g_sendTimestamp);
	strcpy(hostName,g_hostName);
}

/*
	Return code:	0 	: no such system; 
			-x	: the system with ID=x is not enabled
*/
int mysql_getSystemID()
{
	g_systemID=getSystemID(&g_mysql,g_hostName);
	return(g_systemID);
}

/*
	Returns :	TRUE on success
			FALSE on failure
*/
int sisiya_mysql_insert_message(void)
{
	int sID;	
	char sql_str[MAX_STR];
	char recieveTimestamp[15];
 
	if(g_message == NULL)
		return(FALSE);	 

	getTimestamp(recieveTimestamp);

	/* for systemhistorystatus table */
	snprintf(sql_str,MAX_STR-1,"insert into systemhistorystatus values('%s',%d,%d,%d,'%s','%s')",g_sendTimestamp,g_systemID,g_serviceID,g_statusID,recieveTimestamp,g_message); 
	if(db_insert(&g_mysql,sql_str) != 1) {
		syslog(LOG_ERR,"INSERT error : %s",sql_str);	  
		return(FALSE);
	}	 

	/* for systemservice table */
	snprintf(sql_str,MAX_STR-1,"select statusid from systemservicestatus where systemid=%d and serviceid=%d",g_systemID,g_serviceID);
	sID=getIntValue(&g_mysql,sql_str);
	if(sID != -1) {
		/* update */	 
		if(sID != g_statusID) 
			snprintf(sql_str,MAX_STR-1,"update systemservicestatus set statusid=%d,changetime='%s',updatetime='%s',str='%s' where systemid=%d and serviceid=%d",g_statusID,g_sendTimestamp,g_sendTimestamp,g_message,g_systemID,g_serviceID);
		else 
			snprintf(sql_str,MAX_STR-1,"update systemservicestatus set statusid=%d,updatetime='%s',str='%s' where systemid=%d and serviceid=%d",g_statusID,g_sendTimestamp,g_message,g_systemID,g_serviceID);
		if(db_update(&g_mysql,sql_str) != 1) {
			syslog(LOG_ERR,"UPDATE error : %s",sql_str);
			return(FALSE);
		}
	}	 
	else {
		/* new record */	 
		sprintf(sql_str,"insert into systemservicestatus values(%d,%d,%d,'%s','%s','%s')",g_systemID,g_serviceID,g_statusID,g_sendTimestamp,g_sendTimestamp,g_message);
  		if(db_insert(&g_mysql,sql_str) != 1) {
			syslog(LOG_ERR,"INSERT error : %s",sql_str);
			return(FALSE);
		}
	}	 

	return(TRUE);
}


/*
	Returns :	TRUE on success
			FALSE on failure
*/
int mysql_updateSystemStatus(int systemID)
{
	int systemStatusID,maxStatusID;
	char updateTime[MAX_STR+1],changeTime[MAX_STR+1];
	char sql_str[MAX_STR+1];
	char error_warning_str[MAX_STR+1];

	if(getSystemUpdateChangeTimes(&g_mysql,systemID,updateTime,changeTime) == FALSE) {
		syslog(LOG_INFO,"could not get change and update times from the systemservicestatus table. Generating..");
		getTimestamp(changeTime);
		getTimestamp(updateTime);
	}
	
	/* get the system status */
	snprintf(sql_str,MAX_STR,"select statusid from systemstatus where systemid=%d",systemID);
	systemStatusID=getIntValue(&g_mysql,sql_str);

	/* get the max status from systemservicestatus */
	snprintf(sql_str,MAX_STR,"select max(statusid) from systemservicestatus where systemid=%d",systemID);
	maxStatusID=getIntValue(&g_mysql,sql_str);	 
	if(systemStatusID != -1) {
		/* it is going to be an update */	 
		if(maxStatusID < 2) /* The system is OK */
			snprintf(sql_str,MAX_STR,"update systemstatus set statusid=%d,updatetime='%s',str='System is OK' where systemid=%d",MESSAGE_OK,updateTime,systemID);
		else { /* System has warnings and/or errors  */	  
			getErrorWarningMessage(&g_mysql,systemID,error_warning_str);
			if(maxStatusID != systemStatusID) 
					snprintf(sql_str,MAX_STR,"update systemstatus set statusid=%d,changetime='%s',updatetime='%s',str='%s' where systemid=%d",maxStatusID,changeTime,updateTime,error_warning_str,systemID);   
			else 
				snprintf(sql_str,MAX_STR,"update systemstatus set updatetime='%s',str='%s' where systemid=%d",updateTime,error_warning_str,systemID);	   
		}	  
	}
	else {
		/* new record */	 
		systemStatusID=maxStatusID;
		if(systemStatusID < 2)	 
			sprintf(sql_str,"insert into systemstatus values(%d,%d,'%s','%s','System is OK')",systemID,systemStatusID,updateTime,changeTime);
		else {
			getErrorWarningMessage(&g_mysql,systemID,error_warning_str);
			sprintf(sql_str,"insert into systemstatus values(%d,%d,'%s','%s','%s')",systemID,systemStatusID,updateTime,changeTime,error_warning_str);
		}
	}		
 	if(db_query(&g_mysql,sql_str) != 1) { /* update or insert must produce exactly 1 affected row*/
		/*
		syslog(LOG_ERR,"SQL error : %s Update or insert must produce exactly 1 row?!",sql_str);
		return(FALSE);
		*/
		syslog(LOG_ERR,"SQL error : %s Update or insert must produce exactly 1 row?! Should be ok.",sql_str);
		return(TRUE);
	}
	return(TRUE);
}



/* ------------------------------------------------------------------------------------------------*/

static void getTimestamp(char *buff)
{
 time_t tt;
 struct tm *t;
                                                                                                                             
 time(&tt);
 t=localtime(&tt);
                                                                                                                             
 sprintf(buff,"%.2d%.2d%.2d%.2d%.2d%.2d",1900+t->tm_year,1+t->tm_mon,t->tm_mday,t->tm_hour,t->tm_min,t->tm_sec);
};

static int db_init(MYSQL *mysql)
{
 mysql_init(mysql);
 mysql_options(mysql,MYSQL_OPT_COMPRESS,0);
/* mysql_options(&mysql,MYSQL_READ_DEFAULT_GROUP,"odbc");*/
 if(mysql == NULL)
   return(FALSE);
 return(TRUE);
}	

static void db_close(MYSQL *mysql)
{
	mysql_close(mysql);	
}

static int db_connect(MYSQL *mysql,char *host,char *user,char *password,char *db)
{
	if(mysql == NULL)
		return(FALSE);
 
	if(!mysql_real_connect(mysql,host,user,password,db,0,NULL,0)) {
		syslog(LOG_ERR,"Failed to connect to database %s! MySQL Error: %s\n",db,mysql_error(mysql));
		return(FALSE);
	}

	return(TRUE);
}	

static void sisiya_extract_fields(char *msg,int *serviceID,int *statusID,char *hostName,char *str,char *sendTimestamp)
{
 int i;	
 char del[2],s[MAX_STR];	
 char *sptr;
 char *p;

 del[0]=msg[0];
 del[1]='\0';

 strcpy(s,msg);
 
/* 
 sptr=(char *)malloc(sizeof(char)*MAX_STR);
 if(str == NULL) {
  fprintf(stderr,"%s: Cannot allocate memory (sizeof(char)*%d",pname,MAX_STR);	  
  exit(1);
 }	 
*/	 
 p=strtok_r(s,del,&sptr);
 *serviceID=atoi(p);
 
 p=strtok_r(NULL,del,&sptr);
 *statusID=atoi(p);
 
 p=strtok_r(NULL,del,&sptr);
 strcpy(hostName,p);
 
 p=strtok_r(NULL,del,&sptr);
 strcpy(sendTimestamp,p);
 
 p=strtok_r(NULL,del,&sptr);
 strcpy(str,p);

 /* Now arrange sendTimestamp as yyyymmddhhmmss , this is now our Timestamp format (char(14)) */
 /* [yyyy-mm-dd hh:mm:ss] -> [yyyymmddhhmmss]*/
 
 s[0]='\0';
 p=&sendTimestamp[0];
 strncat(s,p,4);
 p=p+5;
 strncat(s,p,2);
 for(i=0;i<4;i++) {
  p=p+3;
  strncat(s,p,2);
 }
 s[14]='\0';
 strcpy(sendTimestamp,s);
 
}

/* Returns : an integer or -1 on error. */
static int getIntValue(MYSQL *mysql,char *sql_str)
{
 int sID=-1; /* set to no such system */	
 MYSQL_ROW row;
 MYSQL_RES *result;

 if(mysql_query(mysql,sql_str)) {
  syslog(LOG_ERR,"Error in the query: %s",sql_str);
  return(sID);
 }
 else { 
  result=mysql_use_result(mysql);
  if(result) {
    row=mysql_fetch_row(result);
    /*if(row != NULL)  */
    if(row)  
     sID=atoi(row[0]);	    
  }
  mysql_free_result(result);	  
 }
 return(sID);
}	

static void getErrorWarningMessage(MYSQL *mysql,int systemID,char *buffer)
{
 MYSQL_ROW row;
 MYSQL_RES *result;
 char sql_str[MAX_STR];	

 sprintf(sql_str,"select b.str,c.str from systemservicestatus a,services b,status c where a.serviceid=b.id and a.statusid=c.id and systemid=%d and c.id > 1 order by statusid desc;",systemID);
 
 if(mysql_query(mysql,sql_str)) {
  syslog(LOG_ERR,"Error in the query: %s",sql_str);
  strcpy(buffer,"");
 }
 else { 
  result=mysql_store_result(mysql);
  if(result) {
    buffer[0]='\0';	  
    /*while((row=mysql_fetch_row(result)) != NULL) {*/
    while((row=mysql_fetch_row(result))) {
     strcat(buffer,row[0]);	    
     strcat(buffer,"(");	    
     strcat(buffer,row[1]);	    
     strcat(buffer,") ");	    
    }
    buffer[strlen(buffer)-1]='\0';
  }
  mysql_free_result(result);	  
 }
}

/* Returns : TRUE on success, FALSE on error.*/
static int getSystemUpdateChangeTimes(MYSQL *mysql,int systemID,char *updateTime,char *changeTime)
{
	char sql_str[MAX_STR+1];
	MYSQL_ROW row;
	MYSQL_RES *result;
	
	updateTime[0]='\0';
	changeTime[0]='\0';

	snprintf(sql_str,MAX_STR,"select updatetime from systemservicestatus where systemid=%d order by updatetime desc",systemID);
	if(mysql_query(mysql,sql_str)) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		return(FALSE);
	}

	result=mysql_store_result(mysql);
	if(result != NULL) { 
		/* may be I should use mysql_num_rows here. See docs! */
		/*if((row=mysql_fetch_row(result)) != NULL) {*/
		if((row=mysql_fetch_row(result))) {
			strcpy(updateTime,row[0]);	    
  			mysql_free_result(result);	  
		}

	}
	else {
		mysql_free_result(result);	  
		return(FALSE);
	}

	snprintf(sql_str,MAX_STR,"select changetime from systemservicestatus where systemid=%d order by changetime desc",systemID);
	if(mysql_query(mysql,sql_str)) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		mysql_free_result(result);	  
		return(FALSE);
	}
	result=mysql_use_result(mysql);
	if(result) {
		row=mysql_fetch_row(result);
		/* may be I should use mysql_num_rows here. See docs! */
		/*if(row != NULL)  */
		if(row)  
			strcpy(changeTime,row[0]);	    
	}
	else {
		mysql_free_result(result);	
		return(FALSE);
	}
	mysql_free_result(result);	
	return(TRUE);
}	


/*
	Return code:	0 	: no such system; 
			-x	: the system with ID=x is not enabled
*/
static int getSystemID(MYSQL *mysql,char *hostName)
{
	int systemID=0; /* set to no such system */	
	MYSQL_ROW row;
	MYSQL_RES *result;
	char sql_str[MAX_STR];	

	strcpy(sql_str,"select id,active from systems where ");
	if(strchr(hostName,'.') == NULL)	
		strcat(sql_str,"hostname='");
	else
		strcat(sql_str,"fullhostname='");
	strcat(sql_str,hostName);
	strcat(sql_str,"'");
 
	if(mysql_query(mysql,sql_str)) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		/*mysql_free_result(result);*/
		return(systemID);
	}
	result=mysql_use_result(mysql);
	if(result) {
		row=mysql_fetch_row(result);
/* may be I should use mysql_num_rows here. See docs! */
		/*if(row != NULL) { */
		if(row) { 
			systemID=atoi(row[0]);
			if(strcmp("f",row[1]) == 0)
				systemID=-1*systemID;
		}
	}
	mysql_free_result(result);	  
	return(systemID);
}	

/*
static int isSystemActive(MYSQL *mysql,int systemID)
{
 MYSQL_ROW row;
 MYSQL_RES *result;
 char sql_str[MAX_STR];	

 sprintf(sql_str,"select active from systems where id=%d",systemID);
 
 if(mysql_query(mysql,sql_str)) {
  syslog(LOG_ERR,"Error in the query: %s",sql_str);
  return(FALSE);
 }
 else { 
  result=mysql_use_result(mysql);
  if(result) {
    row=mysql_fetch_row(result);
  */  /*if(row != NULL)  */
   /* if(row)  
     if(strcmp("t",row[0]) == 0) {
       mysql_free_result(result);	  
       return(TRUE);
     }
  }
  mysql_free_result(result);	  
 }
 return(FALSE);
}	
*/
/*INSERT or UPDATE */
/* Return value: number of affected rows, -1 on failure. */
static int db_query(MYSQL *mysql,char *sql_str)
{
	int affected_rows=-1; 	
	MYSQL_RES *result;

	if(mysql == NULL)
		return(affected_rows);	 
	if(mysql_query(mysql,sql_str)) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		return(0);
	}
	else {
		/*result=mysql_use_result(mysql);*/
		result=mysql_store_result(mysql);
		if(result == NULL) {
			if(mysql_field_count(mysql) == 0) 
				affected_rows=mysql_affected_rows(mysql);
			else  // mysql_store_result() should have returned data
				syslog(LOG_ERR,"Error: %s",mysql_error(mysql));
		}  
		/*  else*/	/* This must not happen for INSERT or UPDATE */ 
		mysql_free_result(result);	 
	}
	/* printf("%s: affected rows=%d\n",pname,affected_rows);*/
	return(affected_rows);
}


/* Return value: number of affected rows, 0 on failure. */
static int db_insert(MYSQL *mysql,char *sql_str)
{
 int affected_rows=0; 	
 MYSQL_RES *result;

 if(mysql == NULL)
   return(affected_rows);	 
 if(mysql_query(mysql,sql_str) == TRUE) {
   syslog(LOG_ERR,"Error in the query: %s",sql_str);
   return(0);
 }
 else {
  result=mysql_use_result(mysql);
  if(result == NULL) {
    if(mysql_field_count(mysql) == 0) 
      affected_rows=mysql_affected_rows(mysql);
    else  // mysql_store_result() should have returned data
      syslog(LOG_ERR,"Error: %s",mysql_error(mysql));
  }  
/*  else*/
   mysql_free_result(result);	 /* this must not happen for an INSERT*/ 
 }
 return(affected_rows);
}


/* Return value: number of affected rows, -1 on failure. */
static int db_update(MYSQL *mysql,char *sql)
{
	int affected_rows=-1; 	
	MYSQL_RES *result;

	if(mysql == NULL)
		return(affected_rows);	 
	if(mysql_query(mysql,sql)) {
		syslog(LOG_ERR,"Error in the query: %s",sql);
		return(0);
	}
	else {
		/*result=mysql_use_result(mysql);*/
		result=mysql_store_result(mysql);
		if(result == NULL) {
			if(mysql_field_count(mysql) == 0) 
				affected_rows=mysql_affected_rows(mysql);
			else  // mysql_store_result() should have returned data
				syslog(LOG_ERR,"Error: %s",mysql_error(mysql));
		}  
		/*  else*/	/* this must not happen for an UPDATE*/ 
		mysql_free_result(result);	 
	}
	return(affected_rows);
}
/*
 *  * Insert the message into a MySQL sisiya database
 *   * Returns TRUE on success FALSE on failure
 *    */
/*
static int sisiya_insert_message(MYSQL *mysql,char *message)
{
 int sID,systemStatusID,maxStatusID;	
 int serviceID,statusID,systemID;
 char hostName[MAX_STR],str[MAX_STR],sendTimestamp[MAX_STR];
 char sql_str[MAX_STR];
 char reciveTimestamp[15];
 
 if(message == NULL)
   return(FALSE);	 
 sisiya_extract_fields(message,&serviceID,&statusID,hostName,str,sendTimestamp);
 systemID=getSystemID(mysql,hostName);
 if(systemID == -1) {
   syslog(LOG_ERR,"No such system %s",hostName);	 
   return(FALSE);
 }	 

*/ /* check if the system is active or not? */
/* if(isSystemActive(mysql,systemID) == FALSE) {
   syslog(LOG_WARNING,"The system %s (SystemID=%d) is not active. Disable client checks for this system or activate it in the DB. Skipping...",hostName,systemID);
   return(TRUE);
 }



 *//* for systemhistorystatus table */
/* getTimestamp(reciveTimestamp);
 sprintf(sql_str,"insert into systemhistorystatus values('%s',%d,%d,%d,'%s','%s')",sendTimestamp,systemID,serviceID,statusID,reciveTimestamp,str);
 if(db_insert(mysql,sql_str) != 1) {
  syslog(LOG_ERR,"INSERT error : %s",sql_str);	  
  return(FALSE);
 }	 

*/ /* for systemservice table */
/* sprintf(sql_str,"select statusid from systemservicestatus where systemid=%d and serviceid=%d",systemID,serviceID);
 sID=getIntValue(mysql,sql_str);
 if(sID != -1) {
 */ /* update */	 
 /* if(sID != statusID) {
    sprintf(sql_str,"update systemservicestatus set statusid=%d,changetime='%s',updatetime='%s',str='%s' where systemid=%d and serviceid=%d",statusID,sendTimestamp,sendTimestamp,str,systemID,serviceID);
  }
  else {
    sprintf(sql_str,"update systemservicestatus set statusid=%d,updatetime='%s',str='%s' where systemid=%d and serviceid=%d",statusID,sendTimestamp,str,systemID,serviceID);
  }	  
  if(db_update(mysql,sql_str) != 1) {
   syslog(LOG_ERR,"UPDATE error : %s",sql_str);
   return(FALSE);
  }
 }	 
 else {
  *//* new record */	 
  /*sprintf(sql_str,"insert into systemservicestatus values(%d,%d,%d,'%s','%s','%s')",systemID,serviceID,statusID,sendTimestamp,sendTimestamp,str);
  if(db_insert(mysql,sql_str) != 1) {
   syslog(LOG_ERR,"INSERT error : %s",sql_str);
   return(FALSE);
  }
 }	 

 *//* for systemstatus table */
/* sprintf(sql_str,"select statusid from systemstatus where systemid=%d",systemID);
 systemStatusID=getIntValue(mysql,sql_str);
 if(systemStatusID != -1) {
 */ /* update */	 
 /* sprintf(sql_str,"select max(statusid) from systemservicestatus where systemid=%d",systemID);
  maxStatusID=getIntValue(mysql,sql_str);	 
  if(maxStatusID < 2) *//* The system is OK */
/*    sprintf(sql_str,"update systemstatus set statusid=%d,updatetime='%s',str='System is OK' where systemid=%d",MESSAGE_OK,sendTimestamp,systemID);
  else { *//* System has warnings and/or errors  */	  
/*   char error_warning_str[MAX_STR];
   getErrorWarningMessage(mysql,systemID,error_warning_str);
   if(maxStatusID != systemStatusID) {
    if(maxStatusID == statusID)	   
      sprintf(sql_str,"update systemstatus set statusid=%d,changetime='%s',updatetime='%s',str='%s' where systemid=%d",maxStatusID,sendTimestamp,sendTimestamp,str,systemID);	   
    else
      sprintf(sql_str,"update systemstatus set statusid=%d,updatetime='%s',str='%s' where systemid=%d",maxStatusID,sendTimestamp,str,systemID);	   
   }
   else {
    sprintf(sql_str,"update systemstatus set updatetime='%s',str='%s' where systemid=%d",sendTimestamp,error_warning_str,systemID);	   
   }	   
  }	  
 }
 else {
  *//* new record */	 
  /*if(sID < 2)	 
    sprintf(sql_str,"insert into systemstatus values(%d,%d,'%s','%s','System is OK')",systemID,statusID,sendTimestamp,sendTimestamp);
  else
    sprintf(sql_str,"insert into systemstatus values(%d,%d,'%s','%s','%s')",systemID,statusID,sendTimestamp,sendTimestamp,str);
 }	
 
	if(db_query(mysql,sql_str) != 1) { *//* update or insert must produce exactly 1 affected row*/
/*		syslog(LOG_ERR,"SQL error : %s",sql_str);
		return(FALSE);
*/		/*  return(TRUE);*/
/*	 }
	return(TRUE);
}
*/

/*
int db_test(MYSQL *mysql)
{	
 MYSQL_ROW row;
 MYSQL_RES *result;
 unsigned int ncolumns;
 unsigned int nrows;
 unsigned int i;

 if(mysql_query(mysql,"select * from systemhistorystatus;")) {
  fprintf(stderr,"%s: Error in the query: %s\n",pname,"select * from systemhistorystatus;");
  mysql_close(mysql);
  exit(1);
 }
 else { *//* query succeeded, process any data returned by it */
/*  result=mysql_store_result(mysql);
  if(result) {
    ncolumns=mysql_num_fields(result);
  */  /* retrieve rows, then call mysql_free_result(result)*/
/*    while((row=mysql_fetch_row(result))) {
      unsigned long *lengths;
      lengths=mysql_fetch_lengths(result);
      for(i=0;i< ncolumns;i++) {
        printf("[%.*s] ", (int) lengths[i], row[i] ? row[i] : "NULL");
      }
      printf("\n");
    }
  }
  else { *//* mysql_store_result() returned nothing; should it have?*/
/*   if(mysql_field_count(mysql) == 0) {
  */   /* query does not return data
       (it was not a SELECT) */
    /* nrows=mysql_affected_rows(mysql);
   }
   else { *//* mysql_store_result() should have returned data */
/*     fprintf(stderr, "Error: %s\n", mysql_error(mysql));
   }
  }
 }
 return(TRUE);
}
*/
