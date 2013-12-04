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
#include<stdlib.h>
#include"systype.h"
#include"misc.h"
#include"mesg.h"
#include"sisiya.h"
#include"resolve.h"

#define PORT_POP3 110

#define RESPONSE_CODE_OK	0
#define RESPONSE_CODE_WARNING	1
#define RESPONSE_CODE_ERROR 	2

char *pname;
/****************************************************************/
int get_pop3_response_code(char *buff,int length,int *response_code); 
int client(register int sockfd,int argc,char *argv[]);
/****************************************************************/
/*
 Returns 0 on success, 1 on failure. On success the response_code is the IMAP response code.
*/
int get_pop3_response_code(char *buff,int length,int *response_code) 
{
	int i;
	char str[4];
 
	if(length > MAX_STR)
		return(1);

	for(i=0;i<3;i++) {
		str[i]=buff[i];
	}
	str[3]='\0';

	*response_code=RESPONSE_CODE_ERROR;
	if(strcmp(str,"+OK") == 0)
		*response_code=RESPONSE_CODE_OK;
	return(0);
}

int client(register int sockfd,int argc,char *argv[])
{
	int n,retcode;
	char str[MAX_STR+1];
 
	if((n=readline(sockfd,str,MAX_STR)) <= 0) {
		fprintf(stderr,"%s: Error reading server response.",pname);
		return(1);
	}
	if(writen(sockfd,"QUIT\n",5) != 5) {
		return(1);
	}
	if(get_pop3_response_code(str,n,&retcode) == 1) {
		fprintf(stderr,"%s: Error getting the server's response.",pname);
		return(1);
	}
	printf("%s",str); 
	if(retcode != RESPONSE_CODE_OK)	
		return(1);
	return(0);
}

int main(int argc,char *argv[])
{
	int sockfd,retval,port=PORT_POP3;
	struct sockaddr_in serv_addr;
	char server_ip[MAX_STR+1];
 
	pname=argv[0];
 
	if(argc < 2) {
		fprintf(stderr,"Usage  : %s server [port]\n",argv[0]);
		fprintf(stderr,"server : is the IP address of the server.\n");
		fprintf(stderr,"port   : Is the port on which the server is listening. Default is %d. This parameter is optional.\n",PORT_POP3);
		fprintf(stderr,"Example: %s pop3.example.org\n",argv[0]);
		exit(1);
	}

	if(get_ip(argv[1],server_ip,MAX_STR) == 0) 
		err_sys("Could not get the IP for %s",argv[1]);

	if(argc == 3)
		port=atoi(argv[2]);

	bzero((char *)&serv_addr,sizeof(serv_addr));
	serv_addr.sin_family=AF_INET;
	serv_addr.sin_addr.s_addr=inet_addr(server_ip);
	serv_addr.sin_port=htons(port);
 
	if((sockfd=socket(AF_INET,SOCK_STREAM,0)) < 0)
		err_sys("Cannot open stream socket.");
 
	if(connect(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr)) < 0) {
		fprintf(stderr,"Cannot connect to server %s:%d.",argv[1],port);
		return(1);
	}

	retval=client(sockfd,argc,argv);  
 
	close(sockfd);
	return(retval);
}
