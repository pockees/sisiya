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

#include<string>
#include<sstream>
#include<list>
#include"MySQL_DatabaseMetaData.hpp"
#include"SQLException.hpp"
#include"stringtok.hpp"
/*
#include<string.h>
#include<stdlib.h> 
*/

using namespace std;

// default constructor
MySQL_DatabaseMetaData::MySQL_DatabaseMetaData()
:  
majorVersion(-1), minorVersion(-1), subVersion(-1), dbProductName("MySQL")
{
#ifdef DEBUG
	cout <<
	    "Constructor : Constructing a MySQL_DatabaseMetaData object:"
	    << this << endl;
#endif
}

// destructor
MySQL_DatabaseMetaData::~MySQL_DatabaseMetaData()
{
#ifdef DEBUG
	cout <<
	    "MySQL_DatabaseMetaData::Destructor: destructing a MySQL_DatabaseMetaData object: "
	    << this << endl;
#endif
}

inline const int MySQL_DatabaseMetaData::getDatabaseMajorVersion(void)
{
	if (majorVersion == -1)
		getVersions();
	return majorVersion;
}

inline const int MySQL_DatabaseMetaData::getDatabaseMinorVersion(void)
{
	if (majorVersion == -1)
		getVersions();
	return minorVersion;
}

inline const int MySQL_DatabaseMetaData::getDatabaseSubVersion(void)
{
	if (subVersion == -1)
		getVersions();
	return subVersion;
}

void MySQL_DatabaseMetaData::getVersions(void)
{
	unsigned long mysql_version;
//      char str[32];

	/*
	   major_version*10000 + minor_version *100 + sub_version
	   For example, 4.1.2 is returned as 40102.
	 */
	mysql_version = mysql_get_server_version(mysql);
	majorVersion = mysql_version / 10000;
	mysql_version -= majorVersion * 10000;
	minorVersion = mysql_version / 100;
	subVersion = mysql_version - 100 * minorVersion;

/*
	sprintf(str,"%d.%d.%d",majorVersion,minorVersion,subVersion);
	dbProductVersion=new char[strlen(str)];
	strcpy(dbProductVersion,str);
*/
	ostringstream osstr;
	osstr << majorVersion << "." << minorVersion << "." << subVersion
	    << ends;
	dbProductVersion = osstr.str();

#ifdef DEBUG
	// XYYZZ
	unsigned int mysql_client_version = mysql_get_client_version();
	int clientMajorVersion = mysql_client_version / 10000;
	mysql_client_version -= clientMajorVersion * 10000;
	int clientMinorVersion = mysql_client_version / 100;
	int clientSubVersion =
	    mysql_client_version - 100 * clientMinorVersion;

	cout << "MySQL_DatabaseMetaData::getVersions: Host info :[" <<
	    mysql_get_host_info(mysql) << "]" << endl;
	cout << "MySQL_DatabaseMetaData::getVersions: Protocol info :[" <<
	    mysql_get_proto_info(mysql) << "]" << endl;
	cout << "MySQL_DatabaseMetaData::getVersions: Server info :[" <<
	    mysql_get_server_info(mysql) << "]" << endl;
	cout << "MySQL_DatabaseMetaData::getVersions: Client info :[" <<
	    mysql_get_client_info() << "]" << endl;
	cout << "MySQL_DatabaseMetaData::getVersions: Client version :[" <<
	    clientMajorVersion << "." << clientMinorVersion << "." <<
	    clientSubVersion << "]" << endl;
#endif
}

inline const string MySQL_DatabaseMetaData::getDatabaseProductName(void)
{
	if (majorVersion == -1)
		getVersions();
	return dbProductName;
}

inline const string MySQL_DatabaseMetaData::getDatabaseProductVersion(void)
{
	if (majorVersion == -1)
		getVersions();
	return dbProductVersion;
}

void MySQL_DatabaseMetaData::setConnection(MySQL_Connection * conn)
{
	this->conn = conn;
}

void MySQL_DatabaseMetaData::setMYSQL(MYSQL * mysql)
{
	this->mysql = mysql;
}
