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


#ifndef _SQLException_header_
#define _SQLException_header_

using namespace std;

//! SQLException class.
/*!
SQLException class is used to store errors which occure when your are using the edbc classes.
*/
class SQLException {
	private:
		//! A description of the exception.
		string reason;		
		//! XOPEN or SQL92 code identifying the exception.
		string SQLState;
		//! A database vendor specific error code.
		/*!
		An integer error code that is specific to each vendor. Normally this will be the actual error code
		returned by the underlying database.
		*/
		int vendorCode;
	public:
		//! Constructor which is used to create a SQLException object with a given description of the error.
		SQLException(string reason_str) : reason(reason_str),SQLState(""),vendorCode(0) {};
		//! Constructor which is used to create a SQLException object with a given description of the error and given SQLState code.
		SQLException(string reason_str,string SQLState_str) : reason(reason_str),SQLState(SQLState_str),vendorCode(0) {};
		//! Constructor which is used to create a SQLException object with a given description of the error, and given SQLState code and vendor specific error code.
		SQLException(string reason_str,string SQLState_str,int code) : reason(reason_str),SQLState(SQLState_str),vendorCode(code) {};
		//! Default destructor.
		~SQLException() {};
					       
		//! Retrieves the database vendor specific error code.
		int getErrorCode(void) { return vendorCode; }
		//! Retrives the XOPEN or SQL92 code identifying the exception. 
		const string getSQLState() const { return SQLState; }
		//! A description of the exception.
		const string getMessage() const { return reason; }
};
#endif
