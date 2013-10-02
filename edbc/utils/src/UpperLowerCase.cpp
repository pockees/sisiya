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

#include<string>
#include<iostream>

#include"UpperLowerCase.hpp"

using namespace std;

/*!
Make an uppercase copy of s. 
*/
string upperCase(const string &s)
{
	char *buf=new char[s.length()];
	s.copy(buf,s.length());
	for(unsigned int i=0;i<s.length();i++)
		buf[i]=toupper(buf[i]);
	string r(buf,s.length());
	delete buf;
	return r;
}

/*!
Make a lowercase copy of s. 
*/
string lowerCase(const string &s)
{
	char *buf=new char[s.length()];
	s.copy(buf,s.length());
	for(unsigned int i=0;i<s.length();i++)
		buf[i]=tolower(buf[i]);
	string r(buf,s.length());
	delete buf;
	return r;
}
