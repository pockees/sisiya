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
#include"PostgreSQL_Statement.hpp"
#include"SQLException.hpp"

using namespace std;

// default constructor
PostgreSQL_Statement::PostgreSQL_Statement() 
: updateCount(-1)
{ 
#ifdef DEBUG
	cout << "PostgreSQL_Statement::Constructor : Constructing a PostgreSQL Statement object :" << this << endl; 
#endif
	pg_conn=NULL;
	conn=NULL;
	result=NULL;
	rset=new PostgreSQL_ResultSet;
	rsmd=new PostgreSQL_ResultSetMetaData;

}

// destructor
PostgreSQL_Statement::~PostgreSQL_Statement() 
{ 
#ifdef DEBUG
	cout << "PostgreSQL_Statement::Destructor : destructing a PostgreSQL Statement object :" << this << endl; 
#endif
}

void PostgreSQL_Statement::setConnection(PostgreSQL_Connection *conn)
{
	this->conn=conn;
#ifdef DEBUG
	cout << "PostgreSQL_Statement::setConnection: conn = " << this->conn << endl;
#endif
}

Connection *PostgreSQL_Statement::getConnection(void)
{
	return conn;
}

ResultSet *PostgreSQL_Statement::getResultSet(void)
{
	rset->setConnection(conn);
	rset->setPGconn(pg_conn);
	rset->setPGresult(result);
	rset->setResultSetMetaData(rsmd);
	rset->setStatement(this);
	
	return rset;
}

int PostgreSQL_Statement::getUpdateCount(void)
{
	return updateCount;
}

void PostgreSQL_Statement::setPGconn(PGconn *pg_conn)
{
	this->pg_conn=pg_conn;
#ifdef DEBUG
	cout << "PostgreSQL_Statement::setPGconn: pg_conn = " << this->pg_conn << endl;
#endif
}

/*
* Return values : true if the first result is a ResultSet object; false if it is an update count or there are no results
*/
bool PostgreSQL_Statement::execute(const string sql)
{
	updateCount=-1; // reset to the default value, this is needed if someone uses the same Statement multiple times

#ifdef DEBUG
	cout << "PostgreSQL_Statement::execute: Executing query :[" << sql << "]" << endl;
	cout << "PostgreSQL_Statement::execute: pg_conn=" << pg_conn << endl;
#endif
	if(pg_conn == NULL) {
		//cerr << "PostgreSQL_Statement::execute: cannot allocate memory for pg_conn" << endl;
		throw SQLException(string("PostgreSQL_Statement::execute: cannot allocate memory for pg_conn"));
		//return false;
	}
/*
	result=PQexec(pg_conn,"BEGIN");
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
		cout << "PostgreSQL_Statement::execute: Could not start a transaction" << endl;
		PQclear(result);
		return false;
		
	}
	cout << "PostgreSQL_Statement::execute: Transaction status is " ;
	switch(PQtransactionStatus(pg_conn)) {
		case PQTRANS_IDLE :
			cout << "currently idle" << endl;
			break;
		case PQTRANS_ACTIVE :
			cout << "a command is in progress" << endl;
			break;
		case PQTRANS_INTRANS :
			cout << "idle, in a valid transaction block" << endl;
			break;
		case PQTRANS_INERROR :
			cout << "idle, in a failed transactional block" << endl;
			break;
		case PQTRANS_UNKNOWN :
			cout << "unknown, the connection is bad!!!" << endl;
			break;
	}
	PQclear(result);
*/


	result=PQexec(pg_conn,sql.c_str());
	if(result == NULL) {
		throw SQLException(string("PostgreSQL_Statement::execute: Error executing query : [")+string(sql)+string("] message=")+string(PQerrorMessage(pg_conn)));
		return false; // here I should throw SQLException
	}
	ExecStatusType resultCode=PQresultStatus(result);
	switch(resultCode) {
		case PGRES_EMPTY_QUERY :
			throw SQLException(string("PostgreSQL_Statement::execute: the query=[")+sql+string("] sent to the database server was empty : ")+string(PQresStatus(resultCode)));
			break;
		case PGRES_COMMAND_OK :
			{	// to make the compiler happy. This is needed in order for the compiler
				// to call the destructors of the variables.
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: query=[" << sql << "] command completed successfuly. No data to be returned : " << PQresStatus(resultCode)  << endl;
#endif
			char *p=PQcmdTuples(result);
			/*
			if(strcmp(p,"") != 0)
				updateCount=atoi(p);
			*/
			string str=p;
			if(str.size() > 0) {
				istringstream isstr(p);
				isstr >> updateCount;
			}
			}
			return false;
			//break;
		case PGRES_TUPLES_OK :
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: query=[" << sql << "] is OK" << endl;
#endif
			rsmd->setColumnCount(PQnfields(result));
			rsmd->setRowCount(PQntuples(result));
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: column count=" << rsmd->getColumnCount() << endl;
			cout << "PostgreSQL_Statement::execute: row count=" << rsmd->getRowCount() << endl;
#endif
			break;
		case PGRES_COPY_OUT :
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: query=[" << sql << "] copy out (from server) data transfer started : " << PQresStatus(resultCode) << endl;
#endif
			break;
		case PGRES_COPY_IN :
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: query=[" << sql << "] copy in (to server) data transfer started : " << PQresStatus(resultCode) << endl;
#endif
			break;
		case PGRES_BAD_RESPONSE :
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: query=[" << sql << "] The server's response was not understood : " << PQresStatus(resultCode) << endl;
#endif
			throw SQLException(string("PostgreSQL_Statement::execute: query=[")+sql+string("] The server's response was not understood : ")+string(PQresStatus(resultCode)));
			break;
		case PGRES_NONFATAL_ERROR :
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: query=[" << sql << "] A non fatal error (a notice or warning) occured : " << PQresStatus(resultCode) << endl;
#endif
			break;
		case PGRES_FATAL_ERROR :
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: query=[" << sql << "] A fatal error occured : " << PQresStatus(resultCode) << endl;
#endif
			throw SQLException(string("PostgreSQL_Statement::execute: query=[")+sql+string("] A fatal error occured : ")+string(PQresStatus(resultCode)));
			break;
		default :
#ifdef DEBUG
			cout << "PostgreSQL_Statement::execute: query=[" << sql << "] Unknown return code" << endl;
#endif
			throw SQLException(string("PostgreSQL_Statement::execute: query=[")+sql+string("] Unknown return code"));
			break;
	}
//	PQclear(result); // I am going to need this result set pointer for later use.
	return true;
}

ResultSet *PostgreSQL_Statement::executeQuery(const string sql)
{
	if(!execute(sql)) {
		cerr << "PostgreSQL_Statement::executeQuery: Error executing the query=[" << sql << "]" << endl;
		return NULL;
	}
	return getResultSet();
}

/*!
\return either the row count for INSERT, UPDATE  or DELETE statements, or 0 for SQL statements that return nothing
\throw SQLException
*/
int PostgreSQL_Statement::executeUpdate(const string sql)
{
	if(execute(sql)) {
		throw SQLException(string("PostgreSQL_Statement::executeUpdate: Error executing the query=[")+sql+string("]"));
		//return -1;
	}
	if(updateCount == -1)
		return 0;
	return updateCount;
}
