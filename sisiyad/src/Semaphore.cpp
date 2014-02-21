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
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
*/

#include<iostream>
#include<cstdlib>
#include"Semaphore.hpp"

using namespace std;

extern int errno;

/*!
Default costructor. One should use the Semaphore::setKey() in order to use this semaphore.
*/
Semaphore::Semaphore()
//: semctl_arg.val(0),createFlag(true),semID(-1),initial(1),key(0)
//: createFlag(true),semID(-1),initial(1),key(0),semctl_arg(0)
:  createFlag(true), semID(-1), initial(1), key(0)
{
}

/*!
Construct a Semaphore object with key=k, initial=i and create_flag. If i is not specified, initial=1 is
used as default initial value. Initial is the number of initial processes that have locked
this semaphore. If flag is not specified true is assumed. For example a client
from a client-server pair would use create_flag=false, if its the server's responibility to create the semaphor.
*/
Semaphore::Semaphore(key_t k, int i, bool create_flag)
:createFlag(create_flag), semID(-1), initial(i), key(k)
{
	setKey(k, initial, create_flag);
}

/*!
Destructor.
*/
Semaphore::~Semaphore()
{
/*
	if(createFlag)
		remove();
	else
*/
	close();
}

/*!
Create a semaphore with a specified initial value.
If the semaphjor already exists, we don't initialize it (of course).
Use exceptions instead of cerr.
*/
void Semaphore::create()
{
	int semval;

	if (key == IPC_PRIVATE) {
		// IPC_PRIVATE is defined with #define ((key_t ), so I cannot use casting to suppres the old-style-cast warning here
		//if(key == static_cast<key_t>(IPC_PRIVATE)) { 
		semID = -1;	// return(-1);  // not intendet for private semaphores.
		cerr <<
		    "Semaphore:create: Not intended for private semaphores."
		    << endl;
		return;
	}
	//else if(key == (key_t)-1) {
	else if (key == static_cast < key_t > (-1)) {
		semID = -1;	// return(-1);  // probably an ftok() error by caller
		cerr <<
		    "Semaphore:create: Probably an ftok() error by caller."
		    << endl;
		return;
	}
      again:
	if ((semID = semget(key, 3, 0666 | IPC_CREAT)) < 0) {
		semID = -1;	// return(-1);  // permission problem or tables full
		cerr <<
		    "Semaphore:create: Permission problem or tables full."
		    << endl;
		return;
	}
	/*
	   When the semaphore is created, we know the value of all 3 members is 0.
	   Get a lock on the semaphore by waiting for [2] to equal 0. Then icrement it.

	   There is a race condition here. There is a possibility that
	   between the semget() above and the semop() bellow, another
	   process can call our sem_close() function which can remove 
	   the semaphore if that process is the last one using it.
	   Therefore, we handle the error condition of an invalid
	   semaphore ID specially below, and if it does happen, we just
	   go back and create it again.
	 */
	//if(semop(semID,&op_lock[0],2) < 0) {
	int retcode;
	while ((retcode = semop(semID, &op_lock[0], 2)) < 0 && errno == EINTR);	// try again
	if (retcode < 0) {
		if (errno == EINVAL)
			goto again;
		semID = -1;	// err_sys("can't lock");
		cerr << "Semaphore::create: Cannot lock." << endl;
		return;
	}
	// Get the value of the process counter. If it equals 0, then no one has initialized the semaphore yet.
	semctl_arg.val = 0;
	if ((semval = semctl(semID, 1, GETVAL, semctl_arg)) < 0) {
		semID = -1;	// err_sys("can't GETVAL");
		cerr << "Semaphore:create: Cannot GETVAL" << endl;
		return;
	}
	if (semval == 0) {
		/*
		   We could initialize by doing a SETVAL, but that
		   would clear the adjust value that we set, when we
		   locked the semaphore above. Instead, we'll do 2
		   system calls to initialize [0] and [1].
		 */
		semctl_arg.val = initial;
		if (semctl(semID, 0, SETVAL, semctl_arg) < 0) {
			semID = -1;	// err_sys("can't SETVAL [0]");
			cerr << "Semaphore:create: Cannot SETVAL [0]" <<
			    endl;
			return;
		}
		semctl_arg.val = BIGCOUNT;
		if (semctl(semID, 1, SETVAL, semctl_arg) < 0) {
			semID = -1;	// err_sys("can't SETVAL [1]");        
			cerr << "Semaphore:create: Cannot SETVAL [1]" <<
			    endl;
			return;
		}
	}
	// Decrement the process counter and than release the lock.
	//if(semop(semID,&op_endcreate[0],2) < 0) {
	while ((retcode = semop(semID, &op_endcreate[0], 2)) < 0 && errno == EINTR);	// try again
	if (retcode < 0) {
		semID = -1;	// err_sys("can't end create");
		cerr << "Semaphore:create: Cannot end create." << endl;
		return;
	}
}

/*!
\return the semaphore id.
*/
int Semaphore::getID(void)
{
	return semID;
}

/*!
Wait to get the lock.
Wait until a semaphore's value is greater than 0, then decrement it by 1 and return.
Dijkstra's P operation. Tanebaum's DOWN operation.
*/
void Semaphore::getLock(void)
{
	operation(-1);
}

/*!
Initial the semaphore structures.
*/
void Semaphore::initializeStructures(void)
{
	/*!
	   1. Wait for [2] (lock) to equal 0.
	   2. Then increment [2] to 1 - this locks it. UNDO to create the lock if processe 
	   exits before explicitly unlocking
	 */
	op_lock[0].sem_num = 2;
	op_lock[0].sem_op = 0;
	op_lock[0].sem_flg = 0;

	op_lock[1].sem_num = 2;
	op_lock[1].sem_op = 1;
	op_lock[1].sem_flg = SEM_UNDO;

	/*!
	   1. Derement [1] (process counter} with undo on exit.UNDO to adjust process counter if 
	   process exits before explicitly calling close().
	   2. Then decrement [2] (lock) back to 0.
	 */
	op_endcreate[0].sem_num = 1;
	op_endcreate[0].sem_op = -1;
	op_endcreate[0].sem_flg = SEM_UNDO;

	op_endcreate[1].sem_num = 2;
	op_endcreate[1].sem_op = -1;
	op_endcreate[1].sem_flg = SEM_UNDO;

	//! decrement [1] (process counter) with undo on exit
	op_open[0].sem_num = 1;
	op_open[0].sem_op = -1;
	op_open[0].sem_flg = SEM_UNDO;

	/*!
	   1. Wait for [2] (lock) to equal 0
	   2. Then increment [2] to 1 - this locks it.
	   3. Then increment [1] (process counter).
	 */
	op_close[0].sem_num = 2;
	op_close[0].sem_op = 0;
	op_close[0].sem_flg = 0;

	op_close[1].sem_num = 2;
	op_close[1].sem_op = 1;
	op_close[1].sem_flg = SEM_UNDO;

	op_close[2].sem_num = 1;
	op_close[2].sem_op = 1;
	op_close[2].sem_flg = SEM_UNDO;

	//! Decrement [2] (lock) backt to 0 
	op_unlock[0].sem_num = 2;
	op_unlock[0].sem_op = -1;
	op_unlock[0].sem_flg = SEM_UNDO;

	/*!
	   Decrement or increment [0] with undo on exit the 99 is set to actual amount to 
	   add or substruct (positive or negative)
	 */
	op_op[0].sem_num = 0;
	op_op[0].sem_op = 99;
	op_op[0].sem_flg = SEM_UNDO;
}

/*!
Release the lock.
Increment a semaphore by 1.
Dijkstra's V operation. Tanenbaum's UP operation.
*/
void Semaphore::releaseLock(void)
{
	operation(1);
}

/*!
Initialize the Semaphore object with key=k, initial=i and createFlag=flag. If i is not specified, i=1 is
used as default initial value. Initial is the number of initial processes that have locked
this semaphore. If flag is not specified true is assumed. For example a client
from a client-server pair would use flag=false, if its the server's responibility to create the semaphor.
*/
void Semaphore::setKey(key_t k, int i, bool create_flag)
{
/*	key=k;
	initial=i;
	createFlag=create_flag;
*/
	initializeStructures();

	if (semID != -1)
		remove();
	if (createFlag)
		create();
	else
		open();
	// Throw exception here.
	if (semID == -1) {
		cerr <<
		    "Semaphore::setKey: Could not create the semaphore with key="
		    << key << " initial=" << initial << endl;
		exit(1);
	}
}

/*!
Open the semaphore that must already exist.
This function should be used, instead of create(), if the caller 
knows that the semaphore must already exist. For example a client
from a client-server pair would use this, if its the server's
responibility to create the semaphore.
Use exceptions instead of cerr.
*/
void Semaphore::open(void)
{
	if (key == IPC_PRIVATE) {
		// IPC_PRIVATE is defined with #define ((key_t ), so I cannot use casting to suppres the old-style-cast warning here
		//if(key == static_cast<key_t>(IPC_PRIVATE)) {
		semID = -1;	// return(-1);  // not intened for private semaphores
		cerr <<
		    "Semaphore::open: Not intened for private semaphores."
		    << endl;
		return;
	}
	//else if(key == (key_t) -1) {
	else if (key == static_cast < key_t > (-1)) {
		semID = -1;	//    return(-1);  // probably an ftok() error by caller
		cerr <<
		    "Semaphore::open: Probably an ftok() error by caller."
		    << endl;
		return;
	}
	if ((semID = semget(key, 3, 0)) < 0) {
		semID = -1;	// return(-1);  /* doesn't exist, or tables full
		cerr <<
		    "Semaphore::open: Does not exist or tables are full."
		    << endl;
		return;
	}
	// Decrement the process counter. We don't need a lock to do this.
	//if(semop(semID,&op_open[0],1) < 0) {
	int retcode;
	while ((retcode = semop(semID, &op_open[0], 1)) < 0 && errno == EINTR);	// try again
	if (retcode < 0) {
		semID = -1;	//    err_sys("can't open");
		cerr << "Semaphore::open: Cannot open the semaphore." <<
		    endl;
		return;
	}
}

/*!
Remove the semaphore.
This call is intended to be called by a sevrer, for example,
when it is being shut down, as we do an IPC_RMID on the semaphore,
regardless wheter other processes may be using it or not.
Most other processes should use close() below.
*/
void Semaphore::remove(void)
{
	semctl_arg.val = 0;
	//cerr << "Semaphore::remove: removing semaphore=" << semID << endl;
	if (semctl(semID, 0, IPC_RMID, semctl_arg) < 0) {
		// Should throw exception here.
		cerr << "Semaphore::remove: Could not remove the semaphore=" << semID << endl;	//err_sys("can't IPC_RMID");
		cerr << "Semaphore:remove: errno=" << errno << " ";
		switch (errno) {
		case EACCES:
			cerr <<
			    "The calling process has no access permissions needed to execute cmd.";
			break;
		case EFAULT:
			cerr <<
			    "The address pointed to by arg.buf or arg.array is not accessible";
			break;
		case EIDRM:
			cerr << "The semaphore set was removed.";
			break;
		case EINVAL:
			cerr << "Invalid value for cmd or semid.";
			break;
		case EPERM:
			cerr <<
			    "The  argument  cmd has value IPC_SET or IPC_RMID but the calling process has";
			cerr <<
			    " insufficient privileges to execute the command.";
			break;
		case ERANGE:
			cerr <<
			    "The argument cmd has value SETALL or SETVAL and the value to which semval has to";
			cerr <<
			    " be  set  (for  some semaphore of the set) is less than 0 or greater than the ";
			cerr << " implementation value SEMVMX.";
			break;
		default:
			cerr << "Unknown errno";
			break;
		}
		cerr << endl;
	}
	//cerr << "Semaphore::remove: removed semaphore=" << semID << endl;
}

/*! 
Close a semaphore.
Unlike the remove function above, this function is for a process
to call before it exits, when it is done with the semaphore.
We "decrement" the counter of processes using the semaphore, and
if this was the last one, we can remove the semaphore.
*/
void Semaphore::close(void)
{

	if (semID == -1)
		return;

	static int count = 1;

	//cout << "Semaphore::close: Closing semaphore=" << semID << " count=" << count << endl;
	count++;

	// The following semop() first gets a lock on the semaphore, then increments [1] - the process counter.
	//if(semop(semID,&op_close[0],3) < 0) {
	int retcode;
	while ((retcode = semop(semID, &op_close[0], 3)) < 0 && errno == EINTR);	// try again
	if (retcode < 0) {
		// I should throw exception here.
		cerr << "Semaphore::close: Cannot semop semaphore=" << semID << endl;	//err_sys("can't semop");
		return;
	}
	/*
	   Now that we have a lock, read the value of the procces
	   counter to see if this is the last reference to the semaphore.
	   There is a race condition here - see the comments in create().
	 */
	semctl_arg.val = 0;
	int semval;
	if ((semval = semctl(semID, 1, GETVAL, semctl_arg)) < 0) {
		// I should throw exception here.
		cerr << "Semaphore::close: Cannot GETVAL for semaphore=" << semID << endl;	//err_sys("can't GETVAL");
		return;
	}
	if (semval > BIGCOUNT) {
		// I should throw exception here.
		cerr << "Semaphore::close: sem[1] > BIGCOUNT=" << BIGCOUNT << endl;	// err_dump("sem[1] > BIGCOUNT");
		return;
	} else if (semval == BIGCOUNT)
		remove();
	else {
		//if(semop(semID,&op_unlock[0],1) < 0) {
		while ((retcode = semop(semID, &op_unlock[0], 1)) < 0 && errno == EINTR);	// try again
		if (retcode < 0) {
			// I should throw exception here.
			cerr << "Semaphore::close: Cannot unlock semaphore=" << semID << endl;	// err_sys("can't unlock"); 
			return;
		}
	}
}

/*!
General semaphore operation. Increment or decrement by user-specified
amount (positive or negative; amount can't be zero).
*/
void Semaphore::operation(int value)
{
	if ((op_op[0].sem_op = value) == 0) {
		// I should throw exception here.
		cerr <<
		    "Semaphore::operation: Cannot have value=0 for semaphore operations."
		    << endl;
		exit(1);
	}
	int retcode;
	while ((retcode = semop(semID, &op_op[0], 1) < 0) && errno == EINTR);	// try again
	if (retcode < 0) {
		// I should throw exception here.
		cerr << "Semaphore::operation: semop error for semaphore="
		    << semID << " value=" << value << endl;
		exit(1);
	}
}
