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

#ifndef _MySQL_DatabaseMetaData_header_
#define _MySQL_DatabaseMetaData_header_

#include<iostream>
#include"DatabaseMetaData.hpp"
#include"MySQL_Connection.hpp"

using namespace std;

//! MySQL implementation of the DatabaseMetaData class.
/*!
Comprehensive information about the database as a whole.
*/

class MySQL_DatabaseMetaData:public DatabaseMetaData {
      public:
	//! Default constructor.
	MySQL_DatabaseMetaData();
	//! Destructor.
	virtual ~ MySQL_DatabaseMetaData();
	//! Retrieves the database's major version number.
	virtual inline const int getDatabaseMajorVersion(void);
	//! Retrieves the database's minor version number.
	virtual inline const int getDatabaseMinorVersion(void);
	//! Retrieves the database's sub version number.
	virtual inline const int getDatabaseSubVersion(void);
	//! Retrieves database's product name.
	virtual inline const string getDatabaseProductName(void);
	//! Retrieves database's product version.
	virtual inline const string getDatabaseProductVersion(void);
	// This public does not belong to the general class
	 public:
	    //! Sets connection object.
	void setConnection(MySQL_Connection * conn);
	//! Sets MySQL connection object.
	void setMYSQL(MYSQL * mysql);
      private:
	//! Connection object.
	 MySQL_Connection * conn;
	//! MySQL connection object.
	MYSQL *mysql;
	//! major version.
	int majorVersion;
	//! Minor version.
	int minorVersion;
	//! Sub version.
	int subVersion;
	//! MyQL communication protocol version.
	int protocolVersion;
	//! Database product name (MySQL).
	string dbProductName;
	//! Database product version (majorVersion.minorVersion.subVersion).
	string dbProductVersion;

	//! Retrive version information.
	void getVersions(void);

};

#endif
