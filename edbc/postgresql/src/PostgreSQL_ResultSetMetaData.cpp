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

//#include<string.h>
#include"PostgreSQL_ResultSetMetaData.hpp"
//#include"SQLTypes.hpp"
#include"SQLException.hpp"

using namespace std;

// default constructor
PostgreSQL_ResultSetMetaData::PostgreSQL_ResultSetMetaData()
:  columnCount(-1), rowCount(-1)
{
#ifdef DEBUG
	cout <<
	    "Constructor : Constructing a PostgreSQL_ResultSetMetaData object:"
	    << this << endl;
#endif
	pg_conn = NULL;
	result = NULL;
}

// destructor
PostgreSQL_ResultSetMetaData::~PostgreSQL_ResultSetMetaData()
{
#ifdef DEBUG
	cout <<
	    "PostgreSQL_ResultSetMetaData::Destructor: destructing a PostgreSQL_ResultSetMetaData object: "
	    << this << endl;
#endif
}

int PostgreSQL_ResultSetMetaData::getColumnCount(void)
{
	return columnCount;
}

/*
* Gets column's suggested title for use in printouts and displays.
*/
string PostgreSQL_ResultSetMetaData::getColumnLabel(int columnIndex)
{
	if (columnIndex < 0 || columnIndex >= columnCount) {
		throw
		    SQLException
		    ("PostgreSQL_ResultSetMetaData::getColumnLabel: column index is out of range!");
	}
	char *p = PQfname(result, columnIndex);
	if (p == NULL) {
		throw
		    SQLException(string
				 ("PostgreSQL_ResultSetMetaData::getColumnLabel: Error occured while calling PQfname:!")
				 + string(PQresultErrorMessage(result)));
	}
	return string(p);
}

/*
* Get column's name.
*/
string PostgreSQL_ResultSetMetaData::getColumnName(int columnIndex)
{
	return getColumnLabel(columnIndex);	// for now call getColumnLabel
}

int PostgreSQL_ResultSetMetaData::getColumnIndex(string columnName)
{
	return PQfnumber(result, columnName.c_str());	// columnIndex=0,1,2...n-1
}

int PostgreSQL_ResultSetMetaData::getColumnType(int columnIndex)
{
	return 0;
}

string PostgreSQL_ResultSetMetaData::getColumnTypeName(int columnIndex)
{
	return string("not implemented yet");
}

long int PostgreSQL_ResultSetMetaData::getRowCount(void)
{
	return rowCount;
}

string PostgreSQL_ResultSetMetaData::getSchemaName(int columnIndex)
{
	return "";
}

string PostgreSQL_ResultSetMetaData::getTableName(int columnIndex)
{
	Oid oid = PQftable(result, columnIndex);
	cout << "PostgreSQL_ResultSetMetaData:getTableName: column oid=" <<
	    oid << endl;
	// then query the pg_class table to find out the columns table name
	return string("not implemented yet");
}

void PostgreSQL_ResultSetMetaData::setColumnCount(int count)
{
	columnCount = count;
}

void PostgreSQL_ResultSetMetaData::setRowCount(int count)
{
	rowCount = count;
}

void PostgreSQL_ResultSetMetaData::setPGconn(PGconn * pg_conn)
{
	this->pg_conn = pg_conn;
}

void PostgreSQL_ResultSetMetaData::setPGresult(PGresult * result)
{
	this->result = result;
}
