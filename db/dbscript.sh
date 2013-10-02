#!/bin/bash
#
# This script is wrapper for exec_DBTYPE.sh scripts. exec_DBTYPE.sh scripts handel
# the details about different (MySQL, PostgreSQL) database clients' parameters.
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
### funcions
echo_usage()
{
	echo "Usage : $0 db.conf action"
	echo "Valid actions: create_user,drop_user create_db drop_db create_tables drop_tables populate_db"
}

create_user()
{
	rm -f $tmp_file
	touch $tmp_file
	case $dbtype in
		PostgreSQL)
			echo "create user $dbuser with PASSWORD '${dbpassword}' createdb;" > $tmp_file
		
  		;;
		MySQL)
	  		#echo "insert into user values('localhost','${dbuser}',PASSWORD('${dbpassword}'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y');" > $tmp_file
		#echo "insert into user values('%','${dbuser}',PASSWORD('${dbpassword}'),'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y');" >> $tmp_file
			echo "GRANT ALL PRIVILEGES ON *.* TO ${dbuser}@localhost IDENTIFIED BY '${dbpassword}' WITH GRANT OPTION;" >> $tmp_file
	                echo "GRANT ALL PRIVILEGES ON *.* TO ${dbuser}@\"%\" IDENTIFIED BY '${dbpassword}' WITH GRANT OPTION;" >> $tmp_file
			echo "flush privileges;" >> $tmp_file
  		;;
  		*)
  			echo "Unknown dbtype $dbtype"
			return 1
		;;
	esac	
	#$exec_sql_prog $tmp_file
	$exec_sql_prog $tmp_file $dbauser $dbadbname $conf_file
	return $?
}

drop_user()
{
	rm -f $tmp_file
	touch $tmp_file
	case $dbtype in
		PostgreSQL)
	  		#echo "delete from pg_shadow where usename='${dbuser}';" > $tmp_file
			echo "drop user ${dbuser};" > $tmp_file
	 	;;
		MySQL)
			echo "delete from user where User='${dbuser}';" >> $tmp_file
			echo "flush privileges;" >> $tmp_file
	  	;;
		*)
	  	echo "Unknown dbtype $dbtype"
		return 1
		;;
	esac	
	#$exec_sql_prog $tmp_file
	$exec_sql_prog $tmp_file $dbauser $dbadbname $conf_file
	return $?
}

create_db()
{
	rm -f tmp_file
	touch $tmp_file
	case $dbtype in
		PostgreSQL|MySQL)
   			echo "create database ${dbname};" > $tmp_file
   		;;
		*)
			echo "unknown dbtype $dbtype"
			return 1
		;;
	esac		   
	#$exec_sql_prog $tmp_file $dbuser 
	$exec_sql_prog $tmp_file $dbuser $dbadbname $conf_file
	return $?
}

drop_db()
{
	rm -f tmp_file
	touch $tmp_file
	case $dbtype in
		PostgreSQL|MySQL)
			echo "drop database ${dbname};" > $tmp_file
   		;;
		*)
			echo "unknown dbtype $dbtype"
			return 1
           ;;
	esac		   
	#$exec_sql_prog $tmp_file $dbuser 
	$exec_sql_prog $tmp_file $dbuser $dbadbname $conf_file
	return $?
}

create_tables()
{
	rm -f tmp_file
	touch $tmp_file
	case $dbtype in
		PostgreSQL|MySQL)
   			cat $create_tables_file > $tmp_file
		;;
		*)
			echo "unknown dbtype $dbtype"
			return 1
		;;
	esac		   
	$exec_sql_prog $tmp_file $dbuser $dbname $conf_file
	return $?
}

drop_tables()
{
	rm -f tmp_file
	touch $tmp_file
	case $dbtype in
		PostgreSQL|MySQL)
   			cat $drop_tables_file > $tmp_file
   		;;
		*)
			echo "unknown dbtype $dbtype"
			return 1
		;;
	esac		   
	$exec_sql_prog $tmp_file $dbuser $dbname $conf_file
	return $?
}

recreate_languages()
{
	echo "delete from interface;"         > languages.sql
	echo "delete from strkeys;"             >> languages.sql
	./language.sh                           >> languages.sql

	$exec_sql_prog  languages.sql $dbuser $dbname $conf_file
	return $?
}

populate_db()
{
	rm -f tmp_file
	touch $tmp_file
	case $dbtype in
		PostgreSQL|MySQL)
			cat $populate_db_file > $tmp_file
			./language.sh >> $tmp_file
cat $tmp_file > tmp.sql
			recreate_languages
#			echo "delete from interface;"         > languages.sql
#			echo "delete from strkeys;"             >> languages.sql
#			./language.sh                           >> languages.sql
   		;;
		*)
			echo "unknown dbtype $dbtype"
			return 1
		;;
		esac		   
	$exec_sql_prog $tmp_file $dbuser $dbname $conf_file
	return $?
}


### end of functions


if test  $# -ne 2 ; then
	echo_usage
	exit 1
fi

conf_file=$1

if test ! -f $conf_file ; then
	echo "Database configuration file $conf_file does not exist!"
	exit 1
fi

. $conf_file

exec_sql_prog=./exec_${dbtype}.sh
if test ! -x $exec_sql_prog ; then
	echo "SQL script prog $exec_sql_prog does not exist!"
	exit 1
fi

tmp_file=`mktemp -q /tmp/tmp_XXXXXXXX`

case $2 in 
	create_user)
	 	create_user
	;;
	drop_user)
	 	drop_user
	;;
	create_db)
	 	create_db
	;;
	drop_db)
 		drop_db
	;;
	create_tables)
	 	create_tables
	;;
	drop_tables)
 		drop_tables
	;;
	populate_db)
 		populate_db
	;;
	recreate_languages)
		recreate_languages
	;;
	*)
 		echo_usage
 	;;
esac
rm -f $tmp_file
