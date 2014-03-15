<?php
/*
    Copyright (C) 2003 - 2014 Erdal Mutlu

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
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

*/
error_reporting(E_ALL);

if (count($argv) != 3) {
	echo "Usage   : $argv[0] web_root_dir send_message_prog\n";
	echo "Example : $argv[0] /srv/http/sisiya-webui-php /usr/share/sisiya-client-checks/utils/sisiya_send_message2.sh\n";
	exit(1);
}

if (! defined('STDIN')) {
	echo "This script should not be run from web!";
	exit(1);
}
global $web_root_dir,$progName;
$prog_name = $argv[0];
$web_root_dir = $argv[1];
$send_message_prog = $argv[2];
# status ID for noretport status
$status_noreport = 16;

include_once($web_root_dir.'/config.php');
include_once(CONF_DIR.'/sisiya_common_conf.php');
include_once(CONF_DIR.'/sisiya_gui_conf.php');

function is_expired($t_str, $now_time, $expired)
{
	$year = substr($t_str, 0, 4);
	$month = substr($t_str, 4, 2);
	$days = substr($t_str, 6, 2);
	$hours = substr($t_str, 8, 2);
	$minutes = substr($t_str, 10, 2);
	$seconds = substr($t_str, 12, 2);
	$t = strtotime($year.'-'.$month.'-'.$days.' '.$hours.':'.$minutes.':'.$seconds);
	$diff_in_minutes = round((abs($now_time - $t) / 60), 0); 
	#echo "diff= $diff_in_minutes expired = $expired\n";
	if ($diff_in_minutes > $expired)
		return(true);
	return(false);
}

date_default_timezone_set($defaultTimezone);
$now_time = strtotime(date('Y-m-d H:i:s'));
$sql_str = "select a.hostname,b.serviceid,b.statusid,b.updatetime,b.expires from systems as a left join systemservicestatus as b on a.id=b.systemid where a.active='t'";
$result = $db->query($sql_str);
$row_count = $db->getRowCount($result);	
for($i = 0; $i<$row_count; $i++) {
	$row = $db->fetchRow($result,$i);
	$expire = $row[4];
	if ($expire == 0) {
		#echo 'This service never expires. 1 system = '.$row[0]." serviceid=".$row[1]." status = ".$row[2]." update time : ".$row[3]." Skipping...\n";
		continue;
	}	
	#echo 'system = '.$row[0]." serviceid=".$row[1]." status = ".$row[2]." update time : ".$row[3]."\n";
	if ($row[2] == '') {
		#echo '1 Expired: system = '.$row[0]." serviceid=".$row[1]." status = ".$row[2]." update time : ".$row[3]."\n";
		$expire = 0;	# never expires
		$message_str = "There is no response from this system!";
		exec("$send_message_prog $row[0] $row[1] $status_noreport $expire \"$message_str\"");
		continue;
	}
	if (is_expired($row[3], $now_time, $expire)) {
		#echo '2 Expired: system = '.$row[0]." serviceid=".$row[1]." status = ".$row[2]." update time : ".$row[3]."\n";
		$s = '';
		if ($expire > 1) 
			$s = 's';
		$message_str = "The service check expired! It was valid for $expire minute$s!";
		$expire = 0;	# never expires
		exec("$send_message_prog $row[0] $row[1] $status_noreport $expire \"$message_str\"");
	}
}	
?>
