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

#include"stdafx.h"
#include<string.h>
#include"SisIYAws.h"
#include"SisIYAwinclient.h"
#include<time.h>
#include"EventLog.h"

using namespace SisIYA;

using namespace System::Text;
using namespace System::Diagnostics;

using namespace System;
using namespace System::Diagnostics;


string getConfDir(void)
{
	HKEY hKey;
	static const int BUFSIZE=4096;
	char str[BUFSIZE];
	DWORD dwBufLen=BUFSIZE;
	LONG lRet;

	string progPath=string("Software\\")+string(progName);
	lRet=RegOpenKeyEx(HKEY_LOCAL_MACHINE,(LPCSTR)progPath.c_str(),0,KEY_QUERY_VALUE,&hKey);
	
	if(lRet != ERROR_SUCCESS) {
		RegCloseKey(hKey);
		return string("C:\\Programs Files\\")+string(progName); // use the default path
	}
	// there is only one key
	lRet=RegQueryValueEx(hKey,NULL,NULL,NULL,(LPBYTE)str,&dwBufLen);
	            
	if((lRet != ERROR_SUCCESS) || (dwBufLen > BUFSIZE) ) {
		RegCloseKey(hKey);
		return string("C:\\Programs Files\\")+string(progName); // use the default path
	}
	RegCloseKey(hKey);
	return string(str);
}

void showUsage(void)
{
	cout << "To install SisIYAws as a Windows service type		: SisIYAws -Install" << endl;
	cout << "To uninstall SisIYAws from service list type		: SisIYAws -Install /u" << endl;
	cout << "To run the SisIYAws on the command line			: SisIYAws -Console" << endl;
	cout << "To run the SisIYAws on the command line in test mode	: SisIYAws -Console -Test" << endl;
}

int _tmain(int argc, _TCHAR* argv[])
{
	if(argc >= 2)	{
		if(argv[1][0] == _T('/')) {
			argv[1][0] = _T('-');
		}

		if(_tcsicmp(argv[1], _T("-Install")) == 0)	{
			//Install this Windows Service using InstallUtil.exe
			String* myargs[]=System::Environment::GetCommandLineArgs();
			String* args[]=new String*[myargs->Length - 1];
			args[0]=myargs[0];
			Array::Copy(myargs,2,args,1,args->Length - 1);
			AppDomain* dom=AppDomain::CreateDomain(S"execDom");
			Type* type=__typeof(System::Object);
			String* path=type->get_Assembly()->get_Location();
			StringBuilder* sb=new StringBuilder(path->Substring(0, path->LastIndexOf(S"\\")));
			sb->Append(S"\\InstallUtil.exe");
			dom->ExecuteAssembly(sb->ToString(), 0, args);
		}
		else if(_tcsicmp(argv[1], _T("-help")) == 0) {
			showUsage();
			return 0;
		}
		else if(_tcsicmp(argv[1], _T("-Console")) == 0) {
			cout << "Running the program on the command line:" << endl;

			string confDir=getConfDir();
			SisIYAwinclient sisiya(string(progName),confDir.c_str());
			if(argc == 3 && _tcsicmp(argv[2], _T("-Test")) == 0) {
				cout << "Running in test mode: The messages are not going to be send to the SisIYA server." << endl;
				cout << "confDir=" << confDir << endl;
				sisiya.showAll();
			}
			else 
				sisiya.sendAll();

			return 0;
		}
		else {
			showUsage();
			return 0;
		}
	}
	else {
		ServiceBase::Run(new SisIYAws());    
	}
	return 0;
}

void SisIYAws::mainLoop(void)
{
	struct tm dateToday;
	time_t timeToday;
	long int checkInterval=5; // initial value is set to 5 minutes
	int r;

	stopping=false;
	loopsleep=60000;	// sleep 1 minute (milliseconds)
	while(!stopping) {
		time(&timeToday);
		localtime_s(&dateToday,&timeToday);
		if((dateToday.tm_min % checkInterval) == 0) {
			string confDir=getConfDir();
			SisIYAwinclient sisiya(string(progName),confDir.c_str());
			sisiya.sendAll();
			checkInterval=sisiya.getCheckInterval();
			// calculate sleep time
			if(checkInterval < 60) {
				time(&timeToday);
				r=dateToday.tm_min % checkInterval;
				loopsleep=1000*((checkInterval-r)*60-dateToday.tm_sec);
			}
			else
				loopsleep=60000;	// sleep 1 minute (milliseconds)
		}
		Threading::Thread::Sleep(loopsleep);
	}
}
