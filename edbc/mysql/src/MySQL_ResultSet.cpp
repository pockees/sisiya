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

#include<stdlib.h>
#include"MySQL_ResultSet.hpp"
#include"SQLException.hpp"
#include<sstream>

using namespace std;

// default constructor
MySQL_ResultSet::MySQL_ResultSet() 
{ 
#ifdef DEBUG
	cout << "Constructor : Constructing a MySQL_ResultSet object:" << this << endl; 
#endif
	mysql=NULL;
	result=NULL;
	rsmd=NULL;
	stmt=NULL;
}

// destructor
MySQL_ResultSet::~MySQL_ResultSet() 
{ 
#ifdef DEBUG
	cout << "MySQL_ResultSet::Destructor: destructing a MySQL_ResultSet object: " << this << endl; 
#endif
	mysql_free_result(result);
}

void MySQL_ResultSet::beforeFirst(void)
{
	currentRow=-1;
}

/*
* Returns -1 if not found or columnIndex E[1,2,...columnCount-1]
*/
int MySQL_ResultSet::findColumn(string columnName)
{
	for(int i=0;i<rsmd->getColumnCount();i++) {
		if(rsmd->getColumnName(i+1) == columnName)  // maybe I should convert to upper or lower case before comparing
			return i+1;
	}
	return -1;
}

bool MySQL_ResultSet::first(void)
{
	currentRow=0;
	mysql_data_seek(result,currentRow); 	// this is possible because I use mysql_store_result in 
						// MySQL_Statement's execute functions
	row=mysql_fetch_row(result);
	if(row) {
#ifdef DEBUG
//		if(mysql_errno(mysql))
			cerr << "MySQL_ResultSet::first: Could not fetch the first row :" << mysql_error(mysql) << endl;
#endif
		return false;
	}
	return true;
}

bool MySQL_ResultSet::getBoolean(const string columnName)
{
	return getBoolean(findColumn(columnName)); // getXXX functions use columnIndex=0,1,2,...n-1
}

bool MySQL_ResultSet::getBoolean(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "MySQL_ResultSet::getBoolean: columnIndex=" << columnIndex << " > columnCount=" << rsmd->getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	// consider trying to convert
	if(rsmd->getColumnType(columnIndex) != FIELD_TYPE_TINY) {
		ostringstream osstr;
		osstr << "MySQL_ResultSet::getBoolean: columnIndex=" << columnIndex << " is not boolean" << ends;
		throw SQLException(osstr.str());
	}
	string str(row[columnIndex]);
	if(str.at(0) == '1')
		return true;
	else
		return false;
}


double MySQL_ResultSet::getDouble(const string columnName)
{
	return getDouble(findColumn(columnName));
}

double MySQL_ResultSet::getDouble(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "MySQL_ResultSet::getDouble: columnIndex=" << columnIndex << " > columnCount=" << rsmd->getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	switch(rsmd->getColumnType(columnIndex)) {
		case FIELD_TYPE_FLOAT :
		case FIELD_TYPE_INT24 :
		case FIELD_TYPE_LONG :
		case FIELD_TYPE_LONGLONG :
		case FIELD_TYPE_SHORT :
		case FIELD_TYPE_DOUBLE :
			return atof(row[columnIndex]);
			break;
		default:
			ostringstream osstr;
			osstr << "MySQL_ResultSet::getDouble: columnIndex=" << columnIndex << " is not double or float"  << ends;
			throw SQLException(osstr.str());
			//break;
	}
}

float MySQL_ResultSet::getFloat(const string columnName)
{
	return getFloat(findColumn(columnName));
}

float MySQL_ResultSet::getFloat(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "MySQL_ResultSet::getFloat: columnIndex=" << columnIndex << " > columnCount=" << rsmd->getColumnCount() << ends;
		throw SQLException(osstr.str());
	}
	switch(rsmd->getColumnType(columnIndex)) {
		case FIELD_TYPE_FLOAT :
		case FIELD_TYPE_INT24 :
		case FIELD_TYPE_LONG :
		case FIELD_TYPE_LONGLONG :
		case FIELD_TYPE_SHORT :
		case FIELD_TYPE_DOUBLE :
			return (float)atof(row[columnIndex]);
			break;
		default:
			ostringstream osstr;
			osstr << "MySQL_ResultSet::getFloat: columnIndex=" << columnIndex << " is not double or float"  << ends;
			throw SQLException(osstr.str());
			//break;
	}
}

int MySQL_ResultSet::getInt(const string columnName)
{
	return getInt(findColumn(columnName));
}

int MySQL_ResultSet::getInt(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "MySQL_ResultSet::getInt: columnIndex=" << columnIndex << " > columnCount=" << rsmd->getColumnCount()  << ends;
		throw SQLException(osstr.str());
	}
	switch(rsmd->getColumnType(columnIndex)) {
		case FIELD_TYPE_INT24 :
		case FIELD_TYPE_LONG :
		case FIELD_TYPE_LONGLONG :
		case FIELD_TYPE_SHORT :
			return atoi(row[columnIndex]);
			//break;
		default:
			ostringstream osstr;
			osstr << "MySQL_ResultSet::getInt: columnIndex=" << columnIndex << " is not int"  << ends;
			throw SQLException(osstr.str());
			//break;
	}
}

long int MySQL_ResultSet::getLong(const string columnName)
{
	return getLong(findColumn(columnName));
}

long int MySQL_ResultSet::getLong(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "MySQL_ResultSet::getLong: columnIndex=" << columnIndex << " > columnCount=" << rsmd->getColumnCount()  << ends;
		throw SQLException(osstr.str());
	}
	switch(rsmd->getColumnType(columnIndex)) {
		case FIELD_TYPE_INT24 :
		case FIELD_TYPE_LONG :
		case FIELD_TYPE_LONGLONG :
		case FIELD_TYPE_SHORT :
			return (long int)atoi(row[columnIndex]);
			break;
		default:
			ostringstream osstr;
			osstr << "MySQL_ResultSet::getLong: columnIndex=" << columnIndex << " is not long int"  << ends;
			throw SQLException(osstr.str());
			//break;
	}
}

ResultSetMetaData *MySQL_ResultSet::getResultSetMetaData(void)
{
	return rsmd;
}

long int MySQL_ResultSet::getRow(void)
{
	return currentRow;
}

short int MySQL_ResultSet::getShort(const string columnName)
{
	return getShort(findColumn(columnName));
}

short int MySQL_ResultSet::getShort(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "MySQL_ResultSet::getShort: columnIndex=" << columnIndex << " > columnCount=" << rsmd->getColumnCount()  << ends;
		throw SQLException(osstr.str());
	}
	switch(rsmd->getColumnType(columnIndex)) {
		case FIELD_TYPE_INT24 :
		case FIELD_TYPE_LONG :
		case FIELD_TYPE_LONGLONG :
		case FIELD_TYPE_SHORT :
			return (short int)atoi(row[columnIndex]);
			break;
		default:
			ostringstream osstr;
			osstr << "MySQL_ResultSet::getShort: columnIndex=" << columnIndex << " is not short int"  << ends;
			throw SQLException(osstr.str());
			//break;
	}
}


Statement* MySQL_ResultSet::getStatement(void)
{
	return stmt;
}

string MySQL_ResultSet::getString(const string columnName)
{
	return getString(findColumn(columnName));
}

string MySQL_ResultSet::getString(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > rsmd->getColumnCount()) {
		ostringstream osstr;
		osstr << "MySQL_ResultSet::getString: columnIndex=" << columnIndex << " > columnCount=" << rsmd->getColumnCount()  << endl;
		throw SQLException(osstr.str());
	}
	return string(row[columnIndex]);
}


bool MySQL_ResultSet::next(void)
{
	currentRow++;
	row=mysql_fetch_row(result);
	if(!row) {
		if(mysql_errno(mysql)) {
			ostringstream osstr;
			osstr << "MySQL_ResultSet::next: Could not fetch the first row :" << mysql_error(mysql) << ends;
			throw SQLException(osstr.str());
		}
		return false;
	}
	return true;
}

void MySQL_ResultSet::setConnection(Connection *conn)
{
	this->conn=conn;
}

void MySQL_ResultSet::setResultSetMetaData(MySQL_ResultSetMetaData *rsmd)
{
	this->rsmd=rsmd;
}

void MySQL_ResultSet::setStatement(MySQL_Statement *stmt)
{
	this->stmt=stmt;
}

void MySQL_ResultSet::setMYSQL(MYSQL *mysql)
{
	this->mysql=mysql;
}

void MySQL_ResultSet::setMYSQL_RES(MYSQL_RES *result)
{
	this->result=result;
}
