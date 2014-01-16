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

#include"MySQL_Connection.hpp"
#include"MySQL_Statement.hpp"
#include"MySQL_DatabaseMetaData.hpp"
#include"SQLException.hpp"
#include<sstream>
//#include<string.h>
//#include<stdlib.h>
#include<ctype.h>		// for isdigit()
#include"parseURL.hpp"


using namespace std;

extern "C" Connection * maker(const string url, const string user,
			      const string password)
{
#ifdef DEBUG
	cout << "maker(MySQL_Connection): creating a MySQL_Connection ..."
	    << endl;
#endif
	string server, dbname, dbtype;
	unsigned int port;

	parseURL(url, server, dbname, dbtype, port);
	if (dbtype == "mysql") {
		MySQL_Connection *c =
		    new MySQL_Connection(server, user, password, dbname,
					 port);
		return c;
	}
	return NULL;
}

/*
extern "C" Connection *maker(const char *url,const char *user,const char *password)
{
#ifdef DEBUG
	cout << "maker(MySQL_Connection): creating a MySQL_Connection ..." << endl;
#endif
	char *server,*dbname,*dbtype;
	unsigned int port;

	size_t length=strlen(url);
	server=new char[length];	
	dbname=new char[length];	
	dbtype=new char[length];	
	parseURL(url,server,dbname,dbtype,port);
	if(strcmp(dbtype,"mysql") == 0) {
		MySQL_Connection *c=new MySQL_Connection(server,user,password,dbname,port); 
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
MySQL_Connection::MySQL_Connection(const string host, const string user,
				   const string password, const string db,
				   const unsigned int port)
:  transactionLevel(TRANSACTION_READ_COMMITTED)
{
	this->host = host;
	this->user = user;
	this->password = password;
	this->db = db;
	this->port = port;

#ifdef DEBUG
	cout << "MySQL_Connection::Constructor(" << host << "," << user <<
	    "," << password << "," << db <<
	    ") : Constructing a Connection object:" << this << endl;
#endif
	db_init();
	connect();
}

/*
// constructor with params
MySQL_Connection::MySQL_Connection(const char *host_str,const char *user_str,const char *password_str,const char *db_str,const unsigned int port) 
: transactionLevel(TRANSACTION_READ_COMMITTED)
{
	//host=new char[strlen(host_str)];
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
	cout << "MySQLConstructor(" << host << "," << user << "," << password << "," << db << ") : Constructing a Connection object:" << this << endl;
#endif
	db_init();
	connect();
}
*/

// destructor
MySQL_Connection::~MySQL_Connection()
{
#ifdef DEBUG
	cout << "Destructor : destructing a MySQL Connection object:" <<
	    this << endl;
#endif
	close();
}

void MySQL_Connection::beginTransaction(void)
{
#ifdef DEBUG
	cout <<
	    "MySQL_Connection:beginTransaction: Rolling back the transaction..."
	    << endl;
#endif

	int code;		// this variable is used for two things : 1) as a mode 2) as a retcode
	if (autoCommit)
		code = 1;
	else
		code = 0;
	if (mysql_autocommit(mysql, code)) {
		ostringstream osstr;
		osstr <<
		    "MySQL_Connection::beginTransaction: could not set autoCommit to "
		    << autoCommit << mysql_error(mysql) << ends;
		throw SQLException(osstr.str());
		return;
	}
	switch (transactionLevel) {
	case TRANSACTION_READ_UNCOMMITTED:
		code =
		    mysql_query(mysql,
				"SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED");
		break;
	case TRANSACTION_READ_COMMITTED:
		code =
		    mysql_query(mysql,
				"SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED");
		break;
	case TRANSACTION_REPEATABLE_READ:
		code =
		    mysql_query(mysql,
				"SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ");
		break;
	case TRANSACTION_SERIALIZABLE:
		code =
		    mysql_query(mysql,
				"SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE");
		break;
	default:		// this must not happen, but I put it anyway.
		code =
		    mysql_query(mysql,
				"SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED");
		break;

	}

	if (code) {
#ifdef DEBUG
		cout <<
		    "MySQL_Connection::beginTransaction: Could not begin a transaction"
		    << endl;
#endif
		throw
		    SQLException(string
				 ("MySQL_Connection::beginTransaction: could not begin transaction : ")
				 + string(mysql_error(mysql)));
		return;
	}
}


void MySQL_Connection::db_init(void)
{
	mysql = new MYSQL;
	if (mysql == NULL) {
		throw
		    SQLException(string
				 ("MySQL_Connection::db_init: Could not allocate memeory for MYSQL structure!"));
		return;
	}
	if (mysql_init(mysql) == NULL) {
		throw
		    SQLException(string
				 ("MySQL_Connection::db_init: Could not initialize a MYSQL structure!"));
		return;
	}
	/*
	   If you want to set MySQL options do it now, before connecting to the server.
	   mysql_options(mysql,MYSQL_OPT_COMPRESS,0);
	 */
	// I should get this value from the DB. Till then:
	autoCommit = true;	// MySQL is per default in auto commit mode
}

bool MySQL_Connection::connect(void)
{
#ifdef DEBUG
	cout << "MySQL_Connection:connect: Connecting to " << user << "/"
	    << db << "@" << host << "..." << endl;
#endif
	if (mysql_real_connect
	    (mysql, host.c_str(), user.c_str(), password.c_str(),
	     db.c_str(), port, NULL, 0) == NULL) {
		throw
		    SQLException(string
				 ("MySQL_Connection::connect: Could not connect to ")
				 + user + string("/") + db + string("@") +
				 host + string(" MySQL Error: ") +
				 string(mysql_error(mysql)));
		// return false;
	}
	return true;
}

/*!
Commits the transaction.
\throw SQLException if a database access error occurs or this Connection object is in auto-commit mode
*/
void MySQL_Connection::close(void)
{
#ifdef DEBUG
	cout << "MySQL_Connection:close: Disconnecting from " << user <<
	    "/" << db << "@" << host << "..." << endl;
#endif
	if (!autoCommit)
		commit();
	mysql_close(mysql);
}

void MySQL_Connection::commit(void)
{
	if (autoCommit)
		throw
		    SQLException(string
				 ("MySQL_Connection::commit: The connection is in auto-commit mode."));

#ifdef DEBUG
	cout << "MySQL_Connection:commit: Commiting the transaction..." <<
	    endl;
#endif

	if (mysql_commit(mysql)) {
		throw
		    SQLException(string
				 ("MySQL_Connection:commit: Could not commit the MySQL transaction.")
				 + string("\nMySQL_Connection:commit: ") +
				 string(mysql_error(mysql)),
				 mysql_sqlstate(mysql),
				 mysql_errno(mysql));
		// return;
	}
	// start another transaction in case the same Connection object is going to be used further.
	beginTransaction();
}

/*!
This method should be used only when auto-commit has been disabled.
\throw SQLException is thrown if a database access error occurs, or this Connection object 
is currently in auto-commit mode.
\sa commit() setAutoCommit()
*/
void MySQL_Connection::rollback(void)
{
#ifdef DEBUG
	cout <<
	    "MySQL_Connection:rollback: Rolling back the transaction..." <<
	    endl;
#endif
	if (autoCommit)
		throw
		    SQLException(string
				 ("MySQL_Connection::rollback: The connection is in auto-commit mode."));
	if (mysql_rollback(mysql)) {
		throw
		    SQLException(string
				 ("MySQL_Connection:rollback: Could not rollback the MySQL transaction.")
				 +
				 string("\nMySQL_Connection:rollback: ") +
				 string(mysql_error(mysql)),
				 mysql_sqlstate(mysql),
				 mysql_errno(mysql));
		//return;
	}
	// start another transaction in case the same Connection object is going to be used further.
	beginTransaction();
}

Statement *MySQL_Connection::createStatement(void)
{
	MySQL_Statement *stmt = new MySQL_Statement;

	stmt->setConnection(this);
	stmt->setMYSQL(mysql);
	return stmt;
}

DatabaseMetaData *MySQL_Connection::getMetaData(void)
{
	MySQL_DatabaseMetaData *dbmd = new MySQL_DatabaseMetaData;

	dbmd->setConnection(this);
	dbmd->setMYSQL(mysql);
	return dbmd;
}

bool MySQL_Connection::getAutoCommit(void)
{
	return autoCommit;
}

int MySQL_Connection::getTransactionIsolation(void)
{
	if (autoCommit)
		return Connection::TRANSACTION_NONE;
	return transactionLevel;
}

// I should throw SQLException here, but first I should develope SQLException s :)
void MySQL_Connection::setAutoCommit(const bool autoCommit)
{
	if (this->autoCommit != autoCommit) {
		if (!this->autoCommit)
			commit();
		this->autoCommit = autoCommit;
		beginTransaction();

#ifdef DEBUG
		cout <<
		    "MySQL_Connection::setAutoCommit: set autoCommit to "
		    << autoCommit << endl;
#endif
	}
}

/*
* If level is valid one, than changes the autoCommit to false.
*/
void MySQL_Connection::setTransactionIsolation(int level)
{
	switch (level) {
	case TRANSACTION_READ_UNCOMMITTED:
	case TRANSACTION_READ_COMMITTED:
	case TRANSACTION_REPEATABLE_READ:
	case TRANSACTION_SERIALIZABLE:
		transactionLevel = level;
		break;
	default:
		ostringstream osstr;
		osstr << "MySQL_Connection::setTransactionLevel: level=" <<
		    level << " is not valid!" << ends;
		throw SQLException(osstr.str());
		//break;
	}

	if (autoCommit) {
		setAutoCommit(false);
	}
}
