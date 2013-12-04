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
#include"inet.h"
#include"resolve.h"
#include"sisiya_conf.h"

int sockfd;
int semid;
char *pname;
char *conf_file_name;
pid_t server_pid; /* This is the PID of the daemon process. */
struct sockaddr_in cli_addr,serv_addr;

/* Configuration variables. */
int loglevel;
long int port;

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
RETSIGTYPE sig_child(int signo);
RETSIGTYPE sig_quit(int signo);
RETSIGTYPE sig_hup(int signo);
RETSIGTYPE sig_term(int signo);
RETSIGTYPE sig_usr1(int signo);
int daemon_init(void);
void clean_and_exit(int code);
void doit(void);
/***********************************************************************/

/*
 sig_child : Signal handler for SIGCHLD.
*/
RETSIGTYPE sig_child(int signo)
{
 pid_t pid;
 int status;
 
 pid=wait(&status);

 syslog(LOG_INFO,"child server(%s:%d) terminated with status=%d",inet_ntoa(cli_addr.sin_addr),cli_addr.sin_port,status);

 if(WIFEXITED(status) != 0){
  if(loglevel > 1)
    syslog(LOG_INFO,"child server(%s:%d) terminated normally.",inet_ntoa(cli_addr.sin_addr),cli_addr.sin_port);
 }
 else 
    syslog(LOG_ERR,"child server(%s:%d) pid=%d terminated abnormally!",inet_ntoa(cli_addr.sin_addr),cli_addr.sin_port,pid);

};

/*
 sig_quit : Signal handler for SIGQUIT.
*/
RETSIGTYPE sig_quit(int signo)
{
 if(loglevel > 1)
   syslog(LOG_INFO,"child server(%s:%d) caught SIGQUIT (%d)",inet_ntoa(cli_addr.sin_addr),cli_addr.sin_port,signo);
 clean_and_exit(EXIT_SUCCESS);
};

/*
 sig_hup : Signal handler for SIGHUP. This way we reconfigure our server.
*/
RETSIGTYPE sig_hup(int signo)
{
 syslog(LOG_INFO,"Server(%s:%d) caught SIGHUP (%d). Reloading configuration.",inet_ntoa(cli_addr.sin_addr),cli_addr.sin_port,signo);
 close(sockfd);
 if(loglevel > 1)
   syslog(LOG_INFO,"closed sockfd %d.",sockfd);
 sem_close(semid);     
 if(loglevel > 1)
   syslog(LOG_INFO,"closed semaphor with id = %d.",semid);

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
   syslog(LOG_INFO,"server caught SIGTERM (%d)",signo);
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
 pid_t pid;

 pid=getpid();
 /* This must be done only if we are the daemon. */
 if(pid == server_pid) {
  /* Exiting the daemon*/
  sem_close(semid);     
  if(loglevel > 1)
   syslog(LOG_INFO,"closed semaphor with id = %d.",semid);

 }
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
	pid_t child_pid;
	int newsockfd,clilen;
	key_t semkey;

	/* become a daemon */
	daemon_init(); 
 
	signal(SIGCHLD,SIG_IGN);

	signal(SIGQUIT,sig_quit);
	signal(SIGTERM,sig_term);
	signal(SIGUSR1,sig_usr1);
	signal(SIGHUP,sig_hup);
 
	if(loglevel > 1)
		syslog(LOG_INFO,"set a signal handlers");

	server_pid=getpid();
	if(write_pid(configs[PID_FILE][1],server_pid) == FALSE) {
		syslog(LOG_ERR,"can't write PID to the file : %s ! Exiting...",configs[PID_FILE][1]);
		clean_and_exit(EXIT_FAILURE); 
	}
 

	/*loglevel=atoi(argv[1]);*/ /* Set the loglevel. For now it is primitive made. Change it later.*/
	loglevel=atoi(configs[LOGLEVEL][1]); /* Set the loglevel. For now it is primitive made. Change it later.*/


	if((sockfd=socket(AF_INET,SOCK_STREAM,0)) < 0) {
		/*    err_dump("server[%d] : can't open stream socket",server_pid);*/
		syslog(LOG_ERR,"can't open stream socket (socket(AF_INET,SOCK_STREAM,0))");
		exit(1);
	}
 
	if(loglevel > 1)
		syslog(LOG_INFO,"opened a stream socket.");
 
	bzero((char *)&serv_addr,sizeof(serv_addr));
	serv_addr.sin_family=AF_INET;
	if(strcmp(configs[IP][1],"any") == 0 || strcmp(configs[IP][1],"0.0.0.0") == 0)
		serv_addr.sin_addr.s_addr=htonl(INADDR_ANY);
	else if(strcmp(configs[IP][1],"127.0.0.1") == 0 || strcmp(configs[IP][1],"localhost") == 0)
		serv_addr.sin_addr.s_addr=htonl(INADDR_LOOPBACK);
	else {	 
		if(inet_aton(configs[IP][1],&(serv_addr.sin_addr)) == 0) {
			syslog(LOG_ERR,"Can't convert numbers-and-dots (%s) notation into  binary  data",configs[IP][1]);
			exit(1);
		} 
	} 

	if(loglevel > 2)
		syslog(LOG_INFO,"inet_ntoa(serv_addr.sin_addr)=%s",inet_ntoa(serv_addr.sin_addr));
  
	serv_addr.sin_port=htons(atoi(configs[PORT][1]));
 
	if(bind(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr)) < 0) {
		close(sockfd);
		syslog(LOG_ERR,"can't bind local address (%s:%s)",configs[IP][1],configs[PORT][1]);
		exit(1);
	} 

	if(loglevel > 1)
		syslog(LOG_INFO,"bind local address (%s:%s)",configs[IP][1],configs[PORT][1]);

	if(listen(sockfd,5) == -1) {
		syslog(LOG_ERR,"can't listen address (%s:%s)",configs[IP][1],configs[PORT][1]);
		exit(1);
	}

	if(loglevel > 1)
		syslog(LOG_INFO,"start to listen");

	semkey=(key_t)atol(configs[SEMKEY][1]);
	if((semid=sem_create(semkey,1)) < 0) {
		syslog(LOG_ERR,"can't open semaphore.");
		exit(1);
	}


	if(loglevel > 1)
		syslog(LOG_INFO,"created semaphor with id=%d",semid);

	syslog(LOG_INFO,"Server (version=%s) started and accepting connection on interface=%s and port=%s. PID is %d",VERSION,configs[IP][1],configs[PORT][1],server_pid); 
 
	for(;;) {
		clilen=sizeof(cli_addr);
		newsockfd=accept(sockfd,(struct sockaddr *)&cli_addr,&clilen);
		if(loglevel > 1)
			syslog(LOG_INFO,"client(%s:%d) connected.",inet_ntoa(cli_addr.sin_addr),cli_addr.sin_port);
		if((child_pid=fork()) < 0) { 
			/* err_dump("server[%d] : fork error",server_pid);*/
			syslog(LOG_ERR,"cannot fork");
			exit(1);
		}
		else if(child_pid == 0) {	/* child process */
			child_pid=getpid(); 
 
			if(setpgid(0,child_pid) == -1)
				syslog(LOG_ERR,"child server[%d] : can't change process group",child_pid);
			/*       syslog(LOG_INFO,"child server[%d] connected.\n",child_pid);    */
  
			if(loglevel > 1)
				syslog(LOG_INFO,"child server connected. PPID=%d PID=%d GPID=%d\n",getppid(),child_pid,getpgid(child_pid));    

			close(sockfd);         /* child process */      
			/* process the request */
			if(server(newsockfd,semid) > 0) 
				syslog(LOG_ERR,"child server(%d) exited with error",child_pid);
			close(newsockfd);
			exit(0);              
		}
		else
			close(newsockfd);          /* parent process */  
	}
};

/*
 ********************************************************************************************************
 ********************************************************************************************************
*/
int main(int argc,char *argv[])
{

	pname=argv[0];

	if(argc != 2 ) {
		fprintf(stderr,"Usage : %s sisiyad.conf\n",argv[0]);
		exit(1);
	}

	openlog("sisiyad",LOG_PID,LOG_USER); /* Open the syslog. Log progname and pid */

	conf_file_name=argv[1];
	if(read_conf(conf_file_name) == FALSE) {
		syslog(LOG_ERR,"error occured while reading configuration file %s !",conf_file_name);
		clean_and_exit(EXIT_FAILURE);
	}

 
	/* everything goes here */
	doit();

	return(0);
}
