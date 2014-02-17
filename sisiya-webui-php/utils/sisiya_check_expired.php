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

function is_expired($t_str, $now_in_minutes)
{
	$year = substr($t_str, 0, 4);
	$month = substr($t_str, 4, 2);
	$days = substr($t_str, 6, 2);
	$hours = substr($t_str, 8, 2);
	$minutes = substr($t_str, 10, 2);
	$t_in_minutes = $year * $month * $days;
	echo date('YmdHis')."\n";
	echo "year=$year month=$month days=$days hours=$hours minutes=$minutes seconds=$seconds result = ".$result."\n";
	return(true);
}

date_default_timezone_set($defaultTimezone);
$sql_str = "select a.hostname,b.serviceid,b.statusid,b.updatetime,b.expires from systems as a left join systemservicestatus as b on a.id=b.systemid where a.active='t'";
$result = $db->query($sql_str);
$row_count = $db->getRowCount($result);	
for($i = 0; $i<$row_count; $i++) {
	$row = $db->fetchRow($result,$i);
	$expire = $row[4];
	if ($expire == 0) {
		echo 'This service never expires. 1 system = '.$row[0]." serviceid=".$row[1]." status = ".$row[2]." update time : ".$row[3]." Skipping...\n";
		continue;
	}	
	#echo 'system = '.$row[0]." serviceid=".$row[1]." status = ".$row[2]." update time : ".$row[3]."\n";
	if ($row[2] == '') {
		#echo "1. type Send message that the service has expired!\n";
		echo '1 system = '.$row[0]." serviceid=".$row[1]." status = ".$row[2]." update time : ".$row[3]."\n";
	}
	if (is_expired($row[3])) {
		echo '2 system = '.$row[0]." serviceid=".$row[1]." status = ".$row[2]." update time : ".$row[3]."\n";
	}
}	
?>