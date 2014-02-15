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
error_reporting(E_ALL);

if (count($argv) != 2) {
	echo "Usage   : $argv[0] web_root_dir\n";
	echo "Example : $argv[0] /srv/http/sisiya-webui-php\n";
	exit(1);
}

if (! defined('STDIN')) {
	echo "This script should not be run from web!";
	exit(1);
}
global $rootDir,$progName;
$prog_name = $argv[0];
$rootDir = $argv[1];



include_once($rootDir."/conf/sisiya_common_conf.php");
include_once($rootDir."/conf/sisiya_gui_conf.php");

$prog_name=$_SERVER['PHP_SELF'];

function echo_error($msg)
{
	echo $msg;
}

### Finds the first timestamp for this systemid,serviceid from systemhistorystatus or systemhistorystatusall
function getFirstTimestamp_old($systemid,$serviceid)
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

function getTimestamp($table_name,$systemid,$serviceid)
{
	global $db;

	$sql_str='select recievetime from '.$table_name.' where systemid='.$systemid.' and serviceid='.$serviceid.' order by recievetime';
	$result=$db->query($sql_str);
	if(!$result)
		return('');
	else {
		if($db->getRowCount($result) == 0) {	
			return('');
		}
		$row=$db->fetchRow($result,0);
		$x=$row[0];
		$db->freeResult($result);
		return($x);
	}
}

function getNextDate($date_str)
{
	$y=substr($date_str,0,4);
	$m=substr($date_str,4,2);
	if(($m+1) < 12) {
		$m=$m+1;
	}
	else {
		$m=1;
		$y=$y+1;
	}
	$prev_date_str=$y.echo_value($m);
	return($prev_date_str);
}


function getPrevDate($date_str)
{
	$y=substr($date_str,0,4);
	$m=substr($date_str,4,2);
	if($m-1 > 0) {
		$m=$m-1;
	}
	else {
		$m=12;
		$y=$y-1;
	}
	$prev_date_str=$y.echo_value($m);
	return($prev_date_str);
}

function getTodayYearMonthAsString()
{
	$t=getdate(); 
	$date_str=$t['year'].echo_value($t['mon']);
	return($date_str);
}

function getOldestDateFor_systemhistorystatus()
{
	global $db;

	$date_str=getTodayYearMonthAsString();
	$found=false;
	while(true) {
		if(table_exists('systemhistorystatus'.$date_str)) {
			$found=true;
			$date_str=getPrevDate($date_str);
			#echo "prev_date=".$date_str."\n";
			continue;
		}
		break;
	}
	if($found)
		$date_str=getNextDate($date_str);
	return($date_str);

}

function getFirstTimestamp($oldest_date,$systemid,$serviceid)
{
	global $db;

	$date_str=$oldest_date;
	$today_str=getTodayYearMonthAsString();
	$found=false;
	while($date_str <= $today_str) {
		$timestamp_str=getTimestamp('systemhistorystatus'.$date_str,$systemid,$serviceid);
		if($timestamp_str != '') {
			$found=true;
			break;
		}
		$date_str=getNextDate($date_str);
	}
	if($found)
		return($timestamp_str);

	$timestamp_str=getTimestamp('systemhistorystatus',$systemid,$serviceid);
	if($timestamp_str == '')
		echo "getFirstTimestamp: Could not get Timestamp!\n";
	return($today_str.'010101');
}



### This function updates the systemservice table from systemhistorystatus and systemhistorystatusall
function update_systemservice()
{
	global $db;

	### get active systems services
	$sql_str="select a.id,b.serviceid from systems a,systemservicestatus b where a.id=b.systemid and a.active='t' order by a.id,b.serviceid";
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);	
	if($row_count > 0) {
		$oldest_date_str=getOldestDateFor_systemhistorystatus();	
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$sql_str='select count(*) from systemservice where systemid='.$row[0].' and serviceid='.$row[1];
			$result2=$db->query($sql_str);
			$row2=$db->fetchRow($result2,0);
			if($row2[0] == 0) {
				$sql_str='insert into systemservice values('.$row[0].','.$row[1].",0,'t','".getFirstTimestamp($oldest_date_str,$row[0],$row[1])."','None')";
				$db->query($sql_str);
			}
		}
	}
}

### This function moves all records, for which recievetime differs from today, from systemhistorystatus table to systemhistorystatusall table
function archive_systemhistorystatus()
{
	global $db;

	$t=getdate(); 
	$date_str=$t['year'].echo_value($t['mon']).echo_value($t['mday']);
	$sql_str="insert into systemhistorystatusall select * from systemhistorystatus where recievetime not like '".$date_str."%'";
	if(! $db->query($sql_str)) 
		return false;
	$sql_str="delete from systemhistorystatus where recievetime not like '".$date_str."%'";
	if(! $db->query($sql_str))
		return false;
	return true;
}

### moves records from systemhistorystatusall table into systemhistorystatus$date_str table
function move_records($date_str)
{
	global $db;

	$sql_str="insert into systemhistorystatus".$date_str." select * from systemhistorystatusall where recievetime like '".$date_str."%'";
	if(! $db->query($sql_str)) {
		echo_error("Error occured during execution of the sql=".$sql_str);
		return false;
	}
	$sql_str="delete from systemhistorystatusall where recievetime like '".$date_str."%'";
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
			if(create_table("create table systemhistorystatus".$ym_str." (sendtime char(14) not null,systemid integer not null references systems(id),serviceid integer not null references services(id),statusid integer not null references status(id),recievetime char(14) not null,str text,data varchar(1024),primary key(sendtime,systemid,serviceid,statusid))") == false)
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
	if($row[0] > 0) {
		$sql_str="select recievetime from systemhistorystatusall order by recievetime";
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);	
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$ym_str=substr($row[0],0,6);
			if(table_exists("systemhistorystatus".$ym_str) == false) {
				if(create_table("create table systemhistorystatus".$ym_str." (sendtime char(14) not null,systemid integer not null references systems(id),serviceid integer not null references services(id),statusid integer not null references status(id),recievetime char(14) not null,str text,data varchar(1024),primary key(sendtime,systemid,serviceid,statusid))") == false) {
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
date_default_timezone_set("Europe/Istanbul");
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
