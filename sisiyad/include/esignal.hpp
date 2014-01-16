#include<signal.h>

/* for signal handlers */
typedef void Sigfunc(int);
Sigfunc *esignal(int signo, Sigfunc * func);
