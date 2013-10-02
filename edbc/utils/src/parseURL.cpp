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
//#include<stdlib.h> // for atol
#include<cstdlib>

using namespace std;

/*!
Parses the EDBC URL, which is of form "edbc:dbtype://server/dbname[:port]".
*/	
void parseURL(string url,string &server,string &dbname,string &dbtype,unsigned int &port)
{
	string::size_type pos,start;

	port=0; // set the default value

	// check if it as edbc URL
	pos=url.find(':');
	//cout << "parseURL: pos=" << pos << endl;
	if(pos == string::npos) {
		//cout << "parseURL: this string does not contain ':' character." << endl;
		return;	// this is not an EDBC URL string
	}
	string edbc=url.substr(0,pos);
	//if(edbc.compare("edbc") != 0) {
	if(edbc != "edbc") {
		//cout << "parseURL: this is not a valid EDBC URL." << endl;
		return;
	}

	// extract dbtype
	start=pos+1;
	pos=url.find(':',start);
	//cout << "parseURL: second pos=" << pos << endl;
	if(pos == string::npos) {
		//cout << "parseURL: this string does not contain the second ':' character." << endl;
		return;
	}
	dbtype=url.substr(start,pos-start);
	/* I do not check for the type any more, because this function is used by all driver implementation and
	   they check this anyway.
	if(dbtype != "postgresql") {
		//cout << "parseURL: this URL is not for PostgreSQL dbtype=" << dbtype << " != postgresql" << endl;
		return;
	}
	*/
	//cout << "parseURL: dbtype=" << dbtype << endl;
	
	// extract server
	start=pos+1;
	pos=url.find("//",start);
	//cout << "parseURL: // is at pos=" << pos << endl;
	if(pos == string::npos) {
		//cout << "parseURL: this string does not contain the \"//\" string." << endl;
		return;
	}
	start+=2; // increment the start position by 2, becaus of "//"
	pos=url.find('/',start);
	//cout << "parseURL: / is at pos=" << pos << endl;
	if(pos == string::npos) {
		//cout << "parseURL: this string does not contain the '/' character after \"//\" string." << endl;
		return;
	}
	server=url.substr(start,pos-start);
	if(server.size() == 0) {
		//cout << "parseURL: there is no server string in this URL server=" << server << endl;
		return;	
	}
	//cout << "parseURL: server=" << server << endl;

	// extract dbname
	start=pos+1;
	pos=url.find(':',start);
	//cout << "parseURL: second pos=" << pos << endl;
	if(pos == string::npos) {
		dbname=url.substr(start,url.size()-start);
		//cout << "parseURL: this string does not contain the optional port number" << endl;
	}
	else {
		dbname=url.substr(start,pos-start);
		string str=url.substr(pos+1);//,url.size()-pos-1);
		port=(unsigned int)atoi(str.c_str()); // if it is not a valid number 0 will be returned
	}
	//cout << "parseURL: dbname=" << dbname << endl;
	//cout << "parseURL: port=" << port << endl;
#ifdef DEBUG
	cout << "parseURL: url=[" << url << "]" << endl;
	cout << "parseURL: server=[" << server << "] dbtype=[" << dbtype << "] dbname=[" << dbname << "] port=" << port << endl;
#endif
}



/*
static void parseURL(const char *url,char *server,char *dbname,char *dbtype,unsigned int &port)
{
	// url=edbc:dbtype://server/dbname[:port]
	int i,j;
	int length;
	char port_str[8];

	port=0;
	length=strlen(url);
	// check the pattern of the url, it must contain at least two :
	j=0;
	for(i=0;i<length;i++) {
		if(url[i] == ':')
			j++;
	}
	if(j < 2) {
		server[0]='\0';
		dbtype[0]='\0';
		dbname[0]='\0';
		return;
	}
	// extract dbtype
	i=5;
	j=0;
	while(i < length && url[i] != ':') 
		dbtype[j++]=url[i++];

	dbtype[j]='\0';
	// extract server
	i+=3; // position to the start of server
	j=0;
	while(i < length && url[i] != '/') 
		server[j++]=url[i++];
	server[j]='\0';

	// extract dbname 
	i++; // position to the start of dbname
	j=0;
	while(i < length && url[i] != '/') 
		dbname[j++]=url[i++];
	dbname[j]='\0';

	// extract port 
	i++; // position to the start of port
	j=0;
	while(i < length) 
		port_str[j++]=url[i++];
	port_str[j]='\0';
	port=(unsigned int)atol(port_str);
#ifdef DEBUG
	cout << "(PostgreSQL)parseURL: url=[" << url << "]" << endl;
	cout << "(PostgreSQL)parseURL: server=[" << server << "] dbtype=[" << dbtype << "] dbname=[" << dbname << "] port_str=[" << port_str << "] port=" << port << endl;
#endif
}
*/


