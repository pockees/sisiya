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

#ifndef _SisIYAServer_header_
#define _SisIYAServer_header_

using namespace std;

class SisIYAServer {
	private:
		//! Default constructor.
		SisIYAServer() {};
		//! Copy constructor.
		SisIYAServer(SisIYAServer &src) {};
		
		void appendToLog(const string m);

		bool checkServiceID(int serviceID);
		//bool checkStatusID(int statusID);
		bool extractMessageFields(const string m,int *serviceID,int *statusID,long *expire,string &msg,string &msgdata);
		string extractXMLField(const string &s,const string &tag);
		bool getNotOkMessage(int systemID,string &error_warning);
		int getIntValue(string &sql);
		int getSystemID(string hostName);
		bool getSystemUpdateChangeTimes(int systemID,string &updateTime,string &changeTime);
		void getTimestamp(string &str);
		bool insertMessage(int systemID,int serviceID,int statusID,long int expire,const string &sendTimestamp,const string &msg,const string &msgdata);
		bool processSisIYAMessages(const string m);
		bool processSystemMessages(const string &sendTimestamp,const string &m);
		bool updateSystemStatus(int systemID);
	private:
		
		//! The process ID of the child server.
		pid_t childPID;
		//! Connection object which must be already connected to the database.
		Connection *conn;
		//! Log level.
		int loglevel;
		//! Read timeout value for reading from the socket.
		int readTimeout;
		//! Semaphore used for locking.
		Semaphore *sem;
		//! Connected socket.
		int sfd;
	public:
		//! The status ids
		static const int MESSAGE_INFO=1;
		static const int MESSAGE_OK=2;
		static const int MESSAGE_WARNING=4;
		static const int MESSAGE_ERROR=8;
		static const int MESSAGE_NOREPORT=16;
		static const int MESSAGE_UNAVAILABLE=32;
		static const int MESSAGE_ALL=1023;

		//! The max string buffer
		static const int MAX_STR=4096;

	public:
		//! Constructor with params.
		SisIYAServer(Connection *connection,int connsocket,int readTimeout,Semaphore *sem,int log_level);
		//! Destructor.
		~SisIYAServer();
		//! Process client messages.
		bool process(void);
};
#endif
