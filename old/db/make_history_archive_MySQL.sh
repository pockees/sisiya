#!/bin/bash
#
#  This script moves everything in from systemhistorystatus table into
#  systemhistorystatusall table execpt for today's records. This way
#  it archives all privious records to the systemhistorystatusall table.
#
#
#    Copyright (C) 2003 - 2010  Erdal Mutlu
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

error()
{
	echo "$1" | mail -s "$0: Error" sisiyaadmins@example.org
	echo "$0: Error : $1"
	cleanup
	exit 1
}

db=sisiya
dbuser=sisiyauser
dbpassword=sisiyauser1

### today's date
date_str=`date '+%Y%m%d'`
### copy all records that are not form today to systemhistorystatusall from systemhistorystatus
sql_str="insert into systemhistorystatusall select * from systemhistorystatus where sendtime not like '$date_str%'"
mysql -u $dbuser -p$dbpassword $db -e "$sql_str" || error "$sql_str"

### delete the copied records from systemhistorystatus
sql_str="delete from systemhistorystatus where sendtime not like '$date_str%'"
mysql -u $dbuser -p$dbpassword $db -e "$sql_str" || error "$sql_str"

exit 0
