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

#ifndef _ConfFile_header_
#define _ConfFile_header_

#include<iostream>
#include<fstream>
#include<map>
#include<cstdlib>
#include<climits>

using namespace std;

/*!
ConfFile is a class which represents a configuration file. The data in this file is of the form key=value.
*/
class ConfFile
{
	public:
		static const int intNotFound=INT_MIN;
	public:
		//! Default constructor
		ConfFile();
		//! Constructor
		ConfFile(const char *fileName);
		//! Constructor
		ConfFile(const string fileName);
		//! Destructor
		~ConfFile();
		double getDouble(const char *key);
		double getDouble(const string key);
		float getFloat(const char *key);
		float getFloat(const string key);
		int getInt(const char *key);
		int getInt(const string key);
		const string getString(const char *key);
		const string getString(const string key);
		void setDefault(const char *key,int value);
		void setDefault(string key,int value);
		void setDefault(const char *key,const char *value);
		void setDefault(const string &key,const string &value);
		bool setFileName(const char *fileName);
	private :
		void extractKeyValue(const char *str,string &key,string &value);
		void extractKeyValues(void);
		string getKeyValue(const string key);
		bool isLineCommentOrEmpty(const char *line,const char ch);
	private:
		ifstream *file;
		map<string,string> confOptionsMap;

		// to make the compiler happy
		//! We do not have copy constructor
		ConfFile(const ConfFile &);	
		//! We do not have assignment operator
		void operator=(const ConfFile &);
};

#endif
