<?php
/*
    Copyright (C) 2004  Erdal Mutlu

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

class DBClass {
 var $debug;
 var $server;
 var $user;
 var $password;
 var $dbname;
 var $conn; 
 var $result; ### result set for SQL a query

 function DBClass($server,$dbname,$user,$password)
 {
  $this->debug=0; #defult is not to debug
  $this->server=$server;
  $this->dbname=$dbname;
  $this->user=$user;
  $this->password=$password;
 }

 function debug() { $this->debug=1; }
 function nodebug() { $this->debug=0; }

 function connect() { echo "[DBClass] Connecting to ".$this->server." ...\n"; }
 function close() { echo "[DBClass] Closing connection ".$this->server." ...\n"; }
 function query($sql) { echo "[DBClass] Executing query [".$sql."] ...\n"; }
 function getRowCount($result) { echo "[DBClass] Getting the row count form a result set ...\n"; }
 function getColumnCount($result) { echo "[DBClass] Getting the column count form a result set ...\n"; }
 function getColumnName($result,$index) { echo "[DBClass] Getting the column name for $index from a result set ...\n"; }
 function fetchRow($result,$index) { echo "[DBClass] Fetching row for $index from a result set ...\n"; }
 function getAffectedRows($result) { echo "[DBClass] Getting the number of affected rows from a result set ...\n"; }
 function freeResult($result) { echo "[DBClass] Freeing memory for the result set."; }
 function printConfig()
 {
  echo "Server : ".$this->server."\ndbname : ".$this->dbname."\nuser : ".$this->user."\npassword : ".$this->password."<br>\n";
 }
}

### MySQL implementation of DBClass
class MySQL_DBClass extends DBClass {
 
 function connect()
 {
  if($this->debug == 1)
    echo "MySQL_DBClass:(connect): Connecting to ".$this->server." ...<br>\n"; 
  $this->conn=mysql_pconnect($this->server,$this->user,$this->password) or die("Could not connect to MySQL DB : ".$this->user."@".$this->server."\n");

  if($this->debug == 1)
    echo "MySQL_DBClass:(connect): Connected to MySQL DB :".$this->user."/".$this->dbname."@".$this->server."<br>\n";

  mysql_select_db($this->dbname,$this->conn) or die("Could not connect to MySQL DB :".$this->user."/".$this->dbname."@".$this->server."\n");

  if($this->debug == 1)
    echo "MySQL_DBClass:(connect): Connectet (select_db) to MySQL DB :".$this->user."/".$this->dbname."@".$this->server."<br>\n";
 }
 
 function close()
 {
  mysql_close($this->conn);
  if($this->debug == 1)
    echo "MySQL_DBClass:(close): Closed connection to MySQL DB :".$this->user."/".$this->dbname."@".$this->server."<br>\n";
 }

 function query($sql)
 {
  if($this->debug == 1) {
    $d=getdate();
    echo "MySQL_DBClass:(query): Start time : $d[mday].$d[month].$d[year] $d[hours]:$d[minutes].$d[seconds] Executing query :[".$sql."]...<br>\n";
  }  
 
  $result=mysql_query($sql,$this->conn);

  if($this->debug == 1) {
    $d=getdate();
    echo "MySQL_DBClass:(query): Stop time : $d[mday].$d[month].$d[year] $d[hours]:$d[minutes].$d[seconds] Executing query :[".$sql."] finished.<br>\n";
  }
  return $result;
 }

 function getRowCount($result) { 
	if($result == '')
		return 0;
	else
		return mysql_num_rows($result); 
}
 function getColumnCount($result) { 
	if($result == '')
		return 0;
	else
		return mysql_num_fields($result); 
}
 function getColumnName($result,$index) { return mysql_field_name($result,$index); }
 function fetchRow($result,$index) 
 { 
  ### improve this method
  mysql_data_seek($result,$index); 
  return mysql_fetch_row($result);
 }

 function getAffectedRows($result) { return mysql_affected_rows($this->conn); }
 function freeResult($result) { return mysql_free_result($result); }
}

### PostgreSQL implementation of DBClass
class PostgreSQL_DBClass extends DBClass {
 function connect()
 {
  if($this->debug == 1)
    echo "PostgreSQL_DBClass:(connect): Connecting to ".$this->server." ...<br>\n"; 
  $this->conn=pg_pconnect("host=".$this->server." dbname=".$this->dbname." user=".$this->user." password=".$this->password) or die("Could not connect to ".$this->user."@".$this->dbname."/".$this->server);

  if($this->debug == 1)
    echo "PostgreSQL_DBClass:(connect): Connectet (select_db) to PostgreSQL DB :".$this->user."/".$this->dbname."@".$this->server."<br>\n";
 }
 
 function close()
 {
  pg_close($this->conn);
  if($this->debug == 1)
    echo "PostgreSQL_DBClass:(close): Closed connection to PostgreSQL DB :".$this->user."/".$this->dbname."@".$this->server."<br>\n";
 }

 function query($sql)
 {
  if($this->debug == 1) {
    $d=getdate();
    echo "PostgreSQL_DBClass:(query): Start time : $d[mday].$d[month].$d[year] $d[hours]:$d[minutes].$d[seconds] Executing query :[".$sql."]...<br>\n";
  }  
 
  $result=pg_exec($this->conn,$sql);

  if($this->debug == 1) {
    $d=getdate();
    echo "PostgreSQL_DBClass:(query): Stop time : $d[mday].$d[month].$d[year] $d[hours]:$d[minutes].$d[seconds] Executing query :[".$sql."] finished.<br>\n";
  }
  return $result;
 }

 function getRowCount($result) { 
	if($result == '')
		return 0;
	else
		return pg_numrows($result); 
}
 function getColumnCount($result) { 
	if($result == '')
		return 0;
	else
		return pg_numfields($result); 
}
 function getColumnName($result,$index) { return pg_fieldname($result,$index); }
 function fetchRow($result,$index) { return pg_fetch_row($result,$index); }
 function getAffectedRows($result) { return pg_cmdtuples($result); }
 function freeResult($result) { return pg_freeresult($result); }

}
?>
