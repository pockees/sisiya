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

echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";
echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n";
echo "<meta NAME=\"GENERATOR\" CONTENT=\"sisiya.php\">\n";
echo "<meta HTTP-EQUIV=\"Refresh\" CONTENT=\"300\">\n";

error_reporting(E_ALL);
include_once("dbclass.php");
include_once("dbconf.php");

/*
 formID : 	0 Overview index page
		1 Detailed index page
		2 Service status for a host. Params : systemID, systemType
		3 Service status history for a host. Params : systemID, serviceID, systemType
		4 System info. Params : systemID, systemType
		5 Detailed overview.
*/
$formIDs=array(0,1,2,3,4);

#$dir='/sisiya';
#$prog_name=$dir.'/sisiya.php';
$prog_name=$_SERVER['PHP_SELF'];
$ncolumns=30; // number of columns to be displayed

### default colors
$colors=array(
	'bg'			=>	'#FFFFFF',
	'font'			=>	'#000000',
	'h1'			=>	'#000000',
	'h2'			=>	'#000000',
	'h3'			=>	'#000000',
	'h4'			=>	'#000000',
	'link'			=>	'#0000FF',
	'vlink'			=>	'#0000FF',
	'alink'			=>	'#0000FF',
	'tableFont'		=>	'#000000',
	'tableBg' 		=>	'#FFFFFF',
	'tableFooterBg' 	=> 	'#AAAAFF',
	'tableFooterFont' 	=> 	'#000000',
	'tableHeaderBg' 	=> 	'#AABBFF',
	'tableHeaderFont' 	=> 	'#000000',
	'nonCriticalSystem'	=>	'#0044AA'	
);

####################################################################################      
#### Functions
####################################################################################      
function setColors()
{
	global $colors;

	### put color definitions in a DB table
	### for now
	$colors['bg']='#FFFFFF';
	$colors['font']='#000000';
	$colors['h1']='#000000';
	$colors['h2']='#000000';
	$colors['h3']='#000000';
	$colors['h4']='#000000';
	$colors['link']='#0000FF';
	$colors['vlink']='#0000FF';
	$colors['alink']='#0000FF';
	$colors['tableFont']='#000000';
	$colors['tableBg']=$colors['bg'];
	$colors['tableFooterBg']='#AACCFF';
	$colors['tableFooterFont']='#000000';
	$colors['tableHeaderBg']='#AABBFF';
	$colors['tableHeaderFont']='#000000';
	$colors['nonCriticalSystem']='#00FFAA';
}
function getChangedString($a,$b)
{
	$a_year=$a{0}.$a{1}.$a{2}.$a{3}; 
	$a_month=$a{4}.$a{5};
	$a_day=$a{6}.$a{7};
	$a_hour=$a{8}.$a{9};
	$a_minute=$a{10}.$a{11};
	$a_second=$a{12}.$a{13};
 
	$b_year=$b{0}.$b{1}.$b{2}.$b{3}; 
	$b_month=$b{4}.$b{5};
	$b_day=$b{6}.$b{7};
	$b_hour=$b{8}.$b{9};
	$b_minute=$b{10}.$b{11};
	$b_second=$b{12}.$b{13};
	$a_timestamp=mktime($a_hour,$a_minute,$a_second,$a_month,$a_day,$a_year);
	$b_timestamp=mktime($b_hour,$b_minute,$b_second,$b_month,$b_day,$b_year);
	$t=$a_timestamp-$b_timestamp;
	$seconds=$t%60;
	$t=(int)($t/60);
	$minutes=$t%60;
	$t=(int)($t/60);
	$hours=$t%24;
	$days=(int)($t/24);
	$str='';
	if($days > 0) {
		$str=$days.' day';
		if($days > 1)
			$str=$str.'s';
	} 
	if($hours > 0) {
		if($str != '')
			$str=$str.' ';
		$str=$str.$hours.' hour';
		if($hours > 1)
			$str=$str.'s';
	}
	if($minutes > 0) {
		if($str != '')
			$str=$str.' ';
		$str=$str.$minutes.' minute';
		if($minutes > 1)
			$str=$str.'s';
	}
	if($seconds > 0) {
		if($str != '')
			$str=$str.' ';
		$str=$str.$seconds.' second';
		if($seconds > 1)
			$str=$str.'s';
	} 
	if($days > 5)
		$str='<font color="#00FF00">'.$str.'</font>';
	else if($days > 3)
		$str='<font color="#FFFF00">'.$str.'</font>';
	else
		$str='<font color="#FF0000">'.$str.'</font>';
	return $str;
}

function printColorInfo()
{
	global $colors;

	echo '<br><center><table border="0">';
	echo '<tr><td><font color="'.$colors['font'].'">Information about colors:</font></td><td>';
	echo '<img src="images/Info.gif" alt="Info.gif"></td><td><font color="'.$colors['font'].'">Info</td><td>';
	echo '<img src="images/Ok.gif" alt="Ok.gif"></td><td><font color="'.$colors['font'].'">Ok</td><td>';
	echo '<img src="images/Warning.gif" alt="Warning.gif"></td><td><font color="'.$colors['font'].'">Warning</font></td><td>';
	echo '<img src="images/Error.gif" alt="Error.gif"></td><td><font color="'.$colors['font'].'">Error</font></td></tr></table></center>'."\n";
}

function printSISIYA()
{
	global $colors;

	echo '<center><h4><font color="'.$colors['h4'].'">SisIYA (a System Monitoring Tool) &copy; Erdal Mutlu</font></h4></center>'."\n";
}

function printSISIYAandCompatable()
{
	global $colors;

	echo '<br><center><h4><font color="'.$colors['h4'].'">SisIYA (a System Monitoring Tool) &copy; Erdal Mutlu&nbsp;&nbsp;'.getCompatable().'</font></h4></center>'."\n";
}

function getCompatable()
{
	return '<a href="http://validator.w3.org/check/referer"><img border="0" src="images/valid-html401.png" alt="Valid HTML 4.01!" height="31" width="88"></a>'."\n";
}

function printTotalNumberOfSystems($location)
{
	global $db;
 
	$sql_str='select c.str,count(*) as cc from systems a,locations b,systemtypes c where a.active=\'t\' and a.systemtypeid=c.id and a.locationid=b.id and b.str=\''.$location.'\' group by c.id order by cc desc';
	$result=$db->query($sql_str);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) {
		$t=getdate(); 
		$str='0';
	} 
	else {
		$str='';
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			if($str == '')
				#$str=$str.$row[0].' '.$row[1];
				$str=$str.$row[1].' '.$row[0];
			else
				#$str=$str.', '.$row[0].' '.$row[1];
				$str=$str.', '.$row[1].' '.$row[0];
		}
	}
	echo $str;
}

function printLastUpdated()
{
	global $db;
 
	$sql_str='select updatetime from systemstatus order by updatetime desc'; 
	$result=$db->query($sql_str);

	if($db->getRowCount($result) == 0) {
		$t=getdate(); 
		$update_str=$t['hours'].':'.echo_value($t['minutes']).':'.echo_value($t['seconds']).' '.$t['mday'].'.'.echo_value($t['mon']).'.'.$t['year'];
	} 
	else {
		$r=$db->fetchRow($result,0);
		$update_str=$r[0]{8}.$r[0]{9}.':'.$r[0]{10}.$r[0]{11}.':'.$r[0]{12}.$r[0]{13}.' '.$r[0]{6}.$r[0]{7}.'.'.$r[0]{4}.$r[0]{5}.'.'.$r[0]{0}.$r[0]{1}.$r[0]{2}.$r[0]{3};
	}
	echo $update_str;
}

function getSystemGlobalStatus()
{
	global $db;
 
	$sql_str='select max(statusid) from systemstatus a,systems b where a.systemid=b.id and b.active=\'t\' and effectsglobal=\'t\''; 
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	if($row_count == 1) {
		$row=$db->fetchRow($result,0);
		$max_status=$row[0];
	} 
	if($max_status == "")
		$max_status=0;

	$status_str="No Info";
	$sql_str='select str from status where id='.$max_status; 
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	if($row_count == 1) {
		$row=$db->fetchRow($result,0);
		$status_str=$row[0];
	} 
	return $status_str;
}
 

function getMaxNumberOfServices()
{
	global $db;
 
	$sql_str='select count(serviceid) as cc from systemservicestatus group by systemid order by cc desc'; 
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	if($row_count > 0) {
		$row=$db->fetchRow($result,0);
		$count=$row[0];
	} 
	if($count == "")
		$count=0;

	return $count;
}
 
function getAllActiveServices()
{
	global $db;
 
	$sql_str='select systemid,count(serviceid) as cc from systemservicestatus group by systemid order by cc desc'; 
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	if($row_count > 0) {
		$row=$db->fetchRow($result,0);
		$systemid=$row[0];
		$count=$row[1];
	} 
	if($count == "")
		return;
	$sql_str='select serviceid,b.str from systemservicestatus a,services b where systemid='.$systemid.' and a.serviceid=b.id order by b.str';
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$services["$i"]['id']=$row[0];
		$services["$i"]['str']=$row[1];
	}	
	return $services;
}
 
function echo_value($value) 
{
	if($value < 10) 
		return "0$value";
	else 
		return "$value";
}

function timeString($s) 
{
	$str=$s{8}.$s{9}.":".$s{10}.$s{11}.":".$s{12}.$s{13}." ".$s{6}.$s{7}.".".$s{4}.$s{5}.".".$s{0}.$s{1}.$s{2}.$s{3};
	return $str;
}

function dateString($s) 
{
	$str=$s{6}.$s{7}.".".$s{4}.$s{5}.".".$s{0}.$s{1}.$s{2}.$s{3};
	return $str;
}

function getHTTPValue($key)
{
	global $HTTP_POST_VARS,$HTTP_GET_VARS;
 
	$value="";
 	if(isset($_POST[$key])) 
		$value=$_POST[$key]; 
	else if(isset($_GET[$key])) 
		$value=$_GET[$key]; 
 
	return $value;
}
###################################################################################
$today=getdate(); 
$hours=$today['hours'];
$minutes=$today['minutes'];
$seconds=$today['seconds'];
$month=$today['mon']; 
$day=$today['mday']; 
$year=$today['year']; 

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

setColors();

$par_formID=getHTTPValue("par_formID");
if($par_formID == "") 
	$par_formID=0;
switch($par_formID) {
	case 0 :
		echo '<title>SISIYA a System Monitoring Tool (by Erdal Mutlu) Overview</title></head><body bgcolor="'.$colors['bg'].'">'."\n";
		echo '<table border="0" width="100%"><tr><td align="left">'."\n";
		echo '<img src="images/sisiya_logo.gif" alt="SisIYA\'s logo">'."\n";
		echo '</td><td align="center"><h1><font color="'.$colors['h1'].'">System Overview</font></h1></td>'."\n";
		echo '<td align="right"><font color="'.$colors['font'].'">Last updated : ';
		printLastUpdated();
		echo '</font></td></tr>'."\n";
		$global_status=getSystemGlobalStatus();
		echo '<tr><td colspan="3" align="center"><table border="0"><tr><td><h2><font color="'.$colors['h2'].'">Overall system status :</font></h2></td><td><img src="images/'.$global_status.'_big.gif" alt=""></td><td><h2><font color="'.$colors['h2'].'">'.$global_status.'</font></h2></td>';
		echo '<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$prog_name.'?par_formID=1"><font color="'.$colors['link'].'">Detailed System View</font></a></td><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$prog_name.'?par_formID=5"><font color="'.$colors['link'].'">Detailed System Overview</font></a></td></tr></table></tr>';

		$sql_str='select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,c.fullhostname from systemstatus a,status b,systems c,systemtypes d,locations e where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active=\'t\' and c.locationid=e.id order by e.str,c.effectsglobal desc,a.statusid desc,c.hostname'; 
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);

		$Count=0;
		$old_location_str='';
		$flag=TRUE;
		$row_index=0;
		while($flag ==  TRUE) {
			for($i=0;$i<$ncolumns && $flag == TRUE;$i++) {
				if($row_index >= $row_count) {
					$flag=FALSE;
					break;
				}
				$row=$db->fetchRow($result,$row_index);
				$row_index++;
				if("$old_location_str" != $row[4]) { // every time when the location is changed
					if("$old_location_str" != "") {
						echo '<tr><td colspan="'.$ncolumns.'" bgcolor="'.$colors['tableFooterBg'].'"><font color="'.$colors['tableFooterFont'].'">';
						echo 'Total number of systems : '.$Count.' (';
						printTotalNumberOfSystems($old_location_str);
						echo ')</font></td></tr>'."\n";

						echo '</table><br>'."\n";
						$Count=0;
					}
					echo '<tr><td colspan="3" align="center"><table border="0" bgcolor="'.$colors['tableBg'].'" cellpadding="1" cellspacing="0">'."\n";
					#echo '<tr><th colspan="'.$ncolumns.'" bgcolor="'.$colors['tableHeaderBg'].'"><font color="'.$colors['tableHeaderFont'].'">'.$row[4].'</font>&nbsp;&nbsp;<a href="'.$prog_name.'?par_formID=1#'.$row[4].'"><font color="'.$colors['link'].'">(detailed view)</font></a></th></tr>'."\n";
					echo '<tr><th colspan="'.$ncolumns.'" bgcolor="'.$colors['tableHeaderBg'].'"><a href="'.$prog_name.'?par_formID=1#'.$row[4].'"><font color="'.$colors['tableHeaderFont'].'">'.$row[4].'</font></a></th></tr>'."\n";
					$old_location_str=$row[4];
					$i=0; // starting a new table
				}
				if($i == 0)
					echo '<tr>'."\n";
				if($row[6] == 'f')
					echo '<td bgcolor="'.$colors['nonCriticalSystem'].'">';
				else
					echo '<td>';
				echo '<a href="'.$prog_name.'?par_formID=2&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[0].'&amp;par_systemType='.$row[3].'" onmouseover="window.status=\''.$row[0].' ('.$row[7].') : '.$row[2].'\'; return true;" onmouseout="window.status=\'\';"><img border="0" src="images/'.$row[1].'_big.gif" alt="'.$row[1].'"></a></td>'."\n";
				$Count++;
			}
			echo '</tr>'."\n";
		}
		echo '<tr><td colspan="'.$ncolumns.'" bgcolor="'.$colors['tableFooterBg'].'"><font color="'.$colors['tableFooterFont'].'">Total number of systems : '.$Count.' (';
		printTotalNumberOfSystems($row[4]);
		echo ')</font></td></tr>'."\n";
			
		echo '</table></td></tr></table>'."\n";
		
		printColorInfo();
		printSISIYA();
		#printSISIYAandCompatable();
		break;
######################################################################################################
	case 1 :
		echo '<title>SISIYA a System Monitoring Tool (by Erdal Mutlu) Detailed View</title></head><body bgcolor="'.$colors['bg'].'" text"'.$colors['font'].'" link="'.$colors['link'].'" vlink="'.$colors['vlink'].'" alink="'.$colors['alink'].'">'."\n";
		echo '<table border="0" width="100%"><tr><td align="left">'."\n";
		echo '<img src="images/sisiya_logo.gif" alt="SisIYA\'s logo">'."\n";
		echo '</td><td align="center"><h1>Detailed System View</h1></td>'."\n";	
		echo '<td align="right">Last updated : ';
		printLastUpdated();
		echo '</td></tr>'."\n";
		$global_status=getSystemGlobalStatus();
		echo '<tr><td colspan="3" align="center"><table border="0"><tr><td>';
		echo '<h2>Overall system status :</h2></td><td><img src="images/'.$global_status.'_big.gif" alt=""></td><td><h2>'.$global_status.'</h2></td>';
		echo '<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$prog_name.'?par_formID=0">System Overview</a></td></tr></table></tr>'."\n";
	
		$sql_str='select c.hostname,b.str,a.str,a.updatetime,a.changetime,d.str,e.str,c.id,c.effectsglobal from systemstatus a,status b,systems c,systemtypes d,locations e where c.active=\'t\' and a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.locationid=e.id order by e.str,c.effectsglobal desc,a.statusid desc,c.hostname'; 
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);
		$Count=0;
		$old_location_str='';
		$flag=TRUE;
		$row_index=0;
		while($flag ==  TRUE) {
			if($row_index >= $row_count) {
				$flag=FALSE;
				break;
			}
			$row=$db->fetchRow($result,$row_index);
			$row_index++;
			if("$old_location_str" != $row[6]) { # every time when the location is changed
				if("$old_location_str" != '') {
					#echo '<tr><td colspan="6" bgcolor="#aabbff">Total number of systems : '.$Count.'</td></tr>'."\n";
					echo '<tr><td colspan="6" bgcolor="#aabbff">Total number of systems : '.$Count.' (';
					printTotalNumberOfSystems($old_location_str);
					echo ')</td></tr>'."\n";
					echo '</table></center><br>'."\n";
					$Count=0;
				}
				echo '<a name="'.$row[6].'"><!--  --></a>'."\n";
				echo '<center><table border="1" width="100%" cellpadding="1" cellspacing="0">'."\n";
				echo '<tr><th colspan="6" bgcolor="#aabbff">'.$row[6].'</font></th></tr>'."\n";
				echo '<tr><th>System</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th><th>Changed since</th></tr>'."\n";
				$old_location_str=$row[6];
			}
			echo '<tr><td><a href="'.$prog_name.'?par_formID=2&amp;par_systemID='.$row[7].'&amp;par_systemName='.$row[0].'&amp;par_systemType='.$row[5].'"><img src="images/'.$row[5].'.gif" alt="'.$row[5].'" border="0" height="25"><br>'.$row[0].'</a></td>';
			if($row[8] == 'f')
				echo '<td bgcolor="#00FFAA"';
			else
				echo '<td';
			echo ' align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'"></td><td>'.$row[2].'</td><td>'.timeString($row[3]).'</td><td>'.timeString($row[4]).'</td><td>'.getChangedString($row[3],$row[4]).'</td></tr>'."\n";
			$Count++;
		} 
		#echo '<tr><td colspan="6" bgcolor="#aabbff">Total number of systems : $Count</td></tr>'."\n";
		echo '<tr><td colspan="6" bgcolor="#aabbff">Total number of systems : '.$Count.' (';
		printTotalNumberOfSystems($row[6]);
		echo ')</td></tr>'."\n";
		echo '</table></center>'."\n";
		printColorInfo();
		printSISIYA();
		break;
######################################################################################################
	case 2 :
		$par_systemName=getHTTPValue("par_systemName");
		if($par_systemName == "") {
			echo "<h1>Error: par_systemName is not set!</h1>";
			break;
		}
		$par_systemID=getHTTPValue("par_systemID");
		if($par_systemID == "") {
			echo "<h1>Error: par_systemID is not set!</h1>";
			break;
		}
		$par_systemType=getHTTPValue("par_systemType");
		if($par_systemType == "") {
			echo "<h1>Error: par_systemType is not set!</h1>";
			break;
		}

		echo "<title>SISIYA a System Monitoring Tool (by Erdal Mutlu) System Services</title></head><body bgcolor=\"#FFFFFF\">\n";
		echo "<table border=\"0\" width=\"100%\"><tr><td align=\"left\">\n";
		echo "<img src=\"images/sisiya_logo.gif\" alt=\"SisIYA's logo\">\n";
		echo "</td><td align=\"center\"><h1>System Services for [$par_systemName]</h1></td>\n";	
		echo '<td align="right">Last updated : ';
		printLastUpdated();
		echo "</td></tr></table>\n";
		echo "<table border=\"0\" width=\"100%\"><tr><td align=\"left\" rowspan=\"2\">\n";
		echo "<img src=\"images/".$par_systemName.".gif\" alt=\"".$par_systemName."\"><img src=\"images/".$par_systemType.".gif\" alt=\"".$par_systemType."\"></td>\n";
		echo "<td><a href=\"$prog_name?par_formID=0\">System Overview</a></td><td><a href=\"$prog_name?par_formID=1\">Detailed System View</a></td><td><a href=\"$prog_name?par_formID=4&amp;par_systemID=$par_systemID&amp;par_systemName=$par_systemName&amp;par_systemType=$par_systemType\">System Info</a></td></table>\n";
		echo '<center><table border=1 cellpadding="1" cellspacing="0">'."\n";
		echo "<tr bgcolor=\"#aabbff\"><th>Service</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th><th>Changed since</th></tr>\n";
	
		$sql_str='select d.str,b.str,a.str,a.updatetime,a.changetime,d.id,e.str from systemservicestatus a,status b,systems c,services d,systemtypes e where c.hostname=\''.$par_systemName.'\' and a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id and c.systemtypeid=e.id order by c.id,a.statusid desc,d.str';
	
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);

		for($row_index=0;$row_index<$row_count;$row_index++) {
			$row=$db->fetchRow($result,$row_index);
			echo "<tr><td><a href=\"$prog_name?par_formID=3&amp;par_systemID=$par_systemID&amp;par_systemName=$par_systemName&amp;par_serviceID=$row[5]&amp;par_serviceName=$row[0]&amp;startDate=0&amp;par_systemType=$par_systemType\">$row[0]</a></td><td align=\"center\"><img src=\"images/".$row[1].".gif\" alt=\"$row[1]\"></td><td>$row[2]</td><td>".timeString($row[3])."</td><td>".timeString($row[4])."</td><td>".getChangedString($row[3],$row[4])."</td></tr>\n"; 
		}
		echo "</table></center>\n";
		printColorInfo();
		printSISIYA();
		break;
######################################################################################################
	case 3 :
		$par_systemName=getHTTPValue('par_systemName');
		if($par_systemName == '') {
			echo '<h1>Error: par_systemName is not set!</h1>';
			break;
		}
		$par_systemID=getHTTPValue('par_systemID');
		if($par_systemID == '') {
			echo '<h1>Error: par_systemID is not set!</h1>';
			break;
		}

		$par_serviceName=getHTTPValue('par_serviceName');
		if($par_serviceName == '') {
			echo '<h1>Error: par_serviceName is not set!</h1>';
			break;
		}
		$par_serviceID=getHTTPValue('par_serviceID');
		if($par_serviceID == '') {
			echo '<h1>Error: par_serviceID is not set!</h1>';
			break;
		}
		$par_systemType=getHTTPValue('par_systemType');
		if($par_systemType == '') {
			echo '<h1>Error: par_systemType is not set!'."</h1>";
			break;
		}
		$startDate=getHTTPValue('startDate');
		if($startDate == '') 
			$startDate='0'; # not defined date, start value

		if($startDate == '0') {
			$sql_str='select starttime from systemservice where systemid='.$par_systemID.' and serviceid='.$par_serviceID;
			$result=$db->query($sql_str);
			if($db->getRowCount($result) == 1) {
				$row=$db->fetchRow($result,0);
				$startDate=$row[0]{0}.$row[0]{1}.$row[0]{2}.$row[0]{3}.$row[0]{4}.$row[0]{5}.$row[0]{6}.$row[0]{7};
			}
		}
		# maybe there are no records in the systemservice table for this system
		if($startDate == '0' ) {
			$startDate=$today['year'].echo_value($today['mon']).echo_value($today['mday']);
			$d=$startDate;
		}
		else 
			$d=$today['year'].echo_value($today['mon']).echo_value($today['mday']);
		$a_date=getdate(mktime(0,0,0,$startDate{4}.$startDate{5},$startDate{6}.$startDate{7}-1,$startDate{0}.$startDate{1}.$startDate{2}.$startDate{3}));
		$beforeStartDate=$a_date['year'].echo_value($a_date['mon']).echo_value($a_date['mday']);
		$date_str=getHTTPValue('date_str');
		if($date_str == '') 
			$date_str=$d;
		echo '<title>SISIYA a System Monitoring Tool (by Erdal Mutlu) Service History View</title></head><body bgcolor="#FFFFFF">'."\n";
		echo '<form action="$prog_name?par_formID=3&amp;par_systemID='.$par_systemID.'&amp;par_systemName='.$par_systemName.'&amp;par_serviceID='.$par_serviceID.'&amp;par_serviceName='.$par_serviceName.'&amp;startDate='.$date_str.'&amp;par_systemType='.$par_systemType.'" method="post">'."\n";
		echo '<table border="0" width="100%" cellpadding="1" cellspacing="1"><tr><td align="left">'."\n";
		echo '<img src="images/sisiya_logo.gif" alt="SisIYA\'s logo">'."\n";
		echo '</td><td align="center" colspan="3"><h1>Service History for ['.$par_systemName.']</h1></td>'."\n";	
		echo '<td align="right">Last updated : ';
		printLastUpdated();
		echo '</td></tr>'."\n";
		echo '<tr><td align="left" rowspan="2">'."\n";
		echo '<img src="images/'.$par_systemName.'.gif" alt="'.$par_systemName.'"><img src="images/'.$par_systemType.'.gif" alt="'.$par_systemType.'"></td>'."\n";
		echo '<td><a href="'.$prog_name.'?par_formID=0">System Overview</a></td>'."\n";
		echo '<td><a href="'.$prog_name.'?par_formID=1">Detailed System View</a></td>'."\n";
		echo '<td><a href="'.$prog_name.'?par_formID=2&amp;par_systemID='.$par_systemID.'&amp;par_systemName='.$par_systemName.'&amp;par_systemType='.$par_systemType.'">System Services for ['.$par_systemName.']</a></td>'."\n";
		echo '<td><a href="'.$prog_name.'?par_formID=4&amp;par_systemID='.$par_systemID.'&amp;par_systemName='.$par_systemName.'&amp;par_systemType='.$par_systemType.'">System Info</a></td></tr>'."\n";
		echo '<tr><td>Service : '.$par_serviceName.'</td><td colspan="3">Choose a date <select name="date_str">'."\n";
		$current_date=$today;
		while($d != $beforeStartDate) {
			echo '<option ';
			if($date_str == $d) 
		 		echo 'selected ';
			echo 'value="'.$d.'">'.dateString($d)."\n"; 
			$current_date=getdate(mktime(0,0,0,$current_date['mon'],$current_date['mday']-1,$current_date['year']));
			$d=$current_date['year'].echo_value($current_date['mon']).echo_value($current_date['mday']);
		}
		echo '</select>&nbsp;<input type="submit" name="button" value="Refresh"></td></tr>'."\n";
		echo '<tr><td colspan="5"><table border="1" width="100%" cellpadding="1" cellspacing="0">'."\n";
		echo '<tr bgcolor="#aabbff"><th>Send Time</th><th>Status</th><th>Description</th><th>Recieve Time</th></tr>'."\n";
		$sql_str='select a.sendtime,b.str,a.str,a.recievetime from systemhistorystatus a,status b where a.systemid='.$par_systemID.' and a.serviceid='.$par_serviceID.' and a.statusid=b.id and a.sendtime like \''.$date_str.'%\' order by a.sendtime desc';
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);
		$flag=FALSE;
		for($row_index=0;$row_index<$row_count;$row_index++) {
			$row=$db->fetchRow($result,$row_index);
			$flag=TRUE;
			echo '<tr><td>'.timeString($row[0]).'</td><td align="center"><img src="images/'.$row[1].'.gif" alt="'.$row[1].'"></td><td>'.$row[2].'</td><td>'.timeString($row[3]).'</td></tr>'."\n";
		}		
		if($flag != TRUE) {
			$sql_str='select a.sendtime,b.str,a.str,a.recievetime from systemhistorystatusall a,status b where a.systemid='.$par_systemID.' and a.serviceid='.$par_serviceID.' and a.statusid=b.id and a.sendtime like \''.$date_str.'%\' order by a.sendtime desc';
			$result=$db->query($sql_str);
			$row_count=$db->getRowCount($result);
			for($row_index=0;$row_index<$row_count;$row_index++) {
				$row=$db->fetchRow($result,$row_index);
				echo '<tr><td>'.timeString($row[0]).'</td><td align="center"><img src="images/'.$row[1].'.gif" alt="'.$row[1].'"></td><td>'.$row[2].'</td><td>'.timeString($row[3]).'</td></tr>'."\n";
			}
		}
		echo '</table></td></tr></table>'."\n";
		echo '<input type="hidden" name="startDate" value="'.$startDate.'">'."\n";
		echo '<input type="hidden" name="par_systemType" value="'.$par_systemType.'">'."\n";
		printColorInfo();
		printSISIYA();
		echo '</form>'."\n";
		break;
######################################################################################################
	case 4 :
		$par_systemName=getHTTPValue('par_systemName');
		if($par_systemName == '') {
			echo '<h1>Error: par_systemName is not set!</h1>';
			break;
		}
		$par_systemID=getHTTPValue('par_systemID');
		if($par_systemID == '') {
			echo '<h1>Error: par_systemID is not set!</h1>';
			break;
		}
		$par_systemType=getHTTPValue('par_systemType');
		if($par_systemType == '') {
			echo '<h1>Error: par_systemType is not set!</h1>';
			break;
		}

		echo '<title>SISIYA a System Monitoring Tool (by Erdal Mutlu) System Services</title></head><body bgcolor="#FFFFFF">'."\n";
		echo '<table border="0" width="100%"><tr><td align="left">'."\n";
		echo '<img src="images/sisiya_logo.gif" alt="SisIYA\'s logo">'."\n";
		echo '</td><td align="left" colspan="3"><h1>System Info ['.$par_systemName.']</h1></td></tr>'."\n";
		echo '<tr><td align="left">'."\n";
		echo '<img src="images/'.$par_systemName.'.gif" alt="'.$par_systemName.'"><img src="images/'.$par_systemType.'.gif" alt="'.$par_systemType.'"></td>'."\n";
		echo '<td><a href="'.$prog_name.'?par_formID=0">System Overview</a></td><td><a href="'.$prog_name.'?par_formID=1">Detailed System View</a></td>';
		echo '<td><a href="'.$prog_name.'?par_formID=2&amp;par_systemID='.$par_systemID.'&amp;par_systemName='.$par_systemName.'&amp;par_systemType='.$par_systemType.'">System Services ['.$par_systemName.']</a></td></tr>'."\n";
		echo '<tr><td align="center" colspan="4"><center><table border="1" cellpadding="1" cellspacing="0">'."\n";
	
		$sql_str='select a.hostname,a.fullhostname,a.cpu,a.ram,a.hd,a.vendorstr,a.sizestr,a.servicesstr,a.effectsglobal from systems a,systemtypes b,locations c where a.hostname=\''.$par_systemName.'\' and a.systemtypeid=b.id and a.locationid=c.id';
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);
		
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			echo '<tr><td>Hostname</td><td>'.$row[0].'</td></tr>'."\n";
			echo '<tr><td>Full Hostname</td><td>'.$row[1].'</td></tr>'."\n";
			echo '<tr><td>CPU</td><td>'.$row[2].'</td></tr>'."\n";
			echo '<tr><td>RAM</td><td>'.$row[3].'</td></tr>'."\n";
			echo '<tr><td>HD</td><td>'.$row[4].'</td></tr>'."\n";
			echo '<tr><td>Vendor Info</td><td>'.$row[5].'</td></tr>'."\n";
			echo '<tr><td>Size</td><td>'.$row[6].'</td></tr>'."\n";
			echo '<tr><td>Function</td><td>'.$row[7].'</td></tr>'."\n";
			echo '<tr><td>Does the system effects the overall status?</td><td>';
			if($row[8] == 't')
				echo 'Yes';
			else
				echo 'No';
			echo '</td></tr>'."\n";
		}
		echo '</table></td></tr></table>'."\n";
		printSISIYA();
		break;
######################################################################################################
	case 5 :
		echo '<title>SISIYA a System Monitoring Tool (by Erdal Mutlu) Detailed System Overview</title></head><body bgcolor="'.$colors['bg'].'" text"'.$colors['font'].'" link="'.$colors['link'].'" vlink="'.$colors['vlink'].'" alink="'.$colors['alink'].'">'."\n";
		echo '<table border="0" width="100%"><tr><td align="left">'."\n";
		echo '<img src="images/sisiya_logo.gif" alt="SisIYA\'s logo">'."\n";
		echo '</td><td align="center"><h1>Detailed System View</h1></td>'."\n";	
		echo '<td align="right">Last updated : ';
		printLastUpdated();
		echo '</td></tr>'."\n";
		$global_status=getSystemGlobalStatus();
		#$nservices=getMaxNumberOfServices();
		$services=getAllActiveServices();
		$nservices=count($services);
		echo '<tr><td colspan="3" align="center"><table border="0"><tr><td>';
		echo '<h2>Overall system status :</h2></td><td><img src="images/'.$global_status.'_big.gif" alt=""></td><td><h2>'.$global_status.'</h2></td>';
		echo '<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$prog_name.'?par_formID=0">System Overview</a></td><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$prog_name.'?par_formID=1">Detailed System View</a></td></tr></table></tr>'."\n";
	

		$sql_str='select e.str,a.effectsglobal,a.hostname,b.str,d.str,a.id,f.str,b.id from systems a,services b,systemservicestatus c,status d,locations e,systemtypes f where a.id=c.systemid and c.serviceid=b.id and d.id=c.statusid and a.locationid=e.id and a.systemtypeid=f.id order by e.str,a.effectsglobal desc,a.hostname,b.str';
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);
		$Count=0;
		$old_location_str='';
		$row_index=0;
		while($row_index < $row_count) {
			if($row_index == 0) {
				$row=$db->fetchRow($result,$row_index);
				$row_index++;
			}
			if("$old_location_str" != $row[0]) { # every time when the location is changed
				if("$old_location_str" != '') {
					echo '<tr><td colspan="'.($nservices+1).'" bgcolor="'.$colors['tableHeaderBg'].'">';
					echo '<font color="'.$colors['tableFooterFont'].'">Total number of systems : '.$Count.' (';
					printTotalNumberOfSystems($old_location_str);
					echo ')</font></td></tr></table></center><br>'."\n";
					$Count=0;
				}
				echo '<a name="'.$row[0].'"><!--  --></a>'."\n";
				echo '<table border="1" width="100%" cellpadding="0" cellspacing="0" bgcolor="'.$colors['tableBg'].'">'."\n";
				echo '<tr><th colspan="'.($nservices+1).'" align="center" bgcolor="'.$colors['tableHeaderBg'].'"><font color="'.$colors['tableHeaderFont'].'">'.$row[0].'</font></th></tr>'."\n";
				echo '<tr bgcolor="'.$colors['tableHeaderBg'].'"><td align="center">Hostanme</td>';
				for($i=0;$i<$nservices;$i++) {
					echo '<td align="center">'.$services["$i"]['str'].'</td>';
				}
				echo '</tr>'."\n";
				$old_location_str=$row[0];
			}
			# print a table row with service statuses
			echo '<tr><td';
			if($row[1] == 'f')
				echo ' bgcolor="'.$colors['nonCriticalSystem'].'"';
			else
				echo ' bgcolor="'.$colors['tableBg'].'"';
			echo '><a href="'.$prog_name.'?par_formID=2&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[2].'&amp;par_systemType='.$row[6].'">'.$row[2].'</a></td>';
			$hostname=$row[2];
			for($i=0;$i<$nservices;$i++) {
				if($row[2] == $hostname) {
					if($services["$i"]['str'] == $row[3]) {
						echo '<td align="center"><a href="'.$prog_name.'?par_formID=3&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[2].'&amp;par_serviceID='.$row[7].'&amp;par_serviceName='.$row[3].'&amp;startDate=0&amp;par_systemType='.$row[6].'"><img src="images/'.$row[4].'.gif" alt="'.$row[4].'" border="0"></a></td>';
						if($row_index < $row_count) {
							$row=$db->fetchRow($result,$row_index);
							$row_index++;
						}
					}
					else {
						echo '<td align="center">.</td>';
					}
				}
				else {
					echo '<td align="center">.</td>';
				}
			}
			echo '</tr>'."\n";
			$Count++;
		} 
		echo '<tr><td colspan="'.($nservices+1).'" bgcolor="'.$colors['tableFooterBg'].'"><font color="'.$colors['tableFooterFont'].'">Total number of systems : '.$Count.' (';
		printTotalNumberOfSystems($row[0]);
		echo ')</font></td></tr></table>'."\n";
		printColorInfo();
		printSISIYA();
		break;
######################################################################################################

	default:
		echo "<title>SisIYA a System Monitoring Tool (by Erdal Mutlu)</title></head><body>\n";
		echo "<center><h2>Error : FormID=$par_formID is not defined!</h2></center>\n";
		printSISIYA();
		break;
}

# free the result
if(isset($result))
	$db->freeResult($result);
# close the db connection  
$db->close(); # this will not have an effect if the connection is persistent

echo "</body></html>\n";
?>
