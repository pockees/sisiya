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
#include"MySQL_ResultSetMetaData.hpp"
#include"SQLException.hpp"
#include<sstream>

using namespace std;

// default constructor
MySQL_ResultSetMetaData::MySQL_ResultSetMetaData() 
: columnCount(-1),rowCount(-1)
{ 
#ifdef DEBUG
	cout << "Constructor : Constructing a MySQL_ResultSetMetaData object:" << this << endl; 
#endif
	fields=NULL;
	mysql=NULL;
	result=NULL;
}

// destructor
MySQL_ResultSetMetaData::~MySQL_ResultSetMetaData() 
{ 
#ifdef DEBUG
	cout << "MySQL_ResultSetMetaData::Destructor: destructing a MySQL_ResultSetMetaData object: " << this << endl; 
#endif
}

int MySQL_ResultSetMetaData::getColumnCount(void)
{
	return columnCount;
}

/*
* Returns -1 if not found or columnIndex E[0,1,2,...columnCount-1]
*/
int MySQL_ResultSetMetaData::getColumnIndex(string columnName)
{
	for(int i=0;i<columnCount;i++) {
		if(columnName == fields[i].name) // maybe I should convert to upper or lower case before comparing
			return i;
	}
	return -1;
}

string MySQL_ResultSetMetaData::getColumnLabel(int columnIndex)
{
	return getColumnName(columnIndex);
}

string MySQL_ResultSetMetaData::getColumnName(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > columnCount) {
		ostringstream osstr;
		osstr << "MySQL_ResultSetMetaData::getColumnName: columnIndex=" << columnIndex << " is out of range!" << ends;
		throw SQLException(osstr.str());
	}
	return string(fields[columnIndex-1].name);
}

int MySQL_ResultSetMetaData::getColumnType(int columnIndex)
{
	// use SQLType_XXX as a return code
	return fields[columnIndex].type;
}

string MySQL_ResultSetMetaData::getColumnTypeName(int columnIndex)
{
	return string("not implemented yet");
}

long int MySQL_ResultSetMetaData::getRowCount(void)
{
	return rowCount;
}

string MySQL_ResultSetMetaData::getSchemaName(int columnIndex)
{
	return string("not implemented yet");
}

string MySQL_ResultSetMetaData::getTableName(int columnIndex)
{
	if(columnIndex < 0 || columnIndex > columnCount) {
		ostringstream osstr;
		osstr << "MySQL_ResultSetMetaData::getTableName: columnIndex=" << columnIndex << " is out of range!" << ends;
		throw SQLException(osstr.str());
	}
	return string(fields[columnIndex-1].table);
}

void MySQL_ResultSetMetaData::setColumnCount(int count)
{
	columnCount=count;
}

void MySQL_ResultSetMetaData::setRowCount(int count)
{
	rowCount=count;
}

void MySQL_ResultSetMetaData::setMYSQL_FIELDS(MYSQL_FIELD *fields)
{
	this->fields=fields;
}

void MySQL_ResultSetMetaData::setMYSQL(MYSQL *mysql)
{
	this->mysql=mysql;
}

void MySQL_ResultSetMetaData::setMYSQL_RES(MYSQL_RES *result)
{
	this->result=result;
}
