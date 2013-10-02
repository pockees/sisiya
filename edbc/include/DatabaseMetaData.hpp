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

#ifndef _DatabaseMetaData_header_
#define _DatabaseMetaData_header_

#include<iostream>
#include<string>

using namespace std;

//! DatabaseMetaData class.
/*!
Comprehensive information about the database as a whole.
*/
class DatabaseMetaData {
	public:
		//! Default constructor.
		DatabaseMetaData()
#ifdef DEBUG
 { std::cout << "DatabaseMetaData::Constructor : Constructing a DatabaseMetaData object: " << this << std::endl; }
#else
{};
#endif
		//! Destructor
		virtual ~DatabaseMetaData()
#ifdef DEBUG
 { std::cout << "DatabaseMetaData::Destructor: destructing a DatabaseMetaData object: " << this << std::endl; }
#else
{};
#endif
		//! Retrieves the database's major version number.
		virtual const int getDatabaseMajorVersion(void)=0;
		//! Retrieves the database's minor version number.
		virtual const int getDatabaseMinorVersion(void)=0;
		//! Retrieves the database's sub version number.
		virtual const int getDatabaseSubVersion(void)=0;
		//! Retrieves database's product name.
		virtual const string getDatabaseProductName(void)=0;
		//! Retrieves database's product version.
		virtual const string getDatabaseProductVersion(void)=0;
};
#endif 
