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

#ifndef _PostgreSQL_DatabaseMetaData_header_
#define _PostgreSQL_DatabaseMetaData_header_

#include<iostream>
#include"DatabaseMetaData.hpp"
#include"PostgreSQL_Connection.hpp"

using namespace std;

//! PostgreSQL implementation of the DatabaseMetaData class.
/*!
Comprehensive information about the database as a whole.
*/
class PostgreSQL_DatabaseMetaData: public DatabaseMetaData {
	public:
		//! Default constructor.
		PostgreSQL_DatabaseMetaData();
		//! Destructor.
		virtual ~PostgreSQL_DatabaseMetaData();
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
        public :
		/*
		 I cannot use inline for this two functions, find out why.
		Note: if use inline only in the CPP file it does not give warnings!? But this time I cannot call them
		from PostgreSQL_Connection object.

		inline void setConnection(PostgreSQL_Connection *conn);
		inline void setPGconn(PGconn *pg_conn);
		*/
		//! Sets connection object.
		void setConnection(PostgreSQL_Connection *conn);
		//! Sets PostgreSQL connection object.
		void setPGconn(PGconn *pg_conn);
	private:
		//! Connection object.
		PostgreSQL_Connection *conn;
		//! PostgreSQL connection object.
		PGconn *pg_conn;
		//! major version.
		int majorVersion;
		//! Minor version.
		int minorVersion;
		//! Sub version.
		int subVersion;
		//! PostgreSQL communication protocol version: 2.0 => < 7.4 ; 3.0 => > 7.4
		int protocolVersion;
		//! Database product name (PostgreSQL).
		string dbProductName; 
		//! Database product version (majorVersion.minorVersion.subVersion).
		string dbProductVersion; 

		//! Retrive version information.
		void getVersions(void);
};

#endif 
