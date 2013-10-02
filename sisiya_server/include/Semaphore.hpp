/*
    Copyright (C) 2005  Erdal Mutlu

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

#ifndef _Semaphore_header_
#define _Semaphore_header_

/*!
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

/*
#if HAVE_CONFIG_H
  #include"config.h"
#endif
*/

#include<sys/types.h>
#include<sys/ipc.h>
#include<sys/sem.h>
#include<errno.h>

#if defined(__GNU_LIBRARY__) && !defined(_SEM_SEMUN_UNDEFINED)
	// The union semun is defined by including <sys/sem.h>
#else
	// According to X/OPEN we have to define it ourselves
	union semun {
		int val;			// value for SETVAL
		struct semid_ds *buf;		// buffer for IPC_STAT, IPC_SET
		unsigned short int *array;	// array for GETALL,SETALL
		struct seminfo *__buf;		// buffer for IPC_INFO
	};
#endif


class Semaphore {
	public:
		//! Default constructor.
		Semaphore();
		//! Constructor.
		Semaphore(key_t key,int initial=1,bool createFlag=true);
		//! Destructor.
		~Semaphore();
		//! Get the semaphore ID.
		int getID(void);
		//! Get the lock.
		void getLock(void);
		//! Set semaphore key.
		void setKey(key_t key,int initial=1,bool createFlag=true);
		//! Release the lock.
		void releaseLock(void);
	private:
		//! Create flag.
		bool createFlag;
		//! The semaphore ID.
		int semID;
		//! Initial number.
		int initial;
		//! The semaphore key.
		key_t key;

		//! Semaphore conrol union.
		union semun semctl_arg;

  		//! Initial value of process counter.
		static const int BIGCOUNT=10000;

		//! Define the semaphor operation arrays for the semop() calls.
		/*!
		1. Wait for [2] (lock) to equal 0.
		2. Then increment [2] to 1 - this locks it. UNDO to create the lock if processe 
			exits before explicitly unlocking
		*/
		struct sembuf op_lock[2];

		/*!
		1. Derement [1] (process counter} with undo on exit.UNDO to adjust process counter if 
		process exits before explicitly calling close().
		2. Then decrement [2] (lock) back to 0.
		*/
		struct sembuf op_endcreate[2];
		
		//! decrement [1] (process counter) with undo on exit
		struct sembuf op_open[1];

		/*!
		1. Wait for [2] (lock) to equal 0
		2. Then increment [2] to 1 - this locks it.
		3. Then increment [1] (process counter).
		*/
		struct sembuf op_close[3];

		//! Decrement [2] (lock) backt to 0 
		struct sembuf op_unlock[1];

		/*!
		Decrement or increment [0] with undo on exit the 99 is set to actual amount to 
		add or substruct (positive or negative)
		*/
		struct sembuf op_op[1];
	private:
		//! Close the semaphore.
		void close(void);
		//! Create the semaphore.
		void create(void);
		//! Open the semaphore.
		void open(void);
		//! Initialize semaphore structures.
		void initializeStructures(void);
		//! General semaphore operation.
		void operation(int value);
		//! Remove the semaphore.
		void remove(void);
};

#endif
