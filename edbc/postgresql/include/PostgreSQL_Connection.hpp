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

#ifndef _PostgreSQL_Connection_header_
#define _PostgreSQL_Connection_header_

#include<iostream>
#include"Connection.hpp"

#include<libpq-fe.h>
#include<ctype.h>

using namespace std;

//! PostgreSQL implementation of Connection object.
class PostgreSQL_Connection:public Connection {
      public:
	//PostgreSQL_Connection(); // default constructor 
	//PostgreSQL_Connection(const char *host,const char *user,const char *password,const char *db,const unsigned int port=0); 
	//! Constructor with params.
	PostgreSQL_Connection(const string host, const string user,
			      const string password, const string db,
			      const unsigned int port = 0);
	//! Destructor.
	 virtual ~ PostgreSQL_Connection();
	//! Close the connection.
	virtual void close(void);
	//! Commits transaction.
	virtual void commit(void);
	//! Creates a Statement object.
	virtual Statement *createStatement(void);
	//! Returns auto commit value.
	virtual bool getAutoCommit(void);
	//! Returns DatabaseMetaDate object.
	virtual DatabaseMetaData *getMetaData(void);
	//! Returns transaction isolation level.
	virtual int getTransactionIsolation(void);
	//! Rolls back the transaction.
	virtual void rollback(void);
	//! Sets the auto commit value.
	virtual void setAutoCommit(const bool autoCommit);
	//! Sets the transaction isolation level.
	virtual void setTransactionIsolation(int level);
      private:
	//! Auto commit variable.
	 bool autoCommit;
	//! Database server.
	string host;
	//! Database user name.
	string user;
	//! Users's password.
	string password;
	//! Database name.
	string db;
	//! PostgreSQL handle.
	PGconn *pg_conn;
	//! PostgreSQL database port.
	unsigned int port;
	//! Transaction isolation level variable.
	int transactionLevel;

	//! Begins a transaction.
	void beginTransaction(void);
	//! Connects to the database.
	bool connect(void);
	//! Initializes database library.
	void db_init(void);

};

// a function to create a Connection object
//extern "C" Connection *maker(const char *host,const char *user,const char *password,const char *db,const unsigned int port); 
//extern "C" Connection *maker(const char *url,const char *user,const char *password);
extern "C" Connection * maker(const std::string url,
			      const std::string user,
			      const std::string password);


#endif
