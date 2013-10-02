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

error_reporting(E_ALL);

include_once("dbclass.php");
include_once("dbconf.php");
include_once("sisiya_functions.php");

$min_password_length=8;
$salt_length=12; ### Use MD5 with 12 character salt

$prog_name=$_SERVER['PHP_SELF'];


function echo_error($msg)
{
	echo $msg;
}

### Finds the first timestamp for this systemid,serviceid from systemhistorystatus or systemhistorystatusall
function getFirstTimestamp($systemid,$serviceid)
{
	global $db;

	$sql_str='select sendtime from systemhistorystatusall where systemid='.$systemid.' and serviceid='.$serviceid.' order by sendtime';
	$result=$db->query($sql_str);
	if($db->getRowCount($result) == 0) {	
		$sql_str='select sendtime from systemhistorystatus where systemid='.$systemid.' and serviceid='.$serviceid.' order by sendtime';
		$result=$db->query($sql_str);
	}
	$row=$db->fetchRow($result,0);
	return($row[0]);
}


### This function updates the systemservice table from systemhistorystatus and systemhistorystatusall
function update_systemservice()
{
	global $db;

	$sql_str='select a.id,b.serviceid from systems a,systemservicestatus b where a.id=b.systemid and a.active=\'t\' order by a.id,b.serviceid';
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);	
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$sql_str='select count(*) from systemservice where systemid='.$row[0].' and serviceid='.$row[1];
		$result2=$db->query($sql_str);
		$row2=$db->fetchRow($result2,0);
		if($row2[0] == 0) {
			$sql_str='insert into systemservice values('.$row[0].','.$row[1].',\'t\',\''.getFirstTimestamp($row[0],$row[1]).'\',\'None\')';
			$db->query($sql_str);
		}
	}
}

### This function moves all records, for which sendtime differs from today, from systemhistorystatus table to systemhistorystatusall table
function archive_systemhistorystatus()
{
	global $db;

	$t=getdate(); 
	$date_str=$t['year'].echo_value($t['mon']).echo_value($t['mday']);
	$sql_str="insert into systemhistorystatusall select * from systemhistorystatus where sendtime not like '".$date_str."%'";
	if(! $db->query($sql_str)) 
		return false;
	$sql_str="delete from systemhistorystatus where sendtime not like '".$date_str."%'";
	if(! $db->query($sql_str))
		return false;
	return true;
}

### moves records from systemhistorystatusall table into systemhistorystatus$date_str table
function move_records($date_str)
{
	global $db;

	$sql_str="insert into systemhistorystatus".$date_str." select * from systemhistorystatusall where sendtime like '".$date_str."%'";
	if(! $db->query($sql_str)) {
		echo_error("Error occured during execution of the sql=".$sql_str);
		return false;
	}
	$sql_str="delete from systemhistorystatusall where sendtime like '".$date_str."%'";
	if(! $db->query($sql_str)) {
		echo_error("Error occured during execution of the sql=".$sql_str);
		return false;
	}
	return true;
}


### checks for existence of a table
function table_exists($table_name)
{
	global $db;

	$sql_str="select count(*) from ".$table_name;
	if(! $db->query($sql_str))
		return false;
	return true;
}

### creates a table
function create_table($sql_str)
{
	global $db;

	if(! $db->query($sql_str))
		return false;
	return true;
}
### This function moves records from systemhistorystatusall table into systemhistorystatusYYYYMM tables
function move_systemhistorystatusall()
{
	global $db;

	$sql_str="select starttime from systemservice order by starttime";
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);	
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$ym_str=substr($row[0],0,6);
		if(table_exists("systemhistorystatus".$ym_str) == false) {
			if(create_table("create table systemhistorystatus".$ym_str." (sendtime char(14) not null,systemid integer not null references systems(id),serviceid integer not null references services(id),statusid integer not null references status(id),recievetime char(14) not null,str text,primary key(sendtime,systemid,serviceid,statusid))") == false)
				return false;
			if(move_records($ym_str) == false) 
				return false;
		}
#		else
#echo "table systemhistorystatus".$ym_str." exist skipping...\n";
	}
	return true;
}

### check if there is anything left in the systemhistorystatustable
function final_check()
{
	global $db;
	
	$sql_str="select count(*) from systemhistorystatusall";
	$result=$db->query($sql_str);
	$row=$db->fetchRow($result,0);
	if($row[0] >= 0) {
		$sql_str="select sendtime from systemhistorystatusall order by sendtime";
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);	
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$ym_str=substr($row[0],0,6);
			if(table_exists("systemhistorystatus".$ym_str) == false) {
				if(create_table("create table systemhistorystatus".$ym_str." (sendtime char(14) not null,systemid integer not null references systems(id),serviceid integer not null references services(id),statusid integer not null references status(id),recievetime char(14) not null,str text,primary key(sendtime,systemid,serviceid,statusid))") == false) {
					return false;
				}
			}
			if(move_records($ym_str) == false)
				return false;
		}
	}
	return true;
}

##############################################################################################

switch($dbType) {
	case "MySQL" :
		$db=new MySQL_DBClass($db_server,$db_name,$db_user,$db_password);
		break;
	case "PostgreSQL" :
		$db=new PostgreSQL_DBClass($db_server,$db_name,$db_user,$db_password);
		break;
	default :
		echo "Unsupported DB Type!";
		exit;
		break;
}

#$db->debug();
$db->connect();

if(archive_systemhistorystatus() == false) {
	echo_error("Error occured during archiving of systemhistorystatus table");
	exit(1);
}

update_systemservice();

if(move_systemhistorystatusall() == false) {
	echo_error("Error occured during moving records from systemhistorystatusall into systemhistorystatusYYYYMM tables!");
	exit(1);
}

final_check();
