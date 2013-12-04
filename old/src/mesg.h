/*
  Definition of "our" message.
  
  You may have to change the 4096 to a smaller value, if message queues
  on your system were configured with "msgmax" less then 4096.
*/

#ifndef _mesg_h
#define _mesg_h

#if HAVE_CONFIG_H
  #include"config.h"
#endif

#if HAVE_UNISTD_H
 #ifdef DARWIN
  #include<sys/unistd.h>
 #else
  #include<unistd.h>
 #endif
#endif

#include"systype.h"

#define MAXMESGDATA   (4096-16) /* we don't want sizeof(Mesg) > 4096 */
#define MESGHDRSIZE   (sizeof(Mesg)-MAXMESGDATA) 
                               /* length of mesg_len and mesg_type */
#define SEND_MESSAGE 1L
#define RECV_MESSAGE 2L

typedef struct {
  unsigned short int mesg_len;      /* #bytes in mesg_data, can be 0 or > 0 */
  unsigned short int mesg_type;    /* message type, must be > 0            */
  char mesg_data[MAXMESGDATA];
}  Mesg;

void mesg_send(int fd,Mesg *mesgptr);
int mesg_recv(int fd,Mesg *mesgptr);

#endif                               
