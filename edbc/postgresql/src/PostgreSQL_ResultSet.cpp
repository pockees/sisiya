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

#include"PostgreSQL_ResultSet.hpp"
#include"SQLException.hpp"
#include<sstream>
#include<stdlib.h>
#include<string.h>

using namespace std;

// default constructor
PostgreSQL_ResultSet::PostgreSQL_ResultSet()
:  currentRow(-1)
{
#ifdef DEBUG
	cout << "Constructor : Constructing a PostgreSQL_ResultSet object:"
	    << this << endl;
#endif
	stmt = NULL;
	pg_conn = NULL;
	result = NULL;
	rsmd = NULL;
}

// destructor
PostgreSQL_ResultSet::~PostgreSQL_ResultSet()
{
#ifdef DEBUG
	cout <<
	    "PostgreSQL_ResultSet::Destructor: destructing a PostgreSQL_ResultSet object: "
	    << this << endl;
#endif
	PQclear(result);
#ifdef DEBUG
	cout <<
	    "PostgreSQL_ResultSet::Destructor: destructing a PostgreSQL_ResultSet object: "
	    << this << " OK" << endl;
#endif
}

void PostgreSQL_ResultSet::beforeFirst(void)
{
	currentRow = -1;
}

int PostgreSQL_ResultSet::findColumn(const string columnName)
{
	return PQfnumber(result, columnName.c_str());	// columnIndex=0,1,2...n-1
}


bool PostgreSQL_ResultSet::first(void)
{
	currentRow = 0;
	return true;
}

bool PostgreSQL_ResultSet::getBoolean(const string columnName)
{
	return getBoolean(findColumn(columnName.c_str()));	// getXXX functions use columnIndex=0,1,2,3...n-1
}

bool PostgreSQL_ResultSet::getBoolean(int columnIndex)
{
	if (columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getBoolean: columnIndex="
		    << columnIndex << " > columnCount=" << rsmd->
		    getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	if (PQftype(result, columnIndex) !=
	    PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Boolean) {
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getBoolean: columnIndex="
		    << columnIndex << " is not of boolean type!" << ends;
		throw SQLException(osstr.str());
	}
	string s = PQgetvalue(result, currentRow, columnIndex);
	if (s.at(0) == 't')
		return true;
	else
		return false;
}

double PostgreSQL_ResultSet::getDouble(const string columnName)
{
	return getDouble(findColumn(columnName));
}

double PostgreSQL_ResultSet::getDouble(int columnIndex)
{
	if (columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getDouble: columnIndex=" <<
		    columnIndex << " > columnCount=" << rsmd->
		    getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	switch (PQftype(result, columnIndex)) {
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Double:
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Float:
		return atof(PQgetvalue(result, currentRow, columnIndex));
		break;
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Int:
//              case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_LongInt :
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_ShortInt:
		return 1.0 *
		    atoi(PQgetvalue(result, currentRow, columnIndex));
		break;
	default:
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getDouble: columnIndex=" <<
		    columnIndex <<
		    " is not double or it cannot be coverted into double!"
		    << ends;
		throw SQLException(osstr.str());
		//break;
	}
}

float PostgreSQL_ResultSet::getFloat(const string columnName)
{
	return getFloat(findColumn(columnName));
}

float PostgreSQL_ResultSet::getFloat(int columnIndex)
{
	if (columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getFloat: columnIndex=" <<
		    columnIndex << " > columnCount=" << rsmd->
		    getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	switch (PQftype(result, columnIndex)) {
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Double:
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Float:
		return (float)
		    atof(PQgetvalue(result, currentRow, columnIndex));
		break;
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Int:
//              case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_LongInt :
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_ShortInt:
		return (float) 1.0
		    *atoi(PQgetvalue(result, currentRow, columnIndex));
		break;
	default:
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getDouble: columnIndex=" <<
		    columnIndex <<
		    " is not double or it cannot be coverted into float!"
		    << ends;
		throw SQLException(osstr.str());
		//break;
	}
}

int PostgreSQL_ResultSet::getInt(const string columnName)
{
	return getInt(findColumn(columnName));
}

int PostgreSQL_ResultSet::getInt(int columnIndex)
{
	if (columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getInt: columnIndex=" <<
		    columnIndex << " > columnCount=" << rsmd->
		    getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	switch (PQftype(result, columnIndex)) {
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Double:
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Float:
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Int:
//              case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_LongInt :
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_ShortInt:
		return atoi(PQgetvalue(result, currentRow, columnIndex));
		break;
	default:
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getDouble: columnIndex=" <<
		    columnIndex <<
		    " is not double or it cannot be coverted into int!" <<
		    ends;
		throw SQLException(osstr.str());
		//break;
	}
}

long int PostgreSQL_ResultSet::getLong(const string columnName)
{
	return getLong(findColumn(columnName));
}

long int PostgreSQL_ResultSet::getLong(int columnIndex)
{
	if (columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getLong: columnIndex=" <<
		    columnIndex << " > columnCount=" << rsmd->
		    getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	switch (PQftype(result, columnIndex)) {
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Double:
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Float:
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Int:
//              case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_LongInt :
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_ShortInt:
		return atol(PQgetvalue(result, currentRow, columnIndex));
		break;
	default:
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getDouble: columnIndex=" <<
		    columnIndex <<
		    " is not double or it cannot be coverted into long!" <<
		    ends;
		throw SQLException(osstr.str());
		//break;
	}
}

short int PostgreSQL_ResultSet::getShort(const string columnName)
{
	return getShort(findColumn(columnName));
}

short int PostgreSQL_ResultSet::getShort(int columnIndex)
{
	if (columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getShort: columnIndex=" <<
		    columnIndex << " > columnCount=" << rsmd->
		    getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	switch (PQftype(result, columnIndex)) {
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Double:
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Float:
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_Int:
//              case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_LongInt :
	case PostgreSQL_ResultSetMetaData::PostgreSQL_Type_ShortInt:
		return (short int)
		    atoi(PQgetvalue(result, currentRow, columnIndex));
		break;
	default:
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getDouble: columnIndex=" <<
		    columnIndex <<
		    " is not double or it cannot be coverted into short!"
		    << ends;
		throw SQLException(osstr.str());
		//break;
	}

}

ResultSetMetaData *PostgreSQL_ResultSet::getResultSetMetaData(void)
{
	return rsmd;
}

long int PostgreSQL_ResultSet::getRow(void)
{
	return currentRow;
}

Statement *PostgreSQL_ResultSet::getStatement(void)
{
	return stmt;
}

bool PostgreSQL_ResultSet::next(void)
{
	currentRow++;
	if (currentRow >= rsmd->getRowCount())
		return false;
	return true;
}

void PostgreSQL_ResultSet::setConnection(Connection * conn)
{
	this->conn = conn;
}

void PostgreSQL_ResultSet::setPGconn(PGconn * pg_conn)
{
	this->pg_conn = pg_conn;
}

void PostgreSQL_ResultSet::setPGresult(PGresult * result)
{
	this->result = result;
}

void PostgreSQL_ResultSet::
setResultSetMetaData(PostgreSQL_ResultSetMetaData * rsmd)
{
	this->rsmd = rsmd;
}

void PostgreSQL_ResultSet::setStatement(PostgreSQL_Statement * stmt)
{
	this->stmt = stmt;
}


string PostgreSQL_ResultSet::getString(const string columnName)
{
	return getString(findColumn(columnName));
}

string PostgreSQL_ResultSet::getString(int columnIndex)
{
	if (columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "PostgreSQL_ResultSet::getString: columnIndex=" <<
		    columnIndex << " > columnCount=" << rsmd->
		    getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	return string(PQgetvalue(result, currentRow, columnIndex));
}
