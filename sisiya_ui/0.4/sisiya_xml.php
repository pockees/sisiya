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
$output_file_name="sisiya.xml";

function echo_xml_header()
{
	echo '<?xml version="1.0" encoding="ISO-8859-1"?>'."\n";
	echo '<sisiya version="0.4">'."\n";
	echo '<copyright>Copyright Erdal Mutlu.</copyright>'."\n";

}

function echo_xml_footer()
{
	echo '</sisiya>'."\n";
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

function generate_xml()
{
	global $db,$output_file_name;

	$sisiya_http='sisiya.sisiya.net';
	$language='en';


	$pubDate_str=get_pubDate();
	$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,f.str from systemstatus a,status b,systems c left outer join systeminfo f on f.systemid=c.id and f.infoid=1,systemtypes d,locations e where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and c.locationid=e.id order by e.sortid,e.str,c.effectsglobal desc,c.hostname;";
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);	

	$count=0;
	$old_group_str='';
	$flag=TRUE;
#	$row_index=0;
#	while($flag == TRUE) {
	for($row_index=0;$row_index<$row_count;$row_index++) {
		$row=$db->fetchRow($result,$row_index);
#		$row_index++;
		if("$old_group_str" != $row[4]) { // every time when the location is changed
			if($row_index != 0)
				echo "</group>\n";
			echo "<group>\n";
			echo '<name>'.$row[4].'</name>'."\n";
			if("$old_group_str" != '') {
			#	echo "</group>\n";
				#printTotalNumberOfSystems2($old_group_str);
				$count=0;
			}
			$old_group_str=$row[4];
		}
#		if($i == 0)
#			echo '<effectsglobal>tr bgcolor="'.$colors['tableBg'].'">'."\n";
		echo '<system>'."\n";
		echo '<name>'.$row[0].'</name>'."\n";
		echo '<type>'.$row[3].'</type>'."\n";
		if($row[6] == 'f')
			echo "<effectsglobal>false</effectsglobal>\n";
		else
			echo "<effectsglobal>true</effectsglobal>\n";

		echo '<message>'.$row[2].'</message>'."\n";
		echo '<url>http://'.$sisiya_http.'/index.php?par_formID=2&amp;par_language='.$language.'&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[0].'&amp;par_systemType='.$row[3].'</url>'."\n";
		echo '<description>'.$row[7].'</description>'."\n";
		echo '</system>'."\n";
		$count++;
	}
	#echo '<tr><td colspan="'.$ncolumns.'" bgcolor="'.$colors['tableFooterBg'].'"><font color="'.$colors['tableFooterFont'].'">'.$lrb['TotalSystems'].' : '.$count.' (';
	#printTotalNumberOfSystems2($row[4]);
	#echo ')</font></td></tr>'."\n";
		
	echo '</group>'."\n";
}

function echo_overall_status()
{
		echo '		<status>Error</status>'."\n";
}

echo_xml_header();
echo_overall_status();
generate_xml();
echo_xml_footer();

?>
