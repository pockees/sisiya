#include"resolve.h"
#include<string.h>

/* 
  get_ip: Resolves hostname to an IP address, copies it to the buffer buffer and returns 0 on error
          or non zero (the length of the buffer) on success. buffer_length is the buffer size.
          If the buffer_length is smaller than the returned address length from gethostbyname,
          an error is returned.
*/
int get_ip(char *hostname,char *buffer,size_t buffer_length)
{
 size_t length;
 struct hostent *h_ptr;

 h_ptr=gethostbyname(hostname);
 if(h_ptr == NULL) 
   return(0);
 length=strlen(inet_ntoa(*(struct in_addr *)h_ptr->h_addr_list[0]));
 if(length < buffer_length) {
   strncpy(buffer,inet_ntoa(*(struct in_addr *)h_ptr->h_addr_list[0]),length);
   buffer[length]='\0';
   return(length); /* Return a non zero value: the length of the IP address. */
 }
 return(0);
};


