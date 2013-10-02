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

#ifndef _SQLTypes_header_
#define _SQLTypes_header_

//! SQL types class.
class SQLTypes {
	public:
		//! SQL type code for array.
		const static int SQLType_ARRAY		=0;
		//! SQL type code for big int.
		const static int SQLType_BIGINT		=1;
		//! SQL type code for binary.
		const static int SQLType_BINARY		=2;
		//! SQL type code for bit.
		const static int SQLType_BIT		=3;
		//! SQL type code for binary object.
		const static int SQLType_BLOB		=4;
		//! SQL type code for boolean.
		const static int SQLType_BOOLEAN	=5;
		//! SQL type code for char.
		const static int SQLType_CHAR		=6;
		//! SQL type code for character object.
		const static int SQLType_CLOB		=7;
		//! SQL type code for datalink.
		const static int SQLType_DATALINK	=8;
		//! SQL type code for date.
		const static int SQLType_DATE		=9;
		//! SQL type code for decimal.
		const static int SQLType_DECIMAL	=10;
		//! SQL type code for distinct.
		const static int SQLType_DISTINCT	=11;
		//! SQL type code for double.
		const static int SQLType_DOUBLE		=12;
		//! SQL type code for float.
		const static int SQLType_FLOAT		=13;
		//! SQL type code for integer.
		const static int SQLType_INTEGER	=14;
		//! SQL type code for long variable binary.
		const static int SQLType_LONGVARBINARY	=15;
		//! SQL type code for null.
		const static int SQLType_NULL		=16;
		//! SQL type code for numeric.
		const static int SQLType_NUMERIC	=17;
		//! SQL type code for other.
		const static int SQLType_OTHER		=18;
		//! SQL type code for real.
		const static int SQLType_REAL		=19;
		//! SQL type code for ref.
		const static int SQLType_REF		=20;
		//! SQL type code for small int.
		const static int SQLType_SMALLINT	=21;
		//! SQL type code for struct.
		const static int SQLType_STRUCT		=22;
		//! SQL type code for time.
		const static int SQLType_TIME		=23;
		//! SQL type code for timestamp.
		const static int SQLType_TIMESTAMP	=24;
		//! SQL type code for tiny int.
		const static int SQLType_TINYINT	=25;
		//! SQL type code for .
		const static int SQLType_VARBINARY	=26;
		//! SQL type code for varchar.
		const static int SQLType_VARCHAR	=27;

		//! Total number of types.
		const static int ntypes=28;

		//! SQL type names array.
		const char *names[ntypes];
		//! Default constructor.
		SQLTypes() {
			names={
			"ARRAY",
			"BIGINT",
			"BINARY",
			"BIT",
			"BLOB",
			"BOOLEAN",
			"CHAR",
			"CLOB",
			"DATALINK",
			"DATE",
			"DECIMAL",
			"DISTINCT",
			"DOUBLE",
			"FLOAT",
			"INTEGER",
			"LONVARBINARY",
			"NULL",
			"NUMERIC",
			"OTHER",
			"REAL",
			"REF",
			"SMALLINT",
			"STRUCT",
			"TIME",
			"TIMESTAMP",
			"TINYINT",
			"VARBINARY",
			"VARCHAR"
			};
		}

		//! Returns SQL type name.
		const char *const getTypeName(const int type) { 
			if(type >= ntypes) 
				return ""; 
			else 
				return names[type];
		}
};
#endif
