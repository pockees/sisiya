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

#include<iostream>
#include"Connection.hpp"
#include"Statement.hpp"
#include"ResultSet.hpp"
#include"ResultSetMetaData.hpp"
#include"DriverManager.hpp"
#include"SQLException.hpp"

class B {
	public:
	virtual void f()=0;
};


class A : public B {
	public:
	void f() { throw SQLException("class exception"); }
};

void f2()
{
	throw SQLException("exception thrown from f2");
}

void f1()
{
	f2();
}
void f0()
{
	f1();
}

int main(void)
{	
	int i,j;
	const int max=2;
	Connection *conn[max];
	DatabaseMetaData *dmd[max];
	Statement *stmt[max];
	ResultSet *rs[max];
	ResultSetMetaData *rsmd[max];
	bool autoCommit;

	char* sql;
	char str[1024];

	// loads all drivers from the driver dir specified by the environment variable EDB_DRIVERS_DIR
	// or /usr/lib/edb
	DriverManager dm; 	
	// connect_str=edbc:dbtype://server/dbname[:port]
	// dbtype=mysql, postgresql
	cout << "Connecting ..." << endl;
	conn[0]=dm.getConnection("edbc:postgresql://localhost/template1","postgres","post123654");
	conn[1]=dm.getConnection("edbc:mysql://localhost/mysql","mysql","mysql123654");

//	B *a1=new A; try{ a1->f(); f1();} catch(SQLException &e) { cout << "caught SQLException message=" << e.getMessage() << endl; return 0;}
	
	// check
	for(i=0;i<max;i++) {
		stmt[i]=NULL;
		dmd[i]=NULL;
		rs[i]=NULL;
		rsmd[i]=NULL;
		if(conn[i] == NULL) {
			cerr << "Could not connect" << endl;
			return 1;
		}
	}
		
	for(i=0;i<max;i++) {
		stmt[i]=conn[i]->createStatement();
		dmd[i]=stmt[i]->getConnection()->getMetaData();//dmd[i]=conn[i]->getMetaData();

		cout << "Database major version    	= " << dmd[i]->getDatabaseMajorVersion() << endl;
		cout << "Database minor version    	= " << dmd[i]->getDatabaseMinorVersion() << endl;
		cout << "Database sub   version    	= " << dmd[i]->getDatabaseSubVersion() << endl;
		cout << "Database product name     	= " << dmd[i]->getDatabaseProductName() << endl;
		cout << "Database product version	= " << dmd[i]->getDatabaseProductVersion() << endl;
		
		autoCommit=conn[i]->getAutoCommit();
		cout << "Auto commit 			= " << autoCommit << endl;
		if(autoCommit == false) {
			cout << "Auto commit is false. Setting to true ..." << endl;
			conn[i]->setAutoCommit(true);	
			autoCommit=conn[i]->getAutoCommit();
			cout << "Now auto commit is		= " << autoCommit << endl;
		}
		sql="create  table test_table(id int,d double precision,str char(32),str2 char(16))";
		cout << "Executing Query :[" << sql << "]" << endl;
		try {
			stmt[i]->executeUpdate(sql);
		}
		catch(SQLException &e) {
			cout << "Query execution FAILED" << endl;
			cout << "SQLException : " << e.getMessage() << endl;
			return 1;
		}
		catch(...) {
			cout << "...Query execution FAILED" << endl;
			return 1;
		}
		
		cout << "Query execution OK" << endl;
		for(j=0;j<10;j++) {
			sprintf(str,"insert into test_table (id,d,str) values(%d,%lf,'This is the %d th row')",j+1,2.3*j,j+1);
			cout << "Executing Query :[" << str << "]" << endl;
			if(stmt[i]->executeUpdate(str) != 1) {
				cout << "Query execution FAILED: Insert must produce exactly 1" << endl;
			}
		}
		sql="select * from test_table";
		cout << "Executing Query :[" << sql << "]" << endl;

		if(rs[i]=stmt[i]->executeQuery(sql)) {
			cout << "Query execution OK" << endl;
			rsmd[i]=rs[i]->getResultSetMetaData();
			cout << "Column count 	= " << rsmd[i]->getColumnCount() << endl;
			cout << "Row count 	= " << rsmd[i]->getRowCount() << endl;
			rs[i]->beforeFirst(); 
			while(rs[i]->next()) {
//				for(int k=0;k<rsmd[i]->getColumnCount();k++) {
//					if(
//				}
				cout << "id=" << rs[i]->getInt(1) << " d=" << rs[i]->getDouble(2) << " str=[" << rs[i]->getString(3) << "]" << endl; 
			}
		}
		else {
			cout << "Query execution FAILED" << endl;
		}
		sql="drop table test_table";
		cout << "Executing Query :[" << sql << "]" << endl;
		if(stmt[i]->executeUpdate(sql) != 0) 
			cout << "Query execution FAILED" << endl;
		else 	
			cout << "Query execution OK" << endl;

	}
	for(i=0;i<max;i++) {
		delete conn[i];
		delete dmd[i];
		delete stmt[i];
		delete rs[i];
		delete rsmd[i];
	}

	return 0;
}
