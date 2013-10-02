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

#include"DriverManager.hpp"
#include<string>
#include<sstream>

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<dlfcn.h>

using namespace std;

/*!
Default constructor. Loads the EDBC drivers.
\throw IOException
*/
DriverManager::DriverManager()
: driverCount(0)
{
#ifdef DEBUG
	cout << "DriverManager::Constructor: Constructing a DriverManager object: " << this << endl;
	cout << "DriverManager::Constructor: ENV_DRIVERS=" << ENV_DRIVERS << endl;
#endif
	char *p=getenv(ENV_DRIVERS);
	if(p == NULL) {
		driversDir="/usr/lib/edbc";
#ifdef DEBUG
		cout << "DriverManager::Constructor: " << ENV_DRIVERS << " is not set. Setting to the default /usr/lib/edbc" << endl;
#endif
	}
	else
		driversDir=p;
#ifdef DEBUG
	cout << "DriverManager::Constructor: driversDir=[" << driversDir << "]" << endl;
#endif
	if(!loadDrivers()) {
		cerr << "DriverManager::Constructor: error loading EDBC drivers" << endl;
		// throw IOException
	}
		
}

DriverManager::~DriverManager()
{
#ifdef DEBUG
	cout << "DriverManager::Destructor: destructing a DriverManager object: " << this << endl;
#endif
}

/*!
Load all EDBC drivers from the driversDir.
\return true if loaded, false on failure.
*/
bool DriverManager::loadDrivers(void)
{
	FILE *dl_ptr;
	void *dlib_ptr;
	const int BUFFER_SIZE=4096;
	char buffer[BUFFER_SIZE];

#ifdef DEBUG
	cout << "DriverManager::loadDrivers: loading the EDBC drivers from [" << driversDir << "]" << endl;
#endif
	ostringstream osstr;
	osstr << "ls " << driversDir << "/*.so" << ends;
	string command=osstr.str();
	dl_ptr=popen(command.c_str(),"r");
	if(!dl_ptr) {
		cerr << "DriverManager::loadDrivers: could not open pipe to [" << command << "]" << endl;
		return false;
	}
	while(fgets(buffer,BUFFER_SIZE,dl_ptr)) {
#ifdef DEBUG
		cout << "DriverManager::loadDrivers: read=[" << buffer << "]" << endl;
#endif
		char *ws=strpbrk(buffer," \t\n");
		if(ws)
			*ws='\0';

#ifdef DEBUG
		cout << "DriverManager::loadDrivers: buffer=[" << buffer << "]" << endl;
#endif
		//dlib_ptr=dlopen(buffer,RTLD_NOW);
		dlib_ptr=dlopen(buffer,RTLD_NOW|RTLD_GLOBAL);
		if(dlib_ptr == NULL) {
			cerr << "DriverManager::loadDrivers: dlerror : " << dlerror() << endl;
			pclose(dl_ptr);
			return false;
		}
		makers[driverCount++]=dlib_ptr; // add the handle to the list
	}
	pclose(dl_ptr);
#ifdef DEBUG
	cout << "DriverManager::loadDrivers: number of loaded drivers=" << driverCount << endl;
#endif
	return true;
}

/*
* Returns a Connection object on success or NULL 
*/
Connection *DriverManager::getConnection(string url,string user,string password)
{
#ifdef DEBUG
	cout << "DriverManager::getConnection: url=[" << url << "] user=[" << user << "] password=[" << password << "]" << endl;
#endif
	Connection *conn;

	for(int i=0;i<driverCount;i++) {
#ifdef DEBUG
		cout << "DriverManager::getConnection: trying " << i << endl;
#endif
		maker_t *create_conn=(maker_t *)dlsym(makers[i],"maker");
		if(!create_conn)
			continue;
		conn=create_conn(url,user,password);
		if(conn != NULL)
			return conn;
	}
	return NULL;
}
