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

#ifndef _PostgreSQL_Statement_header_
#define _PostgreSQL_Statement_header_

#include<iostream>
#include<libpq-fe.h>

#include"Statement.hpp"
#include"PostgreSQL_Connection.hpp"
#include"PostgreSQL_ResultSet.hpp"
#include"PostgreSQL_ResultSetMetaData.hpp"

class PostgreSQL_ResultSet; // forward class declaration

//! PostgreSQL implementation of the Statement class.
class PostgreSQL_Statement : public Statement {
	public:
		//! Default constructor.
		PostgreSQL_Statement();
		//! Destructor.
		virtual ~PostgreSQL_Statement();
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
		//! Sets Connection object. This function is only used by PostgreSQL Connection class.
		void setConnection(PostgreSQL_Connection *conn);
		//! Sets PostgreSQL connection object. This function is only used by PostgreSQL Connection class.
		void setPGconn(PGconn *pg_conn);
	private:
		//! Update count variable (number of affected rows in case of UPDATE, DELETE ...).
		int updateCount;
		//! Pointer to PostgreSQL connection object.
		PGconn *pg_conn; 
		//! Pointer to PostgreSQL result object.
		PGresult *result;
		//! Connection object.
		PostgreSQL_Connection *conn;
		//! ResultSet object.
		PostgreSQL_ResultSet *rset;
		//! ResultSetMetaData object.
		PostgreSQL_ResultSetMetaData *rsmd;
};

#endif 
