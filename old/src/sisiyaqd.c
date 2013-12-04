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

#ifdef HAVE_CONFIG_H
 #include"config.h"
#endif

#ifdef HAVE_MYSQL
 #include"sisiyad_mysql.h"
#endif
#ifdef HAVE_PGSQL
 #include"sisiyad_postgresql.h"
#endif

#include"sisiya.h"
#include"sisiya_conf.h"

#ifdef HAVE_SYS_STAT_H
 #include<sys/stat.h>
#endif

#ifdef HAVE_SYS_TYPES_H
 #include<sys/types.h>
#endif

#ifdef SERVER
 #include"esignal.h"
#endif

#ifdef HAVE_SIGNAL_H 
 #include<signal.h>
#endif

pid_t server_pid; /* This is the PID of the daemon process. */
char *conf_file_name;
int loglevel;

char configs[NUMCONFIGS][2][MAX_STR]={
 {"LOGLEVEL","0"},
 {"IP","any"},
 {"PORT","8888"},
 {"DB_TYPE","PostgreSQL"},
 {"DB_SERVER","localhost"},
 {"DB_NAME","sisiya"},
 {"DB_USER","sisiyauser"},
 {"DB_PASSWORD","sisiyauser1"},
 {"SEMKEY","11"},
 {"PID_FILE","/var/run/sisiyad.pid"},
 {"QPID_FILE","/var/run/sisiyaqd.pid"},
 {"SLEEP_SECONDS","30"}
};

/***********************************************************************/
RETSIGTYPE sig_quit(int signo);
RETSIGTYPE sig_hup(int signo);
RETSIGTYPE sig_term(int signo);
RETSIGTYPE sig_usr1(int signo);
int daemon_init(void);
char *conf_file_name;
void clean_and_exit(int code);
void doit(void);
/***********************************************************************/
/*
 sig_quit : Signal handler for SIGQUIT.
*/
RETSIGTYPE sig_quit(int signo)
{
 if(loglevel > 1)
   syslog(LOG_INFO,"caught SIGQUIT (%d)",signo);
 clean_and_exit(EXIT_SUCCESS);
};

/*
 sig_hup : Signal handler for SIGHUP. This way we reconfigure our server.
*/
RETSIGTYPE sig_hup(int signo)
{
 syslog(LOG_INFO,"caught SIGHUP (%d). Reloading configuration.",signo);
 if(read_conf(conf_file_name) == FALSE) {
   syslog(LOG_ERR,"error occured while reading configuration file %s !",conf_file_name);
   clean_and_exit(EXIT_FAILURE);
 }
 doit();
};

/*
 sig_term : Signal handler for SIGTERM.
*/
RETSIGTYPE sig_term(int signo)
{
 if(loglevel > 1)
   syslog(LOG_INFO,"caught SIGTERM (%d)",signo);
 clean_and_exit(EXIT_SUCCESS);
};

/*
  sig_usr1 : Signal handler for SIGUSR1. Log the configuration options via syslog.
*/
RETSIGTYPE sig_usr1(int signo)
{
 sisiya_showconf();
}



/* 
  clean_and_exit: Performs clean up and exits with the specified exit code.
*/
void clean_and_exit(int code)
{
 syslog(LOG_INFO,"exiting...");
 exit(code);
}

/*
 daemon_init: Initialize a daemon process.
*/
int daemon_init(void)
{
 pid_t pid;

 /* There is a problem when I send the SIGHUP for the second time. The first SIGHUP
    is caught, but the second etc. are not. */

 pid=fork();
 if(pid < 0)
   return(-1);
 else if(pid != 0)
   exit(0); /* the parent exits */

 /* the child process continues */
 pid=setsid(); /* become session leader */  
 if(pid == -1) {
  syslog(LOG_ERR,"cannot set session id");
  exit(1);
 }
 
/* change working dir to /, so that we do not occupie any mounts */ 
 if(chdir("/") != 0) {
  syslog(LOG_ERR,"cannot change dir to /");
  exit(1);
 }
 
 umask(0); /* clear our file creation mask, so that any inherited restriction do not apply */ 
 return(0);
};

void doit(void)
{
	/* become a daemon */
	daemon_init(); 
 
signal(SIGCHLD,SIG_IGN);
	signal(SIGQUIT,sig_quit);
	signal(SIGTERM,sig_term);
	signal(SIGUSR1,sig_usr1);
	signal(SIGHUP,sig_hup);

	server_pid=getpid();
	if(write_pid(configs[QPID_FILE][1],server_pid) == FALSE) {
		syslog(LOG_ERR,"can't write PID to the file : %s ! Exiting...",configs[QPID_FILE][1]);
		clean_and_exit(EXIT_FAILURE); 
	}
 
	loglevel=atoi(configs[LOGLEVEL][1]); /* Set the loglevel. For now it is primitive made. Change it later.*/
	syslog(LOG_INFO,"Queue processor server (version %s) started. PID is %d",VERSION,server_pid); 

	for(;;) {
#ifdef HAVE_MYSQL 
		if(strcmp(configs[DB_TYPE][1],"MySQL") == 0)
			sisiyad_mysql_process_queue(configs[DB_SERVER][1],configs[DB_USER][1],configs[DB_PASSWORD][1],configs[DB_NAME][1]);
		else
			syslog(LOG_ERR,"This type [%s] is not MySQL. The queue is not processed!",configs[DB_TYPE][1]);

#else
 #ifdef HAVE_PGSQL
		if(strcmp(configs[DB_TYPE][1],"PostgreSQL") == 0)
			sisiyad_postgresql_process_queue(configs[DB_SERVER][1],configs[DB_USER][1],configs[DB_PASSWORD][1],configs[DB_NAME][1]);
		else
			syslog(LOG_ERR,"This type [%s] is not PostgreSQL. The queue is not processed!",configs[DB_TYPE][1]);

 #else
		syslog(LOG_ERR,"unknown DB_TYPE [%s]. Queue table is not processed!",configs[DB_TYPE][1]);
		return;
 #endif
#endif
		/* sleep for while */
		sleep(atoi(configs[SLEEP_SECONDS][1]));	
	}
};



int main(int argc,char **argv)
{

 if(argc != 2 ) {
  fprintf(stderr,"Usage : %s sisiyaqd.conf\n",argv[0]);
  exit(1);
 }

 openlog("sisiyaqd",LOG_PID,LOG_USER); /* Open the syslog. Log progname and pid */

 conf_file_name=argv[1];
 if(read_conf(conf_file_name) == FALSE) {
   syslog(LOG_ERR,"error occured while reading configuration file %s !",conf_file_name);
   clean_and_exit(EXIT_FAILURE);
 }

 /* everything goes here */
 doit();
 
 return(0);
}
