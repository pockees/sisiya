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

#include"sisiyad_postgresql.h"

/*char *pname="sisiyad_postgresql";*/
int cursor_declared=FALSE;
static void getTimestamp(char *buff);
static void db_close(PGconn *conn);
static PGconn *db_connect(char *host,char *user,char *password,char *db);
static void sisiya_extract_fields(char *msg,int *serviceID,int *statusID,char *hostName,char *str,char *sendTimestamp);
static PGresult *postgresql_select(PGconn *conn,char *query_sql);
static PGresult *postgresql_query(PGconn *conn,char *query_sql);
static int db_query(PGconn *conn,char *sql);
static void getErrorWarningMessage(PGconn *conn,int systemID,char *buffer);
static int getIntValue(PGconn *conn,char *sql_str);
static int getSystemID(PGconn *conn,char *hostName);
/*static int isSystemActive(PGconn *conn,int systemID);*/
/*static int sisiya_insert_message(PGconn *conn,char *message);*/
/*static int sisiya_process_queue(PGconn *conn);*/
static int getSystemUpdateChangeTimes(PGconn *conn,int systemID,char *updateTime,char *changeTime);
/*static int updateSystemStatus(PGconn *conn,int systemID);*/
/*static int postgresql_lock_table(PGconn *conn,char *table_name,char *mode);*/
int sisiyad_postgresql_insert_message(char *host,char *user,char *password,char *db,char *message);
int sisiyad_postgresql_process_queue(char *host,char *user,char *password,char *db);
/* ------------------------------------------------------------------------------------------------*/
/*static char db_server[MAX_STR+1],db_user[MAX_STR+1],db_password[MAX_STR+1],db_name[MAX_STR+1];*/
static char g_message[MAX_STR+1],g_sendTimestamp[MAX_STR+1],g_hostName[MAX_STR+1];
static int g_systemID,g_serviceID,g_statusID;
static PGconn *g_conn;

int postgresql_db_connect(char *host,char *user,char *password,char *db);
void postgresql_db_close(void);
void postgresql_extract_fields(char *buffer,char *hostName);
int postgresql_getSystemID(void);
int postgresql_begin_transaction(void);
int postgresql_commit_transaction(void);
int postgresql_rollback_transaction(void);
int sisiya_postgresql_insert_message(void);
int postgresql_updateSystemStatus(int systemID);
/* ------------------------------------------------------------------------------------------------*/
                                                                                                                             
/* ------------------------------------------------------------------------------------------------*/
/*
	Returns :	TRUE on success
			FALSE on failure
*/
int postgresql_db_connect(char *host,char *user,char *password,char *db)
{
	g_conn=db_connect(host,user,password,db);
	if(g_conn == NULL) {
		syslog(LOG_ERR,"Could not allocate conn object!");
		return(FALSE);  
	}
	if(PQstatus(g_conn) == CONNECTION_BAD) {
		syslog(LOG_ERR,"postgresql_db_connect: Connection to database '%s' failed.",db);
		syslog(LOG_ERR,"%s",PQerrorMessage(g_conn));
		db_close(g_conn); 
		return(FALSE);
	}
	return(TRUE);
}
	
void postgresql_db_close(void)
{
	db_close(g_conn);
}

void postgresql_extract_fields(char *buffer,char *hostName)
{
	sisiya_extract_fields(buffer,&g_serviceID,&g_statusID,g_hostName,g_message,g_sendTimestamp);
	strcpy(hostName,g_hostName);
}

/*
	Return code:	0 	: no such system; 
			-x	: the system with ID=x is not enabled
*/
int postgresql_getSystemID()
{
	g_systemID=getSystemID(g_conn,g_hostName);
	return(g_systemID);
}

/*
	Returns :	TRUE on success
			FALSE on failure
*/
int postgresql_begin_transaction(void)
{
	PGresult *result;

	result=PQexec(g_conn,"BEGIN");
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
		syslog(LOG_ERR,"postgresql_begin_transaction: [BEGIN] FAILED");
		syslog(LOG_ERR,"postgresql_begin_transaction: Error : %s",PQerrorMessage(g_conn));
		PQclear(result);
		return(FALSE);
	}
	PQclear(result); /* should PQclear PGresult whenever it is no longer needed to avoid memory leaks */
	return(TRUE);
}


/*
	Returns :	TRUE on success
			FALSE on failure
*/
int postgresql_commit_transaction(void)
{
	PGresult *result;

	result=PQexec(g_conn,"COMMIT");
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
		syslog(LOG_ERR,"postgresql_commit_transaction: [COMMIT FAILED");
		syslog(LOG_ERR,"postgresql_commit_transaction: Error : %s",PQerrorMessage(g_conn));
		PQclear(result);
		return(FALSE);
	}
	PQclear(result); /* should PQclear PGresult whenever it is no longer needed to avoid memory leaks */
	if(loglevel > 2)
		syslog(LOG_INFO,"Committed the transaction");
	return(TRUE);
}

/*
	Returns :	TRUE on success
			FALSE on failure
*/
int postgresql_rollback_transaction(void)
{
	PGresult *result;

	result=PQexec(g_conn,"ROLLBACK");
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
		syslog(LOG_ERR,"postgresql_irollback_transaction: [ROLLBACK] FAILED");
		syslog(LOG_ERR,"postgresql_rollback_transaction: Error : %s",PQerrorMessage(g_conn));
		PQclear(result);
		return(FALSE);
	}
	PQclear(result); /* should PQclear PGresult whenever it is no longer needed to avoid memory leaks */
	return(TRUE);
}

/*
	Returns :	TRUE on success
			FALSE on failure
*/
int sisiya_postgresql_insert_message(void)
{
	int sID;	
	char sql_str[MAX_STR];
	char recieveTimestamp[15];
 
	if(g_message == NULL)
		return(FALSE);	 

	getTimestamp(recieveTimestamp);

	/* for systemhistorystatus table */
	snprintf(sql_str,MAX_STR-1,"insert into systemhistorystatus values('%s',%d,%d,%d,'%s','%s')",g_sendTimestamp,g_systemID,g_serviceID,g_statusID,recieveTimestamp,g_message); 
	if(db_query(g_conn,sql_str) != 1) {
		syslog(LOG_ERR,"INSERT error : %s",sql_str);	  
		return(FALSE);
	}	 

	/* for systemservice table */
	snprintf(sql_str,MAX_STR-1,"select statusid from systemservicestatus where systemid=%d and serviceid=%d",g_systemID,g_serviceID);
	sID=getIntValue(g_conn,sql_str);
	if(sID != -1) {
		/* update */	 
		if(sID != g_statusID) 
			snprintf(sql_str,MAX_STR-1,"update systemservicestatus set statusid=%d,changetime='%s',updatetime='%s',str='%s' where systemid=%d and serviceid=%d",g_statusID,g_sendTimestamp,g_sendTimestamp,g_message,g_systemID,g_serviceID);
		else 
			snprintf(sql_str,MAX_STR-1,"update systemservicestatus set statusid=%d,updatetime='%s',str='%s' where systemid=%d and serviceid=%d",g_statusID,g_sendTimestamp,g_message,g_systemID,g_serviceID);
  		if(db_query(g_conn,sql_str) != 1) {
			syslog(LOG_ERR,"UPDATE error : %s",sql_str);
			return(FALSE);
		}
	}	 
	else {
		/* new record */	 
		sprintf(sql_str,"insert into systemservicestatus values(%d,%d,%d,'%s','%s','%s')",g_systemID,g_serviceID,g_statusID,g_sendTimestamp,g_sendTimestamp,g_message);
		if(db_query(g_conn,sql_str) != 1) {
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
int postgresql_updateSystemStatus(int systemID)
{
	int systemStatusID,maxStatusID;
	char updateTime[MAX_STR+1],changeTime[MAX_STR+1];
	char sql_str[MAX_STR+1];
	char error_warning_str[MAX_STR+1];

	if(getSystemUpdateChangeTimes(g_conn,systemID,updateTime,changeTime) == FALSE) {
		syslog(LOG_INFO,"could not get change and update times from the systemservicestatus table. Generating..");
		getTimestamp(changeTime);
		getTimestamp(updateTime);
	}
	
	/* get the system status */
	snprintf(sql_str,MAX_STR,"select statusid from systemstatus where systemid=%d",systemID);
	systemStatusID=getIntValue(g_conn,sql_str);

	getErrorWarningMessage(g_conn,systemID,error_warning_str);

	/* get the max status from systemservicestatus */
	snprintf(sql_str,MAX_STR,"select max(statusid) from systemservicestatus where systemid=%d",systemID);
	maxStatusID=getIntValue(g_conn,sql_str);	 
	if(systemStatusID != -1) {
		/* it is going to be an update */	 
		if(maxStatusID < 2) /* The system is OK */
			snprintf(sql_str,MAX_STR,"update systemstatus set statusid=%d,updatetime='%s',str='System is OK' where systemid=%d",MESSAGE_OK,updateTime,systemID);
		else { /* System has warnings and/or errors  */	  
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
		else
			sprintf(sql_str,"insert into systemstatus values(%d,%d,'%s','%s','%s')",systemID,systemStatusID,updateTime,changeTime,error_warning_str);
	}		
 	if(db_query(g_conn,sql_str) != 1) { /* update or insert must produce exactly 1 affected row*/
		syslog(LOG_ERR,"SQL error : %s Update or insert must produce exactly 1 row?!",sql_str);
		return(FALSE);
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


static void db_close(PGconn *conn)
{
	PQfinish(conn);	
}

static PGconn *db_connect(char *host,char *user,char *password,char *db)
{
	PGconn *conn;	
	char conninfo[MAX_STR+1];

	if(isdigit(host[0])) {
		if(snprintf(conninfo,MAX_STR,"hostaddr=%s dbname=%s user=%s password=%s",host,db,user,password) == -1 ) 
			return(NULL);
	}  
	else { 
		if(snprintf(conninfo,MAX_STR,"host=%s dbname=%s user=%s password=%s",host,db,user,password) == -1 ) 
			return(NULL);
	} 
	conn=PQconnectdb(conninfo);
 
	if(conn == NULL) {
		syslog(LOG_ERR,"The conn objects is NULL. Error allocation memeory!");
		return(NULL);
	}
/* 
 switch(PQstatus(conn)) {
	case CONNECTION_MADE:
		syslog(LOG_INFO,"Connected to %s@%s PostgreSQL server.",db,host);
		break;
	case CONNECTION_BAD :
		syslog(LOG_ERR,"Connection to database %s@%s failed.",db,host);
		syslog(LOG_ERR,"%s",PQerrorMessage(conn));
		db_close(conn);
		return(NULL);
		 break;	
	case CONNECTION_STARTED:
		syslog(LOG_INFO,"Connecting to %s@%s PostgreSQL server...",db,host);
		break;
	default :
		syslog(LOG_INFO,"Connecting to PostgreSQL DB %s@%s ...",db,host);
		break;
 }
*/
	if(PQstatus(conn) == CONNECTION_BAD) {
		syslog(LOG_ERR,"Connection to database %s@%s failed!",db,host);
		syslog(LOG_ERR,"%s",PQerrorMessage(conn));
		db_close(conn); 
		return(NULL);
	}
	return(conn);
}	

static void sisiya_extract_fields(char *msg,int *serviceID,int *statusID,char *hostName,char *str,char *sendTimestamp)
{
	int i;
	char del[2],s[MAX_STR+1];	
	char *sptr;
	char *p;

	del[0]=msg[0];
	del[1]='\0';

	strcpy(s,msg);
 
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
/*
static void postgresql_end_transaction(PGconn *conn,PGresult *result)
{
	if(cursor_declared == TRUE)
		result=PQexec(conn,"CLOSE mycursor");
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
		syslog(LOG_ERR,"(postgresql_end_transaction) [CLOSE mycursor] FAILED");
		syslog(LOG_ERR,"(postgresql_end_transaction) Error : %s",PQerrorMessage(conn));
	}
	PQclear(result);
}
*/

static PGresult *postgresql_select(PGconn *conn,char *query_sql)
{
	char sql_str[MAX_STR+1];
	PGresult *result;
/*
	if(cursor_declared == TRUE) {
		result=PQexec(conn,"CLOSE mycursor");
		if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
			syslog(LOG_ERR,"(postgresql_select) [CLOSE mycursor] FAILED");
			syslog(LOG_ERR,"(postgresql_select) Error : %s",PQerrorMessage(conn));
			PQclear(result);
			return(NULL);
		}
		cursor_declared=FALSE;
		PQclear(result);
	} 
 
	snprintf(sql_str,MAX_STR,"DECLARE mycursor CURSOR FOR %s",query_sql);
	result=PQexec(conn,sql_str);
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
		syslog(LOG_ERR,"(postgresql_select) [%s] FAILED",sql_str);
		syslog(LOG_ERR,"(postgresql_select) Error : %s",PQerrorMessage(conn));
		PQclear(result);
		return(NULL);
	}
	PQclear(result);
	cursor_declared=TRUE;
 
	snprintf(sql_str,MAX_STR,"FETCH ALL in mycursor");
	result=PQexec(conn,sql_str);
	if(result == NULL || PQresultStatus(result) != PGRES_TUPLES_OK) {
		syslog(LOG_ERR,"(postgresql_select) [%s] FAILED",sql_str);
		syslog(LOG_ERR,"(postgresql_select) Error : %s",PQerrorMessage(conn));
		PQclear(result);
		return(NULL);
 	}
*/ 
	snprintf(sql_str,MAX_STR,"%s",query_sql);
	result=PQexec(conn,sql_str);
/*
if(result == NULL) {
	syslog(LOG_ERR,"(postgresql_select) result == NULL",sql_str);
}
else {
	syslog(LOG_ERR,"(postgresql_select) result != NULL",sql_str);
	if(PQresultStatus(result) == PGRES_TUPLES_OK)
		syslog(LOG_ERR,"(postgresql_select)  PQresultStatus(result) == PGRES_TUPLES_OK",sql_str);
	else
		syslog(LOG_ERR,"(postgresql_select)  PQresultStatus(result) != PGRES_TUPLES_OK",sql_str);
	if(PQresultStatus(result) == PGRES_COMMAND_OK)
		syslog(LOG_ERR,"(postgresql_select)  PQresultStatus(result) == PGRES_COMMAND_OK",sql_str);
	else
		syslog(LOG_ERR,"(postgresql_select)  PQresultStatus(result) != PGRES_COMMAND_OK",sql_str);

}
*/
	/*if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {*/
	if(result == NULL || PQresultStatus(result) != PGRES_TUPLES_OK) {
		syslog(LOG_ERR,"(postgresql_select) [%s] FAILED",sql_str);
		syslog(LOG_ERR,"(postgresql_select) Error : %s",PQerrorMessage(conn));
		PQclear(result);
		return(NULL);
	}

	return(result);
}

static PGresult *postgresql_query(PGconn *conn,char *query_sql)
{
	char sql_str[MAX_STR+1];
	PGresult *result;

	snprintf(sql_str,MAX_STR,"%s",query_sql);
	result=PQexec(conn,sql_str);
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
		syslog(LOG_ERR,"(postgresql_query) [%s] FAILED",sql_str);
		syslog(LOG_ERR,"(postgresql_query) Error : %s",PQerrorMessage(conn));
		PQclear(result);
		return(NULL);
	}
	return(result);
}

/* Return value: number of affected rows, 0 on failure. */
static int db_query(PGconn *conn,char *sql_str)
{
	int affected_rows=0; 	
	PGresult *result;

	if(conn == NULL)
		return(affected_rows);	 
	if((result=postgresql_query(conn,sql_str)) == NULL) {
		syslog(LOG_ERR,"Error in the query: [%s] Error : %s",sql_str,PQerrorMessage(conn));
		PQclear(result);
		return(affected_rows);
	}
	else {
		affected_rows=atoi(PQcmdTuples(result));
	}
 	PQclear(result);
	return(affected_rows);
}

static void getErrorWarningMessage(PGconn *conn,int systemID,char *buffer)
{
	PGresult *result;
	char sql_str[MAX_STR+1];	
	int nrows,i;

	snprintf(sql_str,MAX_STR,"select b.str,c.str from systemservicestatus a,services b,status c where a.serviceid=b.id and a.statusid=c.id and systemid=%d and c.id > 1 order by statusid desc;",systemID);
 
	buffer[0]='\0';	  
	if((result=postgresql_select(conn,sql_str)) == NULL) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
	}
	else { 
		nrows=PQntuples(result);
		if(nrows > 0) {
			for(i=0;i<nrows;i++) {
				strcat(buffer,PQgetvalue(result,i,0));	    
				strcat(buffer,"(");	    
				strcat(buffer,PQgetvalue(result,i,1));	    
				strcat(buffer,") ");	    
			}
			buffer[strlen(buffer)-1]='\0';
		}
		PQclear(result);
	}
}

/* Returns : an integer or -1 on error. */
static int getIntValue(PGconn *conn,char *sql_str)
{
	int sID=-1; /* set to no such system */	
	PGresult *result;

	if((result=postgresql_select(conn,sql_str)) == NULL) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		PQclear(result);
		return(sID);
	}
	if(PQntuples(result) != 0)
		sID=atoi(PQgetvalue(result,0,0));	    
	PQclear(result);
	return(sID);
}	

/* Returns : TRUE on success, FALSE on error.*/
static int getSystemUpdateChangeTimes(PGconn *conn,int systemID,char *updateTime,char *changeTime)
{
	char sql_str[MAX_STR+1];
	PGresult *result;
	
	updateTime[0]='\0';
	changeTime[0]='\0';

	snprintf(sql_str,MAX_STR,"select updatetime from systemservicestatus where systemid=%d order by updatetime desc",systemID);
	if((result=postgresql_select(conn,sql_str)) == NULL) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		PQclear(result);
		return(FALSE);
	}
	if(PQntuples(result) != 0) {
		strcpy(updateTime,PQgetvalue(result,0,0));	    
		PQclear(result);
	}
	else {
		PQclear(result);
		return(FALSE);
	}

	snprintf(sql_str,MAX_STR,"select changetime from systemservicestatus where systemid=%d order by changetime desc",systemID);
	if((result=postgresql_select(conn,sql_str)) == NULL) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		PQclear(result);
		return(FALSE);
	}
	if(PQntuples(result) != 0) {
		strcpy(changeTime,PQgetvalue(result,0,0));	    
		PQclear(result);
	}
	else {
		PQclear(result);
		return(FALSE);
	}
	return(TRUE);
}	

/*
	Return code:	0 	: no such system; 
			-x	: the system with ID=x is not enabled
*/
static int getSystemID(PGconn *conn,char *hostName)
{
	int systemID=0; /* set to no such system */	
	PGresult *result;
	char sql_str[MAX_STR+1];	

	strcpy(sql_str,"select id,active from systems where ");
	if(strchr(hostName,'.') == NULL)	
		strcat(sql_str,"hostname='");
	else
		strcat(sql_str,"fullhostname='");
	strcat(sql_str,hostName);
	strcat(sql_str,"'");
 
	if((result=postgresql_select(conn,sql_str)) == NULL) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		PQclear(result);
		return(systemID);
	}
	 
	if(PQntuples(result) != 0) {
		systemID=atoi(PQgetvalue(result,0,0));	    
		if(strcmp("f",PQgetvalue(result,0,1)) == 0)
			systemID=-1*systemID; 
	}
	PQclear(result);
	return(systemID);
}	



/* 
static int isSystemActive(PGconn *conn,int systemID)
{
	PGresult *result;
	char sql_str[MAX_STR+1];	

	sprintf(sql_str,"select active from systems where id=%d",systemID);
 
	if((result=postgresql_select(conn,sql_str)) == NULL) {
		syslog(LOG_ERR,"Error in the query: %s",sql_str);
		return(FALSE);
	}
 
	if(strcmp("t",PQgetvalue(result,0,0)) == 0)	    
		return(TRUE);
	return(FALSE);
};
*/

/*
 * Insert the message into a PostgreSQL sisiya database
 * Returns TRUE on success FALSE on failure 
 */
/*
static int sisiya_insert_message(PGconn *conn,char *message)
{
	int sID,systemStatusID,maxStatusID;	
	int serviceID,statusID,systemID;
	char hostName[MAX_STR+1],str[MAX_STR+1],sendTimestamp[MAX_STR+1];
	char sql_str[MAX_STR+1];
	char recieveTimestamp[15];
 
	if(message == NULL)
		return(FALSE);	 
	sisiya_extract_fields(message,&serviceID,&statusID,hostName,str,sendTimestamp);

	systemID=getSystemID(conn,hostName);
	if(systemID == -1) {
		syslog(LOG_ERR,"No such system %s !",hostName);	 
		return(FALSE);	 
	}	 
	if(isSystemActive(conn,systemID) == FALSE) {
		syslog(LOG_WARNING,"The system %s (SystemID=%d) is not active. Disable client checks for this system or activate it in the DB. Skipping...",hostName,systemID);
		return(TRUE);
	}

	getTimestamp(recieveTimestamp);
	snprintf(sql_str,MAX_STR,"insert into systemhistorystatusqueue values('%s',%d,%d,%d,'%s','%s')",sendTimestamp,systemID,serviceID,statusID,recieveTimestamp,str); 
	if(db_query(conn,sql_str) != 1) {
		syslog(LOG_ERR,"INSERT error : %s",sql_str);	  
		return(FALSE);
	}	 
	return(TRUE);
}
*/


/*
void db_test(PGconn *conn)
{
 PGresult   *result;
 char sql_str[MAX_STR+1];
 int ncolumns,i,j;
 
 snprintf(sql_str,MAX_STR,"BEGIN");
 result=PQexec(conn,sql_str);
 if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
   fprintf(stderr, "db_test: [%s] FAILED",sql_str);
   fprintf(stderr, "db_test: Error : %s",PQerrorMessage(conn));
   PQclear(result);
   return;
 }
 PQclear(result); 
 
 printf("db_test: %s",sql_str);
 
 snprintf(sql_str,MAX_STR,"DECLARE mycursor CURSOR FOR select * from systems;");
 result=PQexec(conn,sql_str);
 if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
   fprintf(stderr, "db_test: [%s] FAILED",sql_str);
   fprintf(stderr, "db_test: Error : %s",PQerrorMessage(conn));
   PQclear(result);
   return;
 }
 PQclear(result);
 
 printf("db_test: %s",sql_str);
 
 snprintf(sql_str,MAX_STR,"FETCH ALL in mycursor");
 result=PQexec(conn,sql_str);
 if(result == NULL || PQresultStatus(result) != PGRES_TUPLES_OK) {
   fprintf(stderr, "db_test: [%s] FAILED",sql_str);
   fprintf(stderr, "db_test: Error : %s",PQerrorMessage(conn));
   PQclear(result);
   return;
 }
 
 printf("db_test: %s",sql_str);

 ncolumns=PQnfields(result);
 for(i=0;i<ncolumns;i++)
   printf("%-15s",PQfname(result,i));
 printf("\n");
     
 for(i=0;i<PQntuples(result);i++) {
    for(j=0;j<ncolumns;j++)
       printf("%-15s", PQgetvalue(result,i,j));
    printf("");
 }
 PQclear(result);

 result=PQexec(conn, "CLOSE mycursor");
 PQclear(result);
}	
*/

/*
static int updateSystemStatus(PGconn *conn,int systemID)
{
	int systemStatusID,maxStatusID;
	char updateTime[MAX_STR+1],changeTime[MAX_STR+1];
	char sql_str[MAX_STR+1];
	char error_warning_str[MAX_STR+1];

	if(getSystemUpdateChangeTimes(conn,systemID,updateTime,changeTime) == FALSE) {
		syslog(LOG_INFO,"could not get change and update times from the systemservicestatus table. Generating..");
		getTimestamp(changeTime);
		getTimestamp(updateTime);
	}
	
*/	/* get the system status */
/*	snprintf(sql_str,MAX_STR,"select statusid from systemstatus where systemid=%d",systemID);
	systemStatusID=getIntValue(conn,sql_str);

	getErrorWarningMessage(conn,systemID,error_warning_str);

*/	/* get the max status from systemservicestatus */
/*	snprintf(sql_str,MAX_STR,"select max(statusid) from systemservicestatus where systemid=%d",systemID);
	maxStatusID=getIntValue(conn,sql_str);	 
	if(systemStatusID != -1) {
*/		/* it is going to be an update */	 
/*		if(maxStatusID < 2) *//* The system is OK */
/*			snprintf(sql_str,MAX_STR,"update systemstatus set statusid=%d,updatetime='%s',str='System is OK' where systemid=%d",MESSAGE_OK,updateTime,systemID);
		else { *//* System has warnings and/or errors  */	  
			/*if(maxStatusID != systemStatusID) 
					snprintf(sql_str,MAX_STR,"update systemstatus set statusid=%d,changetime='%s',updatetime='%s',str='%s' where systemid=%d",maxStatusID,changeTime,updateTime,error_warning_str,systemID);	   
			else 
				snprintf(sql_str,MAX_STR,"update systemstatus set updatetime='%s',str='%s' where systemid=%d",updateTime,error_warning_str,systemID);	   
		}	  
	}
	else {
*/		/* new record */	 
/*		systemStatusID=maxStatusID;
		if(systemStatusID < 2)	 
			sprintf(sql_str,"insert into systemstatus values(%d,%d,'%s','%s','System is OK')",systemID,systemStatusID,updateTime,changeTime);
		else
			sprintf(sql_str,"insert into systemstatus values(%d,%d,'%s','%s','%s')",systemID,systemStatusID,updateTime,changeTime,error_warning_str);
	}		
 	if(db_query(conn,sql_str) != 1) { *//* update or insert must produce exactly 1 affected row*/
/*		syslog(LOG_ERR,"SQL error : %s Update of insert must produce exactly 1 row?!",sql_str);
		return(FALSE);
	}
	return(TRUE);
}
*/
/*
static int postgresql_lock_table(PGconn *conn,char *table_name,char *mode)
{
	PGresult *result;
	char sql_str[MAX_STR+1];
	
	snprintf(sql_str,MAX_STR,"lock table %s in %s mode",table_name,mode);
	result=PQexec(conn,sql_str);
	if(result == NULL) {
		syslog(LOG_ERR,"Could not execute : [%s]. Result set returned NULL",sql_str);
		return(FALSE);
	}
	if(PQresultStatus(result) == PGRES_COMMAND_OK) {
		PQclear(result);
		if(loglevel > 2)
			syslog(LOG_INFO,"Locked table %s in %s mode",table_name,mode);
		return(TRUE);
	}
	else {
		syslog(LOG_ERR,"Could not execute : %s",sql_str);
		syslog(LOG_ERR,"ERROR : %s",PQresultErrorMessage(result));
		return(FALSE);
	}	
}
*/
