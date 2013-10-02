#include<iostream>

#include<libpq-fe.h>
#include<ctype.h>

using namespace std;
		PGconn *pg_conn;
		bool autoCommit;
		char *host,*user,*password,*db;
		unsigned int port;

void db_init(void)
{
	// I should get this value from the DB. Till then:
	autoCommit=false;
}
void PostgreSQL_Connection(char *host_str,char *user_str,char *password_str,char *db_str,unsigned int port1=5432) 
{
	host=new char[strlen(host_str)];
	strcpy(host,host_str);
	user=new char[strlen(user_str)];
	strcpy(user,user_str);
	password=new char[strlen(password_str)];
	strcpy(password,password_str);
	db=new char[strlen(db_str)];
	strcpy(db,db_str);
	port=port1;
	db_init();
}


bool connect(void)
{
	const int MAX_STR=4096;
        char conninfo[MAX_STR+1];
	
	cout << "connect: Connecting to " << user << "/" << db << "@" << host << "..." << endl;

	if(isdigit(host[0])) {
		if(snprintf(conninfo,MAX_STR,"hostaddr=%s dbname=%s user=%s password=%s",host,db,user,password) == -1 )
			return false;
	}
	else {
		if(snprintf(conninfo,MAX_STR,"host=%s dbname=%s user=%s password=%s",host,db,user,password) == -1 )
			return false;
	}
        pg_conn=PQconnectdb(conninfo);

        if(pg_conn == NULL) // could not allocate the object
		return false;
	cout << "connect: CONNECTION_OK  = " << CONNECTION_OK << endl;
	cout << "connect: CONNECTION_BAD = " << CONNECTION_BAD << endl;
	cout << "connect: Connect result =  " << PQstatus(pg_conn) << endl;
	if(PQstatus(pg_conn) == CONNECTION_BAD) {
		cerr << "connect: " << PQerrorMessage(pg_conn) << endl;
		return false;
	}

	PGresult *result;
	result=PQexec(pg_conn,"select * from test");
	if(result == NULL) {
		cerr << "Error executing sql" << endl;
		exit(1); 
	}
	for(int i=0;i<PQnfields(result);i++) {
		cout << "i=" << i << " type=" << PQftype(result,i) << " value=" << PQgetvalue(result,0,i) << endl;
	}
	return true;
}

void db_close(void)
{
	cout << "db_close: Disconnecting from " << user << "/" << db << "@" << host << "..." << endl;
	PQfinish(pg_conn);
}


bool execute(const char* sql)
{
//	this->sql=sql;
	cout << "execute: Executing query :[" << sql << "]" << endl;
	if(pg_conn == NULL)
		return false;
	// begin 
	PGresult *result;

	result=PQexec(pg_conn,"BEGIN");
	if(!result || PQresultStatus(result) != PGRES_COMMAND_OK) {
		cout << "execute: Could not start a transaction" << endl;
		PQclear(result);
		return false;
		
	}
	cout << "execute: Transaction status is " ;
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
	result=PQexec(pg_conn,sql);
	if(result == NULL)
		return false;
	return true;
}

int main(void)
{
	PostgreSQL_Connection("localhost","postgres","post123654","template1");
	if(connect())
		cout << "Connected" << endl;
	else {
		cerr << "Could not connect!" << endl;
		return 1;
	}
	char* sql="select * from pg_shadow"; // PostgreSQL

	cout << "Executing Query :[" << sql << "]" << endl;
	if(execute(sql)) 
		cout << "Query execution OK" << endl;
	else
		cout << "Query execution FAILED" << endl;

	db_close();
	return 0;
}
