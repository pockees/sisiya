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


//#include<pthread.h>
#include<iostream>
#include<string>

using namespace std;

class SisIYAMessage {
      public:
	//! operator <<
	friend ostream & operator<<(ostream & os, SisIYAMessage & p);
	//! operator =
	SisIYAMessage & operator=(const SisIYAMessage & src);
	//! operator ==
	int operator==(const SisIYAMessage & m) const;
	//! operator <
	int operator<(const SisIYAMessage & m) const;

      public:
	//! Default constructor.
	 SisIYAMessage();
	//! Constructor with params.
	 SisIYAMessage(unsigned long int systemID,
		       unsigned long int serviceID,
		       unsigned short int statusID,
		       unsigned long int expire, string sendTimestamp,
		       string recieveTimestamp, string message);
	//! Default destructor.
	~SisIYAMessage();
	//! Copy constructor
	 SisIYAMessage(const SisIYAMessage & src);
	//! Print the SisIYA message.
	void print(ostream * os);
	//! Return system id
	unsigned long int getSystemID(void) {
		return systemID;
	};
	//! Returns serice id.
	unsigned long int getServiceID(void) {
		return serviceID;
	};
	//! Set status id.
	unsigned short int getStatusID(void) {
		return statusID;
	};
	//! returns expire.
	unsigned long int getExpire(void) {
		return expire;
	};
	//! Returns send timestamp.
	string getSendTimestamp(void) {
		return sendTimestamp;
	};
	//! Returns recieve timestamp.
	string getRecieveTimestamp(void) {
		return recieveTimestamp;
	};
	//! Returns message.
	string getMessage(void) {
		return message;
	};

	//! Set system id.
	void setSystemID(int id) {
		systemID = id;
	};
	//! Set serice id.
	void setServiceID(unsigned long int id) {
		serviceID = id;
	};
	//! Set status id.
	void setStatusID(unsigned short int id) {
		statusID = id;
	};
	//! Set expire.
	void setExpire(unsigned long int x) {
		expire = x;
	};
	//! Set send timestamp.
	void setSendTimestamp(const string timestamp) {
		sendTimestamp = timestamp;
	};
	//! Set recieve timestamp.
	void setRecieveTimestamp(const string timestamp) {
		recieveTimestamp = timestamp;
	};
	//! Set message.
	void setMessage(const string str) {
		message = str;
	};
      private:
	//! system id
	unsigned long int systemID;
	//! service id
	unsigned long int serviceID;
	//! status id
	unsigned short int statusID;
	//! expire in minutes
	unsigned long int expire;
	//! message string.
	string message;
	//! Sent timestamp.
	string sendTimestamp;
	//! Recieve timestamp.
	string recieveTimestamp;
};
