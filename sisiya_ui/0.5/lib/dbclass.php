<?php
/*
    Copyright (C) 2003 - __YEAR__ Erdal Mutlu

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
	var $results;

	function DBClass($server,$dbname,$user,$password,$debug=0)
	{
		$this->debug=$debug; #defult is not to debug
		$this->server=$server;
		$this->dbname=$dbname;
		$this->user=$user;
		$this->password=$password;
		$this->results=array();
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
			echo "MySQL_DBClass:(connect): Connected (select_db) to MySQL DB :".$this->user."/".$this->dbname."@".$this->server."<br>\n";
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

	function getRowCount($result) 
	{ 
		if($result == '')
			return 0;
		else
			return mysql_num_rows($result); 
	}

	function getColumnCount($result) 
	{ 
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

	function getRowCount($result) 
	{ 
		if($result == '')
		return 0;
	else
		return pg_numrows($result); 
	}

	function getColumnCount($result) 
	{ 
		if($result == '')
			return 0;
		else
			return pg_numfields($result); 
	}

	function getColumnName($result,$index)	{ return pg_fieldname($result,$index); }
	function fetchRow($result,$index) 	{ return pg_fetch_row($result,$index); }
	function getAffectedRows($result) 	{ return pg_cmdtuples($result); }
	function freeResult($result) 		{ return pg_freeresult($result); }
}


### Oracle implementation of DBClass
class Oracle_DBClass extends DBClass {
 
	function connect()
	{
		if($this->debug == 1)
			echo "Oracle_DBClass:(connect): Connecting to ".$this->server." ...<br>\n"; 
		$this->conn=oci_pconnect($this->user,$this->password,$this->server) or die("Could not connect to Oracle DB : ".$this->user."@".$this->server."\n");

		if($this->debug == 1)
			echo "Oracle_DBClass:(connect): Connected to Oracle DB :".$this->user."/".$this->dbname."@".$this->server."<br>\n";
	}
 
	function close()
	{
		oci_close($this->conn);
		if($this->debug == 1)
			echo "Oracle_DBClass:(close): Closed connection to Oracle DB :".$this->user."/".$this->dbname."@".$this->server."<br>\n";
	}

	function query($sql)
	{
		if($this->debug == 1) {
			$d=getdate();
			echo "Oracle_DBClass:(query): Start time : $d[mday].$d[month].$d[year] $d[hours]:$d[minutes].$d[seconds] Executing query :[".$sql."]...<br>\n";
	}  
		# Parse the statement. Note there is no final semi-colon in the SQL statement
		$result=oci_parse($this->conn,$sql);
		if($result == false) {
			if($this->debug == 1)
				echo 'Oracle_DBClass:(query): Could not parse SQL!';
			return false;
		}
  		# Set before calling oci_execute()
/*
		$prefetch_rows=300;
		if(oci_set_prefetch($result, $prefetch_rows) == false) {
			if($this->debug == 1)
				echo 'Oracle_DBClass:(query): Could not set prefetch to '.$prefetch_rows.'!';
			return false;
		}
*/
		if(oci_execute($result) == false) {
			if($this->debug == 1)
				echo 'Oracle_DBClass:(query): Could not execute the query!';
			return false;
		} 

		if($this->debug == 1) {
			$d=getdate();
			echo "Oracle_DBClass:(query): Stop time : $d[mday].$d[month].$d[year] $d[hours]:$d[minutes].$d[seconds] Executing query :[".$sql."] finished.<br>\n";
		}

		if(oci_statement_type($result) == 'SELECT') {
			# fetch all rows and store in an array
			$this->fetchAll($result);
		}
		return $result;
	}
	
	protected function fetchAll($result)
	{
		$skip=0;	# skip # rows
		$maxrows=-1;	# -1 : get all after skipping $skip rows
		$flags=OCI_FETCHSTATEMENT_BY_ROW + OCI_NUM;
		$nrows=oci_fetch_all($result,$rs,$skip,$maxrows,$flags);
		if($this->debug == 1) {
			echo "Oracle_DBClass:(fetchAll): count(rs)=".count($rs)."<br>\n";
#			echo "Oracle_DBClass:(fetchAll): =".var_dump($rs)."<br>\n";
		}
		if($nrows == false) {
			echo "Oracle_DBClass:(fetchAll): Error occured while fetching all result!<br>\n";
			return false;
		}
		# add to the result sets array
	#	$this->results[]=array($result => array('nrows' => $nrows, 'rs' => $rs));
/*
		$x=array();
		$x[$result]=array('nrows' => $nrows, 'rs' => $rs);
		$this->results[]=$x;
*/
		$resultid=(string)$result;
		echo "resultid=".$resultid."<br />";
		$this->results[$resultid]=array('nrows' => $nrows, 'rs' => $rs);
		if($this->debug == 1) {
                      	echo "Oracle_DBClass:(fetchAll): Added result into the results table.<br>\n";
			echo "Oracle_DBClass:(fetchAll): number of result sets=".count($this->results)." <br>\n";
			echo "Oracle_DBClass:(fetchAll): nrows=".$this->results[$resultid]['nrows']."<br>\n";
			echo "Oracle_DBClass:(fetchAll): count(rs)=".count($this->results[$resultid]['rs'])."<br>\n";
			$rs=$this->results[$resultid]['rs'];
			echo "Oracle_DBClass:(fetchAll): result ID=".$result." type=".gettype($result)." is resource=".is_resource($result)." type of resource=".get_resource_type($result)."<br>\n";
			$row_index=1;
			$col_index=0;
			echo "Oracle_DBClass:(fetchAll): omer icin=".$this->results[$resultid]['rs'][$row_index][$col_index]."<br>\n";
#			echo "Oracle_DBClass:(fetchAll): =".var_dump($this->results)."<br>\n";
		}
		return true;
	}

	function getRowCount($result) 
	{ 
		if($result == '')
			return 0;
		else {
			# because all rows are fetched at once oci_num_rows($result); could also be called, but we have already stored the
			# nrows in the $rs array, that is why we use $rs array's nrows 
			$resultid=(string)$result;
			if(array_key_exists($resultid,$this->results) == false) {
				if($this->debug == 1) 
                        		echo "Oracle_DBClass:(getRowCount): The result id=".$resultid." is not in the results table!<br>\n";
					echo "Oracle_DBClass:(getRowCount): =".var_dump($this->results)."<br>\n";
				return 0;
			}
			return $this->results[$resultid]['nrows'];
		}

	}

	function getColumnCount($result) 
	{ 
		if($result == '')
			return 0;
		else {
			return oci_num_fields($result); 
		}
	}

	function getColumnName($result,$index) { return oci_field_name($result,$index+1); }

	function fetchRow($result,$index) 
	{ 
		$resultid=(string)$result;
		if(array_key_exists($resultid,$this->results) == false) {
			if($this->debug == 1) 
                        	echo "Oracle_DBClass:(fetchRow): The result id is not in the results table!<br>\n";
			return false;
		}
		$nrows=$this->results[$resultid]['nrows'];
		if($index >= $nrows) {
			if($this->debug == 1) 
                        	echo "Oracle_DBClass:(fetchRow): The index ".$index." is >= number of rows=".$nrows."!<br>\n";
			return false;
		}
		$rs=$this->results[$resultid]['rs'];
		return $rs[$index];
	}

	function getAffectedRows($result) { return oci_num_rows($result); }

	function freeResult($result) 
	{ 
		$resultid=(string)$result;
		if(array_key_exists($resultid,$this->results) == false) {
			if($this->debug == 1) 
                        	echo "Oracle_DBClass:(freeResult): The result id is not in the results table!<br>\n";
			return false;
		}
		# unset
		unset($this->results[$resultid]['rs']);
		unset($this->results[$resultid]['nrows']);
		unset($this->results[$resultid]);
		return oci_free_statement($result); 
	}
}


?>
