#
# Makefile for creating database
#
#    Copyright (C) 2003 - __YEAR__ Erdal Mutlu
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
#
# DBTYPE can be PostgreSQL or MySQL
#
#DBTYPE=PostgreSQL
DBTYPE=MySQL
DBCONF=db_$(DBTYPE).conf
DBSCRIPT=./dbscript.sh

all: create_user create_db create_tables populate
	
create_user:
	$(DBSCRIPT) $(DBCONF) create_user
	
delete_user:
	$(DBSCRIPT) $(DBCONF) drop_user
	
create_db:
	$(DBSCRIPT) $(DBCONF) create_db
	
drop_db:
	$(DBSCRIPT) $(DBCONF) drop_db

create_tables:
	$(DBSCRIPT) $(DBCONF) create_tables

drop_tables:
	$(DBSCRIPT) $(DBCONF) drop_tables
	
populate:
	$(DBSCRIPT) $(DBCONF) populate_db 

recreate_languages:
	$(DBSCRIPT) $(DBCONF) recreate_languages
update_languages:
	$(DBSCRIPT) $(DBCONF) update_languages
	
recreate: drop_db create_db create_tables populate

clean: delete_db delete_user
