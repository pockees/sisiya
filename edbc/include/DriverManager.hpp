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

#ifndef _DriverManager_header_
#define _DriverManager_header_

#include<iostream>
#include"Connection.hpp"

// The environment variable which defines where the edbc database libraries are.
const static char *const ENV_DRIVERS="EDBC_DRIVERS_DIR";

// Defines a function that has three string params and returns a Connection* object as result.
typedef Connection* maker_t(std::string,std::string,std::string);

//! DriverManager class.
class DriverManager {
	public:
		//! Default constructor.
		DriverManager();
		//! Destructor.
		~DriverManager();
		//! Attempts to make a database connection to the given URL.
		/*!
		The driver should return "null" if it realizes it is the wrong kind of driver to connect
		to the given URL. The driver manager passes the URL to each loaded driver in turn.

		\param url a string of the form edbc:dbtype://server/dbname:port
		\param user user name used to connect to the database system.
		\param password the user's password.
		\return a Connection object that represents a connection to the URL.
		\throw Throws an SQLException on error.
		*/
		Connection *getConnection(string url,string user,string password); 
	private:
		//! We do not have copy constructor.
		DriverManager(const DriverManager &);
		//! We do not have assignment operator.
		void operator=(const DriverManager&);
		//! The path name, where the edbc drivers are.
		string driversDir;
		//! The number of loaded drivers.
		int driverCount; 
		//! An array to store dl handles
		void *makers[32];
		//! Function which loads the drivers.
		bool loadDrivers(void);
};

#endif 
