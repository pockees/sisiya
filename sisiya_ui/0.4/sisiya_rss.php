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

#session_start();
error_reporting(E_ALL);

include_once("dbclass.php");
include_once("dbconf.php");
include_once("sisiyaconf.php");
include_once("sisiya_functions.php");

$prog_name=$_SERVER['PHP_SELF'];
$output_file_name="sisiya_rss.xml";

function echo_rss_header()
{
	global $sisiya_url;

	echo '<?xml version="1.0" encoding="ISO-8859-1"?>'."\n";
	echo '<rss version="2.0">'."\n";

	echo '	<channel>'."\n";
	echo '		<title>SisIYA RSS</title>'."\n";
	echo '		<link>'.$sisiya_url.'</link>'."\n";
	echo '		<description>SisIYA</description>'."\n";
	echo '		<language>en</language>'."\n";
	echo '		<copyright>Copyright Erdal Mutlu.</copyright>'."\n";

}

function echo_rss_footer()
{
	echo '	</channel>'."\n";
	echo '</rss>'."\n";
}
 
function get_pubDate()
{
# <pubDate>Sun, 29 Oct 2006 18:37:41 EST</pubDate>

	$t=getdate(); 
	switch($t['wday']) {
		case 0:
			$date_str='Sun';
			break;
		case 1:
			$date_str='Mon';
			break;
		case 2:
			$date_str='Thu';
			break;
		case 3:
			$date_str='Wed';
			break;
		case 4:
			$date_str='T';
			break;
		case 5:
			$date_str='Fri';
			break;
		case 6:
			$date_str='Sat';
			break;
	}
	$date_str.=', '.echo_value($t['mday']).' '.substr($t['month'],0,3).' '.$t['year'].' '.echo_value($t['hours']).':'.echo_value($t['minutes']).':'.echo_value($t['seconds']).' GMT';
	return $date_str;
}

function generate_rss()
{
	global $db,$output_file_name,$sisiya_url;


	$pubDate_str=get_pubDate();
	$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,f.str from systemstatus a,status b,systems c left outer join systeminfo f on f.systemid=c.id and f.infoid=1,systemtypes d,locations e where a.statusid=b.id and b.id>1 and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and c.locationid=e.id order by b.str,e.str,c.effectsglobal desc,c.hostname;";
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);	
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$status_str=$row[1];
		echo '		<item>'."\n";
		echo '			<title>'.$row[0].': '.$row[2].'</title>'."\n";
		echo '			<link>'.$sisiya_url.'/index.php?par_formName=system_services&amp;par_language=en&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[0].'&amp;par_systemType='.$row[3]."</link>\n";
		echo '			<description>'.$row[7].'</description>'."\n";
		echo '			<pubDate>'.$pubDate_str.'</pubDate>'."\n";
		echo '			<systemStatus>'.$status_str.'</systemStatus>'."\n";
		echo '		</item>'."\n";
#		echo $row[0].' ('.$row[7].') : '.$row[2]."\n";
	}
}

echo_rss_header();
generate_rss();
echo_rss_footer();

?>
