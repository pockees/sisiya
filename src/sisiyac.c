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

#include"inet.h"
#include"sisiyac1.h"
#include"resolve.h"

char *pname;

int main(int argc,char *argv[])
{
	int sockfd,retval;
	struct sockaddr_in serv_addr;
	char server_ip[MAX_STR+1];
	FILE *fptr;
 
	pname=argv[0];
 
	if(argc < 4) {
		fprintf(stderr,"Usage          : %s server port sisiya_message\n",argv[0]);
		fprintf(stderr,"or             : %s server port file_name\n",argv[0]);
		fprintf(stderr,"server         : The name or IP address of the SisIYA server to connect.\n");
		fprintf(stderr,"port           : The port on which the SisIYA server is listening.\n");
		fprintf(stderr,"sisiya_message : The SisIYA message string that is going to be transfered to the SisIYA server.\n");
		fprintf(stderr,"file contents : Every line is a SisIYA message string.\n");
		fprintf(stderr,"For more information please refer to the project's website : http://sisiya.sourceforge.net\n");
		exit(1);
	}

	if(get_ip(argv[1],server_ip,MAX_STR) == 0) {
		fprintf(stderr,"%s : Could not get the IP for %s",pname,argv[1]);
		exit(1);
	}

	bzero((char *)&serv_addr,sizeof(serv_addr));
	serv_addr.sin_family=AF_INET;
	serv_addr.sin_addr.s_addr=inet_addr(server_ip);
	serv_addr.sin_port=htons(atoi(argv[2]));
 
	if((sockfd=socket(AF_INET,SOCK_STREAM,0)) < 0) {
		fprintf(stderr,"%s : Can't open stream socket.",pname);
		exit(1);
	}
 
	if(connect(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr)) < 0) {
		fprintf(stderr,"%s : Can't connect to server %s:%s.",pname,argv[1],argv[2]);
		exit(1);
	}
	fptr=fopen(argv[3],"r");
 	if(fptr == NULL)
		retval=client(sockfd,argc,argv);  
	else {
		fclose(fptr);
		retval=client2(sockfd,argv[3]);  
	}
	close(sockfd);
	return(retval);
}
