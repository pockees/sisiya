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
#include"resolve.h"

#define MAX_STR 4096

char *pname;

int main(int argc,char *argv[])
{
	int sockfd;
	struct sockaddr_in serv_addr;
	char server_ip[MAX_STR];

	pname=argv[0];
 
	if(argc < 3) {
		fprintf(stderr,"Usage : %s server_name_or_IP port\n",pname);
		fprintf(stderr,"server_name_or_IP: is the name or IP address of the server.\n");
		fprintf(stderr,"port     : Is the port on which the server is listening.\n");
		exit(1);
	}

	if(get_ip(argv[1],server_ip,MAX_STR) == 0) {
		fprintf(stderr,"%s : cannot get the IP address for %s !\n",pname,argv[1]);
		exit(1);
	}

	bzero((char *)&serv_addr,sizeof(serv_addr));
	serv_addr.sin_family=AF_INET;
	serv_addr.sin_addr.s_addr=inet_addr(server_ip);
	serv_addr.sin_port=htons(atoi(argv[2]));
 
	if((sockfd=socket(AF_INET,SOCK_STREAM,0)) < 0) {
		fprintf(stderr,"%s : Can't open stream socket!\n",pname);
		exit(1);
	}
	if(connect(sockfd,(struct sockaddr *)&serv_addr,sizeof(serv_addr)) < 0) {
		fprintf(stderr,"%s : Can't connect to server %s:%s !\n",pname,server_ip,argv[2]);
		exit(1);
	}

 
	close(sockfd);
	return(0);
}
