/*
    Copyright (C) 2003 - 2012  Erdal Mutlu

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
#include"EventLog.h"

using namespace std;

void logEvent(string appName, string msg, WORD type)
{
	HANDLE h;
 
    h = RegisterEventSource(NULL,TEXT(appName.c_str()));
	if(h == NULL) {
		cerr << "logEvent: Could not register the event source for" << appName.c_str() << endl;
		return;
	}
 	const char *p=msg.c_str();
	if(ReportEvent(h, type, 0,(DWORD)1, NULL, 1, 0, (LPCSTR *)&p, NULL) == 0) {
		cerr << "logEvent: Could not report the event :" << msg.c_str() << endl;
		cerr << "logEvent: Last error : " << GetLastError() << endl;
		DeregisterEventSource(h); 
		return;
	}
    DeregisterEventSource(h); 
}
