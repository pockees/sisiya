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
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
*/

#include<iostream>
#include<fstream>
#include<sstream>
#include<list>
#include<map>

#include"ConfFile.hpp"
#include"stringtok.hpp"
#include"trim.hpp"

/*!
The default constructor.
*/
ConfFile::ConfFile()
//: file(NULL),confOptionsMap(string("Erdal"),string("Mutlu"))
:  file(NULL)
{
}

/*!
Constructor with a parameter: fileName
*/
ConfFile::ConfFile(const char *fileName)
//: file(NULL),confOptionsMap(string("Erdal"),string("Mutlu"))
:file(NULL)
{
	setFileName(fileName);
}

/*!
Constructor with a parameter: fileName
*/
ConfFile::ConfFile(const string fileName)
//: file(NULL),confOptionsMap(string("Erdal"),string("Mutlu"))
:file(NULL)
{
	setFileName(fileName.c_str());
}

ConfFile::~ConfFile()
{
}

void ConfFile::extractKeyValue(const char *str, string & key,
			       string & value)
{
/*
		list<string> ls;
		stringtok(ls,str,"= \t\n");
		list<string>::const_iterator i=ls.begin();
		if(i != ls.end())
			key=(*i);
		else
			return;
		i++;
		if(i != ls.end())
			value=(*i);
*/
	string s = str;
	string::size_type pos = s.find('=');
	if (pos == string::npos)
		return;
	key = trim(s.substr(0, pos));
	value = trim(s.substr(pos + 1, s.size() - pos - 1));
}

/*!
Extracts all key/value pairs from the file. The format is key=value.
*/
void ConfFile::extractKeyValues(void)
{
	char line[4096];

	while (!file->eof()) {
		file->getline(line, 4096);
		//cout << "ConfFile::extractKeyValues: line=[" << line << "]" << endl;
		// check if the line is empty or a comment
		if (isLineCommentOrEmpty(line, '#')) {
			//cout << "ConfFile::extractKeyValues: The line is empty or a coment. Skipping" << endl;
			continue;
		}

		string key, value;
		extractKeyValue(line, key, value);
		if (key.size() > 0 && value.size() > 0) {
//                      cout << "ConfFile::extractKeyValues: key=[" << key << "] value=[" << value << "]" << endl;
			map < string, string >::iterator i =
			    confOptionsMap.find(key);
			if (i == confOptionsMap.end())
				confOptionsMap.
				    insert(make_pair(key, value));
			else
				(*i).second = value;
		}
		//else
		//      cout << "ConfFile::extractKeyValues: No key/value" << endl;

	}
/*
	cout << "ConfFile::extractKeyValues: Now printing key/value from the map object:" << endl;
	for(map<string,string>::iterator i=confOptionsMap.begin();i!=confOptionsMap.end();i++) {
		cout << "ConfFile::extractKeyValues: key=[" << (*i).first << "] value=[" << (*i).second << "]" << endl;
	}
*/
}

double ConfFile::getDouble(const char *key)
{
	return getDouble(string(key));
}

double ConfFile::getDouble(const string key)
{
	return atof(getKeyValue(key).c_str());
}

float ConfFile::getFloat(const char *key)
{
	return getFloat(string(key));
}

float ConfFile::getFloat(const string key)
{
	return float (atof(getKeyValue(key).c_str()));
}

int ConfFile::getInt(const char *key)
{
	return getInt(string(key));
}

int ConfFile::getInt(const string key)
{
	string s = getKeyValue(key);
	if (s.size() == 0)
		return ConfFile::intNotFound;

	istringstream isstr(s);
	int i;
	isstr >> i;
	return i;
}

/*!
Search for the key and return its value as string. If not found return an empty string.
*/
string ConfFile::getKeyValue(const string key)
{
	if (confOptionsMap.count(key) == 1) {
		map < string, string >::iterator i =
		    confOptionsMap.find(key);
		return (*i).second;
	} else
		return string();
}

const string ConfFile::getString(const char *key)
{
	return getString(string(key));
}

const string ConfFile::getString(const string key)
{
	return string(getKeyValue(key));
}

/*!
Check if the line a comment or empty is. Comment char is '#'.
*/
bool ConfFile::isLineCommentOrEmpty(const char *line, const char ch)
{
	if (line[0] == '\0')
		return true;	// empty line

	// check if the line is a configuration line or if it is only an empty or comment line
	// find the first char which is not ' ','\t' or ch
	for (int i = 0; line[i] != '\0'; i++) {
		if (line[i] == ' ' || line[i] == '\t')
			continue;
		else if (line[i] == ch)
			return true;
		else
			return false;
	}
	return false;
}


void ConfFile::setDefault(const char *key, int value)
{
	ostringstream osstr;
	osstr << value << ends;
	setDefault(string(key), osstr.str());
}

void ConfFile::setDefault(string key, int value)
{
	ostringstream osstr;
	osstr << value << ends;
	setDefault(key, osstr.str());
}

void ConfFile::setDefault(const char *key, const char *value)
{
	setDefault(string(key), string(value));
}

void ConfFile::setDefault(const string & key, const string & value)
{
	if (confOptionsMap.count(key) == 0) {
		confOptionsMap.insert(make_pair(key, value));
	} else {
		map < string, string >::iterator i =
		    confOptionsMap.find(key);
		(*i).second = value;
	}
}

bool ConfFile::setFileName(const char *fileName)
{
	file = new ifstream;
	file->open(fileName);
	if (!file->is_open()) {	// I should throw an IO exception here
		cerr << "ConfFile::setFile: Could not open file : " <<
		    fileName << endl;
		delete file;
		return false;
	}
	extractKeyValues();
	delete file;
	return true;
}
