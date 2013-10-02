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

#include"PostgreSQL_Connection.hpp"
#include"PostgreSQL_Statement.hpp"
#include"PostgreSQL_DatabaseMetaData.hpp"
#include"SQLException.hpp"
#include<sstream>
//#include<string.h>
//#include<stdlib.h>
#include<ctype.h>	// for isdigit()
#include"parseURL.hpp"

using namespace std;

extern "C" Connection *maker(const string url,const string user,const string password)
{
#ifdef DEBUG
	cout << "maker(PostgreSQL_Connection): creating a PostgreSQL_Connection ..." << endl;
#endif
	string server,dbname,dbtype;
	unsigned int port;

	parseURL(url,server,dbname,dbtype,port);
#ifdef DEBUG
	cout << "maker(PostgreSQL_Connection): dbtype=" << dbtype << endl;
#endif
	if(dbtype == "postgresql") {
#ifdef DEBUG
	cout << "maker(PostgreSQL_Connection): calling PostgreSQL_Connection" << endl;
#endif
		PostgreSQL_Connection *c=new PostgreSQL_Connection(server,user,password,dbname,port); 
		return c;
	}
	return NULL;
}

/*
extern "C" Connection *maker(const char *url,const char *user,const char *password)
{
#ifdef DEBUG
	cout << "maker(PostgreSQL_Connection): creating a PostgreSQL_Connection ..." << endl;
#endif
	char *server,*dbname,*dbtype;
	unsigned int port;

	size_t length=strlen(url);
	server=new char[length];	
	dbname=new char[length];	
	dbtype=new char[length];	
	parseURL(url,server,dbname,dbtype,port);
	if(strcmp(dbtype,"postgresql") == 0) {
		PostgreSQL_Connection *c=new PostgreSQL_Connection(server,user,password,dbname,port); 
		delete server;
		delete dbname;
		delete dbtype;
		return c;
	}
	delete server;
	delete dbname;
	delete dbtype;
	return NULL;
}
*/

// constructor with params
PostgreSQL_Connection::PostgreSQL_Connection(const string host,const string user,const string password,const string db,const unsigned int port) 
: transactionLevel(TRANSACTION_READ_COMMITTED)
{
	this->host=host;
	this->user=user;
	this->password=password;
	this->db=db;
	this->port=port;

#ifdef DEBUG
	cout << "PostgreSQL_Connection::Constructor(" << host << "," << user << "," << password << "," << db << ") : Constructing a Connection object:" << this << endl;
#endif
	db_init();
	connect();
}

/*
PostgreSQL_Connection::PostgreSQL_Connection(const char *host_str,const char *user_str,const char *password_str,const char *db_str,const unsigned int port) 
: transactionLevel(TRANSACTION_READ_COMMITTED)
{
	host=new char[strlen(host_str)];
	strcpy(host,host_str);
	user=new char[strlen(user_str)];
	strcpy(user,user_str);
	password=new char[strlen(password_str)];
	strcpy(password,password_str);
	db=new char[strlen(db_str)];
	strcpy(db,db_str);
	this->port=port;

#ifdef DEBUG
	cout << "PostgreSQL_Connection::Constructor(" << host << "," << user << "," << password << "," << db << ") : Constructing a Connection object:" << this << endl;
#endif
	db_init();
	connect();
}
*/


// destructor
PostgreSQL_Connection::~PostgreSQL_Connection() 
{ 
#ifdef DEBUG
	cout << "PostgreSQL_Connection::Destructor : destructing a PostgreSQL Connection object:" << this << endl; 
#endif
	close();
/*
	delete host;
	delete user;
	delete password;
	delete db;
*/
}

void PostgreSQL_Connection::beginTransaction(void)
{
#ifdef DEBUG
	cout << "PostgreSQL_Connection:beginTransaction: Starting transaction..." << endl;
#endif
	PGresult *result;

	if(PQtransactionStatus(pg_conn) == PQTRANS_INTRANS) {
#ifdef DEBUG
	cout << "PostgreSQL_Connection:beginTransaction:  Already in transaction. Exiting without starting a transaction..." << endl;
#endif
		return;
	}

	result=PQexec(pg_conn,"BEGIN");
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
#ifdef DEBUG
		cout << "PostgreSQL_Connection::beginTransaction: Could not begin a transaction" << endl;
#endif
		/*
		ExecStatusType rstatus=PQresultStatus(result);
		throw SQLException(string("PostgreSQL_Connection::beginTransaction: Could not begin a transaction")+string(PQresStatus(rstatus)));
		*/
		string a("PostgreSQL_Connection::beginTransaction: Could not begin a transaction: ");
		string b(PQresultErrorMessage(result));
		PQclear(result);
		throw SQLException(a+b);
		return;
	}
	PQclear(result);
	// now set the transaction isolation level. PostgreSQL supports only two of four defined levels
	switch(transactionLevel) {	
		case TRANSACTION_READ_UNCOMMITTED : 
		case TRANSACTION_READ_COMMITTED :
			result=PQexec(pg_conn,"SET TRANSACTION ISOLATION LEVEL READ COMMITTED"); 
			break;
		case TRANSACTION_REPEATABLE_READ :
		case TRANSACTION_SERIALIZABLE :
			result=PQexec(pg_conn,"SET TRANSACTION ISOLATION LEVEL SERIALIZABLE"); 
			break;
		default : // this must not happen, but I put it anyway.
			transactionLevel=TRANSACTION_READ_COMMITTED; 
			result=PQexec(pg_conn,"SET TRANSACTION ISOLATION LEVEL READ COMMITTED"); 
			break;
	}

	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
#ifdef DEBUG
		cout << "PostgreSQL_Connection::beginTransaction: Could not set transaction isolation level" << endl;
#endif
		string a("PostgreSQL_Connection::beginTransaction: Could not set transaction isolation level: ");
		string b(PQresultErrorMessage(result));
		PQclear(result);
		throw SQLException(a+b);
		return;
	}
	PQclear(result);
}

void PostgreSQL_Connection::db_init(void)
{
	pg_conn=NULL;
	autoCommit=true; // this is default for PostgreSQL, unless it is explicitely set in .psqlrc file
			 // At the momemnt I do not know how to get this value dinamically.
}

bool PostgreSQL_Connection::connect(void)
{
#ifdef DEBUG
	cout << "PostgreSQL_Connection::connect: Connecting to " << user << "/" << db << "@" << host << "..." << endl;
#endif

	string conninfo;
	if(isdigit(host[0])) 
		conninfo=string("hostaddr=")+host+string(" dbname=")+db+string(" user=")+user+string(" password=")+password;
	else
		conninfo=string("host=")+host+string(" dbname=")+db+string(" user=")+user+string(" password=")+password;
        pg_conn=PQconnectdb(conninfo.c_str());

        if(pg_conn == NULL) { // could not allocate the object
		throw SQLException(string("PostgreSQL_Connection::connect: Could not allocate pg_conn object!"));
		//return false;
	}
	if(PQstatus(pg_conn) == CONNECTION_BAD) {
#ifdef DEBUG
		cerr << "PostgreSQL_Connection::connect: " << PQerrorMessage(pg_conn) << endl;
#endif	
		throw SQLException(string("PostgreSQL_Connection::connect: Could not connect: ")+string(PQerrorMessage(pg_conn)));
		//return false;
	}
	if(!autoCommit)
		beginTransaction();
	return true;
}

/*!
Commits the transaction.
\throw SQLException if a database access error occurs or this Connection object is in auto-commit mode
*/
void PostgreSQL_Connection::close(void)
{
#ifdef DEBUG
	cout << "PostgreSQL_Connection:close: Disconnecting from " << user << "/" << db << "@" << host << "..." << endl;
#endif
	if(!autoCommit) { 
#ifdef DEBUG
	cout << "PostgreSQL_Connection:close: The connection was not in auto-commit mode. Commiting the transaction..." << endl;
#endif
		commit();
	}
	PQfinish(pg_conn);
	pg_conn=NULL;
}

void PostgreSQL_Connection::commit(void)
{
	if(autoCommit) 
		throw SQLException(string("PostgreSQL_Connection::commit: The connection is in auto-commit mode."));

	PGresult *result;
	
#ifdef DEBUG
	cout << "PostgreSQL_Connection:commit: Commiting the transaction..." << endl;
#endif

	if(PQtransactionStatus(pg_conn) != PQTRANS_INTRANS) {
#ifdef DEBUG
		cout << "PostgreSQL_Connection:commit: Not in transaction. Exiting without commit..." << endl;
#endif
		throw SQLException(string("PostgreSQL_Connection:commit: Not in transaction!"));
		//return;
	}
	if(autoCommit) { // this must not happen, but I put this check anyway.
#ifdef DEBUG
		cout << "PostgreSQL_Connection:commit: autoCommit is true! Exiting without commit..." << endl;
#endif
		throw SQLException(string("PostgreSQL_Connection:commit: This connection is in auto commit mode!"));
		//return;
	}

	result=PQexec(pg_conn,"COMMIT");
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
#ifdef DEBUG
		cout << "PostgreSQL_Connection::execute: Could not commit the transaction" << endl;
#endif
		string b(PQresultErrorMessage(result));
		PQclear(result);
		throw SQLException(string("PostgreSQL_Connection::execute: Could not commit the transaction! ")+b);
		//return;
	}
	PQclear(result);

	// start another transaction in case the same Connection object is going to be used further.
	beginTransaction(); 
}

/*!
This method should be used only when auto-commit has been disabled.
\throw SQLException is thrown if a database access error occurs, or this Connection object 
is currently in auto-commit mode.
\sa commit() setAutoCommit()
*/
void PostgreSQL_Connection::rollback(void)
{
#ifdef DEBUG
	cout << "PostgreSQL_Connection:rollback: Rolling back the transaction..." << endl;
#endif
	PGresult *result;

	if(autoCommit)
		throw SQLException(string("PostgreSQL_Connection::rollback: The connection is in auto-commit mode."));
	if(PQtransactionStatus(pg_conn) != PQTRANS_INTRANS) {
		throw SQLException(string("PostgreSQL_Connection::rollback: Not in transaction!"));
		//return;
	}

	if(autoCommit) { 
#ifdef DEBUG
		cout << "PostgreSQL_Connection:rollback: autoCommit is true! Exiting without rolling back..." << endl;
#endif
		throw SQLException(string("PostgreSQL_Connection::rollback: This connection is in auto commit mode!"));
		//return;
	}


	result=PQexec(pg_conn,"ROLLBACK");
	if(result == NULL || PQresultStatus(result) != PGRES_COMMAND_OK) {
#ifdef DEBUG
		cout << "PostgreSQL_Connection::rollback: Could not roll back the transaction" << endl;
#endif
		string b(PQresultErrorMessage(result));
		PQclear(result);
		throw SQLException(string("PostgreSQL_Connection::rollback: Could not roll back the transaction: ")+string(b));
		//return;
	}
	PQclear(result);

	// start another transaction in case the same Connection object is going to be used further.
	beginTransaction(); 
}


Statement *PostgreSQL_Connection::createStatement(void)
{
	PostgreSQL_Statement *stmt=new PostgreSQL_Statement;

	stmt->setConnection(this);
	stmt->setPGconn(pg_conn);
	return stmt;
}

DatabaseMetaData *PostgreSQL_Connection::getMetaData(void)
{
	PostgreSQL_DatabaseMetaData *dbmd=new PostgreSQL_DatabaseMetaData;
	
	dbmd->setConnection(this);
	dbmd->setPGconn(pg_conn);
	return dbmd;
}

bool PostgreSQL_Connection::getAutoCommit(void)
{
	return autoCommit;	
}

int PostgreSQL_Connection::getTransactionIsolation(void)
{
	if(autoCommit)
		return Connection::TRANSACTION_NONE;
	return transactionLevel;
}


// Note: If this method is called during a trasnaction, the transaction is commited.
void PostgreSQL_Connection::setAutoCommit(const bool autoCommit)
{
	if(this->autoCommit != autoCommit) {
		if(!this->autoCommit)
			commit();
		this->autoCommit=autoCommit;
		beginTransaction();
#ifdef DEBUG
		cout << "PostgreSQL_Connection::setAutoCommit: set autoCommit to " << autoCommit << endl;
#endif
	}
}

/*
* If level is valid one, than changes the autoCommit to false.
*/
void PostgreSQL_Connection::setTransactionIsolation(int level)
{
	switch(level) {
		case TRANSACTION_READ_UNCOMMITTED : 
		case TRANSACTION_READ_COMMITTED :
			transactionLevel=TRANSACTION_READ_COMMITTED;
			break;
		case TRANSACTION_REPEATABLE_READ :
		case TRANSACTION_SERIALIZABLE :
			transactionLevel=TRANSACTION_SERIALIZABLE;
			break;
		default :
			ostringstream osstr;
			osstr << "PostgreSQL_Connection::setTransactionLevel: level=" << level << " is not valid!" << ends;
			throw SQLException(osstr.str());
			//return;
			//break;
	}
	if(autoCommit) {
		setAutoCommit(false);
	}
}
