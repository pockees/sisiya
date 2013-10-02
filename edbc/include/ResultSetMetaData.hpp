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

#ifndef _ResultSetMetaData_header_
#define _ResultSetMetaData_header_

#include<iostream>
//#include"Connection.hpp"
#include"Statement.hpp"

class Statement; // forward class decleration

using namespace std;

//! ResultSetMetaData class.
/*!
An object that can be used to get information about the types and properties of the columns in a ResultSet object.
*/
class ResultSetMetaData {
	public:
		//! Default constructor.
		ResultSetMetaData()
#ifdef DEBUG
{ std::cout << "ResultSetMetaData::Constructor: Constructing a ResultSetMetaData object: " << this << std::endl; }
#else
{};
#endif
		//! Destructor.
		virtual ~ResultSetMetaData()
#ifdef DEBUG
{ std::cout << "ResultSetMetaData::Destructor: destructing a ResultSetMetaData object: " << this << std::endl; }
#else
{};
#endif
		//! Returns column count.
		virtual int getColumnCount(void)=0;
		//! Returns column label.
		virtual string getColumnLabel(int columnIndex)=0;
		//! Return column name.
		virtual string getColumnName(int columnIndex)=0;
		//! Returns column type.
		virtual int getColumnType(int columnIndex)=0;
		//! Returns column type name.
		virtual string getColumnTypeName(int columnIndex)=0;
		//! Returns schema name.
		virtual string getSchemaName(int columnIndex)=0;
		//! Returns table name.
		virtual string getTableName(int columnIndex)=0;
		//! Returns row count.
		virtual long int getRowCount(void)=0;
};

#endif 
