#ifdef HAVE_CONFIG_H
 #include"config.h"
#endif

/* Definitions for TCP and UDP client/server programs. */
#include<stdio.h>

#ifdef HAVE_SYS_STAT_H
 #include<sys/stat.h>
#endif

#ifdef HAVE_SYS_SOCKET_H
 #include<sys/socket.h>
#endif

#ifdef HAVE_SYS_TYPES_H
 #include<sys/types.h>
#endif

#ifdef HAVE_SYS_WAIT_H
 #include<sys/wait.h>
#endif

#ifdef HAVE_NETINET_IN_H
 #include<netinet/in.h>
#endif

#ifdef HAVE_ARPA_INET_H
 #include<arpa/inet.h>
#endif

#if HAVE_UNISTD_H
 #ifdef DARWIN
  #include<sys/unistd.h>
 #else
  #include<unistd.h>
 #endif
#endif


#include"systype.h"

#ifdef SERVER
 #include"esignal.h"
#endif
