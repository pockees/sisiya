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

#include"inet.h"
#include<stdio.h>
#include"systype.h"
#include"misc.h"
#include"mesg.h"
#include"sisiya.h"
#include"resolve.h"
#include<signal.h>
#include"esignal.h"

char *pname;
/****************************************************************/
int client(register int sockfd,int argc,char *argv[]);
RETSIGTYPE sig_alarm(int signo);
/****************************************************************/

/*!
Signal handler for SIGALRM.
*/
RETSIGTYPE sig_alarm(int signo)
{
	/* exit the program with error */
	fprintf(stderr,"%s : Alarm expired!\n",pname);
	exit(1);
}

int client(register int sockfd,int argc,char *argv[])
{
	char str[MAX_STR+1];
	int n;
 
	if((n=readline(sockfd,str,MAX_STR)) <= 0) {
		fprintf(stderr,"%s: Error reading server response.",pname);
		return(1);
	} 
	str[n-2]='\0';
	printf("%s",str);

	return(0);
}

int main(int argc,char *argv[])
{
	int sockfd,retval,port=22,timeout=10;
	struct sockaddr_in serv_addr;
	char server_ip[MAX_STR+1];
 
	pname=argv[0];
 
	if(argc < 2) {
		fprintf(stderr,"Usage  : %s server [port] [timeout]\n",argv[0]);
		fprintf(stderr,"server : is the IP address of the server.\n");
		fprintf(stderr,"port   : is the port where the SSH server is listening to incoming connections.\n");
		fprintf(stderr,"Example: %s www.linux.org\n",argv[0]);
		fprintf(stderr,"Example: %s www.linux.org 22 10\n",argv[0]);
		fprintf(stderr,"Default: port=22 and timeout=10 seconds\n");
		exit(1);
	}

	if(get_ip(argv[1],server_ip,MAX_STR) == 0) 
		err_sys("Could not get the IP for %s",argv[1]);

	if(argc == 3)
		port=atoi(argv[2]);
	if(argc == 4)
		timeout=atoi(argv[3]);


	bzero((char *)&serv_addr,sizeof(serv_addr));
	serv_addr.sin_family=AF_INET;
	serv_addr.sin_addr.s_addr=inet_addr(server_ip);
	serv_addr.sin_port=htons(port);
 
	if(esignal(SIGALRM,sig_alarm) == SIG_ERR)
		err_sys("%s : could not set signal handler for SIGALRM!",pname);

	/* start alarm */
	alarm(timeout);


	if((sockfd=socket(AF_INET,SOCK_STREAM,0)) < 0)
		err_sys("Cannot open stream socket.");
 
	if(connect(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr)) < 0) {
		fprintf(stderr,"Cannot connect to server %s:%d.",argv[1],port);
		return(1);
	}


	retval=client(sockfd,argc,argv);  
 
	/* cancel the alarm */
	alarm(0);

	close(sockfd);
	return(retval);
}
