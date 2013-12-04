#
# Makefile for creating SISIYA database
#
#    Copyright (C) 2003  Erdal Mutlu
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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
# DBTYPE can be PostgreSQL or MySQL
#
#DBTYPE=PostgreSQL
DBTYPE=MySQL
DBCONF=db_$(DBTYPE).conf
DBSCRIPT=./dbscript.sh

all: create_user create_db create_tables populate_db
	
create_user:
	$(DBSCRIPT) $(DBCONF) create_user
	
delete_user:
	$(DBSCRIPT) $(DBCONF) drop_user
	
create_db:
	$(DBSCRIPT) $(DBCONF) create_db
	
delete_db:
	$(DBSCRIPT) $(DBCONF) drop_db

create_tables:
	$(DBSCRIPT) $(DBCONF) create_tables

delete_tables:
	$(DBSCRIPT) $(DBCONF) drop_tables
	
populate_db:
	$(DBSCRIPT) $(DBCONF) populate_db 
	
recreate: delete_db create_db create_tables populate_db

recreate_languages:
	$(DBSCRIPT) $(DBCONF) recreate_languages

clean: delete_db delete_user
