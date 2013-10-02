/*
    Copyright (C) 2003  Erdal Mutlu

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

#pragma once

#include<iostream>
#include<fstream> // for ofstream
#include<string>
#include"winsock2.h"
#include<windows.h>
#include<winioctl.h>
#include<pdh.h>
#include"ConfFile.hpp"

//#define DEBUG // define this to log debug infromation to the system event log

class RangeError{};

//! Checks if the line comment or empty is.
bool isLineCommentOrEmpty(const char *line,const char ch);
//! Resolves hostname to an IP address.
int getIP(const char *hostname,char *buffer,int buffer_length);

using namespace std;

/*!
A class to store the SisIYA message, together with status and service IDs.
*/
class CheckInfo {
	public:
		CheckInfo();
		~CheckInfo();
		void add(void);
		int getCount(void);
		int getStatusID(void);
		void setServiceID(const int serviceID);
		void setStatusID(int status);
		void setExpire(long int expire);
		void setMessage(const string Message);
		//! Generate a string, which is suitable for sending to the SisIYA server.
		const string getSisIYAMessage(int index,const string host,char del);
	private :
		int count;	// the total number of elements in the info array
		int current;	// index to keep track of the current index of the info array
		long int expire; // the expire time in minutes for checks
		static const int max=20;
		class DataType {
			public:
				DataType() : statusID(0),serviceID(-1) {};
				int statusID;
				int serviceID;
				string Message;
		};
		DataType *data[max];
};


/*!
SisIYAwinclient is a class which is used to check the system and send messages to the SisIYA server.
*/
class SisIYAwinclient
{
	public:

		//! Default constractor.
		SisIYAwinclient::SisIYAwinclient(string logName,const char *confDir);
		//! Default destractor
		~SisIYAwinclient();
		//! Returns the check_interval.
		long int getCheckInterval(void);
		//! Send all messages to the SisIYA server.
		void sendAll(void);
		//! Only show the messages without actually sending them.
		void showAll(void);
		void SisIYAwinclient::showLogs(void);
	private:
		string getTimeString(void);
		SOCKET mySocket;
		//! The name of this client.
		string hostName; 
		//! The IP of the SisIYA server.
		string serverIP;
		//! The top level directory, where all the other SisIYA configuration files are.
		string confDir;
		//! The class which represents a configuration file. The data in this file is of the form key=value.
		ConfFile sisiyaConf;
		//! The port number of the SisIYA server, to which the messages are going to be sent.
		int port;
		//! The interval for checking
		long int checkInterval;
		//! Checks expire after expire minutes.
		long int expire;
		//! Delimiter which is used to make up the SisIYA message.
		char delimiter;
		//! The three status IDs.
		int statusid_info,statusid_ok,statusid_warning,statusid_error; 
		int error_fs,warning_fs;
		int error_load,warning_load;
		string error_uptime,warning_uptime;
		int error_swap,warning_swap;
		string logName;
		//! The class where the results of the checks are stored.
		CheckInfo info;
		//! Language depended key string for getting uptime info from the registry.
		string uptimeKey;
		//! Language depended key string for getting load info from the registry.
		string loadKey;
	private:
		bool checkProcess(char *name);
		int getCPUCount(void);
		void getCPUInfo(void);
		void getFilesystemInfo(void);
		void getHostName(void);
		void getLoadInfo(void);
		string getOSVersion(void);
		string getPdhStatusMessage(PDH_STATUS status);
		void getProcessesAndThreads(void);
		void getSystemInfo(void);
		void getSwapInfo(void);
		double getUptime(void);
		void setDefaults(void);

		// to make the compiler happy
		SisIYAwinclient(const SisIYAwinclient &) {};	// no copy constructor
		int operator=(const SisIYAwinclient &);		// no assignment operator
};
