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
#include"PostgreSQL_DatabaseMetaData.hpp"
#include"SQLException.hpp"
#include"stringtok.hpp"
/*
#include<string.h>
#include<stdlib.h> 
*/

using namespace std;

// default constructor
PostgreSQL_DatabaseMetaData::PostgreSQL_DatabaseMetaData()
:  
majorVersion(-1), minorVersion(-1), subVersion(-1),
dbProductName("PostgreSQL")
{
#ifdef DEBUG
	cout <<
	    "Constructor : Constructing a PostgreSQL_DatabaseMetaData object:"
	    << this << endl;
#endif
}

// destructor
PostgreSQL_DatabaseMetaData::~PostgreSQL_DatabaseMetaData()
{
#ifdef DEBUG
	cout <<
	    "PostgreSQL_DatabaseMetaData::Destructor: destructing a PostgreSQL_DatabaseMetaData object: "
	    << this << endl;
#endif
}

inline const int PostgreSQL_DatabaseMetaData::getDatabaseMajorVersion(void)
{
	if (majorVersion == -1)
		getVersions();
	return majorVersion;
}

inline const int PostgreSQL_DatabaseMetaData::getDatabaseMinorVersion(void)
{
	if (majorVersion == -1)
		getVersions();
	return minorVersion;
}

inline const int PostgreSQL_DatabaseMetaData::getDatabaseSubVersion(void)
{
	if (majorVersion == -1)
		getVersions();
	return subVersion;
}

void PostgreSQL_DatabaseMetaData::getVersions(void)
{
	// to get the server version use : show server_version -> 7.4.6
	PGresult *result;
//      char str[32];

	result = PQexec(pg_conn, "show server_version");
	if (result == NULL) {
		throw
		    SQLException(string
				 ("PostgreSQL_DatabaseMetaData::getVersions: Result from PQexec is NULL! ")
				 + string(PQerrorMessage(pg_conn)));
		return;
	} else if (PQresultStatus(result) != PGRES_TUPLES_OK) {
		string b(PQresultErrorMessage(result));
		PQclear(result);
		throw
		    SQLException(string
				 ("PostgreSQL_DatabaseMetaData::getVersions: Could not get the server version of the PostgreSQL: ")
				 + b);
		return;
	}
	if (PQntuples(result) != 0) {
		char *p = PQgetvalue(result, 0, 0);
/*
		int i;

		i=0;
		while(*p != '\0' && *p != '.') 
			str[i++]=*p++;
		p++;
		str[i]='\0';
		majorVersion=atoi(str);

		i=0;
		while(*p != '\0' && *p != '.') 
			str[i++]=*p++;
		p++;
		str[i]='\0';
		minorVersion=atoi(str);
		subVersion=atoi(p);
*/
/*
		string str=p;
		int pos=str.find('.');
		majorVersion=atoi(str.substr(0,pos).c_str());
		int start=pos+1;
		pos=str.find('.',start);
		minorVersion=atoi(str.substr(start,pos-start).c_str());
		subVersion=atoi(str.substr(pos+1).c_str());
*/
		dbProductVersion = p;
		list < string > ls;
		stringtok(ls, p, ".");
		ostringstream osstr;
		for (list < string >::const_iterator i = ls.begin();
		     i != ls.end(); ++i) {
			osstr << (*i) << " ";
		}
		osstr << ends;
		istringstream isstr(osstr.str());
		isstr >> majorVersion >> minorVersion >> subVersion;
	}
	PQclear(result);
/*
	sprintf(str,"%d.%d.%d",majorVersion,minorVersion,subVersion);
	dbProductVersion=new char[strlen(str)];
	strcpy(dbProductVersion,str);
*/
	protocolVersion = PQprotocolVersion(pg_conn);
#ifdef DEBUG
	cout <<
	    "PostgreSQL_DatabaseMetaData::getVersions: Protocol version :["
	    << protocolVersion << "]" << endl;
#endif
}

inline const string PostgreSQL_DatabaseMetaData::
getDatabaseProductName(void)
{
	return dbProductName;
}

const string PostgreSQL_DatabaseMetaData::getDatabaseProductVersion(void)
{
	return dbProductVersion;
}

//inline void PostgreSQL_DatabaseMetaData::setConnection(PostgreSQL_Connection *conn)
void PostgreSQL_DatabaseMetaData::setConnection(PostgreSQL_Connection *
						conn)
{
	this->conn = conn;
}

//inline void PostgreSQL_DatabaseMetaData::setPGconn(PGconn *pg_conn)
void PostgreSQL_DatabaseMetaData::setPGconn(PGconn * pg_conn)
{
	this->pg_conn = pg_conn;
}
