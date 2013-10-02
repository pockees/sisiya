#ifndef _resolve_h
#define _resolve_h

#if HAVE_CONFIG_H
 #include"config.h"
#endif

#ifdef HAVE_NETDB_H
 #include<netdb.h>
#endif

#ifdef HAVE_SYS_SOCKET_H 
 #include<sys/socket.h>
#endif

#ifdef HAVE_NETINET_IN_H
 #include<netinet/in.h>
#endif

#ifdef HAVE_ARPA_INET_H 
 #include<arpa/inet.h>
#endif

/* 
  get_ip: Resolves hostname to an IP address, copies it to the buffer buffer and returns 0 on error
          or non zero (the length of the buffer) on success. buffer_length is the buffer size.
          If the buffer_length is smaller than the returned address length from gethostbyname,
          an error is returned.
*/
int get_ip(char *hostname,char *buffer,size_t buffer_length);

#endif
