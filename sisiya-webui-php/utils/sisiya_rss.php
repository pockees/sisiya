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
#session_start();
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
$progName = $argv[0];
$rootDir = $argv[1];

include_once($rootDir."/conf/sisiya_common_conf.php");
include_once($rootDir."/conf/sisiya_gui_conf.php");

$output_file_name=$rssFile;

function echo_rss_header()
{
	echo '<?xml version="1.0" encoding="ISO-8859-1"?>'."\n";
	echo '<rss version="2.0">'."\n";

	echo '	<channel>'."\n";
	echo '		<title>SisIYA RSS</title>'."\n";
	echo '		<link>'.SISIYA_URL.'</link>'."\n";
	echo '		<description>SisIYA</description>'."\n";
	echo '		<language>en</language>'."\n";
	echo '		<copyright>Copyright 2003 - __YEAR__ Erdal Mutlu</copyright>'."\n";

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
	global $db,$output_file_name,$defaultLanguage,$progNameSisIYA_GUI,$rootDir;

	$gui_url=SISIYA_URL.str_replace($rootDir,'',$progNameSisIYA_GUI);

	$pubDate_str=get_pubDate();
	###		    0         1    2     3      4      5        6           7
	$sql_str="select c.hostname,i.str,a.str,d.str,i2.str,c.id,c.effectsglobal,f.str ";
	$sql_str.="from systemstatus a,status b,systems c left outer join systeminfo f on f.systemid=c.id and f.infoid=1,";
	$sql_str.="systemtypes d,locations e,";
	$sql_str.="interface i,strkeys s,languages l,interface i2,strkeys s2,languages l2";
	$sql_str.=" where a.systemid=c.id and a.statusid=b.id and b.id>1";
	### status - language
	$sql_str.=" and b.keystr=s.keystr and s.id=i.strkeyid and i.languageid=l.id   and l.code='".$defaultLanguage."'";
	### locations - language
	$sql_str.=" and e.keystr=s2.keystr and s2.id=i2.strkeyid  and i2.languageid=l2.id and l2.id=l.id";
	###
	$sql_str.=" and c.systemtypeid=d.id and c.active='t' and c.locationid=e.id order by i.str,i2.str,c.effectsglobal desc,c.hostname;";
#echo "sql=".$sql_str;
#exit;
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);	
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$status_str=$row[1];
		echo '		<item>'."\n";
		echo '			<title>'.$row[0].': '.$row[2].'</title>'."\n";
		echo '			<link>'.$gui_url.'?menu=system_services&amp;&amp;systemID='.$row[5].'&amp;systemName='.$row[0].'&amp;systemType='.$row[3]."</link>\n";
		echo '			<description>'.validateContent($row[7]).'</description>'."\n";
# pubDate is optional		echo '			<pubDate>'.$pubDate_str.'</pubDate>'."\n";
# pubDate is optional		echo '			<pubDate>'.$pubDate_str.'</pubDate>'."\n";
		echo '			<systemStatus>'.$status_str.'</systemStatus>'."\n";
		echo '		</item>'."\n";
#		echo $row[0].' ('.$row[7].') : '.$row[2]."\n";
	}
}

date_default_timezone_set("Europe/Istanbul");
echo_rss_header();
generate_rss();
echo_rss_footer();

?>
