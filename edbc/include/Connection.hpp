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

#ifndef _Connection_header_
#define _Connection_header_

#include<iostream>
#include"Statement.hpp"
#include"DatabaseMetaData.hpp"

class Statement; // forward class decleration

using namespace std;

//! Connection class.
/*! 
This class is the interface (an abstract class) used to create a connection to the database system. 
By default a Connection object is in auto-commit mode, which means that it automatically commits 
changes after executing each statement. If auto-commit mode has been disabled, the method commit
must be called explicitly in order to commit changes; otherwise, database changes will not be saved.	
*/
class Connection {
	public:
		//! A constant indicating that transactions are not supported. 
		const static int TRANSACTION_NONE=0;
		//! A constant indicating that dirty reads, non-repeatable reads and phantom reads can occur.
		/*!
		This level allows a row changed by one transaction to be read by another transaction before 
		any changes in that row have been committed (a "dirty read"). If any of the changes are rolled 
		back, the second transaction will have retrieved an invalid row.
		*/
		const static int TRANSACTION_READ_UNCOMMITTED=1;
		//! A constant indicating that dirty reads are prevented; non-repeatable reads and phantom reads can occur. 
		/*!
		This level only prohibits a transaction from reading a row with uncommitted changes in it.
		*/
		const static int TRANSACTION_READ_COMMITTED=2;
		//! A constant indicating that dirty reads and non-repeatable reads are prevented; phantom reads can occur.
		/*!
		This level prohibits a transaction from reading a row with uncommitted changes in it, and it also
		prohibits the situation where one transaction reads a row, a second transaction alters the row, and the
		first transaction rereads the row, getting different values the second time (a "non-repeatable read").
		*/
		const static int TRANSACTION_REPEATABLE_READ=4;
		//! A constant indicating that dirty reads, non-repeatable reads and phantom reads are prevented.
		/*!
		This level includes the prohibitions in TRANSACTION_REPEATABLE_READ and further prohibits the
		situation where one transaction reads all rows that satisfy a WHERE condition, a second transaction
		inserts a row that satisfies that WHERE condition, and the first transaction rereads for the same
		condition, retrieving the additional "phantom" row in the second read.
		*/
		const static int TRANSACTION_SERIALIZABLE=8;

	public:
		//! Default constructor.
		Connection() {};
		//! Constructor.
		Connection(const string url,const string user,const string password,const unsigned int port);
		//! Destructor
		virtual ~Connection()
#ifdef DEBUG
		 { std::cout << "Connection::Destructor: destructing a Connection object: " << this << std::endl; }
#else
{};
#endif
		//! Close the connection to the database system.
		virtual void close(void)=0;
		//! Makes all changes made since the previous commit/rollback permanent.
		/*!
		This method should be used only when auto-commit mode has been disabled.
		\throw SQLException is thrown if a database access error occurs or this Connection
		object is in auto-commit mode.
		\sa rollback() setAutoCommit()
		*/
		virtual void commit(void)=0;
		//! Creates a Statement object.
		/*!
		\return a pointer to a new default Statement object.
		\throw SQLException is thrown if a database access error occurs.
		*/
		virtual Statement *createStatement(void)=0;
		//! Retrieves the current auto-commit mode for this Connection  object.
		/*!
		\return the current state of this Connection object's auto-commit mode.
		\throw SQLException is thrown if a database access error occurs.
		\sa setAutoCommit()
		*/
		virtual bool getAutoCommit(void)=0;
		//! Retrieves a DatabaseMetaData object that contains metadata about the database to which this Connection object represents a connection.
		/*!
		\return a DatabaseMetaData object for this Connection object.
		\sa setAutoCommit()
		*/
		virtual DatabaseMetaData *getMetaData(void)=0;
		//! Retrieves this Connection object's current transaction isolation level.
		/*!
		\return the current transaction isolation level, which will be one of the following constants: 
		Connection::TRANSACTION_READ_UNCOMMITTED, Connection::TRANSACTION_READ_COMMITTED,
		Connection::TRANSACTION_REPEATABLE_READ, Connection::TRANSACTION_SERIALIZABLE,
		or Connection::TRANSACTION_NONE. Connection::TRANSACTION_NONE is returned when the
		connection in auto-commit mode is and the getTransactionIsolation() function is called.
		*/
		virtual int getTransactionIsolation(void)=0;
		//! Undoes all changes made in the current transaction.
		/*!
		This method should be used only when auto-commit has been disabled.
		\throw SQLException is thrown if a database access error occurs, or this Connection object 
		is currently in auto-commit mode.
		\sa commit() setAutoCommit()
		*/
		virtual void rollback(void)=0;
		//! Sets this connection's auto-commit mode to the given state.
		/*!
		Sets this connection's auto-commit mode to the given state. If a connection is
		in auto-commit mode, then all its SQL statements will be executed and committed
		as individual transactions. Otherwise, its SQL statements are grouped into transactions
		that are terminated by a call to either the method commit or the method rollback.
		By default, new connections are in auto-commit mode.

		The commit occurs when the statement completes or the next execute occurs, whichever
		comes first. In the case of statements returning a ResultSet object, the statement
		completes when the last row of the ResultSet object has been retrieved or the ResultSet
		object has been closed. In advanced cases, a single statement may return multiple results
		as well as output parameter values. In these cases, the commit occurs when all results
		and output parameter values have been retrieved.

		\note If this method is called during a transaction, the transaction is committed. 
		\param autoCommit - true to enable auto-commit mode; false to disable it.
		\throw SQLException is thrown if a database access error occurs.
		\sa commit(), setAutoCommit()
		*/
		virtual void setAutoCommit(const bool autoCommit)=0;
		//! Attempts to change the transaction isolation level for this Connection object to the one given.
		/*!
		The constants defined in the interface Connection  are the possible transaction isolation levels.
		\note If this method is called during a transaction, the result is implementation-defined.
		\param level - one of the following Connection constants: Connection::TRANSACTION_READ_UNCOMMITTED,
		Connection::TRANSACTION_READ_COMMITTED, Connection::TRANSACTION_REPEATABLE_READ, or
		Connection::TRANSACTION_SERIALIZABLE. (Note that Connection.TRANSACTION_NONE cannot be used
		because it specifies that transactions are not supported.) 
		\throw SQLException is thrown if a database access error occurs or the given parameter is not
		one of the Connection constants.
		*/
		virtual void setTransactionIsolation(int level)=0;
};
#endif 
