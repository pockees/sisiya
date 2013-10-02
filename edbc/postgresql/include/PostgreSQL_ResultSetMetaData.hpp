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

#ifndef _PostgreSQL_ResultSetMetaData_header_
#define _PostgreSQL_ResultSetMetaData_header_

#include<iostream>

#include<libpq-fe.h>

#include"ResultSetMetaData.hpp"

using namespace std;

//! PostgreSQL implementation of the ResultSetMetaData class.
class PostgreSQL_ResultSetMetaData: public ResultSetMetaData {
	public:
		//! PostgreSQL boolean type code.
		const static unsigned int PostgreSQL_Type_Boolean=16;
		//! PostgreSQL char type code.
		const static unsigned int PostgreSQL_Type_Char=1042;
		//! PostgreSQL double type code.
		const static unsigned int PostgreSQL_Type_Double=701;
		//! PostgreSQL float type code.
		const static unsigned int PostgreSQL_Type_Float=700;
		//! PostgreSQL int type code.
		const static unsigned int PostgreSQL_Type_Int=23;
		//! PostgreSQL date type code.
		const static unsigned int PostgreSQL_Type_Date=1082;
	//	const static unsigned int PostgreSQL_Type_LongInt=23; // find if there is real long int
		//! PostgreSQL short int type code.
		const static unsigned int PostgreSQL_Type_ShortInt=21;
		//! PostgreSQL string type code.
		const static unsigned int PostgreSQL_Type_String=1042;
		//! PostgreSQL text type code.
		const static unsigned int PostgreSQL_Type_Text=25;
		//! PostgreSQL time type code.
		const static unsigned int PostgreSQL_Type_Time=1083;
		//! PostgreSQL varchar type code.
		const static unsigned int PostgreSQL_Type_Varchar=1043;

		//! Default constructor.
		PostgreSQL_ResultSetMetaData();
		//! Destructor.
		virtual ~PostgreSQL_ResultSetMetaData();
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
		//! Returns column index. This function is only used by the PostgreSQL Statement class.
		int getColumnIndex(string columnName);
		//! Returns column count. This function is only used by the PostgreSQL Statement class.
		void setColumnCount(int count);
		//! Sets PostgreSQL object. This function is only used by the PostgreSQL Statement class.
		void setPGconn(PGconn *pg_conn);
		//! Sets PostgreSQL result object. This function is only used by the PostgreSQL Statement class.
		void setPGresult(PGresult *result);
		//! Sets row count. This function is only used by the PostgreSQL Statement class.
		void setRowCount(int count);
	private:
		//! Column count variable.
		int columnCount; 
		//! Row count variable.
		int rowCount;
		//! Pointer to PostgreSQL object.
		PGconn *pg_conn;
		//! Pointer to PostgreSQL result object.
		PGresult *result;
};

#endif 
