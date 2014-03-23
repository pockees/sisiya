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

#include<iostream>
#include<string>

#include"trim.h"

/*!
A function which removes spaces from both ends from the given string s.
*/
std::string trim(const std::string &s) 
{
	if(s.length() == 0)
		return s;
	std::string::size_type b=s.find_first_not_of(" \t\n");
	if(b == std::string::npos)
		return "";	// no non-space chars
	std::string::size_type e=s.find_last_not_of(" \t\n");
	//return string(s,b,e-b+1);
	return s.substr(b,e-b+1);
}
