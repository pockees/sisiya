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

#include"sisiyac1.h"

extern char *pname;

int client(register int sockfd,int argc,char *argv[])
{
	int n;
	char msg_str[MAX_STR+1];

	n=strlen(argv[3]);
	if(n >= (MAX_STR -1)) {
		fprintf(stderr,"%s: Message length %d is greater than %d. Truncating the message...\n",pname,n,MAX_STR-1);
		if(MAX_STR < 5) 
			return(1);
		strncpy(msg_str,argv[3],MAX_STR-4);
		n=MAX_STR;
		strcat(msg_str,"...\n");
	}
	else {
		strcpy(msg_str,argv[3]);
		strcat(msg_str,"\n");
	}

	if((write(sockfd,msg_str,n)) != n) {
		fprintf(stderr,"%s: Error writing data to the socket.",pname);
		return(1);
	}
	else  
		return(0);
};

int client2(register int sockfd,char *file_name)
{
	int n;
	char line[MAX_STR+1];
	FILE *fptr;

	fptr=fopen(file_name,"r");
	if(fptr == NULL) {
		fprintf(stderr,"%s : Cannot open file %s!",pname,file_name);
		return(1);
	}
	while(!feof(fptr)) {
		if(fgets(line,MAX_STR,fptr) == NULL)
			continue;
		n=strlen(line);
		if(line[n-1] != '\n') {
			fprintf(stderr,"%s : Line starting with :\n",pname);
			fprintf(stderr,"%s\n",line);
			if(MAX_STR < 5) {
				fprintf(stderr,"%s : has length greater than %d (<5) exiting...\n",pname,MAX_STR);
				fclose(fptr);
				return(1);
			}
			fprintf(stderr,"%s : has length greater than %d. Truncating the message...\n",pname,MAX_STR);
			/* truncate the message */
			line[MAX_STR-4]='.';
			line[MAX_STR-3]='.';
			line[MAX_STR-2]='.';
			line[MAX_STR-1]='\n';
			n=MAX_STR;
		}
		if((writen(sockfd,line,n)) != n) {
			fprintf(stderr,"%s: Error writing data to the socket.",pname);
			fclose(fptr);
			return(1);
		}
	}
	fclose(fptr);
	return(0);
};
