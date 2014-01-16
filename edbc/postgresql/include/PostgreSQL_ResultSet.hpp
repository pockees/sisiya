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

#ifndef _PostgreSQL_ResultSet_header_
#define _PostgreSQL_ResultSet_header_

#include<iostream>

#include<libpq-fe.h>

#include"ResultSet.hpp"
#include"PostgreSQL_ResultSetMetaData.hpp"
#include"PostgreSQL_Statement.hpp"

using namespace std;

class PostgreSQL_Statement;	// forward class decleration

//! PostgreSQL implementation of the ResultSet object.
class PostgreSQL_ResultSet:public ResultSet {
      public:
	//! Default constructor.
	PostgreSQL_ResultSet();
	//! Destructor.
	virtual ~ PostgreSQL_ResultSet();
	//! Moves the cursor to the front of this ResultSet object, just before the first row.
	/*!
	   This method has no effect if the result set contains no rows.
	 */
	virtual void beforeFirst(void);
	//! Maps the given ResultSet column name to its ResultSet column index.
	/*!
	   \param columnName - the name of the column.
	   \return the column index of the specified column name. The column index starts at 0 and goes to columnCount-1
	   \throw SQLException is thrown if the ResultSet object does not contain columnName or a database
	   access error occurs.
	   \sa next()
	 */
	//! Maps the given ResultSet column name to its ResultSet column index.
	/*!
	   \param columnName - the name of the column.
	   \return the column index of the given column name. Column index starts from 0 and goes to columnCount-1.
	   \throw SQLException is thrown if the ResultSet object does not contain columnName or a database access
	   error occurs.
	 */
	virtual int findColumn(const string columnName);
	//! Moves the cursor to the first row in this ResultSet object.
	/*!
	   \return true if the cursor is on a valid row; false if there are no rows in the result set.
	   \throw SQLException is thrown if a database access error occurs.
	 */
	virtual bool first(void);
	//! Retrieves the value of the designated column in the current row of this ResultSet object as a bool.
	/*!
	   \return the column value; if the value is SQL NULL, the value returned is false.
	   \throw SQLException is thrown if a database access error occurs.
	 */
	virtual bool getBoolean(const string columnName);
	//! Returns column value as a boolean.
	virtual bool getBoolean(int columnIndex);
	//! Returns column value as a double.
	virtual double getDouble(const string columnName);
	//! Returns column value as a double.
	virtual double getDouble(int columnIndex);
//              virtual char getChar(const string columnName);
//              virtual char getChar(int columnIndex);
	//! Returns column value as a float.
	virtual float getFloat(const string columnName);
	//! Returns column value as a float.
	virtual float getFloat(int columnIndex);
	//! Returns column value as a int.
	virtual int getInt(const string columnName);
	//! Returns column value as a int.
	virtual int getInt(int columnIndex);
	//! Returns column value as a long.
	virtual long int getLong(const string columnName);
	//! Returns column value as a long.
	virtual long int getLong(int columnIndex);
	//! Returns ResultSetMetaDate object.
	virtual ResultSetMetaData *getResultSetMetaData(void);
	//! Returns current row number. 
	virtual long int getRow(void);
	//! Returns column value as a short.
	virtual short int getShort(const string columnName);
	//! Returns column value as a short.
	virtual short int getShort(int columnIndex);
	//! Returns Statement object.
	virtual Statement *getStatement(void);
	//! Returns column value as a String object.
	virtual string getString(const string columnName);
	//! Returns column value as a String object.
	virtual string getString(int columnIndex);
	//! Position to the next row.
	virtual bool next(void);
	// This public does not belong to the general class and is used only by the PostgreSQL driver classes
      public:
	//! Sets the Connection object. This is only used by PostgreSQL driver classes.
	void setConnection(Connection * conn);
	//! Sets the PostgreSQL connection object. This is only used by PostgreSQL driver classes.
	void setPGconn(PGconn * pg_conn);
	//! Sets PG result object. This is only used by PostgreSQL driver classes.
	void setPGresult(PGresult * result);
	//! Sets ResultSetMetaData object. This is only used by PostgreSQL driver classes.
	void setResultSetMetaData(PostgreSQL_ResultSetMetaData * rsmd);
	//! Sets Statement object. This is only used by PostgreSQL driver classes.
	void setStatement(PostgreSQL_Statement * stmt);
      private:
	//! Connection object variable.
	 Connection * conn;
	//! Holds the current row number.
	long int currentRow;
	//! PostgreSQL connection object handle.
	PGconn *pg_conn;
	//! PostgreSQL result object handle.
	PGresult *result;
	//! ResultSetMetaData object variable.
	PostgreSQL_ResultSetMetaData *rsmd;
	//! Statement object variable.
	Statement *stmt;

	//! Returns column index.
	int getColumnIndex(const string columnName);
};

#endif
