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
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
*/

#ifndef _SystemsConfFile_header_
#define _SystemsConfFile_header_

#include<iostream>
#include<fstream>
#include<vector>

using namespace std;

class systemItem {
      public:
	string systemName;
	string method;
	unsigned long int checkInterval;
	unsigned long int messageSendInterval;
};

/*!
SystemsConfFile is a class which represents a systems configuration file. Every line contains system name,heartbeat method
name, check interval in seconds and message send interval in minutes.
*/
class SystemsConfFile {
      public:
	//! Default constructor
	SystemsConfFile();
	//! Constructor
	SystemsConfFile(const char *fileName);
	//! Constructor
	 SystemsConfFile(const string fileName);
	//! Destructor
	~SystemsConfFile();
	//! Retuns the number of systems
	int getCount(void) {
		return count;
	}
	//! Retuns check interval
	    unsigned long int getCheckInterval(const int index);
	//! Retuns message send interval
	unsigned long int getMessageSendInterval(const int index);
	//! Retuns method name for the specified index
	const string getMethod(const int index);
	//! Retuns system name for the specified index
	const string getSystemName(const int index);
	bool setFileName(const char *fileName);
      private:
	void extractKeyValue(const char *str, string & key,
			     string & value);
	void extractKeyValues(void);
	string getKeyValue(const string key);
	bool isLineCommentOrEmpty(const char *line, const char ch);
      private:
	ifstream * file;
	int count;

	// to make the compiler happy
	//! We do not have copy constructor
	SystemsConfFile(const SystemsConfFile &);
	//! We do not have assignment operator
	void operator=(const SystemsConfFile &);
};

#endif
