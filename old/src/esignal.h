#ifndef _esignal_h
#define _esignal_h

#if HAVE_CONFIG_H
  #include"config.h"
#endif

typedef void Sigfunc(int);   /* for signal handlers */

Sigfunc *esignal(int signo, Sigfunc *func);

#endif
