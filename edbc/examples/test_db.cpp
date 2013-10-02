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

#include<ostream>
#include"Connection.hpp"
#include"Statement.hpp"
#include"ResultSet.hpp"
#include"ResultSetMetaData.hpp"
#include"DriverManager.hpp"
#include"SQLException.hpp"
#include"parseURL.hpp"

#include<stdlib.h>

const bool debug=false;
//const bool debug=true;
string dbuser,dbpassword,edbc;
string dbtype,server,dbname;
unsigned int port;
DriverManager dm; 	

void doAllTests(void);
void printInfo(void);
char *getDBType(void);
void printTransactionIsolation(int level);
bool testCreateTable(char *sql);
bool testInsertDelete(void);
bool testAutoCommit(void);
bool testCommitRollback(void);
bool testDropTable(char *sql);

void printTransactionIsolation(int level)
{
	switch(level) {
		case Connection::TRANSACTION_READ_UNCOMMITTED : 
			cout << "READ UNCOMMITTED" << endl; 
			break;
		case Connection::TRANSACTION_READ_COMMITTED :
			cout << "READ COMMITTED" << endl; 
			break;
		case Connection::TRANSACTION_REPEATABLE_READ :
			cout << "REPEATABLE READ" << endl; 
			break;
		case Connection::TRANSACTION_SERIALIZABLE :
			cout << "SERIALIZABLE" << endl; 
			break;
		default :
			cout << "UKNOWN" << endl; 
			break;
	}
}

void printInfo(void) 
{
	if(debug)
		cout << "printInfo: Connecting ..." << endl;
	Connection *conn;

	try {
		conn=dm.getConnection(edbc,dbuser,dbpassword);
	}
	catch(SQLException &e) {
		cerr << "printInfo: Error connecting to the DB! Caught SQLException:" << endl;
		cerr << e.getMessage() << endl;
		return;
	}
	if(conn == NULL) {
		cerr << "printInfo: Could not connect" << endl;
		return;
	}
	DatabaseMetaData *dbmd;
	try {
		dbmd=conn->getMetaData(); 
	}
	catch(SQLException &e) {
		cerr << "printInfo: Error getting the DatabaseMetaData ! Caught SQLException:" << endl;
		cerr << e.getMessage() << endl;
		return;
	}

	cout << "printInfo: Database major version    	= " << dbmd->getDatabaseMajorVersion() << endl;
	cout << "printInfo: Database minor version    	= " << dbmd->getDatabaseMinorVersion() << endl;
	cout << "printInfo: Database sub   version    	= " << dbmd->getDatabaseSubVersion() << endl;
	cout << "printInfo: Database product name     	= " << dbmd->getDatabaseProductName() << endl;
	cout << "printInfo: Database product version	= " << dbmd->getDatabaseProductVersion() << endl;
	cout << "printInfo: Auto commit			= " << conn->getAutoCommit() << endl;

	delete conn;
	delete dbmd;
}


bool testCreateTable(char *sql) 
{
	if(debug)
		cout << "testCreateTable: Connecting ..." << endl;
	Connection *conn;
	
	try {
		conn=dm.getConnection(edbc,dbuser,dbpassword);
	}
	catch(SQLException &e) {
		cerr << "testCreateTable: Error connecting to the DB! Caught SQLException:" << endl;
		cerr << e.getMessage() << endl;
		return false;
	}
	if(conn == NULL) {
		if(debug)
			cerr << "testCreateTable: Could not connect" << endl;
		return false;
	}
	
	Statement *stmt;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		cerr << "testCreateTable: Error creating a Statement object! Caught SQLException:" << endl;
		cerr << e.getMessage() << endl;
		return false;
	}
	if(debug)
		cout << "testCreateTable: Executing Query :[" << sql << "]" << endl;
	int retcode;
	try {
		retcode=stmt->executeUpdate(sql);
	}
	catch(SQLException &e) {
		cout << "testCreateTable: Error executing sql=[" << sql << "] Caught SQLException:" << endl;
		cout << e.getMessage() << endl;
		return false;
	}
	if(retcode !=0) {
		if(debug)
			cerr << "testCreateTable: Query executon FAILED" << endl;
		return false;
	}
	if(debug)
		cout << "testCreateTable: Query executon OK" << endl;
	delete conn;
	delete stmt;
	return true;
}

bool testAutoCommit(void)
{
	if(testCreateTable("create table test_auto_commit(id int,str char(128),primary key(id))") == false) {
		if(debug)
			cout << "testAutoCommit: Error creating table : test_auto_commit" << endl;
		return false;
	}

	if(debug)
		cout << "testAutoCommit: Connecting ..." << endl;
	Connection *conn;

	try {
		conn=dm.getConnection(edbc,dbuser,dbpassword);
	}
	catch(SQLException &e) {
		cout << "testAutoCommit: Error connection to DB! Caught SQLException:" << endl;
		cout << e.getMessage() << endl;
		return false;
	}

	if(conn == NULL) {
		if(debug)
			cerr << "testAutoCommit: Could not connect" << endl;
		return false;
	}
	bool autoCommit=conn->getAutoCommit();
	if(debug)
		cout << "testAutoCommit: Auto commit 			= " << autoCommit << endl;
	if(autoCommit == false) {
		if(debug)
			cout << "testAutoCommit: Auto commt is false. Setting to true ..." << endl;
		try {
			conn->setAutoCommit(true);	
		}
		catch(SQLException &e) {
			cout << "testAutoCommit: Error setting auto-commit to true! Caught SQLException:" << endl;
			cout << e.getMessage() << endl;
			return false;
		}
		autoCommit=conn->getAutoCommit();
		if(!autoCommit) {
			if(debug)
				cerr << "testAutoCommit: Could not set auto commit to true!" << endl;
			delete conn;
			return false;
		}
		if(debug)
			cout << "testAutoCommit: Now auto commit is		= " << autoCommit << endl;
	}
	Statement *stmt=conn->createStatement();
	char *sql="insert into test_auto_commit values(1,'test row')";
	if(debug)
		cout << "testAutoCommit: Executing Query :[" << sql << "]" << endl;
	if(stmt->executeUpdate(sql) != 1) {
		if(debug)
			cerr << "testAutoCommit: Query executon FAILED" << endl;
		delete conn;
		delete stmt;
		return false;
	}
	if(debug)
		cout << "testAutoCommit: Query executon OK" << endl;

	delete conn;
	delete stmt;
	// now use another session for testing the inserted row	
	conn=dm.getConnection(edbc,dbuser,dbpassword);

	if(conn == NULL) {
		if(debug)
			cerr << "testAutoCommit: Could not connect" << endl;
		return false;
	}
	stmt=conn->createStatement();
	sql="select * from test_auto_commit";
	if(debug)
		cout << "testAutoCommit: Executing Query :[" << sql << "]" << endl;
	ResultSet *rs;
	try {
		rs=stmt->executeQuery(sql);
	}
	catch(SQLException &e) {
		cout << "testAutoCommit: Caught SQLException :"<< endl;
		cout << "testAutoCommit: reason: "<< e.getMessage() << endl;
		cout << "testAutoCommit: SQL State: "<< e.getSQLState() << endl;
		cout << "testAutoCommit: Vendor error code: "<< e.getErrorCode() << endl;
		if(debug)
			cerr << "testAutoCommit: Query executon FAILED" << endl;
		delete stmt;
		return false;
	}
	if(debug)
		cout << "testAutoCommit: Query executon OK" << endl;
	ResultSetMetaData *rsmd=rs->getResultSetMetaData();
	if(rsmd == NULL) {
		if(debug)
			cerr << "testAutoCommit: Could not get ResultSetMetaData" << endl;
		delete conn;
		delete stmt;
		delete rs;
		return false;
	}
	if(rsmd->getRowCount() != 1) {
		if(debug)
			cerr << "testAutoCommit: The test_auto_commit table must had contained exactly 1 row. row count=" << rsmd->getRowCount() << endl;
		delete conn;
		delete stmt;
		delete rs;
		delete rsmd;
		return false;

	}
	delete conn;
	delete stmt;
	delete rs;
	delete rsmd;

	if(testDropTable("drop table test_auto_commit") == false) {
		if(debug)
			cerr << "testAutoCommit: Error dropping table : test_auto_commit" << endl;
		return false;
	}
	if(debug)
		cout << "testAutoCommit: Droped table : test_auto_commit" << endl;
	return true;
}

bool testCommitRollback(void)
{
	// when using MySQL, use INNODB tables for transactional operations. The default table type in MySQL is 
	// usually MyISAM, and they do not support transactions.
	char *sql;
	if(dbtype == "mysql")
		sql="create table test_commit_rollback(id int,str char(128),primary key(id)) type=INNODB";
	else
		sql="create table test_commit_rollback(id int,str char(128),primary key(id))";

	if(testCreateTable(sql) == false) {
		if(debug)
			cout << "testCommitRollback: Error creating table : test_commit_rollback" << endl;
		return false;
	}

	if(debug)
		cout << "testCommitRollback: Connecting ..." << endl;
	Connection *conn;
	try {
		conn=dm.getConnection(edbc,dbuser,dbpassword);
	}
	catch(SQLException &e) {
		cout << "testCommitRollback: Error connection to DB! Caught SQLException:" << endl;
		cout << e.getMessage() << endl;
		return false;
	}

	if(conn == NULL) {
		if(debug)
			cerr << "testCommitRollback: Could not connect" << endl;
		return false;
	}
	if(debug) {
		cout << "testCommitRollback: Default transaction level is = ";
		printTransactionIsolation(conn->getTransactionIsolation());
	}
	conn->setTransactionIsolation(Connection::TRANSACTION_SERIALIZABLE);
	if(debug) {
		cout << "testCommitRollback: Transaction level is = ";
		printTransactionIsolation(conn->getTransactionIsolation());
	}

	bool autoCommit=conn->getAutoCommit();
	if(debug)
		cout << "testCommitRollback: Auto commit 			= " << autoCommit << endl;
	if(autoCommit == true) {
		if(debug)
			cout << "testCommitRollback: Auto commt is true. Setting to false ..." << endl;
		conn->setAutoCommit(false);	
		autoCommit=conn->getAutoCommit();
		if(autoCommit) {
			if(debug)
				cerr << "testCommitRollback: Could not set auto commit to false!" << endl;
			delete conn;
			return false;
		}
		if(debug)
			cout << "testCommitRollback: Now auto commit is		= " << autoCommit << endl;
	}
	
	Statement *stmt=conn->createStatement();
	sql="insert into test_commit_rollback values(1,'test row')";
	if(debug)
		cout << "testCommitRollback: Executing Query :[" << sql << "]" << endl;
	if(stmt->executeUpdate(sql) != 1) {
		if(debug)
			cerr << "testCommitRollback: Query executon FAILED" << endl;
		delete conn;
		delete stmt;
		return false;
	}
	if(debug)
		cout << "testCommitRollback: Query executon OK" << endl;
	if(debug)
		cout << "testCommitRollback: Now using anothor session to test the inserted row..." << endl;
		
	// now use another session for testing the inserted row	
	Connection *conn2=dm.getConnection(edbc,dbuser,dbpassword);

	if(conn2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Could not connect" << endl;
		delete conn;
		delete stmt;
		return false;
	}
	Statement *stmt2=conn2->createStatement();
	sql="select * from test_commit_rollback";
	if(debug)
		cout << "testCommitRollback: Executing Query :[" << sql << "]" << endl;
	ResultSet *rs2=stmt2->executeQuery(sql);
	if(rs2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Query executon FAILED" << endl;
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		return false;
	}
	if(debug)
		cout << "testCommitRollback: Query executon OK" << endl;
	ResultSetMetaData *rsmd2=rs2->getResultSetMetaData();
	if(rsmd2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Could not get ResultSetMetaData" << endl;
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		delete rs2;
		return false;
	}
	if(rsmd2->getRowCount() != 0) {
		if(debug)
			cerr << "testCommitRollback: The test_commit_rollback table must had contained no rows. row count=" << rsmd2->getRowCount() << endl;
	try {
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		delete rs2;
		delete rsmd2;
	}
	catch(SQLException &e) {
		cout << "testCommitRollback: Error destructing objects! Caught SQLException:" << endl;
		cout << e.getMessage() << endl;
	}
		return false;
	}
	// now commit the inserted value
	if(debug)
		cout << "testCommitRollback: Now commiting..." << endl;
	conn->commit();

	delete conn2;
	delete stmt2;
	delete rs2;
	delete rsmd2;
	// now use another session for testing the inserted row	
	if(debug)
		cout << "testCommitRollback: Now using another session to test the inserted row after commit..." << endl;
	conn2=dm.getConnection(edbc,dbuser,dbpassword);

	if(conn2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Could not connect" << endl;
		delete conn;
		delete stmt;
		return false;
	}
	stmt2=conn2->createStatement();
	sql="select * from test_commit_rollback";
	if(debug)
		cout << "testCommitRollback: Executing Query :[" << sql << "]" << endl;
	rs2=stmt2->executeQuery(sql);
	if(rs2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Query executon FAILED" << endl;
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		return false;
	}
	if(debug)
		cout << "testCommitRollback: Query executon OK" << endl;
	rsmd2=rs2->getResultSetMetaData();
	if(rsmd2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Could not get ResultSetMetaData" << endl;
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		delete rs2;
		return false;
	}
	if(rsmd2->getRowCount() != 1) {
		if(debug)
			cerr << "testCommitRollback: The test_commit_rollback table must had contained one row. row count=" << rsmd2->getRowCount() << endl;
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		delete rs2;
		delete rsmd2;
		return false;
	}

	// now test rollback
	if(debug)
		cout << "testCommitRollback: Now testing rollback..." << endl;
	delete conn2;
	delete stmt2;
	delete rs2;
	delete rsmd2;

	delete stmt;
	stmt=conn->createStatement();
	sql="delete from test_commit_rollback";
	if(debug)
		cout << "testCommitRollback: Executing Query :[" << sql << "]" << endl;
	if(stmt->executeUpdate(sql) != 1) {
		if(debug)
			cerr << "testCommitRollback: Query executon FAILED" << endl;
		delete conn;
		delete stmt;
		return false;
	}
	if(debug)
		cout << "testCommitRollback: Query executon OK" << endl;

	// now use another session for testing the deleted row	
	if(debug)
		cout << "testCommitRollback: Now using another session to test the deleted row..." << endl;
	conn2=dm.getConnection(edbc,dbuser,dbpassword);

	if(conn2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Could not connect" << endl;
		delete conn;
		delete stmt;
		return false;
	}
	stmt2=conn2->createStatement();
	sql="select * from test_commit_rollback";
	if(debug)
		cout << "testCommitRollback: Executing Query :[" << sql << "]" << endl;
	rs2=stmt2->executeQuery(sql);
	if(rs2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Query executon FAILED" << endl;
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		return false;
	}
	if(debug)
		cout << "testCommitRollback: Query executon OK" << endl;
	rsmd2=rs2->getResultSetMetaData();
	if(rsmd2 == NULL) {
		if(debug)
			cerr << "testCommitRollback: Could not get ResultSetMetaData" << endl;
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		delete rs2;
		return false;
	}
	if(rsmd2->getRowCount() != 1) {
		if(debug)
			cerr << "testCommitRollback: The test_commit_rollback table must had contained one row. row count=" << rsmd2->getRowCount() << endl;
		delete conn;
		delete conn2;
		delete stmt;
		delete stmt2;
		delete rs2;
		delete rsmd2;
		return false;
	}
	// now rollback the delete operation
	if(debug)
		cout << "testCommitRollback: Rolling back the deleted row..." << endl;
	conn->rollback();

	delete conn2;
	delete stmt2;
	delete rs2;
	delete rsmd2;
	// now use the same session for testing the rolled back deletion	
	if(debug)
		cout << "testCommitRollback: Now use the same session to test that the rolled back command was successful..." << endl;
	sql="select * from test_commit_rollback";
	if(debug)
		cout << "testCommitRollback: Executing Query :[" << sql << "]" << endl;
	ResultSet *rs=stmt->executeQuery(sql);
	if(rs == NULL) {
		if(debug)
			cerr << "testCommitRollback: Query executon FAILED" << endl;
		delete conn;
		delete stmt;
		return false;
	}
	if(debug)
		cout << "testCommitRollback: Query executon OK" << endl;
	ResultSetMetaData *rsmd=rs->getResultSetMetaData();
	if(rsmd == NULL) {
		if(debug)
			cerr << "testCommitRollback: Could not get ResultSetMetaData" << endl;
		delete conn;
		delete stmt;
		delete rs;
		return false;
	}
	if(rsmd->getRowCount() != 1) {
		if(debug)
			cerr << "testCommitRollback: The test_commit_rollback table must had contained one row. row count=" << rsmd->getRowCount() << endl;
		delete conn;
		delete stmt;
		delete rs;
		delete rsmd;
		return false;
	}

	delete conn;
	delete stmt;
	delete rs;
	delete rsmd;

	if(testDropTable("drop table test_commit_rollback") == false) {
		if(debug)
			cout << "testCommitRollback: Error dropping table : test_autoCommit" << endl;
		return false;
	}

	return true;
}


bool testInsertDelete(void)
{
	char str[1024];
	char *sql="create table test_insert_delete(id int,str char(128),primary key(id))";

	if(testCreateTable(sql) == false) {
		if(debug)
			cout << "testInsertDelete: Error creating table : test_commit_rollback" << endl;
		return false;
	}

	if(debug)
		cout << "testInsertDelete: Connecting ..." << endl;
	Connection *conn=dm.getConnection(edbc,dbuser,dbpassword);

	if(conn == NULL) {
		if(debug)
			cerr << "testInsertDelete: Could not connect" << endl;
		return false;
	}
	
	Statement *stmt=conn->createStatement();
	int nrows=1000;
	cout << " " << nrows << " rows ...";
	cout.flush();
	for(long int j=0;j<nrows;j++) {
		sprintf(str,"insert into test_insert_delete values(%ld,'This is the %ld th row')",j+1,j+1);
		if(stmt->executeUpdate(str) != 1) {
			cerr << "Query executon FAILED: Insert must produce exactly 1" << endl;
			delete conn;
			delete stmt;
			return false;
		}
	}

	if(debug)
		cout << "testInsertDelete: Inserted " << nrows << endl;

	sql="select * from test_insert_delete";
	if(debug)
		cout << "testInsertDelete: Executing Query :[" << sql << "]" << endl;
	ResultSet *rs=stmt->executeQuery(sql);
	if(rs == NULL) {
		if(debug)
			cerr << "testInsertDelete: Query executon FAILED" << endl;
		delete conn;
		delete stmt;
		return false;
	}
	if(debug)
		cout << "testInsertDelete: Query executon OK" << endl;
	ResultSetMetaData *rsmd=rs->getResultSetMetaData();
	if(rsmd == NULL) {
		if(debug)
			cerr << "testInsertDelete: Could not get ResultSetMetaData" << endl;
		delete conn;
		delete stmt;
		delete rs;
		return false;
	}
	if(rsmd->getRowCount() != nrows) {
		if(debug)
			cerr << "testInsertDelete: The test_insert_delete table must had contained " << nrows << " row count=" << rsmd->getRowCount() << endl;
		delete conn;
		delete stmt;
		delete rs;
		delete rsmd;
		return false;
	}

	delete conn;
	delete stmt;
	delete rs;
	delete rsmd;

	if(testDropTable("drop table test_insert_delete") == false) {
		if(debug)
			cout << "testInsertDelete: Error dropping table : test_autoCommit" << endl;
		return false;
	}

	return true;
}

bool testDropTable(char *sql)
{
	if(debug)
		cout << "testDropTable: Connecting ..." << endl;
	Connection *conn;
	
	try {
		conn=dm.getConnection(edbc,dbuser,dbpassword);
	}
	catch(SQLException &e) {
		cout << "testCreateTable: Error connecting to the DB! Caught SQLException:" << endl;
		cout << e.getMessage() << endl;
		return false;
	}

	if(conn == NULL) {
		if(debug)
			cerr << "testDropTable: Could not connect" << endl;
		return false;
	}
	
	Statement *stmt=conn->createStatement();
	if(debug)
		cout << "testDropTable: Executing Query :[" << sql << "]" << endl;
	if(stmt->executeUpdate(sql) != 0) {
		if(debug)
			cerr << "testDropTable: Query executon FAILED" << endl;
		return false;
	}
	if(debug)
		cout << "testDropTable: Query executon OK" << endl;

	delete conn;
	delete stmt;

	return true;
}

void doAllTests(void)
{
	bool allTests=true;

	cout << "Testing create table ...";
	if(testCreateTable("create table test_table(id int,str char(128),primary key(id))")) 
		cout << "OK" << endl;
	else {
		cout << "FAILED" << endl;
		allTests=false;
	}

	cout << "Testing drop table ...";
	if(testDropTable("drop table test_table")) 
		cout << "OK" << endl;
	else {
		cout << "FAILED" << endl;
		allTests=false;
	}

	cout << "Testing auto commit ...";
	if(testAutoCommit()) 
		cout << "OK" << endl;
	else {
		cout << "FAILED" << endl;
		allTests=false;
	}


	cout << "Testing commit/rollback ...";
	if(testCommitRollback()) 
		cout << "OK" << endl;
	else {
		cout << "FAILED" << endl;
		allTests=false;
	}

	cout << "Testing insert/delete data ...";
	cout.flush();
	if(testInsertDelete()) 
		cout << "OK" << endl;
	else {
		cout << "FAILED" << endl;
		allTests=false;
	}

	cout << "All tests ...";
	if(allTests) {
		cout << "OK" << endl;
	}
	else {
		cout << "FAILED" << endl;
		return;
	}
	printInfo();
}

int main(int argc,char *argv[])
{	
	if(argc != 4) {
		cerr << "Usage : " << argv[0] << " edbc:dbtype://server/dbname[:port] dbuser dbpassword" << endl;
		cerr << "dbtype : mysql or postgresql" << endl;
		return 1;
	}

	edbc=argv[1];
	dbuser=argv[2];
	dbpassword=argv[3];

	parseURL(edbc,server,dbname,dbtype,port);

	doAllTests();
	return 0;
}
