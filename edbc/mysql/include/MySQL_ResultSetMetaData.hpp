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

#ifndef _MySQL_ResultSetMetaData_header_
#define _MySQL_ResultSetMetaData_header_

#include<iostream>

#include<mysql/mysql.h>
#include<mysql/errmsg.h>

#include"ResultSetMetaData.hpp"

using namespace std;

//! MySQL implementation of the ResultSetMetaData class.
class MySQL_ResultSetMetaData: public ResultSetMetaData {
	public:
		//! Default constructor.
		MySQL_ResultSetMetaData();
		//! Destructor.
		virtual ~MySQL_ResultSetMetaData();
		//! Returns column count.
		virtual int getColumnCount(void);
		//! Returns column label.
		virtual string getColumnLabel(int columnIndex);
		//! Return column name.
		virtual string getColumnName(int columnIndex);
		//! Returns column type.
		virtual int getColumnType(int columnIndex);
		//! Returns column type name.
		virtual string getColumnTypeName(int columnIndex);
		//! Returns schema name.
		virtual string getSchemaName(int columnIndex);
		//! Returns table name.
		virtual string getTableName(int columnIndex);
		//! Returns row count.
		virtual long int getRowCount(void);

	// This public does not belong to the general class
	public:
		//! Returns column index. This function is only used by the MySQL Statement class.
		int getColumnIndex(string columnName);
		//! Returns column count. This function is only used by the MySQL Statement class.
		void setColumnCount(int count);
		//! Returns MySQL fields. This function is only used by the MySQL Statement class.
		void setMYSQL_FIELDS(MYSQL_FIELD *fields);
		//! Sets MySQL object. This function is only used by the MySQL Statement class.
		void setMYSQL(MYSQL *mysql);
		//! Sets MySQL result object. This function is only used by the MySQL Statement class.
		void setMYSQL_RES(MYSQL_RES *result);
		//! Sets row count. This function is only used by the MySQL Statement class.
		void setRowCount(int count);
	private:
		//! Column count variable.
		int columnCount; 
		//! Row count variable.
		int rowCount;
		//! Pointer to MySQL fields (columns).
		MYSQL_FIELD *fields;
		//! Pointer to MySQL object.
		MYSQL *mysql;
		//! Pointer to MySQL result object.
		MYSQL_RES *result;
};

#endif 
