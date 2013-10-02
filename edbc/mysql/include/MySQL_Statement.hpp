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

#ifndef _MySQL_Statement_header_
#define _MySQL_Statement_header_

#include<iostream>
#include<mysql/mysql.h>
#include<mysql/errmsg.h>

#include"Statement.hpp"
#include"MySQL_Connection.hpp"
#include"MySQL_ResultSet.hpp"
#include"MySQL_ResultSetMetaData.hpp"

class MySQL_ResultSet; // forward class declaration

//! MySQL implementation of the Statement class.
class MySQL_Statement : public Statement {
	public:
		//! Default constructor.
		MySQL_Statement();
		//! Destructor.
		virtual ~MySQL_Statement();
		//! Executes the statement.
		virtual bool execute(const string sql);
		//! Executes query.
		virtual ResultSet *executeQuery(const string sql);
		//! Executes insert/update/delete
		virtual int executeUpdate(const string sql);
		//! Returns the connection object. 
		virtual Connection *getConnection(void);
		//! Returns result set object.
		virtual ResultSet *getResultSet(void);
		//! Returns update count.
		virtual int getUpdateCount(void);

	// This public does not belong to the general class 
	public :
		//! Sets Connection object. This function is only used by MySQL Connection class.
		void setConnection(MySQL_Connection *conn);
		//! Sets ResultSetMetaData object. This function is only used by MySQL Statement class.
		void setResultSetMetaData(MySQL_ResultSetMetaData *rsmd);
		//! Sets MySQL object. This function is only used by MySQL Connection class.
		void setMYSQL(MYSQL* mysql);
	private:
		//! Update count variable.
		int updateCount;
		//! Pointer to MySQL object.
		MYSQL *mysql; 
		//! Pointer to MySQL result object.
		MYSQL_RES *result;
		//! Connection object.
		MySQL_Connection *conn;
		//! ResultSet object.
		MySQL_ResultSet *rset;
		//! ResultSetMetaData object.
		MySQL_ResultSetMetaData *rsmd;
};

#endif 
