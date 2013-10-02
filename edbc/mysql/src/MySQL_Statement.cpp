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
#include<string>
#include<sstream>
#include"MySQL_Statement.hpp"
#include"SQLException.hpp"

using namespace std;

// default constructor
MySQL_Statement::MySQL_Statement() 
: updateCount(-1)
{ 
#ifdef DEBUG
	cout << "MySQL_Statement::Constructor : Constructing a MySQL Statement object :" << this << endl; 
#endif
	conn=NULL;
	result=NULL;
	rset=new MySQL_ResultSet;
	rsmd=new MySQL_ResultSetMetaData;
}

// destructor
MySQL_Statement::~MySQL_Statement() 
{ 
#ifdef DEBUG
	cout << "MySQL_Statement::Destructor : destructing a MySQL Statement object :" << this << endl; 
#endif
}

void MySQL_Statement::setConnection(MySQL_Connection *conn)
{
	this->conn=conn;
}

Connection* MySQL_Statement::getConnection()
{
	return conn;
}

ResultSet* MySQL_Statement::getResultSet()
{
	rset->setConnection(conn);
	rset->setMYSQL(mysql);
	rset->setMYSQL_RES(result);
	rset->setResultSetMetaData(rsmd);
	rset->setStatement(this);

	return rset;
}

int MySQL_Statement::getUpdateCount(void)
{
	return updateCount;
}

void MySQL_Statement::setMYSQL(MYSQL* mysql)
{
	this->mysql=mysql;
}
/*!
\param sql any SQL statement
\return true if the result is a ResultSet object; false if it is an update count or there are no results
\throw SQLException
*/
bool MySQL_Statement::execute(const string sql)
{
	updateCount=-1; // reset to the default value, this is needed if someone uses the same Statement multiple times
#ifdef DEBUG
	cout << "MySQL_Statement::execute: Executing query :[" << sql << "]" << endl;
#endif
	if(mysql_query(mysql,sql.c_str())) {
		throw SQLException(string("MySQL_Statement::execute: Error occured during executing of the query :[")+sql+string("]")+string("\nMySQL_Statement:execute: MySQL Error: ")+string(mysql_error(mysql)),mysql_sqlstate(mysql),mysql_errno(mysql));
		//return false; 
	}
	else {
		result=mysql_store_result(mysql); // this will get all data from the server, this cause memory problems
		if(result) { // there are rows
			rsmd->setColumnCount(mysql_num_fields(result));
			rsmd->setRowCount(mysql_num_rows(result));
			rsmd->setMYSQL_FIELDS(mysql_fetch_fields(result));
#ifdef DEBUG
			cout << "MySQL_Statement::execute: column count=" << rsmd->getColumnCount() << endl;
			cout << "MySQL_Statement::execute: row count=" << rsmd->getRowCount() << endl;
			return true;
#endif
		}
		else { // mysql_store_result returned nothing, should it have ?
			if(mysql_field_count(mysql) == 0) {
				// query does not return data
				updateCount=mysql_affected_rows(mysql);
#ifdef DEBUG
				cout << "MySQL_Statement::execute: updateCount=" << updateCount << endl;
#endif
				return false; // this OK, the query does not have ResultSet object
			}
			else { // mysq_store_result should have returned data
				throw SQLException(string("MySQL_Statement::execute: Error for the query :[")+sql+string("]")+string(mysql_error(mysql)));
				//return false;

			}
		}
	}
	return true;
}

ResultSet *MySQL_Statement::executeQuery(const string sql)
{
	if(!execute(sql)) {
		throw SQLException(string("MySQL_Statement::executeQuery: Error executing the query=[")+sql+string("]"));
		//return NULL;
	}
	return getResultSet();
}

/*!
\return either the row count for INSERT, UPDATE  or DELETE statements, or 0 for SQL statements that return nothing
\throw SQLException
*/
int MySQL_Statement::executeUpdate(const string sql)
{
	if(execute(sql)) {
		throw SQLException(string("MySQL_Statement::executeUpdate: Error executing the query=[")+sql+string("]"));
		//return -1;
	}
	if(updateCount == -1)
		return 0;
	return updateCount;
}
