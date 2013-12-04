/*
  Provide a simpler and easier to understand interface to the System V
  semaphor system calls. There are 7 routines available to the user :
  
  id=sem_create(key,initial);    # create with initial value or open
  id=sem_open(key);              # open (must already exist)
  sem_wait(id);                  # wait=P=down by 1
  sem_signal(id);                # signal=V=up by 1
  sem_op(id,amount);             # wait if (amount < 0)
                                 # signal if (amount > 0)
  sem_close(id);                 # close
  sem_rm(id);                    # remove (delete)
  
  We cretate and use a 3-member set for the requested semaphor.
  The first member , [0], is the actual semaphor value, and the second member, 
  [1], is a counter used to know all processes has finished
  with the semaphor. The counter is initialized to a large number,
  decremented on every create or open and incremented on every close.
  This way we can use the "adjust" feature provided by System V so that
  any process that exits without calling sem_close() is accounted for.
  It doesn't help us if the last process does this (as we have
  no way of getting control to remove the semaphor) but it will
  work if any process other than the last does exit (intentional
  or unintentianal).
  The third member, [2], of the semaphor set is used as a lock variable
  to avoid any race conditions in the sem_create() and sem_close() functions.
*/

#if HAVE_CONFIG_H
  #include"config.h"
#endif

#include<sys/types.h>
#include<sys/ipc.h>
#include<sys/sem.h>
#include<errno.h>
#include"systype.h"
/*************************************************************************/
int sem_create(key_t key,int initial);
int sem_open(int key);
void sem_rm(int id);
void sem_close(int id);
void sem_wait(int id);
void sem_signal(int id);
void sem_op(int id,int value);
/*************************************************************************/

#if defined(__GNU_LIBRARY__) && !defined(_SEM_SEMUN_UNDEFINED)
/* The union semun is defined by including <sys/sem.h> */
#else
 /* According to X/OPEN we have to define it ourselves */
 union semun {
              int val;			 /* value for SETVAL */
              struct semid_ds *buf;	 /* buffer for IPC_STAT, IPC_SET */
              unsigned short int *array; /* array for GETALL,SETALL */
              struct seminfo *__buf;     /* buffer for IPC_INFO */
             };
#endif
