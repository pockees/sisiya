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

extern int errno;
char *pname;
/****************************************************************/
int get_http_response_code(char *buff,int length,int *response_code); 
int get_http_date_str(char *buff,int length,char *date_str); 
int get_http_server_name(char *buff,int length,char *server_str); 
int client(register int sockfd,int argc,char *argv[]);
/****************************************************************/
/*
 Returns 0 on success, 1 on failure. On success the response_code is the HTTP response code.
*/
int get_http_response_code(char *buff,int length,int *response_code) 
{
 int i;
 char str[MAX_STR+1];
 
 if(length > MAX_STR)
	return(1);

 for(i=0;i<3;i++) {
		str[i]=buff[9+i];
 }
 str[3]='\0';

 *response_code=(int)strtol(str,(char **)NULL,10);
 if(errno != 0)
   return(1);

 return(0);
}

/*
 Returns 0 on success, 1 on failure. On success the date_str is filled with the date string.
Note: Not all HTTP servers return data in their response.
*/
int get_http_date_str(char *buff,int length,char *date_str) 
{
 int i;
 
 if(length > MAX_STR)
	return(1);

 for(i=0;i<length;i++) {
		date_str[i]=buff[6+i];
 }
 date_str[length-8]='\0';
 return(0);
}

/*
 Returns 0 on success, 1 on failure. On success the server_str is filled with the servers' string.
*/
int get_http_server_name(char *buff,int length,char *server_name) 
{
 int i;
 
 if(length > MAX_STR)
	return(1);

 for(i=0;i<length;i++) {
		server_name[i]=buff[8+i];
 }
 server_name[length-10]='\0';
 return(0);
}

int client(register int sockfd,int argc,char *argv[])
{
 int n,retcode;
 char str[MAX_STR+1];
 char str2[MAX_STR+1];
 char mesg_str[MAX_STR+1];
 
 sprintf(str,"GET http://%s%s HTTP/%s\n\n",argv[1],argv[2],argv[3]);
 n=strlen(str);
 if((writen(sockfd,str,n)) != n) {
   fprintf(stderr,"%s: Error writing data to the socket.",pname);
   return(1);
 }
 if((n=readline(sockfd,str,MAX_STR)) <= 0) {
   fprintf(stderr,"%s: Error reading server response.",pname);
   return(1);
 } 
 if(get_http_response_code(str,n,&retcode) == 1) {
   fprintf(stderr,"%s: Error getting the server's response.",pname);
   return(1);
 }

 if((n=readline(sockfd,str,MAX_STR)) <= 0) {
   fprintf(stderr,"%s: Error reading server response.",pname);
   return(1);
 } 
 if(get_http_date_str(str,n,str2) == 1) { 
   fprintf(stderr,"%s: Error getting the server's date!",pname);
   return(1);
 }
 strcpy(mesg_str,str2);
/* printf("HTTP Date : %s\n",str2); */

 if((n=readline(sockfd,str,MAX_STR)) <= 0) {
   fprintf(stderr,"%s: Error reading server response.",pname);
   return(1);
 } 
 if(get_http_server_name(str,n,str2) == 1) { 
   fprintf(stderr,"%s: Error getting the server's identification string!",pname);
   return(1);
 }
 strcpy(str,mesg_str);
 sprintf(mesg_str,"%d ",retcode);
 strcat(mesg_str,str2);
 strcat(mesg_str," ");
 strcat(mesg_str,str);
/* printf("HTTP Server : %s\n",str2); 
 printf("Message : [%s]\n",mesg_str);
*/ 
 printf("%s",mesg_str); 
 
  switch(retcode) {
		case 200 :
/*			printf("OK\n");*/
			return(0);
			break;
		default :
/*			printf("Error occured! Return code=%d\n",retcode);*/
			break;
	}
 

 return(1);
}

int main(int argc,char *argv[])
{
	int sockfd,retval,port=80;
	struct sockaddr_in serv_addr;
	char server_ip[MAX_STR+1];
 
	pname=argv[0];
 
	if(argc < 4) {
		fprintf(stderr,"Usage  : %s server file protocol_no_string [port]\n",argv[0]);
		fprintf(stderr,"server : is the IP address of the server.\n");
		fprintf(stderr,"file   : This is the file used for checking. It should exists on the HTTP server.\n");
		fprintf(stderr,"protocol_no_str : is the HTTP protocol number : 1.0 or 1.1.\n");
		fprintf(stderr,"port   : Is the port on which the server is listening. Default is 80. This parameter is optional.\n");
		fprintf(stderr,"Example: %s www.linux.org /index.html 1.0\n",argv[0]);
		exit(1);
	}

	if(get_ip(argv[1],server_ip,MAX_STR) == 0) 
		err_sys("Could not get the IP for %s",argv[1]);

	if(argc == 5)
		port=atoi(argv[4]);

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
