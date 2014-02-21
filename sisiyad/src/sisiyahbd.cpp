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

/*
#ifdef HAVE_CONFIG_H
	#include"config.h"
#endif
*/

#include<iostream>
#include<pthread.h>
#include<fstream>
#include<syslog.h>
#include<list>
#include<string>
#include<sstream>

// this is a C++ program
#ifndef __cplusplus
#define __cplusplus
#endif

#include"common.hpp"
/*
 Declare all C function with
	BEGIN_C_DECLS
	C function list
	END_C_DECLS
*/

#include<errno.h>
#include<sys/times.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<sys/stat.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<signal.h>
#include<setjmp.h>

#include<error.h>
#include<string.h>

#include"misc.h"

#include"ConfFile.hpp"
#include"UpperLowerCase.hpp"
#include"trim.hpp"
#include"stringtok.hpp"
#include"stringConvert.hpp"

#include"SisIYAMessage.hpp"

/*
BEGIN_C_DECLS
END_C_DECLS
*/

using namespace std;

//! The name of the configuration file.
char *confFileName;

//! The name of the configuration file for systems.
char *systemsConfFileName;

//! The name of the program.
char *pname;

//! Configuration file object.
ConfFile confFile;

//! Configuration file object for systems.
ConfFile systemsConfFile;

//! The process ID of the server process
pid_t serverPID;

//! loglevel variable, change the code to use confFile.getInt("LOGLEVEL")
int loglevel;

//! The max string buffer
static const int MAX_STR = 4096;

// defined in include/config.h generated by autoconf/automake #define RETSIGTYPE void
//! The proccess ID of the child server
pid_t childPID;


//! A queue of SisIYA messages, This queue is used to collect messages and afterwards to insert them into the DB
list < SisIYAMessage > mqueue;

//! A mutex to protect the queue which contains the SisiIYA messages
pthread_mutex_t mqueueMutex = PTHREAD_MUTEX_INITIALIZER;

//! A condition variable for the queue, which contains the SisIYA messages
pthread_cond_t mqueueCond = PTHREAD_COND_INITIALIZER;


//! The number of active connections to the database system
int ndbconn = 0;

//! A mutex to protect the ndbconn variable
pthread_mutex_t ndbconnMutex = PTHREAD_MUTEX_INITIALIZER;

//! A condition variable for the ndbconn variable
pthread_cond_t ndbconnCond = PTHREAD_COND_INITIALIZER;

// The mutex provides mutual exclusion and the conditional variable provides a signaling mechanism.

/*************************************************************************************/
void clean_and_exit(int code);
void clean_up(void);
int daemon_init(void);
void doit(void);
bool condBroadcast(pthread_cond_t & cond);
bool condSignal(pthread_cond_t & cond);
bool condWait(pthread_cond_t & cond, pthread_mutex_t & mutex);
void getTimestamp(string & str);
bool lockMutex(pthread_mutex_t & mutex);
void sisiya_showconf(void);
void *t_server(void *arg);
bool unlockMutex(pthread_mutex_t & mutex);
bool updateSystemStatus(int systemID);

typedef void Sigfunc(int);	/* for signal handlers */
Sigfunc *esignal(int signo, Sigfunc * func);
/***********************************************************************/

/*************************************************************************************/
Sigfunc *esignal(int signo, Sigfunc * func)
{
	struct sigaction act, oact;

	act.sa_handler = func;
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;
	if (signo == SIGALRM) {
#ifdef  SA_INTERRUPT
		act.sa_flags |= SA_INTERRUPT;	/* SunOS */
#endif
	} else {
#ifdef  SA_RESTART
		act.sa_flags |= SA_RESTART;	/* SVR4, 44BSD */
#endif
	}
	if (sigaction(signo, &act, &oact) < 0)
		return (SIG_ERR);
	return (oact.sa_handler);
}

/*! 
Performs clean up and exits with the specified exit code.
*/
void clean_and_exit(int code)
{
	clean_up();
	if (code != 0)
		syslog(LOG_INFO, "exited with error code=%d", code);
	else
		syslog(LOG_INFO, "exited");

	exit(code);
}

/*! 
Performs clean up.
*/
void clean_up(void)
{
	pid_t pid;

	pid = getpid();
}


/*!
Print the configuration information to syslog.
*/
void sisiya_showconf(void)
{
	syslog(LOG_INFO, "PID_FILE : [%s]",
	       confFile.getString("PID_FILE").c_str());
	syslog(LOG_INFO, "LOGLEVEL : [%d]", confFile.getInt("LOGLEVEL"));
}

/*!
*/
void showConfigs(void)
{
	cout << "PID_FILE		: [" << confFile.
	    getString("PID_FILE") << "]" << endl;
	cout << "LOGLEVEL		: [" << confFile.
	    getInt("LOGLEVEL") << "]" << endl;
}

void setDefaults(void)
{
	confFile.setDefault("MESSAGE_SEND_INTERVAL", 5);
	confFile.setDefault("PID_FILE", "/var/run/sisiyahbd.pid");
	confFile.setDefault("LOGLEVEL", 0);
	confFile.setDefault("CLIENT_CONF",
			    "/opt/sisiya_checks/sisiya_client.conf");
}

/*!
Initialize a daemon process.
*/
int daemon_init(void)
{
	pid_t pid;

	pid = fork();
	if (pid < 0) {
		syslog(LOG_ERR, "could not fork");
		return (-1);
	} else if (pid != 0)
		exit(0);	// the parent exits

	// the 1st child process continues
	pid = setsid();		// become session leader
	if (pid == -1) {
		syslog(LOG_ERR, "cannot set session id");
		exit(1);
	}
	// fork again leaving the child to continue. This is done uarantee that the daemon cannot automatically 
	// acquire a controlling terminal if it opens a terminal device in the future.
	// But before ignore the SIGHUP signal, because when the session leader terminates, all processes in the
	// session are sent the SIGHUP signal.
	if (esignal(SIGHUP, SIG_IGN) == SIG_ERR) {
		syslog(LOG_ERR, "could not set SIGHUP to SIG_IGN.");
		return (-1);
	}
	pid = fork();
	if (pid < 0) {
		syslog(LOG_ERR, "could not fork");
		return (-1);
	} else if (pid != 0)
		exit(0);	// the 1st child continues

	// the 2nd child process continues

	// change working dir to /, so that we do not occupy any mounts
	if (chdir("/") != 0) {
		syslog(LOG_ERR, "cannot change dir to /");
		exit(1);
	}

	umask(0);		// clear our file creation mask, so that any inherited restriction do not apply
	return (0);
};

void doit(void)
{
	/* become a daemon */
	if (daemon_init() == -1) {
		syslog(LOG_ERR, "could initialize the daemon. Exiting...");
		clean_and_exit(EXIT_FAILURE);
	}
	setDefaults();
	if (!confFile.setFileName(confFileName)) {
		syslog(LOG_ERR, "could open file %s", confFileName);
		clean_and_exit(EXIT_FAILURE);
	}
//      systemsConfFile.setFileName(systemsConfFileName);
	// Set the loglevel. For now it is primitive made. Change it later
	loglevel = confFile.getInt("LOGLEVEL");

	serverPID = getpid();

	ofstream pidFile;
	pidFile.open(confFile.getString("PID_FILE").c_str(), ios::out);
	if (pidFile.bad()) {
		syslog(LOG_ERR,
		       "can't open the PID file : %s ! Exiting...",
		       confFile.getString("PID_FILE").c_str());
		clean_and_exit(EXIT_FAILURE);
	}
	pidFile << serverPID;
	pidFile.close();
	syslog(LOG_INFO, "closed PID file %s",
	       confFile.getString("PID_FILE").c_str());

	// read system information

	// create one thread for each host to check
}

void getTimestamp(string & str)
{
	time_t tt;
	struct tm *t;

	time(&tt);
	t = localtime(&tt);

	char buf[15];
	// change this to use ostringstream
	sprintf(buf, "%d%.2d%.2d%.2d%.2d%.2d", 1900 + t->tm_year,
		1 + t->tm_mon, t->tm_mday, t->tm_hour, t->tm_min,
		t->tm_sec);
	str = buf;
};


void *t_server(void *arg)
{
	int retcode;

	pthread_t tid = pthread_self();
	retcode = pthread_detach(tid);
	switch (retcode) {
	case 0:		// OK
		break;
	case ESRCH:
		syslog(LOG_ERR,
		       "no thread could be found with thread ID=%d to detach! Etrror code=%d message=%s",
		       tid, retcode, strerror(retcode));
		return NULL;
		break;
	case EINVAL:
		syslog(LOG_ERR,
		       "thread with ID=%d is already in detached state! Etrror code=%d message=%s",
		       tid, retcode, strerror(retcode));
		return NULL;
		break;
	default:
		syslog(LOG_ERR,
		       "could not detach thread with ID=%d! Etrror code=%d message=%s",
		       tid, retcode, strerror(retcode));
		return NULL;
		break;
	}
	childPID = tid;
	if (loglevel > 2)
		syslog(LOG_INFO, "thread with ID=%d detached itself.",
		       (int) tid);

	if (loglevel > 2)
		syslog(LOG_INFO, "thread with ID=%d started.", (int) tid);


	return NULL;
}

//! Locks the specified mutex. Ruterns true on success, false on error.
bool lockMutex(pthread_mutex_t & mutex)
{
	int retcode = pthread_mutex_lock(&mutex);
	switch (retcode) {
	case 0:
		return true;
		//break;
	case EINVAL:
		syslog(LOG_ERR,
		       "lockMutex: child server(%d) : the mutex is not properly inituialized!",
		       childPID);
		break;
	case EDEADLK:
		syslog(LOG_ERR,
		       "lockMutex: child server(%d) : the mutex is already lock by the calling thread!",
		       childPID);
		break;
	default:
		syslog(LOG_ERR,
		       "lockMutex: child server(%d) : got unknown error code=%d while trying to lock the mutex!",
		       childPID, retcode);
		break;
	}
	return false;
}

//! Unlocks the specified mutex. Ruterns true on success, false on error.
bool unlockMutex(pthread_mutex_t & mutex)
{
	int retcode = pthread_mutex_unlock(&mutex);
	switch (retcode) {
	case 0:
		return true;
		//break;
	case EINVAL:
		syslog(LOG_ERR,
		       "unlockMutex: child server(%d) : the mutex is not properly inituialized",
		       childPID);
		break;
	case EPERM:
		syslog(LOG_ERR,
		       "unlockMutex: child server(%d) : the calling thread does not own this mutex!",
		       childPID);
		break;
	default:
		syslog(LOG_ERR,
		       "unlockMutex: child server(%d) : got unknown error code=%d while trying to unlock the mutex!",
		       childPID, retcode);
		break;
	}
	return false;
}

//! Waits on the cond conditional variable using the mutex. Returns true on success, false on error.
bool condWait(pthread_cond_t & cond, pthread_mutex_t & mutex)
{
	if (pthread_cond_wait(&cond, &mutex) == 0)
		return true;
	// According to the man page this function never returns a error code.
	syslog(LOG_ERR,
	       "condWait: child server(%d) : got unknown error while waiting on the conditional variable!",
	       childPID);
	return false;

}

//! Awakens one of the waiting threads for a conditional variable. Returns true on success, false on error.
bool condSignal(pthread_cond_t & cond)
{
	if (pthread_cond_signal(&cond) == 0)
		return true;
	// According to the man page this function never returns a error code.
	syslog(LOG_ERR,
	       "condSignal: child server(%d) : got unknown error while signalling for the conditional variable!",
	       childPID);
	return false;
}

//! Awakens all waiting threads for a conditional variable. Returns true on success, false on error.
bool condBroadcast(pthread_cond_t & cond)
{
	if (pthread_cond_broadcast(&cond) == 0)
		return true;
	// According to the man page this function never returns a error code.
	syslog(LOG_ERR,
	       "condBroadcast: child server(%d) : got unknown error while broadcasting the conditional variable!",
	       childPID);
	return false;

}

/*!
Main function.
*/
int main(int argc, char *argv[])
{
	if (argc != 3) {
		cerr << "Usage : " << argv[0] <<
		    " sisiyahbd.conf sisiyahbd_systems.conf" << endl;
		return 1;
	}
	openlog("sisiyahbd", LOG_PID, LOG_USER);	/* Open the syslog. Log progname and pid */

	pname = argv[0];
	confFileName = argv[1];
	systemsConfFileName = argv[2];
	doit();
	return 0;
}
