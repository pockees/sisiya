/*
    Copyright (C) 2003 - 2010  Erdal Mutlu

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

/*
#ifdef HAVE_CONFIG_H
	#include"config.h"
#endif
*/

#include<iostream>
#include<fstream>
#include<syslog.h>
#include<list>
#include<string>
#include<sstream>
#include<climits>

#include"common.hpp"

#include"misc.h"
#include"esignal.hpp"

/*
 Declare all C function with
	BEGIN_C_DECLS
	C function list
	END_C_DECLS
*/

// this is a C++ program
#ifndef __cplusplus
	#define __cplusplus
#endif

#include<sys/times.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<sys/stat.h>
#include<signal.h>
#include<setjmp.h>

#include<error.h>
#include<string.h>

#include"Semaphore.hpp"
#include"UpperLowerCase.hpp"
#include"trim.hpp"
#include"stringtok.hpp"
#include"stringConvert.hpp"

#include"Connection.hpp"
#include"ResultSet.hpp"
#include"SQLException.hpp"
#include"Statement.hpp"

#include"SisIYAServer.hpp"

RETSIGTYPE sig_alarm(int signo);

//! Environment variable for sigsetjump() used for SIGALRM
static jmp_buf env_alarm;

/*!
Signal handler for SIGALRM.
*/
RETSIGTYPE sig_alarm(int signo)
{
	// restore the set of blocked signals if any		
	siglongjmp(env_alarm,1);
}



//! Constructor with params.
SisIYAServer::SisIYAServer(Connection *connection,int connsocket,int rt,Semaphore *s,int log_level) 
	: loglevel(log_level),readTimeout(rt),sfd(connsocket)
{
	conn=connection;
	sem=s;
	childPID=getpid();
}

//! Destructor.
SisIYAServer::~SisIYAServer()
{
	// close the connected socket
	close(sfd);
}

/*!
Checks in the status table whether the status ID is valid or not.
*/
/*
bool SisIYAServer::checkStatusID(int statusID)
{
	if(statusID < MESSAGE_INFO || statusID > MESSAGE_ERROR)
		return false;
	return true;
*/
	/*
	string sql="select id from status where id="+toString(statusID);
	
	Statement *stmt=NULL;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"checkStatusID: Error creating a Statement object! Caught SQLException : %s",e.getMessage().c_str());
		return false;
	}
	ResultSet *rs=NULL;
	try {
		rs=stmt->executeQuery(sql);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"checkStatusID: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rs == NULL) {
		syslog(LOG_ERR,"checkStatusID: Query [%s] executiuon failed!",sql.c_str());
		delete stmt;
		return false;
	}
	else
		if(loglevel > 2)
			syslog(LOG_INFO,"checkStatusID: Query [%s] execution OK",sql.c_str());
	ResultSetMetaData *rsmd;
	try {
		rsmd=rs->getResultSetMetaData();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"checkStatusID: Caught SQLException! Could not create ResultSetMetadata object! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd == NULL) {
		syslog(LOG_ERR,"checkStatusID: Could not create ResultSetMetadata object!");
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd->getRowCount() != 1) {
		if(loglevel > 2)
			syslog(LOG_INFO,"checkStatusID: No such statusid=%d!",statusID);
		delete rsmd;
		delete rs;
		delete stmt;
		return false;
	}
	if(loglevel > 2)
		syslog(LOG_INFO,"checkStatusID: status id=%d is valid",statusID);
	delete rsmd;
	delete rs;
	delete stmt;
	return true;
*/
//}	

/*!
Checks in the status table if the whether the status ID is valid or not.
*/
bool SisIYAServer::checkServiceID(int serviceID)
{
	string sql="select id from services where id="+toString(serviceID);
	
	Statement *stmt=NULL;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"checkServiceID: Error creating a Statement object! Caught SQLException : %s",e.getMessage().c_str());
		return false;
	}
	ResultSet *rs=NULL;
	try {
		rs=stmt->executeQuery(sql);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"checkServiceID: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rs == NULL) {
		syslog(LOG_ERR,"checkServiceID: Query [%s] executiuon failed!",sql.c_str());
		delete stmt;
		return false;
	}
	else
		if(loglevel > 2)
			syslog(LOG_INFO,"checkServiceID: Query [%s] execution OK",sql.c_str());
	ResultSetMetaData *rsmd;
	try {
		rsmd=rs->getResultSetMetaData();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"checkServiceID: Caught SQLException! Could not create ResultSetMetadata object! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd == NULL) {
		syslog(LOG_ERR,"checkServiceID: Could not create ResultSetMetadata object!");
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd->getRowCount() != 1) {
		if(loglevel > 2)
			syslog(LOG_INFO,"checkServiceID: No such service id=%d!",serviceID);
		delete rsmd;
		delete rs;
		delete stmt;
		return false;
	}
	if(loglevel > 2)
		syslog(LOG_INFO,"checkServiceID: service id=%d is valid",serviceID);
	delete rsmd;
	delete rs;
	delete stmt;
	return true;
}	

/*!
Retrieves the system status information for the specified system.
\return true on success or false on error.
*/
bool SisIYAServer::getNotOkMessage(int systemID,string &notOkMessage)
{
	/*
	string sql=string("select b.str,c.str from systemservicestatus a,services b,status c where a.serviceid=b.id and a.statusid=c.id and systemid=")+toString(systemID)+string(" and c.id > 1 order by statusid desc");
	*/
	string sql=string("select i.str,i2.str from systemservicestatus a,services b,status c,interface i,strkeys s,languages l,interface i2,strkeys s2,languages l2 where a.serviceid=b.id and a.statusid=c.id and systemid=")+toString(systemID)+string(" and c.id > 2 and b.keystr=s.keystr and l.code='en' and l.id=i.languageid and i.strkeyid=s.id and c.keystr=s2.keystr and l2.code='en' and l2.id=i2.languageid and i2.strkeyid=s2.id order by statusid desc");

	Statement *stmt=NULL;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getNotOkMessage: Error creating a Statement object! Caught SQLException : %s",e.getMessage().c_str());
		return false;
	}
	ResultSet *rs=NULL;
	try {
		rs=stmt->executeQuery(sql);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getNotOkMessage: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rs == NULL) {
		syslog(LOG_ERR,"getNotOkMessage: Query [%s] executiuon failed!",sql.c_str());
		delete stmt;
		return false;
	}
	else
		if(loglevel > 2)
			syslog(LOG_INFO,"getNotOkMessage: Query [%s] execution OK",sql.c_str());
	ResultSetMetaData *rsmd;
	try {
		rsmd=rs->getResultSetMetaData();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getNotOkMessage: Caught SQLException! Could not create ResultSetMetadata object! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd == NULL) {
		syslog(LOG_ERR,"getNotOkMessage: Could not create ResultSetMetadata object!");
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd->getRowCount() == 0) {
		//if(loglevel > 2)
		//	syslog(LOG_INFO,"getSystemUpdateChangeTimes: No records for systemID=%d in the systemservicestatus table!",systemID);
		delete rsmd;
		delete rs;
		delete stmt;
		return false;
	}
	notOkMessage="";
	while(rs->next()) {
		try {
			notOkMessage.append(rs->getString(0));
			notOkMessage.append(string("("));
			notOkMessage.append(rs->getString(1));
			notOkMessage.append(string(") "));

		}
		catch(SQLException &e) {
			syslog(LOG_ERR,"getNotOkMessage: Caught SQLException! Could not get systemID Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
			delete rsmd;
			delete rs;
			delete stmt;
			return false;
		}
	}
	notOkMessage=trim(notOkMessage);
	delete rsmd;
	delete rs;
	delete stmt;
	return true;
}


/*!
Excecutes the given sql which must return one row with a integer column.
\return	INT_MIN on error or the result of the query as a integer value.
*/
int SisIYAServer::getIntValue(string &sql)
{
	int retvalue=INT_MIN;

	Statement *stmt=NULL;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getIntValue: Error creating a Statement object! Caught SQLException : %s",e.getMessage().c_str());
		return retvalue;
	}
	ResultSet *rs=NULL;
	try {
		rs=stmt->executeQuery(sql);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getIntValue: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return retvalue;
	}
	if(rs == NULL) {
		syslog(LOG_ERR,"getIntValue: Query [%s] executiuon failed!",sql.c_str());
		delete stmt;
		return retvalue;
	}
	else
		if(loglevel > 2)
			syslog(LOG_INFO,"getIntValue: Query [%s] execution OK",sql.c_str());
	ResultSetMetaData *rsmd;
	try {
		rsmd=rs->getResultSetMetaData();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getIntValue: Caught SQLException! Could not create ResultSetMetadata object! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return retvalue;

	}
	if(rsmd == NULL) {
		syslog(LOG_ERR,"getIntValue: Could not create ResultSetMetadata object!");
		delete rs;
		delete stmt;
		return retvalue;
	}
	if(rsmd->getRowCount() != 1) {
		if(loglevel > 2)
			syslog(LOG_INFO,"getIntValue: No results for the query [%s]!",sql.c_str());
		delete rsmd;
		delete rs;
		delete stmt;
		return retvalue;
	}
	rs->first();
	try {
		retvalue=rs->getInt(0);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getIntValue: Caught SQLException! Could not get retvalue Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rsmd;
		delete rs;
		delete stmt;
		return retvalue;

	}
	delete rsmd;
	delete rs;
	delete stmt;
	return(retvalue);
}	

/*!
Retrieves the system id from systems table.
\return	0 : no such system; -x	: the system with ID=x is not enabled
*/
int SisIYAServer::getSystemID(string hostName)
{
	int systemID=0; // set to no such system

	string sql="select id,active from systems where ";
	if(hostName.find('.') == string::npos)
		sql.append("hostname='");
	else
		sql.append("fullhostname='");
	sql.append(hostName+string("'"));
	
	Statement *stmt=NULL;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemID: Error creating a Statement object! Caught SQLException : %s",e.getMessage().c_str());
		return systemID;
	}
	ResultSet *rs=NULL;
	try {
		rs=stmt->executeQuery(sql);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemID: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return systemID;
	}
	if(rs == NULL) {
		syslog(LOG_ERR,"getSystemID: Query [%s] executiuon failed!",sql.c_str());
		delete stmt;
		return systemID;
	}
	else
		if(loglevel > 2)
			syslog(LOG_INFO,"getSystemID: Query [%s] execution OK",sql.c_str());
	ResultSetMetaData *rsmd;
	try {
		rsmd=rs->getResultSetMetaData();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemID: Caught SQLException! Could not create ResultSetMetadata object! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return systemID;

	}
	if(rsmd == NULL) {
		syslog(LOG_ERR,"getSystemID: Could not create ResultSetMetadata object!");
		delete rs;
		delete stmt;
		return systemID;
	}
	if(rsmd->getRowCount() != 1) {
		if(loglevel > 2)
			syslog(LOG_INFO,"getSystemID: No such system with name=[%s]!",hostName.c_str());
		delete rsmd;
		delete rs;
		delete stmt;
		return systemID; // no such system
	}
	rs->first();
	try {
		systemID=rs->getInt(0);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemID: Caught SQLException! Could not get systemID Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rsmd;
		delete rs;
		delete stmt;
		return systemID;

	}

	try {
		if(rs->getString(1) == "f")
			systemID=-1*systemID; // the system is not enabled
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemID: Caught SQLException! Could not get systems active flag! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rsmd;
		delete rs;
		delete stmt;
		return systemID;

	}
	if(loglevel > 2)
		syslog(LOG_INFO,"getSystemID: systemID=%d",systemID);
	delete rsmd;
	delete rs;
	delete stmt;
	return(systemID);
}	



/*!
Retrieves update and change times for the speciefied system.
\return true on success or false on error.
*/
bool SisIYAServer::getSystemUpdateChangeTimes(int systemID,string &updateTime,string &changeTime)
{
	string sql=string("select updatetime from systemservicestatus where systemid=")+toString(systemID)+string(" order by updatetime desc");
	
	Statement *stmt=NULL;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Error creating a Statement object! Caught SQLException : %s",e.getMessage().c_str());
		return false;
	}
	ResultSet *rs=NULL;
	try {
		rs=stmt->executeQuery(sql);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rs == NULL) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Query [%s] executiuon failed!",sql.c_str());
		delete stmt;
		return false;
	}
	else
		if(loglevel > 2)
			syslog(LOG_INFO,"getSystemUpdateChangeTimes: Query [%s] execution OK",sql.c_str());
	ResultSetMetaData *rsmd;
	try {
		rsmd=rs->getResultSetMetaData();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Caught SQLException! Could not create ResultSetMetadata object! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd == NULL) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Could not create ResultSetMetadata object!");
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd->getRowCount() == 0) {
		if(loglevel > 2)
			syslog(LOG_INFO,"getSystemUpdateChangeTimes: No records for systemID=%d in the systemservicestatus table!",systemID);
		delete rsmd;
		delete rs;
		delete stmt;
		return false;
	}
	rs->first();
	try {
		updateTime=rs->getString(0);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Caught SQLException! Could not get systemID Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rsmd;
		delete rs;
		delete stmt;
		return false;

	}
	/*
	I am going to use the same statement object, so I must not delete rs and rsmd s 
	delete rsmd;
	delete rs;
	*/

	sql=string("select changetime from systemservicestatus where systemid=")+toString(systemID)+string(" order by changetime desc");
	try {
		rs=stmt->executeQuery(sql);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;
	}
	if(rs == NULL) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Query [%s] executiuon failed!",sql.c_str());
		delete stmt;
		return false;
	}
	else
		if(loglevel > 2)
			syslog(LOG_INFO,"getSystemUpdateChangeTimes: Query [%s] execution OK",sql.c_str());
	try {
		rsmd=rs->getResultSetMetaData();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Caught SQLException! Could not create ResultSetMetadata object! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rs;
		delete stmt;
		return false;

	}
	if(rsmd == NULL) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Could not create ResultSetMetadata object!");
		delete rs;
		delete stmt;
		return false;
	}
	if(rsmd->getRowCount() == 0) {
		//if(loglevel > 2)
		//	syslog(LOG_INFO,"getSystemUpdateChangeTimes: No records for systemID=%d in the systemservicestatus table!",systemID);
		delete rsmd;
		delete rs;
		delete stmt;
		return false;
	}
	rs->first();
	try {
		changeTime=rs->getString(0);
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"getSystemUpdateChangeTimes: Caught SQLException! Could not get systemID Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete rsmd;
		delete rs;
		delete stmt;
		return false;

	}
	delete rsmd;
	delete rs;
	delete stmt;

	return true;
}	

/*!
Generate time stamp value in the form: yyyymmddhhmmss.
*/
void SisIYAServer::getTimestamp(string &str)
{
	time_t tt;
	struct tm *t;
                                                                                                                             
	time(&tt);
	t=localtime(&tt);
        
	char buf[15];
	// change this to use ostringstream
	sprintf(buf,"%d%.2d%.2d%.2d%.2d%.2d",1900+t->tm_year,1+t->tm_mon,t->tm_mday,t->tm_hour,t->tm_min,t->tm_sec);
	str=buf;
}

/*!
Insert SisIYA message.
*/
bool SisIYAServer::insertMessage(int systemID,int serviceID,int statusID,long int expire,const string &sendTimestamp,const string &msg,const string &msgdata)
{
	string recieveTimestamp;
	getTimestamp(recieveTimestamp);

	// for systemhistorystatus table
	string sql=string("insert into systemhistorystatus values('")+sendTimestamp+string("',")+toString(systemID)+string(",")+toString(serviceID)+string(",")+toString(statusID)+string(",'")+recieveTimestamp+string("','")+msg+string("','")+msgdata+string("')");

	Statement *stmt;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"insertMessage: Error creating a Statement object! Caught SQLException : %s",e.getMessage().c_str());
		return false;
	}
	try {
		if(stmt->executeUpdate(sql) != 1) {
			syslog(LOG_ERR,"insertMessage: Query [%s] executiuon failed! Insert must produce exactly 1 row?!",sql.c_str());
			delete stmt;
			return false;
		}
		else
			if(loglevel > 2)
				syslog(LOG_INFO,"insertMessage: Query [%s] execution OK",sql.c_str());
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"insertMessage: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete stmt;
		return false;
	}

	// for systemservice table
	sql=string("select statusid from systemservicestatus where systemid=")+toString(systemID)+string(" and serviceid=")+toString(serviceID);
	int sID=getIntValue(sql);
	if(sID != INT_MIN) {
		// update 
		if(sID != statusID) 
			sql=string("update systemservicestatus set statusid=")+toString(statusID)+string(",changetime='")+recieveTimestamp+string("',updatetime='")+recieveTimestamp+string("',expires=")+toString(expire)+string(",str='")+msg+string("',data='")+msgdata+string("' where systemid=")+toString(systemID)+string(" and serviceid=")+toString(serviceID);
		else 
			sql=string("update systemservicestatus set statusid=")+toString(statusID)+string(",updatetime='")+recieveTimestamp+string("',expires=")+toString(expire)+string(",str='")+msg+string("',data='")+msgdata+string("' where systemid=")+toString(systemID)+string(" and serviceid=")+toString(serviceID);
		try {
			if(stmt->executeUpdate(sql) != 1) {
				syslog(LOG_ERR,"insertMessage: Query [%s] executiuon failed! Update must produce exactly 1 row?!",sql.c_str());
				delete stmt;
				return false;
			}
			else
				if(loglevel > 2)
					syslog(LOG_INFO,"insertMessage: Query [%s] execution OK",sql.c_str());
		}
		catch(SQLException &e) {
			syslog(LOG_ERR,"insertMessage: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
			delete stmt;
			return false;
		}
	}	 
	else {
		// new record
		sql=string("insert into systemservicestatus values(")+toString(systemID)+string(",")+toString(serviceID)+string(",")+toString(statusID)+string(",'")+recieveTimestamp+string("','")+recieveTimestamp+string("',")+toString(expire)+string(",'")+msg+string("','")+msgdata+string("')");
		try {
			if(stmt->executeUpdate(sql) != 1) {
				syslog(LOG_ERR,"insertMessage: Query [%s] executiuon failed! Insert must produce exactly 1 row?!",sql.c_str());
				delete stmt;
				return false;
			}
			else
				if(loglevel > 2)
					syslog(LOG_INFO,"insertMessage: Query [%s] execution OK",sql.c_str());
		}
		catch(SQLException &e) {
			syslog(LOG_ERR,"insertMessage: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
			delete stmt;
			return false;
		}
	}	 
	delete stmt;
	return true;
}

/*!
Extracts the first occurence of a XML string. It uses the tag and extracts the string between "<tag>" and "</tag>".
*/
string SisIYAServer::extractXMLField(const string &s,const string &tag)
{
	string start_tag("<"+tag+">");
	string end_tag("</"+tag+">");
	string x;

	int p1=s.find(start_tag);

	if(p1 >= 0) { 
		int p2=s.find(end_tag);
		if(p2 >= 0) { 
			int a=tag.length();
			if((p2-p1-a-2) > 0) 
				x=s.substr(p1+a+2,p2-p1-a-2);
		}
	}
	return x;
}


bool SisIYAServer::extractMessageFields(const string m,int *serviceID,int *statusID,long *expire,string &msg,string &msgdata)
{
/*
 	<message>
		<serviceid>serviceid</serviceid>
		<statusid>statusid</statusid>
		<expire>expire in minutes</expire>
		<data>
			<msg></msg> => this part (the message) is going to be shown on the web GUI
			<datamsg>
				<x></x>  --\ 
				<y></y>     }=> These are used for grahics, statistics etc purposes. Example : for the ping service <responcetime>100</responcetime> <packetlost</packetlost>
				<z></z>  --/
					Every service (ping uses responce times and packet lost percentages; filesystem service could 
					use disk capacity, usage percentage and etc) has its own type of information stored within XML 
					tags and interpreted correspondingly.
			</datamsg>
		</data>
	</message>
*/
	string x;

	x=extractXMLField(m,string("serviceid"));
	if(x.length() == 0)
		return false;
	(*serviceID)=fromString<int>(x);

	x=extractXMLField(m,string("statusid"));
	if(x.length() == 0)
		return false;
	(*statusID)=fromString<int>(x);

	x=extractXMLField(m,string("expire"));
	if(x.length() == 0)
		return false;
	(*expire)=fromString<int>(x);
	
	msg=trim(extractXMLField(m,string("msg")));
	if(msg.length() == 0)
		return false;
	
	msgdata=trim(extractXMLField(m,string("datamsg")));
	return true;
}

bool SisIYAServer::processSystemMessages(const string &sendTimestamp,const string &m)
{
	if(loglevel > 2)
		syslog(LOG_INFO,"child server(%d) : processSystemMessages: length=%d Processing m=[%s]",childPID,m.length(),m.c_str());
	string systemName=extractXMLField(m,"name");
	if(systemName.length() == 0)
		return false;

	int systemID=getSystemID(systemName);
	if(loglevel > 2)
		syslog(LOG_INFO,"child server(%d) : processSystemMessages : systemID=%d",childPID,systemID);

	if(systemID <= 0) { 
		if(systemID == 0)
			syslog(LOG_ERR,"child server(%d) : no such system=%s",childPID,systemName.c_str());
		else if(systemID < 2)
			syslog(LOG_ERR,"child server(%d) : the system %s with systemID=%d is not enabled. Disable checks for this system or enable the system.",childPID,systemName.c_str(),-1*systemID);
		return false; // the system is not enabled or no such system
	}

	int serviceID,statusID;
	long int expire;
	string data,msg;
	
	string x=m;
	int p,x_length;
	string message_str;

	while(x.length() > 0) {
		x_length=x.length();
		p=x.find("</message>"); // </message> length is 10

		message_str=extractXMLField(x,string("message"));
		if(loglevel > 2)
			syslog(LOG_INFO,"child server(%d) : processSystemMessages: length=%d Processing message_str=[%s]",childPID,message_str.length(),message_str.c_str());
		if(message_str.length() == 0)
			break;	// there are no more messages
		if(extractMessageFields(message_str,&serviceID,&statusID,&expire,msg,data) == false) {
			syslog(LOG_ERR,"child server(%d) : Bad formated message! %s",childPID,message_str.c_str());

			// remove the processed part of the message
			x=x.substr(p+10,x_length-p); // </message> length is 10 => cut verything before end of the first </message> tag

			continue; // bad formated message
		}	
		if(loglevel > 2)
			syslog(LOG_INFO,"child server(%d) : processSystemMessages: serviceID=%d statusID=%d expire=%ld data=[%s]",childPID,serviceID,statusID,expire,data.c_str());
		// remove the processed part of the message
		x=x.substr(p+10,x_length-p); // </message> length is 10 => cut everything before end of the first </message> tag
		if(loglevel > 2)
			syslog(LOG_INFO,"child server(%d) : processSystemMessages: length=%d x=[%s]",childPID,x.length(),x.c_str());

		// now do the job of inserting the message into the DB

		//if(checkStatusID(statusID) == false) {
		if(statusID < MESSAGE_INFO || statusID > MESSAGE_ALL) {
			syslog(LOG_ERR,"child server(%d) : no such statusID=%d",childPID,statusID);
			//messag_str=message_str+string(" Status id=")+toString(statusID)+string(" is not defined in SisIYA!");
			//statusID=MESSAGE_UNAVAILABLE;
			continue;
		}
		if(checkServiceID(serviceID) == false) {
			syslog(LOG_ERR,"child server(%d) : no such serviceID=%d",childPID,serviceID);
			//systemID=-1; // set to -1 untill I have a better way of error control
			continue;
		}

		if(insertMessage(systemID,serviceID,statusID,expire,sendTimestamp,msg,data) == false) {
			syslog(LOG_ERR,"child server(%d) : Could not insert the message! %s",childPID,message_str.c_str());
			continue;
		}

	}
	if(updateSystemStatus(systemID) == false) {
		syslog(LOG_ERR,"child server(%d) : could not update systemstatus for systemID=%d",childPID,systemID);
		return false;
	}
	else {
		if(loglevel > 2)
			syslog(LOG_INFO,"child server(%d) : (1)updated systemstatus for systemID=%d",childPID,systemID);
	}
	return true;
}

void SisIYAServer::appendToLog(const string m)
{
	ofstream logFile("/tmp/sisiyad.log",ios::app);

	if(! logFile.is_open()) {
		return;
	}
	logFile << "=============================================================================================================================\n";
	logFile << m << endl;
	logFile << "=============================================================================================================================\n";
	logFile.close();

}

bool SisIYAServer::processSisIYAMessages(const string m)
{
	/*
The new XML message format:
------------------------------------------------------------------------
- SisIYA server accepts SisIYA messages in the form of XML file:
	<?xml version="1.0" encoding="utf-8"?>
	<sisiya_messages>
		<timestamp>send timestamp of the form: YYYYMMDDHHMMSS </timestamp>
		<system>
			<name>system name</name>
			<message>
				<serviceid>serviceid</serviceid>
				<statusid>statusid</statusid>
				<expire>expire in minutes</expire>
				<data>
					<msg></msg> => this part (the message) is going to be shown on the web GUI
					<x></x>  --\ 
					<y></y>     }=> These are used for grahics, statistics etc purposes. Example : for the ping service <responcetime>100</responcetime> <packetlost</packetlost>
					<z></z>  --/
						Every service (ping uses responce times and packet lost percentages; filesystem service could use disk capacity, usage percentage and etc) 
						has its own type of information stored within XML tags and interpreted correspondingly.
				</data>
			</message>
		</system>
		<system>
		...
		</system>
		... more systems
	</sisiya_messages>
	*/

	// get sisiya_messages
//	if(loglevel > 2)
//		syslog(LOG_INFO,"child server(%d) : processSisIYAMessages: message=[%s]",childPID,m.c_str());
	if(loglevel > 2)
		appendToLog(m);
	string sisiya_messages=extractXMLField(m,"sisiya_messages");
	if(sisiya_messages.length() == 0) {
		syslog(LOG_ERR,"child server(%d) : processSisIYAMessages: Malformed SisIYA message! Could not find any valid messages!",childPID);
		return false;
	}

	// get timestamp
	string sendTimestamp=extractXMLField(sisiya_messages,string("timestamp"));
	if(sendTimestamp.length() == 0) {
		syslog(LOG_ERR,"child server(%d) : processSisIYAMessages: The length of send timestamp is 0!",childPID);
		return false;
	}

	if(loglevel > 2)
		syslog(LOG_INFO,"child server(%d) : processSisIYAMessages: timestamp [%s]",childPID,sendTimestamp.c_str());

	string x=sisiya_messages;
	int p,x_length;
	string system_str;
	while(x.length() > 0) {
		if(loglevel > 2)
			syslog(LOG_INFO,"child server(%d) : processSisIYAMessages: length=%d Processing x=[%s]",childPID,x.length(),x.c_str());
		x_length=x.length();
		p=x.find("</system>"); // </system> length is 9

		system_str=extractXMLField(x,string("system"));
		if(system_str.length() == 0)
			break;
		if(processSystemMessages(sendTimestamp,system_str) == false) {
			syslog(LOG_ERR,"child server(%d) : processSisIYAMessages: Error occured during processing of system messages! system_str=[%s]",childPID,system_str.c_str());
			/*return false; continue to the next messge */
		}
		x=x.substr(p+9,x_length-p-2); // </system> length is 9 => cut verything before end of the first </system> tag
	}
	return true;	
}


/*!
Process messages send from a client through the socket.
*/
bool SisIYAServer::process(void)
{
	clock_t tcstart,tcend;
	struct tms tmstart,tmend;
	double clockticks,cticks;
	string messages;
	
	if(loglevel > 2) {
		if((int)(clockticks=(double)sysconf(_SC_CLK_TCK)) == -1) {
			syslog(LOG_ERR,"child server(%d) : could not get _SC_CLK_TCK!",childPID);
			return false;
		}
		syslog(LOG_INFO,"child server(%d) : the number of ticks per second is clockticks=%f",childPID,clockticks);
		if((int)clockticks == 0) {
			syslog(LOG_ERR,"child server(%d) : the number of ticks per second is invalid!",childPID);
			return false;
		}
		if((int)(tcstart=times(&tmstart)) == -1) {
			syslog(LOG_ERR,"child server(%d) : failed to get start time!",childPID);
			return false;
		}
	}	


	char line[MAX_STR];
	int n;
	if(esignal(SIGALRM,sig_alarm) == SIG_ERR) {
		syslog(LOG_ERR,"child server(%d) : could not set signal handler for SIGALRM!",childPID);
		return false;
	}

	if(loglevel > 2) 
		syslog(LOG_INFO,"child server(%d) : starting to read from socket %d",childPID,sfd);
	unsigned int remaining_time;
	int number_of_reads=1;
	while(1) {
		// save the set of blocked signals, so that the siglongjump if called with this env_alarm will be restored
		if(sigsetjmp(env_alarm,1) != 0) {
			if(loglevel > 2) 
				syslog(LOG_INFO,"child server(%d) : Read timeout=%d expired.",childPID,readTimeout);
			syslog(LOG_INFO,"child server(%d) : alarm (%d seconds) expired while reading from the socket=%d! ",childPID,readTimeout,sfd);
			//clean up
			return false;
		
		}
		// set a read timeout
		alarm(readTimeout);

		if((n=readn(sfd,line,MAX_STR)) < 0) {
			syslog(LOG_ERR,"socket read error");
			return false; 
		}

		// cancel the alarm
		remaining_time=alarm(0);
		if(loglevel > 2)
			syslog(LOG_INFO,"child server(%d) : canceled alarm (remaining seconds=%d) for ReadTimeout of %d seconds.",childPID,remaining_time,readTimeout);

		// no more data
		if(n == 0)
			break;

		line[n]='\0';

		if(loglevel > 2) 
			syslog(LOG_INFO,"child server(%d) received data : [%s]\n",childPID,line);
		if((messages.max_size()-messages.length()) >= strlen(line)) { 
			if(loglevel > 2) {
				appendToLog(toString(number_of_reads) + string(" --READ LINE--:") + string(line));
				number_of_reads++;
			}
			//messages=messages+string(line);
			messages+=string(line);
		}
		else {
			syslog(LOG_ERR,"child server(%d) : Received message length exceeded max size of string, which is  %d! The rest of the message is discarded!",childPID,messages.max_size());
			break;
		}
	}
	if(loglevel > 2)
		syslog(LOG_INFO,"child server(%d) : received messages : [%s]",childPID,messages.c_str());


	if(loglevel > 2) 
		syslog(LOG_INFO,"child server(%d) : getting the lock from semaphore=%d",childPID,sem->getID());
	sem->getLock();
	if(loglevel > 2) 
		syslog(LOG_INFO,"child server(%d) : got the lock from semaphore for %d",childPID,sem->getID());
	// process received messages
	if(processSisIYAMessages(messages) == false) {
		syslog(LOG_ERR,"child server(%d) : Error occured during processing of SisIYA messages!",childPID);
	}
	if(loglevel > 2) 
		syslog(LOG_INFO,"child server(%d) : releasing the lock from semaphore id=%d",childPID,sem->getID());
	sem->releaseLock();
	if(loglevel > 2) 
		syslog(LOG_INFO,"child server(%d) : released the lock from semaphore id=%d",childPID,sem->getID());

	if(loglevel > 2) {
		if((tcend=times(&tmend)) == -1) {
			syslog(LOG_ERR,"child server(%d) : failed to get end time!",childPID);
			return false;
		}
		cticks=tmend.tms_utime+tmend.tms_stime-tmstart.tms_utime-tmstart.tms_stime;
		syslog(LOG_INFO,"child server(%d) : total CPU execution time = %f",childPID,cticks/clockticks);
		if((tcend <= tcstart) || tcend < 0 || tcstart < 0) {
			syslog(LOG_ERR,"child server(%d) : tick time wrapped, couldn't calculate fraction!",childPID);
			return false;
		}
		syslog(LOG_INFO,"child server(%d) : fraction CPU time used is %f",childPID,cticks/(tcend-tcstart));
	}
	return true;
}

/*!
Update system's status.
*/
bool SisIYAServer::updateSystemStatus(int systemID)
{
	int systemStatusID;
	string updateTime,changeTime;


	if(getSystemUpdateChangeTimes(systemID,updateTime,changeTime) == false) {
		syslog(LOG_INFO,"updateSystemStatus: Could not get change and update times from the systemservicestatus table. Generating...");
		getTimestamp(changeTime);
		getTimestamp(updateTime);
	}
	
	// get the system status
	string sql=string("select statusid from systemstatus where systemid=")+toString(systemID);

	systemStatusID=getIntValue(sql);
	string notOkMessage;

	// get the max status from systemservicestatus
	//sql=string("select max(statusid) from systemservicestatus where systemid=")+toString(systemID);
	sql=string("select cast(sum(statusid) as unsigned) from (select statusid from systemservicestatus where systemid=")+toString(systemID)+string(" group by statusid) w");
	// totalStatusID variable holds the sum of power of 2's of uniq statusielect sum(pow(2,statusid)) from (select statusid from systemservicestatus group by statusid) w
	int totalStatusID=getIntValue(sql);

	if(loglevel > 2)
		syslog(LOG_INFO,"updateSystemStatus: Got system max(statusid)=%d for systemID=%d",totalStatusID,systemID); 

	if(systemStatusID != INT_MIN) {
		// it is going to be an update
		if(totalStatusID < MESSAGE_WARNING) { 	// The system is OK
			//int mk=MESSAGE_OK; // the toString needs a reference
			int mk=totalStatusID;
			sql=string("update systemstatus set statusid=")+toString(mk)+string(",updatetime='")+updateTime+string("',str='System is OK' where systemid=")+toString(systemID);
		}
		else {	// System has warnings and/or errors
			if(getNotOkMessage(systemID,notOkMessage) == false) {
				syslog(LOG_ERR,"updateSystemStatus: Could not get error and/or warning messages for the system=%d. totalStatusID=%d",systemID,totalStatusID);
				notOkMessage="There was no status info!";
			}
			if(totalStatusID != systemStatusID)
				sql=string("update systemstatus set statusid=")+toString(totalStatusID)+string(",changetime='")+changeTime+string("',updatetime='")+updateTime+string("',str='")+notOkMessage+string("' where systemid=")+toString(systemID);
			else
				sql=string("update systemstatus set updatetime='")+updateTime+string("',str='")+notOkMessage+string("' where systemid=")+toString(systemID);
		}	  
	}
	else {
		// check this logic !!! There is a probem when a client sends a message for a not valid service ID ?!
		// new record
		systemStatusID=totalStatusID;
		if(systemStatusID < 2)
			sql=string("insert into systemstatus values(")+toString(systemID)+string(",")+toString(systemStatusID)+string(",'")+updateTime+string("','")+changeTime+string("','System is OK')");
		else {
			if(getNotOkMessage(systemID,notOkMessage) == false) {
				syslog(LOG_ERR,"updateSystemStatus: Could not get error and/or warning messages for the system=%d",systemID);
				notOkMessage="There was no status info!";
			}
			sql=string("insert into systemstatus values(")+toString(systemID)+string(",")+toString(systemStatusID)+string(",'")+updateTime+string("','")+changeTime+string("','")+notOkMessage+string("')");
		}
	}

	Statement *stmt;
	try {
		stmt=conn->createStatement();
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"updateSystemStatus: Error creating a Statement object! Caught SQLException : %s",e.getMessage().c_str());
		return false;
	}
	try {
		if(stmt->executeUpdate(sql) != 1) {
//			syslog(LOG_ERR,"updateSystemStatus: Query [%s] executiuon failed! Update or insert must produce exactly 1 row?!",sql.c_str());
			delete stmt;
//			return false;
			return true;
		}
		else
			if(loglevel > 2)
				syslog(LOG_INFO,"updateSystemStatus: Query [%s] execution OK",sql.c_str());
	}
	catch(SQLException &e) {
		syslog(LOG_ERR,"updateSystemStatus: Caught SQLException! Reason: %s SQL State: %s Vendor error code: %d",e.getMessage().c_str(),e.getSQLState().c_str(),e.getErrorCode());
		delete stmt;
		return false;
	}
	delete stmt;
	return true;
}
