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

#include"sisiyad1.h"

time_t start_time,stop_time;

int get_function(char *string) 
{
 int i;
 char *p,tmp_str[MAX_ID];
 char delimiter;

 p=string;
 delimiter=*p;
 p++;
  
 i=0;
 tmp_str[i]='\0';        
 while(*p != delimiter)
      {
       tmp_str[i++]=*p++;
      } 
 tmp_str[i]='\0';       
 return(atoi(tmp_str)); 
};

void record_message(char *string) 
{
	int status=-1;

	if(loglevel > 1) 
		syslog(LOG_INFO,"recording message[%s]",string);

/*
#ifdef HAVE_MYSQL 
	if(strcmp(configs[DB_TYPE][1],"MySQL") == 0)
		status=sisiyad_mysql_insert_message(configs[DB_SERVER][1],configs[DB_USER][1],configs[DB_PASSWORD][1],configs[DB_NAME][1],string);
	else
		syslog(LOG_ERR,"This type [%s] is not MySQL. The message (%s) did not inserted!",configs[DB_TYPE][1],string);
#else
 #ifdef HAVE_PGSQL

	if(strcmp(configs[DB_TYPE][1],"PostgreSQL") == 0)
		status=sisiyad_mysql_insert_message(configs[DB_SERVER][1],configs[DB_USER][1],configs[DB_PASSWORD][1],configs[DB_NAME][1],string);
	else
		syslog(LOG_ERR,"This type [%s] is not PostgreSQL. The message (%s) did not inserted!",configs[DB_TYPE][1],string);
 #else
	syslog(LOG_ERR,"unknown DB_TYPE [%s]. The message (%s) did not inserted!",configs[DB_TYPE][1],string);
	return;
 #endif
#endif
*/
  
	if(status == FALSE) 
		syslog(LOG_ERR,"error inserting message(%s)",string);

	if(loglevel > 1)
		syslog(LOG_INFO,"recorded message[%s]",string);
};



/*********************************************************************/
#ifdef HAVE_MYSQL
int server(int sockfd,int semid)
{
	pid_t child_server_pid;	 
	int n;
	int error;
	int old_systemID,systemID;
/*	int function;*/
	char line[MAX_STR+1],hostName[MAX_STR+1],old_hostName[MAX_STR+1];

	child_server_pid=getpid();
	if(loglevel > 1)
		time(&start_time);

	if(loglevel > 1) 
		syslog(LOG_INFO,"child server(%d) : getting the lock from semaphore",child_server_pid);
	sem_wait(semid);  /* get the lock */                   
	if(loglevel > 1) 
		syslog(LOG_INFO,"child server(%d) : got the lock from semaphore id=%d",child_server_pid,semid);

	/* connect to db */
	if(mysql_db_connect(configs[DB_SERVER][1],configs[DB_USER][1],configs[DB_PASSWORD][1],configs[DB_NAME][1]) == FALSE) {
		syslog(LOG_ERR,"child server(%d) : failed to connect to DB %s@%s",child_server_pid,configs[DB_NAME][1],configs[DB_SERVER][1]);
		return(1); 
	}

	if(loglevel > 1)
		syslog(LOG_INFO,"child server(%d) : connected to the DB",child_server_pid);
/*
	if(mysql_begin_transaction() == FALSE) {
		syslog(LOG_ERR,"child server(%d) : failed to start a db transaction",child_server_pid);
		return(1); 
	}
*/
	old_hostName[0]='\0';
	systemID=-1;
	old_systemID=-1;
	error=FALSE;
	while(1) {
		if((n=readline(sockfd,line,MAX_STR)) < 0) {
			syslog(LOG_ERR,"socket read error");
			return(1); 
		}
		if(n == 0)
			break;

		if(loglevel > 1) 
			syslog(LOG_INFO,"child server(%d) recieved data : [%s] (Time:%ld)\n",child_server_pid,line,start_time);

		mysql_extract_fields(line,hostName);

		if(loglevel > 1)
			syslog(LOG_INFO,"child server(%d) : extracted fields",child_server_pid);
		if(strcmp(old_hostName,hostName) != 0) {
			systemID=mysql_getSystemID();
			if(loglevel > 1)
				syslog(LOG_INFO,"child server(%d) : systemID=%d",child_server_pid,systemID);
		}
		if(systemID <= 0) { 
			if(systemID == 0)
				syslog(LOG_ERR,"child server(%d) : no such system=%s",child_server_pid,hostName);
			else if(systemID < 0)
				syslog(LOG_ERR,"child server(%d) : the system %s with systemID=%d is not active. Disable client chack for this or enabled the system.",child_server_pid,hostName,-1*systemID);
			continue; /* the system is not enabled or no such system */
		}
	
		if(old_systemID != -1 && old_systemID != systemID) {
			if(loglevel > 1)
				syslog(LOG_INFO,"child server(%d) : systemID is changed (old_systemID=%d,systemID=%d) => update systemstatus",child_server_pid,old_systemID,systemID);
			if(mysql_updateSystemStatus(old_systemID) == FALSE) {
				syslog(LOG_ERR,"child server(%d) : could not update systemstatus for systemID=%d",child_server_pid,old_systemID);
/*
				if(mysql_rollback_transaction() == FALSE) 
					syslog(LOG_ERR,"child server(%d) : failed to rollback the db transaction",child_server_pid);
*/
				error=TRUE;
				break;
			}
		}
		old_systemID=systemID;
		strcpy(old_hostName,hostName);

		if(sisiya_mysql_insert_message() == FALSE) {
/*
			if(mysql_rollback_transaction() == FALSE) 
				syslog(LOG_ERR,"child server(%d) : failed to rollback the db transaction",child_server_pid);
*/
			error=TRUE;
			break;
		}

	}
	if(error == FALSE)
		return(1);
	if(old_systemID != -1 && mysql_updateSystemStatus(systemID) == FALSE) {
		syslog(LOG_ERR,"child server(%d) : failed to update systemstatus table for systemID=%d",child_server_pid,systemID);
/*
		if(loglevel > 1)
			syslog(LOG_INFO,"child server(%d) : rolling back the db transaction",child_server_pid);

		if(mysql_rollback_transaction() == FALSE) 
			syslog(LOG_ERR,"child server(%d) : failed to rollback the db transaction",child_server_pid);
*/
		return(1);
	}
	else {
		if(loglevel > 1)
			syslog(LOG_INFO,"child server(%d) : update systemstatus for systemID=%d",child_server_pid,systemID);
	}
/*
	
	if(error == FALSE && mysql_commit_transaction() == FALSE) {
		syslog(LOG_ERR,"child server(%d) : failed to commit the db transaction",child_server_pid);
		return(1); 
	}
*/
	mysql_db_close();
	if(loglevel > 1)
		syslog(LOG_INFO,"child server(%d) : disconnected from the DB",child_server_pid);

	sem_signal(semid);   /* release the lock */
	if(loglevel > 1) 
		syslog(LOG_INFO,"child server(%d) : releasing the lock from semaphore id=%d",child_server_pid,semid);

	if(loglevel > 1) {
		time(&stop_time);
		syslog(LOG_INFO,"child server(%d) : start     time = %ld",child_server_pid,start_time);
		syslog(LOG_INFO,"child server(%d) : stop      time = %ld",child_server_pid,stop_time);
		syslog(LOG_INFO,"child server(%d) : execution time = %ld",child_server_pid,stop_time-start_time);
	}

	return(0);
};

#else 
 #ifdef HAVE_PGSQL
int server(int sockfd,int semid)
{
	pid_t child_server_pid;	 
	int n;
	int error;
	int old_systemID,systemID;
	char line[MAX_STR+1],hostName[MAX_STR+1],old_hostName[MAX_STR+1];

	child_server_pid=getpid();
	if(loglevel > 1)
		time(&start_time);

	if(loglevel > 1) 
		syslog(LOG_INFO,"child server(%d) : getting the lock from semaphore",child_server_pid);
	sem_wait(semid);  /* get the lock */                   
	if(loglevel > 1) 
		syslog(LOG_INFO,"child server(%d) : got the lock from semaphore id=%d",child_server_pid,semid);

	/* connect to db */
	if(postgresql_db_connect(configs[DB_SERVER][1],configs[DB_USER][1],configs[DB_PASSWORD][1],configs[DB_NAME][1]) == FALSE) {
		syslog(LOG_ERR,"child server(%d) : failed to connect to DB %s@%s",child_server_pid,configs[DB_NAME][1],configs[DB_SERVER][1]);
		return(1); 
	}

	if(loglevel > 1)
		syslog(LOG_INFO,"child server(%d) : connected to the DB",child_server_pid);

	if(postgresql_begin_transaction() == FALSE) {
		syslog(LOG_ERR,"child server(%d) : failed to start a db transaction",child_server_pid);
		return(1); 
	}
	old_hostName[0]='\0';
	systemID=-1;
	old_systemID=-1;
	error=FALSE;
	while(1) {
		if((n=readline(sockfd,line,MAX_STR)) < 0) {
			syslog(LOG_ERR,"socket read error");
			return(1); 
		}
		if(n == 0)
			break;

		if(loglevel > 1) 
			syslog(LOG_INFO,"child server(%d) recieved data : [%s] (Time:%ld)\n",child_server_pid,line,start_time);

		postgresql_extract_fields(line,hostName);

		if(loglevel > 1)
			syslog(LOG_INFO,"child server(%d) : extracted fields",child_server_pid);
		if(strcmp(old_hostName,hostName) != 0) {
			systemID=postgresql_getSystemID();
			if(loglevel > 1)
				syslog(LOG_INFO,"child server(%d) : systemID=%d",child_server_pid,systemID);
		}
		if(systemID <= 0) { 
			if(systemID == 0)
				syslog(LOG_ERR,"child server(%d) : no such system=%s",child_server_pid,hostName);
			else if(systemID < 0)
				syslog(LOG_ERR,"child server(%d) : the system %s with systemID=%d is not active. Disable client chack for this or enabled the system.",child_server_pid,hostName,-1*systemID);
			continue; /* the system is not enabled or no such system */
		}
	
		if(old_systemID != -1 && old_systemID != systemID) {
			if(loglevel > 1)
				syslog(LOG_INFO,"child server(%d) : systemID is changed (old_systemID=%d,systemID=%d) => update systemstatus",child_server_pid,old_systemID,systemID);
			if(postgresql_updateSystemStatus(old_systemID) == FALSE) {
				syslog(LOG_ERR,"child server(%d) : could not update systemstatus for systemID=%d",child_server_pid,old_systemID);
				if(postgresql_rollback_transaction() == FALSE) 
					syslog(LOG_ERR,"child server(%d) : failed to rollback the db transaction",child_server_pid);
				error=TRUE;
				break;
			}
		}
		old_systemID=systemID;
		strcpy(old_hostName,hostName);

		if(sisiya_postgresql_insert_message() == FALSE) {
			if(postgresql_rollback_transaction() == FALSE) 
				syslog(LOG_ERR,"child server(%d) : failed to rollback the db transaction",child_server_pid);
			error=TRUE;
			break;
		}

	}
	if(error == FALSE) {
		if(postgresql_rollback_transaction() == FALSE) 
			syslog(LOG_ERR,"child server(%d) : failed to rollback the db transaction",child_server_pid);
		return(1);
	}
	if(old_systemID != -1 && postgresql_updateSystemStatus(systemID) == FALSE) {
		syslog(LOG_ERR,"child server(%d) : failed to update systemstatus table for systemID=%d",child_server_pid,systemID);
		if(loglevel > 1)
			syslog(LOG_INFO,"child server(%d) : rolling back the db transaction",child_server_pid);

		if(postgresql_rollback_transaction() == FALSE) 
			syslog(LOG_ERR,"child server(%d) : failed to rollback the db transaction",child_server_pid);
		return(1);
	}
	else {
		if(loglevel > 1)
			syslog(LOG_INFO,"child server(%d) : update systemstatus for systemID=%d",child_server_pid,systemID);
	}
	if(error == FALSE && postgresql_commit_transaction() == FALSE) {
		syslog(LOG_ERR,"child server(%d) : failed to commit the db transaction",child_server_pid);
		return(1); 
	}

	postgresql_db_close();
	if(loglevel > 1)
		syslog(LOG_INFO,"child server(%d) : disconnected from the DB",child_server_pid);

	sem_signal(semid);   /* release the lock */
	if(loglevel > 1) 
		syslog(LOG_INFO,"child server(%d) : releasing the lock from semaphore id=%d",child_server_pid,semid);

	if(loglevel > 1) {
		time(&stop_time);
		syslog(LOG_INFO,"child server(%d) : start     time = %ld",child_server_pid,start_time);
		syslog(LOG_INFO,"child server(%d) : stop      time = %ld",child_server_pid,stop_time);
		syslog(LOG_INFO,"child server(%d) : execution time = %ld",child_server_pid,stop_time-start_time);
	}

	return(0);
};
 #else
	syslog(LOG_ERR,"unknown DB_TYPE [%s]. The message (%s) did not inserted!",configs[DB_TYPE][1],string);
	return;
 #endif
#endif
