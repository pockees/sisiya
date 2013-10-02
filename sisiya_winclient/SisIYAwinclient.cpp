/*
    Copyright (C) 2003  Erdal Mutlu

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

#include<time.h>
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include"SisIYAwinclient.h"
#include<pdhmsg.h>
#include<tlhelp32.h>		// for processes and threads
#include<sstream>
#include<list>
#include"EventLog.h"
#include"stringtok.hpp"
#include"stringConvert.hpp"
#include"trim.hpp"


using namespace std;

using namespace System;
using namespace System::Text;			// for Encoding
using namespace System::Diagnostics;	// for event logging

//! Buffer size for the varios char strings.
static const int BUFSIZE=4096;

/*************************************************************************************/
void extractUptimes(string uptime,int &days,int &hours,int &minutes);
string formTimeString(int days,int hours,int minutes);
/*************************************************************************************/

/*!
Check if the line a comment or empty is. Comment char is '#'.
*/
bool isLineCommentOrEmpty(const char *line,const char ch)
{
	if(line[0] == '\0') {
			//cout << "isLineCommentOrEmpty: Skipping empty line[" << line << "]" << endl;
			return true; // empty line
	}
	// check if the line is a configuration line or if it is only an empty or comment line
	// find the firt char which is not ' ','\t' or ch
	bool flag=true;
	int i=0;
	while(line[i] != '\0') {
		if(line[i] == ' ' || line[i] == '\t') {
			i++;
			continue;
		}
		else if(line[i] == ch) {
			i=-1;
			break;
		}
		flag=false;
		i++;
	}
	return flag;
}

/*! 
Resolves hostname to an IP address, copies it to the buffer buffer and returns 0 on error
or non zero (the length of the buffer) on success. buffer_length is the buffer size.
If the buffer_length is smaller than the returned address length from gethostbyname, an error is returned.
*/
int getIP(const char *hostname,char *buffer,int buffer_length)
{

	int length;
	struct hostent *h_ptr;

	// Initialize Winsock library	
	WSADATA wsaData;
	if(WSAStartup(MAKEWORD(2,2),&wsaData) != NO_ERROR) {
		cerr << "Cannot initialize Winsock Library."; 
		exit(1);
	}

	buffer[0]='\0';
	h_ptr=gethostbyname(hostname);
	if(h_ptr == NULL) 
		return(0);
	length=(int)strlen(inet_ntoa(*(struct in_addr *)h_ptr->h_addr_list[0]));
	if(length < buffer_length) {
		//strncpy(buffer,inet_ntoa(*(struct in_addr *)h_ptr->h_addr_list[0]),length);
		strncpy_s(buffer,buffer_length,inet_ntoa(*(struct in_addr *)h_ptr->h_addr_list[0]),length);
		buffer[length]='\0';
		return(length); /* Return a non zero value: the length of the IP address. */
	}
	return(0);
};



/*!
Constructor.
*/
CheckInfo::CheckInfo()
{
	current=-1;
	count=0;
}

/*!
Destructor.
*/
CheckInfo::~CheckInfo()
{
	for(int i=0;i<count;i++)
		delete data[i];
}

/*!
Add a new element.
*/
void CheckInfo::add(void)
{
	if(count < max)
		count++;
	else
		throw RangeError();
	current++;
	data[current]=new DataType();
}

/*!
Get the number of elements.
*/
int CheckInfo::getCount(void)
{
	return count;
}

/*!
Get the status id.
*/
int CheckInfo::getStatusID(void)
{
	return data[current]->statusID;
}

/*!
Set the service id.
*/
void CheckInfo::setServiceID(const int serviceID)
{
	data[current]->serviceID=serviceID;
}

/*!
Set the status.
*/
void CheckInfo::setStatusID(int status)
{
	/*
	if(status < SISIYA_STATUSID_INFO && status > statusid_error)
		data[current]->statusID=statusid_error; //  invalid status
	else
	*/
		data[current]->statusID=status;
}

/*!
Set the check interval.
*/
void CheckInfo::setExpire(long int expire)
{
	this->expire=expire;
}

/*!
Sets the message.
*/
void CheckInfo::setMessage(string Message)
{
	data[current]->Message=Message;
}

/*!
Contsruct SisIYA message.
*/
const string CheckInfo::getSisIYAMessage(int index,const string host,char del)
{
	struct tm d; // today
	time_t timeToday;
	char str[4096];

	if(index >= count)
		throw RangeError();

	time(&timeToday);
	localtime_s(&d,&timeToday);

	// no buffer overflow check :(
	sprintf_s(str,4096,"%c%d%c%d%c%s%c%d%.2d%.2d%.2d%.2d%.2d%c%ld%c%s\n",del,
		data[index]->serviceID,del,data[index]->statusID,del,
		host.c_str(),del,1900+d.tm_year,1+d.tm_mon,d.tm_mday,d.tm_hour,
		d.tm_min,d.tm_sec,del,expire,del,data[index]->Message.c_str());
	return string(str);
}


/*!
Constructor. Make all checks (getXXXInfo()) and Initialize Winsock. 
*/
SisIYAwinclient::SisIYAwinclient(string logName,const char *confDir)
: checkInterval(5),expire(10),error_fs(90),warning_fs(85),error_load(90),
warning_load(80),error_uptime("1"),warning_uptime("3"),error_swap(50),
warning_swap(30),delimiter('~'),
uptimeKey("\\System\\System Up Time"),
loadKey("")
{
#ifdef DEBUG	
	ostringstream osstr;
	osstr << "SisIYAwinclient::~SisIYAwinclient: Start : " << getTimeString() << ends;
	logEvent(logName,osstr.str(),EVENTLOG_INFORMATION_TYPE);
#endif

	this->logName=logName;
	this->confDir=confDir;
	setDefaults();
	sisiyaConf.setFileName(string(confDir+string("\\sisiya_client.conf")).c_str());
	string serverName=sisiyaConf.getString("SISIYA_SERVER");
	if(serverName == "localhost" )
		logEvent(logName,string("SisIYAwinclient::SisIYAwinclient: No SISIYA_SERVER configuration option specified. The default is not going to be enaugh serverName=")+serverName,EVENTLOG_WARNING_TYPE);
	char str[128];
	getIP(serverName.c_str(),str,127);
	serverIP=str;
	
	port=sisiyaConf.getInt("SISIYA_PORT");
	if((checkInterval=sisiyaConf.getLong("check_interval")) == ConfFile::longNotFound)
		checkInterval=5;
	if((expire=sisiyaConf.getLong("expire")) == ConfFile::longNotFound)
		expire=10;
	info.setExpire(expire);
	string s=sisiyaConf.getString("SP");
	if(s.size() > 0)
		delimiter=s.at(0);
	uptimeKey=sisiyaConf.getString("uptimeKey");
	loadKey=sisiyaConf.getString("loadKey");
	statusid_info=sisiyaConf.getInt("status_info");
	statusid_ok=sisiyaConf.getInt("status_ok");
	statusid_warning=sisiyaConf.getInt("status_warning");
	statusid_error=sisiyaConf.getInt("status_error");

	getHostName();
	// get default check values for this host
	string defaultsFileName=confDir+string("\\systems\\")+hostName+string("\\sisiya_defaults.conf");
	ifstream file;

	file.open(defaultsFileName.c_str(),ios::in);
	if(file) {	// if the defauts file exists, extract the default values.
		file.close();
		ConfFile defaultsConf(defaultsFileName.c_str());

		if((error_fs=defaultsConf.getInt("error_fs")) == ConfFile::intNotFound)
			error_fs=90;
		if((warning_fs=defaultsConf.getInt("warning_fs")) == ConfFile::intNotFound)
			warning_fs=85;

		if((error_load=defaultsConf.getInt("error_load")) == ConfFile::intNotFound)
			error_load=90;
		if((warning_load=defaultsConf.getInt("warning_load")) == ConfFile::intNotFound)
			warning_load=80;

		if((error_uptime=defaultsConf.getString("error_uptime")) == "") 
			error_uptime="1";
		if((warning_uptime=defaultsConf.getString("warning_uptime")) == "")
			warning_uptime="3";

		if((error_swap=defaultsConf.getInt("error_swap")) == ConfFile::intNotFound)
			error_swap=50;
		if((warning_swap=defaultsConf.getInt("warning_swap")) == ConfFile::intNotFound)
			warning_swap=30;
	}
	getSystemInfo();
	getFilesystemInfo();
	getSwapInfo();
	getLoadInfo();
	getProcessesAndThreads();
	getCPUInfo();
	
	// Initialize Winsock library	
	WSADATA wsaData;
	if(WSAStartup(MAKEWORD(2,2),&wsaData) != NO_ERROR) {
		cerr << "Cannot initialize Winsock Library."; 
		exit(1);
	}
}


/*!
Clean up.
*/
SisIYAwinclient::~SisIYAwinclient() 
{ 
#ifdef DEBUG	
	ostringstream osstr;
	osstr << "SisIYAwinclient::~SisIYAwinclient: Stop : " << getTimeString() << ends;
	logEvent(logName,osstr.str(),EVENTLOG_INFORMATION_TYPE);
#endif
	WSACleanup();
}

bool SisIYAwinclient::checkProcess(char *name)
{
	HANDLE hSnapshot=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
	if(hSnapshot == INVALID_HANDLE_VALUE) {
		ostringstream osstr;
		osstr << " Error code=" << GetLastError() << ends;
		logEvent(logName,string("SisIYAwinclient::getProcessesAndThreads: Error calling CreateToolhelp32Snapshot!")+osstr.str(),EVENTLOG_ERROR_TYPE);
	}
	
	PROCESSENTRY32 pe;

	// fill up its size
	pe.dwSize=sizeof(PROCESSENTRY32);

	BOOL retval=Process32First(hSnapshot,&pe);
	while(retval) {
	//	printf("Process ID : %08X name=%s\n",pe.th32ProcessID,pe.szExeFile);
	//	cout << "Process ID : " << pe.th32ProcessID << " Name : " << pe.szExeFile << endl;
		// check case insensitive
		if(strcmp((char *)CharLower(name),(char *)CharLower(pe.szExeFile)) == 0) {
			CloseHandle(hSnapshot);
			return true;
		}
		pe.dwSize=sizeof(PROCESSENTRY32);
		retval=Process32Next(hSnapshot,&pe);
	}
	CloseHandle(hSnapshot);
	return false;
}
/*
	Extracts uptime from a string, which has the format: d:h:m (d=days, h=hours and m=minutes)
*/
void extractUptimes(string uptime,int &days,int &hours,int &minutes)
{
	days=0;
	hours=0;
	minutes=0;

	list<string> ls;
	stringtok(ls,uptime,":");
	//cout << "extractUptimes: uptime=[" << uptime.c_str() << "] ls.size()=" << ls.size() << endl;
	list<string>::const_iterator i;
	if(ls.size() == 1) {
		days=fromString<int>(*ls.begin());
	}
	else if(ls.size() == 2) {
		i=ls.begin();
		hours=fromString<int>((*i));
		i++;
		minutes=fromString<int>((*i));
	}
	else {
		i=ls.begin();
		days=fromString<int>((*i));
		i++;
		hours=fromString<int>((*i));
		i++;
		minutes=fromString<int>((*i));
	}
	// some checks & corrections
	if(minutes > 60) {
		int t=int(minutes/60);
		hours+=t;
		minutes=minutes-t*60;
	}
	if(hours > 24) {
		int t=int(hours/24);
		days+=t;
		hours=hours-t*24;
	}
	//cout << "extractUptimes: days=" << days << " hours=" << hours << " minutes=" << minutes << endl;
}

int SisIYAwinclient::getCPUCount(void)
{
	HKEY hKey;
	LONG lRet;
	int cpuCount=0;

	// get the number of CPUs
	while(1) {
		ostringstream osstr;
		osstr << "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\" << cpuCount << ends;
		//cout << "SisIYAwinclient::getCPUInfo: Trying CPU : " << cpuCount << endl;
		lRet=RegOpenKeyEx(HKEY_LOCAL_MACHINE,(LPCSTR)osstr.str().c_str(),0,KEY_QUERY_VALUE,&hKey);
	
		if(lRet != ERROR_SUCCESS) {
			//cout << "SisIYAwinclient::getCPUInfo: Trying CPU : " << cpuCount << " NO." << endl;
			RegCloseKey(hKey);
			break;
		}
		//cout << "SisIYAwinclient::getCPUInfo: Trying CPU : " << cpuCount << " OK." << endl;
		cpuCount++;
		RegCloseKey(hKey);
	}
	return cpuCount;
}

void SisIYAwinclient::getCPUInfo(void)
{
	HKEY hKey;
	static const int BUFSIZE=4096;
	char str[BUFSIZE];
	DWORD dwBufLen=BUFSIZE;
	LONG lRet;
	string msg;
	
//	int cpuCount=getCPUCount();

	ostringstream osstr;
	//osstr << cpuCount << " x ";
	msg=osstr.str();

	string cpuPath=string("HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0");
	lRet=RegOpenKeyEx(HKEY_LOCAL_MACHINE,(LPCSTR)cpuPath.c_str(),0,KEY_QUERY_VALUE,&hKey);
	
	if(lRet != ERROR_SUCCESS) {
		RegCloseKey(hKey);
		logEvent(logName,string("SisIYAwinclient::getCPUInfo: Could not get the CentralProcessor information"),EVENTLOG_ERROR_TYPE);
		return;
	}
/*
	lRet=RegQueryValueEx(hKey,"ProcessorNameString",NULL,NULL,(LPBYTE)str,&dwBufLen);
	            
	if((lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) ) {
		//RegCloseKey(hKey);
		logEvent(logName,string("SisIYAwinclient::getCPUInfo: Could not get the ProcessorNameString information"),EVENTLOG_WARNING_TYPE);
		//return;
	}
	else
		msg+=str;
*/	
	dwBufLen=BUFSIZE;
	lRet=RegQueryValueEx(hKey,"VendorIdentifier",NULL,NULL,(LPBYTE)str,&dwBufLen);
	            
	if((lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) ) {
		RegCloseKey(hKey);
		logEvent(logName,string("SisIYAwinclient::getCPUInfo: Could not get the VendorIdentifier information"),EVENTLOG_ERROR_TYPE);
		return;
	}
	msg+=string(" ")+str;
	
	/*
	dwBufLen=BUFSIZE;
	lRet=RegQueryValueEx(hKey,"~MHz",NULL,NULL,(LPBYTE)str,&dwBufLen);
	            
	if((lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) ) {
		RegCloseKey(hKey);
		logEvent(logName,string("SisIYAwinclient::getCPUInfo: Could not get the ~MHz information"),EVENTLOG_ERROR_TYPE);
		return;
	}
	msg+=string(" ")+str;
	*/

	dwBufLen=BUFSIZE;
	lRet=RegQueryValueEx(hKey,"Identifier",NULL,NULL,(LPBYTE)str,&dwBufLen);
	            
	if((lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) ) {
		RegCloseKey(hKey);
		logEvent(logName,string("SisIYAwinclient::getCPUInfo: Could not get the Identifier information"),EVENTLOG_ERROR_TYPE);
		return;
	}
	msg+=string(" ")+str;

	info.add();
	info.setServiceID(sisiyaConf.getInt("serviceid_cpu"));
	info.setStatusID(statusid_info);
	info.setMessage(msg);
	RegCloseKey(hKey);
	return;
}

/*!
Return the checkInterval value.
*/
long int SisIYAwinclient::getCheckInterval(void)
{
	return checkInterval;
}

/*!
Get information about the file system.
*/
void SisIYAwinclient::getFilesystemInfo(void)
{
	string msg;

	DWORD driveMask;	// the bitmask representing the currently available disk drives.
						// Bit position 0 (the least-significant bit) is drive A, bit 
						// position 1 is drive B, bit position 2 is drive C, and so on.
	UINT driveType;		// the type of the drive
	char driveName[4];	// c:\ d:\ etc
	DWORD sectorsPerClustes=0;		// Number of sectors per cluster.
	DWORD bytesPerSector=0;			// Number of bytes per sector.
	DWORD numberOfFreeClusters=0;		// The total number of free clusters on the 
										// disk that are available to the user associated with the calling thread. 
										// If per-user disk quotas are in use, this value may be less than the 
										// total number of free clusters on the disk.
	DWORD totalNumberOfClusters=0;	// Total number of clusters on the disk
										// that are available to the user associated with the calling thread.
										// If per-user disk quotas are in use, this value may be less than 
										// the total number of clusters on the disk.
	char bufOK[BUFSIZE];
	char bufWarning[BUFSIZE];
	char bufError[BUFSIZE];

	bufOK[0]='\0';
	bufWarning[0]='\0';
	bufError[0]='\0';

	info.add();
	info.setServiceID(sisiyaConf.getInt("serviceid_filesystem"));
	info.setStatusID(statusid_ok);

	driveMask=GetLogicalDrives();

	if(driveMask == 0) {
		msg="Could not obtain filesystem information! Drive mask returned 0!";
		info.setMessage(msg);
		logEvent(logName,string("SisIYAwinclient::getFilesystemInfo: Could not obtain filesystem information! Drive mask returned 0!"),EVENTLOG_ERROR_TYPE);
		return;
	}
	SetErrorMode(SEM_FAILCRITICALERRORS);	// The system does not display the critical-error-handler message box. 
											// Instead, the system sends the error to the calling process.
	driveName[1]=':';
	driveName[2]='\\';
	driveName[3]='\0';
	for(driveName[0]='A';driveName[0]<='Z';driveName[0]++) {
		if(driveMask & 1) {
			driveType=GetDriveType(driveName);
			switch(driveType) {
				case DRIVE_UNKNOWN :
#ifdef DEBUG
	logEvent(logName,string("SisIYAwinclient::getFilesystemInfo: ")+string(driveName)+string(" The drive type cannot be determined."),EVENTLOG_INFORMATION_TYPE);
#endif
					break;
				case DRIVE_NO_ROOT_DIR:
#ifdef DEBUG
	logEvent(logName,string("SisIYAwinclient::getFilesystemInfo: ")+string(driveName)+string(" The root path is invalid. For example, no volume is mounted at the path."),EVENTLOG_INFORMATION_TYPE);
#endif
					break;
				case DRIVE_REMOVABLE :
#ifdef DEBUG
	logEvent(logName,string("SisIYAwinclient::getFilesystemInfo: ")+string(driveName)+string(" The disk can be removed from the drive."),EVENTLOG_INFORMATION_TYPE);
#endif
					break;
				case DRIVE_REMOTE :
#ifdef DEBUG
	logEvent(logName,string("SisIYAwinclient::getFilesystemInfo: ")+string(driveName)+string(" The drive is a remote (network) drive."),EVENTLOG_INFORMATION_TYPE);
#endif
					break;
				case DRIVE_CDROM :
#ifdef DEBUG
	logEvent(logName,string("SisIYAwinclient::getFilesystemInfo: ")+string(driveName)+string(" The drive is a CD-ROM drive."),EVENTLOG_INFORMATION_TYPE);
#endif
					break;
				case DRIVE_RAMDISK :
#ifdef DEBUG
	logEvent(logName,string("SisIYAwinclient::getFilesystemInfo: ")+string(driveName)+string(" The drive is a RAM disk."),EVENTLOG_INFORMATION_TYPE);
#endif
					break;
				case DRIVE_FIXED :
#ifdef DEBUG
	logEvent(logName,string("SisIYAwinclient::getFilesystemInfo: ")+string(driveName)+string(" The disk cannot be removed from the drive."),EVENTLOG_INFORMATION_TYPE);
#endif
					if(GetDiskFreeSpace(driveName,&sectorsPerClustes,&bytesPerSector,&numberOfFreeClusters,&totalNumberOfClusters) != 0) {
						double totalSpace=((double)totalNumberOfClusters*sectorsPerClustes*bytesPerSector)/(1024*1024*1024);
						double freeSpace=((double)numberOfFreeClusters*sectorsPerClustes*bytesPerSector)/(1024*1024*1024);						
						int usage=int(100.0*(totalNumberOfClusters-numberOfFreeClusters)/totalNumberOfClusters);
						//cout << "SisIYAwinclient::getFilesystemInfo: totalNumberOfClusters=" << totalNumberOfClusters << " numberOfFreeClusters=" << numberOfFreeClusters << " sectorsPerClustes=" << sectorsPerClustes << " bytesPerSector=" << bytesPerSector << " usage=" << usage << endl; 
						char str[BUFSIZE];
						if(usage >= error_fs) {
							if(bufError[0] == '\0')
								sprintf_s(bufError,BUFSIZE,"ERROR: %s (total=%.1lfGB free=%.1lfGB) %d%% >= %d%% full.",driveName,totalSpace,freeSpace,usage,error_fs);
							else {
								sprintf_s(str,BUFSIZE," ERROR: %s (total=%.1lfGB free=%d.1lfGB) %d%% >= %d%% full.",driveName,totalSpace,freeSpace,usage,error_fs);
								strcat_s(bufError,BUFSIZE,str);
							}
						}
						else if(usage >= warning_fs) {
							if(bufWarning[0] == '\0')
								sprintf_s(bufWarning,BUFSIZE,"WARNING: %s (total=%.1lfGB free=%.1lfGB) %d%% >= %d%% full.",driveName,totalSpace,freeSpace,usage,warning_fs);
							else {								
								sprintf_s(str,BUFSIZE," WARNING: %s (total=%.1lfGB free=%.1lfGB) %d%% >= %d%% full.",driveName,totalSpace,freeSpace,usage,warning_fs);
								strcat_s(bufWarning,BUFSIZE,str);
							}
						}
						else {
							if(bufOK[0] == '\0')
								sprintf_s(bufOK,BUFSIZE,"OK: %s (total=%.1lfGB free=%.1lfGB) %d%% full.",driveName,totalSpace,freeSpace,usage);
							else {		
								sprintf_s(str,BUFSIZE," OK: %s (total=%.1lfGB free=%.1lfGB) %d%% full.",driveName,totalSpace,freeSpace,usage);
								strcat_s(bufOK,BUFSIZE,str);
							}
						}
					}
#ifdef DEBUG
					else {					
						int lastError=GetLastError();
						LPVOID lpMsgBuf;
						FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,NULL,
							lastError,0,(LPTSTR)&lpMsgBuf,0,NULL);
						ostringstream osstr;
						
						osstr << "SisIYAwinclient::getFilesystem: Error ocured calling the GetDiskFreeSpaceA function!";
						osstr << "Error code: " << lastError << " Message: " << lpMsgBuf << ends;
						logEvent(logName,osstr.str(),EVENTLOG_ERROR_TYPE);
						LocalFree(lpMsgBuf);
					}
#endif
					break;
				default :
#ifdef DEBUG
	logEvent(logName,string("SisIYAwinclient::getFilesystem: [")+string(driveName)+string("] Undocumented drive type!"),EVENTLOG_WARNING_TYPE);
#endif
					break;
			}
		}
		driveMask>>=1;
	}

	if(bufError[0] != '\0') {
		info.setStatusID(statusid_error);
		msg=string(bufError)+string(" ");
	}
	if(bufWarning[0] != '\0') {
		if(info.getStatusID() < statusid_warning)
			info.setStatusID(statusid_warning);
		if(msg.size() == 0)
			msg=string(bufWarning)+string(" ");
		else
			msg+=string(" ")+string(bufWarning)+string(" ");
	}
	if(bufOK[0] != '\0') {
		if(info.getStatusID() < statusid_ok)
			info.setStatusID(statusid_ok);
		if(msg.size() == 0)
			msg=string(bufOK);
		else
			msg+=string(" ")+string(bufOK);
	}
	if(msg.size() == 0)
		msg="Could not obtain filesystem information!";
	info.setMessage(msg);
}

/*!
Get system name.
*/
void SisIYAwinclient::getHostName(void)
{
	LPTSTR lpszSystemInfo;		// pointer to system information string 
	DWORD cchBuff=BUFSIZE;		// size of computer or user name 
	TCHAR tchBuffer[BUFSIZE];	// buffer for string
  
	lpszSystemInfo=tchBuffer; 
 
	if(GetComputerName(lpszSystemInfo,&cchBuff))
		hostName=(char *)CharLower(lpszSystemInfo);
}

/*!
Get the total CPU load in %.
*/
void SisIYAwinclient::getLoadInfo(void)
{
	HQUERY hQuery;
	HCOUNTER hCounter;
	PDH_FMT_COUNTERVALUE FmtValue;

	if(PdhOpenQuery(0,0,&hQuery) != ERROR_SUCCESS) {
		cerr << "SisIYAwinclient::getLoadInfo: Error calling PdhOpenQuery function!" << endl;
		return;
	}
/*
	char *str="\\Prozessor(_Total)\\Prozessorzeit (%)";
	PDH_STATUS pdhStatus=PdhAddCounter(hQuery,str,0,&hCounter);
	// find another way to distinguish between DE and EN systems
	if(pdhStatus != ERROR_SUCCESS) {
		str="\\Processor(_Total)\\% Processor Time";	
		pdhStatus=PdhAddCounter(hQuery,str,0,&hCounter);
	}
	if(pdhStatus != ERROR_SUCCESS) {
		str="\\Ýþlemci(_Toplam)\\% Ýþlemci Süresi";	
		pdhStatus=PdhAddCounter(hQuery,str,0,&hCounter);
	}
	*/
	PDH_STATUS pdhStatus=PdhAddCounter(hQuery,loadKey.c_str(),0,&hCounter);
	if(pdhStatus != ERROR_SUCCESS) {
		//logEvent(logName,string("SisIYAwinclient::getLoadInfo: Could not add pdh counter for str=")+string(str)+string(" Message : ")+getPdhStatusMessage(pdhStatus),EVENTLOG_ERROR_TYPE);
		logEvent(logName,string("SisIYAwinclient::getLoadInfo: Could not add pdh counter for str=")+loadKey+string(" Message : ")+getPdhStatusMessage(pdhStatus),EVENTLOG_ERROR_TYPE);
		//cout << string("SisIYAwinclient::getLoadInfo: Could not add pdh counter for str=") << loadKey << string(" Message : ") << getPdhStatusMessage(pdhStatus) << endl;
		PdhCloseQuery(hQuery);
		return;
	}
	long usage=0;
	for(int i=0;i<8;i++) {
		pdhStatus=PdhCollectQueryData(hQuery);
		if(pdhStatus != ERROR_SUCCESS) {
			logEvent(logName,string("SisIYAwinclient::getLoadInfo: Error calling PdhCollectQueryData function!"),EVENTLOG_ERROR_TYPE);
			PdhCloseQuery(hQuery);
			return;
		}
		// do not use the first 3, they usually effected by our process
		if(i < 3) {
			Sleep(1000);
			continue;
		}
		
		//pdhStatus=PdhGetFormattedCounterValue(hCounter,PDH_FMT_DOUBLE,NULL,&FmtValue);
		pdhStatus=PdhGetFormattedCounterValue(hCounter,PDH_FMT_LONG,NULL,&FmtValue);
		if(pdhStatus == ERROR_SUCCESS) {
			//cout << "The cpu usage is : " << FmtValue.doubleValue << endl;
			//cout << "The cpu usage is : " << FmtValue.longValue << endl;
			usage+=FmtValue.longValue;
		}
		else {
			logEvent(logName,string("SisIYAwinclient::getLoadInfo: Error calling PdhGetFormattedCounterValue function!"),EVENTLOG_ERROR_TYPE);
		}
		Sleep(1000);
	}
	PdhCloseQuery(hQuery);
	usage=usage/5;

	info.add();
	info.setServiceID(sisiyaConf.getInt("serviceid_load"));
	char str2[BUFSIZE];
	if(usage >= error_load) {
		info.setStatusID(statusid_error);
		sprintf_s(str2,BUFSIZE,"ERROR: Load is %d%% >= %d%%!",usage,error_load);
		info.setMessage(string(str2));
	}
	else if(usage >= warning_load) {
		info.setStatusID(statusid_warning);
		sprintf_s(str2,BUFSIZE,"WARNING: Load is %d%% >= %d%%!",usage,warning_load);
		info.setMessage(string(str2));
	}
	else {
		info.setStatusID(statusid_ok);
		sprintf_s(str2,BUFSIZE,"OK: Load is %d%%.",usage);
		info.setMessage(string(str2));
	}
}

/*!
Get operating system version.
*/
string SisIYAwinclient::getOSVersion(void)
{
	char str1[BUFSIZE],str2[BUFSIZE],str3[BUFSIZE];	 
	OSVERSIONINFOEX osvi;
	BOOL bOsVersionInfoEx;

	str2[0]='\0';
	str3[0]='\0';

	// Try calling GetVersionEx using the OSVERSIONINFOEX structure.
	// If that fails, try using the OSVERSIONINFO structure.

	ZeroMemory(&osvi,sizeof(OSVERSIONINFOEX));
	osvi.dwOSVersionInfoSize=sizeof(OSVERSIONINFOEX);

	//if(!(bOsVersionInfoEx=GetVersionEx((OSVERSIONINFO *)&osvi)) == false) {
	if((bOsVersionInfoEx=GetVersionEx((OSVERSIONINFO *)&osvi)) == false) {
		osvi.dwOSVersionInfoSize=sizeof(OSVERSIONINFO);
		/* 
		if (! GetVersionEx ( (OSVERSIONINFO *) &osvi) ) 
			return FALSE;
		*/
	}

	switch(osvi.dwPlatformId) {
		case VER_PLATFORM_WIN32_NT:	// Test for the Windows NT product family.
			// Test for the specific product family.
			if(osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2)
				sprintf_s(str1,BUFSIZE,"Microsoft Windows Server 2003 family, ");
			if(osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1)
				sprintf_s(str1,BUFSIZE,"Microsoft Windows XP ");
			if(osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0)
				sprintf_s(str1,BUFSIZE,"Microsoft Windows 2000 ");
			if(osvi.dwMajorVersion <= 4)
				sprintf_s(str1,BUFSIZE,"Microsoft Windows NT ");

			// Test for specific product on Windows NT 4.0 SP6 and later.
			if(bOsVersionInfoEx) {
				// Test for the workstation type.
				if(osvi.wProductType == VER_NT_WORKSTATION) {
					if(osvi.dwMajorVersion == 4)
						sprintf_s(str2,BUFSIZE,"Workstation 4.0 ");
					else if(osvi.wSuiteMask & VER_SUITE_PERSONAL)
						sprintf_s(str2,BUFSIZE,"Home Edition ");
					else
						sprintf_s(str2,BUFSIZE,"Professional ");
				}
				else if (osvi.wProductType == VER_NT_SERVER) {  // Test for the server type.
					if(osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2) {
						if(osvi.wSuiteMask & VER_SUITE_DATACENTER)
							sprintf_s(str2,BUFSIZE,"Datacenter Edition ");
						else if(osvi.wSuiteMask & VER_SUITE_ENTERPRISE)
							sprintf_s(str2,BUFSIZE,"Enterprise Edition ");
						else if(osvi.wSuiteMask == VER_SUITE_BLADE)
							sprintf_s(str2,BUFSIZE,"Web Edition ");
						else
							sprintf_s(str2,BUFSIZE,"Standard Edition ");
					}
					else if(osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0) {
						if(osvi.wSuiteMask & VER_SUITE_DATACENTER)
							sprintf_s(str2,BUFSIZE,"Datacenter Server ");
						else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE)
							sprintf_s(str2,BUFSIZE,"Advanced Server ");
						else
							sprintf_s(str2,BUFSIZE,"Server ");
					}
					else { // Windows NT 4.0 
						if(osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
							sprintf_s(str2,BUFSIZE,"Server 4.0, Enterprise Edition ");
						else
							sprintf_s(str2,BUFSIZE,"Server 4.0 ");
					}
				}
			}
			else  { // Test for specific product on Windows NT 4.0 SP5 and earlier
				HKEY hKey;
				char szProductType[BUFSIZE];
				DWORD dwBufLen=BUFSIZE;
				LONG lRet;
				
				lRet=RegOpenKeyEx(HKEY_LOCAL_MACHINE,(LPCSTR)"SYSTEM\\CurrentControlSet\\Control\\ProductOptions",0, KEY_QUERY_VALUE, &hKey );
				/*            
				if( lRet != ERROR_SUCCESS )
					return FALSE;

				*/
				lRet=RegQueryValueEx(hKey,(LPCSTR)"ProductType",NULL,NULL,(LPBYTE)szProductType,&dwBufLen);
				/*            
				if( (lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) )
					return FALSE;
				*/

				RegCloseKey(hKey);

				if(lstrcmpi((LPCSTR)"WINNT",(LPCSTR)szProductType) == 0)
					sprintf_s(str3,BUFSIZE,"Workstation ");
				if(lstrcmpi((LPCSTR)"LANMANNT",(LPCSTR)szProductType) == 0)
					sprintf_s(str3,BUFSIZE,"Server ");
				if(lstrcmpi((LPCSTR)"SERVERNT",(LPCSTR)szProductType) == 0)
					sprintf_s(str3,BUFSIZE,"Advanced Server ");

				sprintf_s(str2,BUFSIZE,"%s %d.%d ",str3,osvi.dwMajorVersion,osvi.dwMinorVersion);
				str3[0]='\0';
			}

			// Display service pack (if any) and build number.
			if(osvi.dwMajorVersion == 4 && lstrcmpi(osvi.szCSDVersion,(LPCSTR)"Service Pack 6") == 0) {
				HKEY hKey;
				LONG lRet;

				// Test for SP6 versus SP6a.
				lRet=RegOpenKeyEx(HKEY_LOCAL_MACHINE,(LPCSTR)"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Hotfix\\Q246009",0,KEY_QUERY_VALUE,&hKey);
				if(lRet == ERROR_SUCCESS )
					sprintf_s(str3,BUFSIZE,"Service Pack 6a (Build %d)", osvi.dwBuildNumber & 0xFFFF);
				else { // Windows NT 4.0 prior to SP6a
					sprintf_s(str3,BUFSIZE,"%s (Build %d)",osvi.szCSDVersion,osvi.dwBuildNumber & 0xFFFF);
				}
				RegCloseKey(hKey);
			}
			else { // Windows NT 3.51 and earlier or Windows 2000 and later
				sprintf_s(str3,BUFSIZE,"%s (Build %d)",osvi.szCSDVersion,osvi.dwBuildNumber & 0xFFFF);
			}
			break;
		case VER_PLATFORM_WIN32_WINDOWS: // Test for the Windows 95 product family.
			if(osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 0) {
				sprintf_s(str1,BUFSIZE,"Microsoft Windows 95 ");
				if(osvi.szCSDVersion[1] == 'C' || osvi.szCSDVersion[1] == 'B')
					sprintf_s(str1,BUFSIZE,"OSR2 ");
			}
			if(osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 10) {
				sprintf_s(str1,BUFSIZE,"Microsoft Windows 98 ");
				if(osvi.szCSDVersion[1] == 'A')
					sprintf_s(str1,BUFSIZE,"SE ");
			}
			if(osvi.dwMajorVersion == 4 && osvi.dwMinorVersion == 90) {
				sprintf_s(str1,BUFSIZE,"Microsoft Windows Millennium Edition");
			} 
			break;
		case VER_PLATFORM_WIN32s:
			sprintf_s(str1,BUFSIZE,"Microsoft Win32s");
			break;
	}
	return string(str1)+string(str2)+string(str3);
}

/*!
replace this function.
*/
string SisIYAwinclient::getPdhStatusMessage(PDH_STATUS status)
{
	switch(status) {
		case PDH_CSTATUS_BAD_COUNTERNAME :
			return string("The counter name path string could not be parsed or interpreted.");
			break;
		case PDH_CSTATUS_NO_COUNTER :
			return string("The specified counter was not found.");
			break;
		case PDH_CSTATUS_NO_COUNTERNAME :
			return string("An empty counter name path string was passed in.");
			break;
		case PDH_CSTATUS_NO_MACHINE :
			return string("A computer entry could not be created.");
			break;
		case PDH_CSTATUS_NO_OBJECT :
			return string("The specified object could not be found.");
			break;
		case PDH_FUNCTION_NOT_FOUND :
			return string("The calculation function for this counter could not be determined.");
			break;
		case PDH_INVALID_ARGUMENT :
			return string("One or more arguments are invalid.");
			break;
		case PDH_INVALID_HANDLE :
			return string("The query handle is not valid.");
			break;
		case PDH_MEMORY_ALLOCATION_FAILURE :
			return string("A memory buffer could not be allocated.");
			break;
		case ERROR_SUCCESS :
			return string("OK");
			break;
		default  :
			return string("Unknown status code returned from pdhAddCounterHandle status=");
			break;
	}
}


void SisIYAwinclient::getProcessesAndThreads(void)
{
	char line[BUFSIZE];
	char str[BUFSIZE];

	char bufOK[BUFSIZE];
	char bufError[BUFSIZE];

	bufOK[0]='\0';
	bufError[0]='\0';

	ifstream file;
	
	string fname=string(confDir+string("\\systems\\")+hostName+string("\\sisiya_progs.conf"));
	file.open(fname.c_str(),ios::in);
	// if there is no such file, then do nothing.
	if(!file) {
		cerr << "SisIYAwinclient::getProcessesAndThreads: Could open file " << fname << " for reading." << endl;
		return;
	}

	while(!file.eof()) {
		file.getline(line,BUFSIZE-1);		
		//cout << "line=[" << line << "]" << endl;
		if(isLineCommentOrEmpty(line,'#'))
			continue;
		if(checkProcess(line)) {
			if(bufOK[0] == '\0')
				sprintf_s(bufOK,BUFSIZE,"OK: %s",line);
			else {		
				sprintf_s(str,BUFSIZE,", %s",line);
				strcat_s(bufOK,BUFSIZE,str);
			}
		}
		else {
			if(bufError[0] == '\0')
				sprintf_s(bufError,BUFSIZE,"ERROR: %s",line);
			else {
				sprintf_s(str,BUFSIZE,", %s",line);
				strcat_s(bufError,BUFSIZE,str);
			}
		}
	}
	file.close();

	if(bufOK[0] == '\0' && bufError[0] == '\0')
		return; // the file did not contain any program name

	info.add();
	info.setServiceID(sisiyaConf.getInt("serviceid_progs"));
	info.setStatusID(statusid_ok);
	
	string msg;

	if(bufError[0] != '\0') {
		info.setStatusID(statusid_error);
		msg=string(bufError);
	}
	if(bufOK[0] != '\0') {
		if(info.getStatusID() < statusid_ok)
			info.setStatusID(statusid_ok);
		if(msg.size() == 0)
			msg=string(bufOK);
		else
			msg+=string(" ")+string(bufOK);
	}
	if(msg.size() == 0)
		msg="Could not obtain nformation about the running processes!";
	info.setMessage(msg);
}


/*!
Information about swap. The check is performed only on virtual memory. The RAM and page file along with
virtual memeory is given only for informational purposes.
*/
void SisIYAwinclient::getSwapInfo(void)
{
	MEMORYSTATUS stat;
	int usage;
	char str[BUFSIZE];

    GlobalMemoryStatus(&stat);

	info.add();
	info.setServiceID(sisiyaConf.getInt("serviceid_swap"));
	info.setStatusID(statusid_ok);
	
	//usage=int(100*(stat.dwTotalVirtual-stat.dwAvailVirtual)/stat.dwTotalVirtual);
	usage=int(100*(stat.dwTotalPageFile-stat.dwAvailPageFile)/stat.dwTotalPageFile);
	if(usage >= error_swap) {
		info.setStatusID(statusid_error);
		sprintf_s(str,BUFSIZE,"ERROR: Swap usage is %d%% >= %d%%. ",usage,error_swap);
	}
	else if(usage >= warning_swap) {
		info.setStatusID(statusid_warning);
		sprintf_s(str,BUFSIZE,"WARNING: Swap usage is %d%% >= %d%%. ",usage,warning_swap);
	}
	else {
		sprintf_s(str,BUFSIZE,"OK: Swap usage is %d%%. ",usage);
	}
	
	char str2[BUFSIZE];
	double total,free,used;
	
	total=(double)stat.dwTotalPhys/(1024*1024);
	free=(double)stat.dwAvailPhys/(1024*1024);
	used=(double)(stat.dwTotalPhys-stat.dwAvailPhys)/(1024*1024);
	if(total > 1000) {
		total=total/1024;
		sprintf_s(str2,BUFSIZE,"RAM: total=%.1lfGB ",total);		
	}
	else 
		sprintf_s(str2,BUFSIZE,"RAM: total=%.0lfMB ",total);
	strcat_s(str,BUFSIZE,str2);
	if(used > 1000) {
		used=used/1024;
		sprintf_s(str2,BUFSIZE,"used=%.1lfGB ",used);
	}
	else 
		sprintf_s(str2,BUFSIZE,"used=%.0lfMB ",used);
	strcat_s(str,BUFSIZE,str2);

	if(free > 1000) {
		free=free/1024;
		sprintf_s(str2,BUFSIZE,"free=%.1lfGB.",free);
	}
	else 
		sprintf_s(str2,BUFSIZE,"free=%.0lfMB.",free);
	strcat_s(str,BUFSIZE,str2);

	total=(double)stat.dwTotalPageFile/(1024*1024);
	free=(double)stat.dwAvailPageFile/(1024*1024);
	used=(double)(stat.dwTotalPageFile-stat.dwAvailPageFile)/(1024*1024);
	if(total > 1000) {
		total=total/1024;
		sprintf_s(str2,BUFSIZE," Page file: total=%.1lfGB ",total);		
	}
	else 
		sprintf_s(str2,BUFSIZE," Page file: total=%.0lfMB ",total);
	strcat_s(str,BUFSIZE,str2);
	if(used > 1000) {
		used=used/1024;
		sprintf_s(str2,BUFSIZE,"used=%.1lfGB ",used);
	}
	else 
		sprintf_s(str2,BUFSIZE,"used=%.0lfMB ",used);
	strcat_s(str,BUFSIZE,str2);

	if(free > 1000) {
		free=free/1024;
		sprintf_s(str2,BUFSIZE,"free=%.1lfGB.",free);
	}
	else 
		sprintf_s(str2,BUFSIZE,"free=%.0lfMB.",free);
	strcat_s(str,BUFSIZE,str2);

	total=(double)stat.dwTotalVirtual/(1024*1024);
	free=(double)stat.dwAvailVirtual/(1024*1024);
	used=(double)(stat.dwTotalVirtual-stat.dwAvailVirtual)/(1024*1024);
	if(total > 1000) {
		total=total/1024;
		sprintf_s(str2,BUFSIZE," Virtual memory: total=%.1lfGB ",total);		
	}
	else 
		sprintf_s(str2,BUFSIZE," Virtual memory: total=%.0lfMB ",total);
	strcat_s(str,BUFSIZE,str2);
	if(used > 1000) {
		used=used/1024;
		sprintf_s(str2,BUFSIZE,"used=%.1lfGB ",used);
	}
	else 
		sprintf_s(str2,BUFSIZE,"used=%.0lfMB ",used);
	strcat_s(str,BUFSIZE,str2);

	if(free > 1000) {
		free=free/1024;
		sprintf_s(str2,BUFSIZE,"free=%.1lfGB.",free);
	}
	else 
		//sprintf(str2,"free=%.0lfMB.",free);
		sprintf_s(str2,BUFSIZE,"free=%.0lfMB.",free);
	//strcat(str,str2);
	strcat_s(str,BUFSIZE,str2);
	info.setMessage(string(str));
}

/*!
Get information about the system version and check for uptime.
*/
void SisIYAwinclient::getSystemInfo(void)
{
	string osVersion=getOSVersion();

	info.add();
	info.setServiceID(sisiyaConf.getInt("serviceid_system"));
	
	double upTime=getUptime();
	int days=int(upTime/86400);
	upTime-=days*86400;
	int hours=int(upTime/3600);
	upTime-=hours*3600;
	int minutes=int(upTime/60);
	upTime=days*1440+hours*60+minutes; // we do not use seconds, upTime is now in minutes

	//cout << "days=" << days << " hours=" << hours << " minutes=" << minutes << endl;
	//cout << "uptime=" << upTime << endl;

	int error_days,error_hours,error_minutes;
	extractUptimes(error_uptime,error_days,error_hours,error_minutes);
	//cout << "SisIYAwinclient::getSystemInfo: error_days=" << error_days << " error_hours=" << error_hours << " error_minutes=" << error_minutes << endl;

	int warning_days,warning_hours,warning_minutes;
	extractUptimes(warning_uptime,warning_days,warning_hours,warning_minutes);
	//cout << "SisIYAwinclient::getSystemInfo: warning_days=" << warning_days << " warning_hours=" << warning_hours << " warning_minutes=" << warning_minutes << endl;
	
	double error_in_minutes=error_days*1440+error_hours*60+error_minutes;
	double warning_in_minutes=warning_days*1440+warning_hours*60+warning_minutes;
	//cout << "SisIYAwinclient::getSystemInfo: error_in_minutes=" << error_in_minutes << " warning_in_minutes=" << warning_in_minutes << endl;	
	ostringstream osstr;
	if(upTime < error_in_minutes) {
		info.setStatusID(statusid_error);
		osstr << "ERROR: The system was restarted ";
		osstr << formTimeString(days,hours,minutes) << " (< " << formTimeString(error_days,error_hours,error_minutes) << ") ago! ";
	}
	else if(upTime < warning_in_minutes) {
		info.setStatusID(statusid_warning);
		osstr << "WARNING: The system was restarted ";
		osstr << formTimeString(days,hours,minutes) << " (< " << formTimeString(warning_days,warning_hours,warning_minutes) << ") ago! ";
	}
	else {
		info.setStatusID(statusid_ok);
		osstr << "OK: The system is up since " << formTimeString(days,hours,minutes) << ". ";
	}
	info.setMessage(osstr.str()+osVersion);
}


/*!
Get info about this server.
*/ 
string SisIYAwinclient::getTimeString(void)
{
	struct tm dateToday;
	time_t timeToday;
	char buffer[BUFSIZE];
	
	time(&timeToday);
	localtime_s(&dateToday,&timeToday);
	sprintf_s(buffer,BUFSIZE,"%d%.2d%.2d %.2d:%.2d:%.2d",1900+dateToday.tm_year,1+dateToday.tm_mon,dateToday.tm_mday,
		dateToday.tm_hour,dateToday.tm_min,1+dateToday.tm_sec);
	return string(buffer);
}

/*!
Returns uptime in seconds, -1.0 on error.
*/
double SisIYAwinclient::getUptime(void)
{
	HQUERY hQuery;
	HCOUNTER hCounter;
	PDH_FMT_COUNTERVALUE FmtValue;

	if(PdhOpenQuery(0,0,&hQuery) != ERROR_SUCCESS) {
		//cerr << "SisIYAwinclient::getUptime: Error calling PdhOpenQuery function!" << endl;
		return -1.0;
	}
/*
	const char *str="\\System\\Systembetriebszeit";
	//cout << "SisIYAwinclient::getUptime: str=" << str << endl;

	PDH_STATUS pdhStatus=PdhAddCounter(hQuery,str,0,&hCounter);
	if(pdhStatus != ERROR_SUCCESS) 
		pdhStatus=PdhAddCounter(hQuery,"\\System\\System Up Time",0,&hCounter);
	if(pdhStatus != ERROR_SUCCESS) 
		pdhStatus=PdhAddCounter(hQuery,"\\Sistem\\Sistem Çalýþma Zamaný",0,&hCounter);
*/
//	cout << "uptimeKey=" << uptimeKey << endl;
//	cout << "loadKey=" << loadKey << endl;
	PDH_STATUS pdhStatus=PdhAddCounter(hQuery,uptimeKey.c_str(),0,&hCounter);
	if(pdhStatus != ERROR_SUCCESS) {
		logEvent(logName,string("SisIYAwinclient::getUptime: Error : ")+getPdhStatusMessage(pdhStatus),EVENTLOG_ERROR_TYPE);
		PdhCloseQuery(hQuery);
		return -1.0;
	}
	
	pdhStatus=PdhCollectQueryData(hQuery);
	if(pdhStatus != ERROR_SUCCESS) {
		logEvent(logName,string("SisIYAwinclient::getUptime: Error calling PdhCollectQueryData function!"),EVENTLOG_ERROR_TYPE);
		PdhCloseQuery(hQuery);
		return -1.0;
	}

	pdhStatus=PdhGetFormattedCounterValue(hCounter,PDH_FMT_DOUBLE,NULL,&FmtValue);
	if(pdhStatus == ERROR_SUCCESS) {
		//cout << "Uprime =" << FmtValue.doubleValue << endl;
		PdhCloseQuery(hQuery);
		return FmtValue.doubleValue;
	}
	else {
		logEvent(logName,string("SisIYAwinclient::getUptime: Error calling PdhGetFormattedCounterValue function!"),EVENTLOG_ERROR_TYPE);
		PdhCloseQuery(hQuery);
		return -1.0;
	}
}

string formTimeString(int days,int hours,int minutes)
{
	ostringstream osstr;

	if(days > 1)
		osstr << days << " days";
	else if(days == 1)
		osstr << days << " day";
	osstr << " ";
	if(hours > 1)
		osstr << hours << " hours";
	else if(hours == 1)
		osstr << hours << " hour";
	osstr << " ";
	if(minutes > 1)
		osstr << minutes << " minutes";
	else if(minutes == 1)
		osstr << minutes << " minute";
	//osstr << ends;
	return trim(osstr.str());
}

/*!
Sends all messages at once using only one connection to the SisIYA server.
*/
void SisIYAwinclient::sendAll(void)
{
	//int bytesSent;
	//int bytesRecv=SOCKET_ERROR;

	mySocket=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
	if(mySocket == INVALID_SOCKET) {
		cerr << "Error at socket(): " << WSAGetLastError() << "\n";
		WSACleanup();
		exit(1);
	}
	 
	sockaddr_in clientService;
	clientService.sin_family=AF_INET;
	clientService.sin_addr.s_addr=inet_addr((const char *)serverIP.c_str());
	clientService.sin_port=htons((u_short)port);

	if(connect(mySocket,(SOCKADDR*)&clientService,sizeof(clientService)) == SOCKET_ERROR) { 
		cerr << "Failed to connect to " << serverIP << ":" << port <<" !\n";
    	return;
	}

	for(int i=0;i<info.getCount();i++) {
		//bytesSent=send(mySocket,info.getSisIYAMessage(i,hostName).c_str(),(int)strlen(info.getSisIYAMessage(i,hostName).c_str()),0);
		send(mySocket,info.getSisIYAMessage(i,hostName,delimiter).c_str(),(int)strlen(info.getSisIYAMessage(i,hostName,delimiter).c_str()),0);
	}
		
	if(closesocket(mySocket) != 0) {
		cerr << "Socket close error!\n";
	}
}

/*!
Sets the default configuration options.
*/
void SisIYAwinclient::setDefaults(void)
{
	sisiyaConf.setDefault("SISIYA_SERVER","localhost");
	sisiyaConf.setDefault("SISIYA_PORT",8888);
	sisiyaConf.setDefault("check_interval",5);
	sisiyaConf.setDefault("expire",10);
	sisiyaConf.setDefault("SP","~");

	sisiyaConf.setDefault("uptimeKey","\\System\\System Up Time");
	sisiyaConf.setDefault("loadKey","\\Processor(_Total)\\% Processor Time");

	sisiyaConf.setDefault("statusid_info",0);
	sisiyaConf.setDefault("statusid_ok",1);
	sisiyaConf.setDefault("statusid_warning",2);
	sisiyaConf.setDefault("statusid_error",3);

	sisiyaConf.setDefault("serviceid_system",0);
	sisiyaConf.setDefault("error_uptime","1");
	sisiyaConf.setDefault("warning_uptime","3");

	sisiyaConf.setDefault("serviceid_filesystem",1);
	sisiyaConf.setDefault("error_fs",90);
	sisiyaConf.setDefault("warning_fs",85);
	
	sisiyaConf.setDefault("serviceid_cpu",2);

	sisiyaConf.setDefault("serviceid_swap",3);
	sisiyaConf.setDefault("error_swap",50);
	sisiyaConf.setDefault("warning_swap",30);

	sisiyaConf.setDefault("serviceid_load",4);
	sisiyaConf.setDefault("error_load",90);
	sisiyaConf.setDefault("warning_load",80);

	sisiyaConf.setDefault("serviceid_progs",48);
}

/*!
Sends all messages at once using only one connection to the SisIYA server.
*/
void SisIYAwinclient::showAll(void)
{
	for(int i=0;i<info.getCount();i++) {
		cout << "info=[" << info.getSisIYAMessage(i,hostName,delimiter) << "]" << endl;
	}
}
