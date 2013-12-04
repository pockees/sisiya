#include"EventLog.h"

using namespace std;

void logEvent(string appName,string msg,WORD type)
{
	HANDLE h;
 
    h=RegisterEventSource(NULL,TEXT(appName.c_str()));
	if(h == NULL) {
		cerr << "logEvent: Could not register the event source for" << appName.c_str() << endl;
		return;
	}
 	const char *p=msg.c_str();
	if(ReportEvent(h,type,0,(DWORD)1,NULL,1,0,(LPCSTR *)&p,NULL) == 0) {
		cerr << "logEvent: Could not report the event :" << msg.c_str() << endl;
		cerr << "logEvent: Last error : " << GetLastError() << endl;
		DeregisterEventSource(h); 
		return;
	}
    DeregisterEventSource(h); 
}
