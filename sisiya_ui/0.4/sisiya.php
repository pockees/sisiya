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

include_once("sisiyaconf.php");

$progName=$_SERVER['PHP_SELF'];


startSession($sessionName);


####################################################################################      
#### Functions
####################################################################################      
function format_message($msg_str)
{
	### 
	$str=$msg_str;
	#$patterns=array('/INFO:/i','/OK:/i','/WARNING:/i','/ERROR:/i');
	$patterns=array('/INFO:/','/OK:/','/WARNING:/','/ERROR:/');
	#$replacements=array('<br /><span style="background-color:blue">INFO:</span>','<br /><span style="background-color:green">OK:</span>','<br /><span style="background-color:yellow">WARNING:</span>','<br /><span style="background-color:red">ERROR:</span>');

	#$info_str='<br /><span style="background-color:blue">INFO:</span>';
	#$ok_str='<br /><span style="background-color:green">OK:</span>';
	#$warning_str='<br /><span style="background-color:yellow">WARNING:</span>';
	#$error_str='<br /><span style="background-color:red">ERROR:</span>';
	$info_str='<br /><span style="color:blue">INFO:</span>';
	$ok_str='<br /><span style="color:green">OK:</span>';
	$warning_str='<br /><span style="color:orange">WARNING:</span>';
	$error_str='<br /><span style="color:red">ERROR:</span>';
	$replacements=array($info_str,$ok_str,$warning_str,$error_str);
	$str=preg_replace($patterns, $replacements, $str);
	### remove the first <br />
	$str=preg_replace("/<br \/>/","",$str,1);
	return $str;
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
		$str='<td class="ok">'.$str;
	else if($days > 3)
		$str='<td class="warning">'.$str;
	else
		$str='<td class="error">'.$str;
	return $str.'</td>';
}

function getTotalNumberOfSystems2($location)
{
	global $db,$valid_user,$user_id;
 
	if($valid_user != '')
		$sql_str='select c.str,count(*) as cc from systems a,groups b,systemtypes c,groupsystem d where a.active=\'t\' and a.systemtypeid=c.id and a.id=d.systemid and b.id=d.groupid and b.userid='.$user_id.' and b.str=\''.$location.'\' group by c.id order by cc desc,c.str';
	else
		$sql_str='select c.str,count(*) as cc from systems a,locations b,systemtypes c where a.active=\'t\' and a.systemtypeid=c.id and a.locationid=b.id and b.str=\''.$location.'\' group by c.id order by cc desc,c.str';
	$result=$db->query($sql_str);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) 
		$str='0';
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
	return $str;
}

function printTotalNumberOfSystems2($location)
{
	echo getTotalNumberOfSystems2($location);
}

function getNumberOfNotViewedSystems()
{
	global $db,$valid_user;
 
	if($valid_user == '')
		return;

	$sql_str='select bb.str,count(*) as cc from systems aa,systemtypes bb where aa.systemtypeid=bb.id and aa.active=\'t\' and aa.hostname not in (select a.hostname from systems a,groups b,groupsystem c where a.id=c.systemid and b.id=c.groupid and b.userid=-1 group by a.hostname) group by bb.id order by cc desc';
	$result=$db->query($sql_str);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) 
		$str='0';
	else {
		$str='';
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			if($str == '')
				$str=$str.$row[1].' '.$row[0];
			else
				$str=$str.', '.$row[1].' '.$row[0];
		}
	}
	$html='';
	if($str != '0') {
		$html.='<center><table border="0">'."\n";
		$html.='<tr><td>';
		$html.='Not viewed systems: '.$str.'</td><tr>';
		$html.='</table></center>'."\n";
	}
	return $html;
}


function printNumberOfNotViewedSystems()
{
	echo getNumberOfNotViewedSystems();
}

function printTotalNumberOfSystems($location)
{
	global $db;
 
	$sql_str='select c.str,count(*) as cc from systems a,locations b,systemtypes c where a.active=\'t\' and a.systemtypeid=c.id and a.locationid=b.id and b.str=\''.$location.'\' group by c.id order by cc desc';
	$result=$db->query($sql_str);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) 
		$str='0';
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
function getSystemGlobalStatus()
{
	global $db,$valid_user,$user_id,$lrb;
 
	if($valid_user != '')
		$sql_str='select max(statusid) from systemstatus a,systems b,groups c,groupsystem d where a.systemid=b.id and b.active=\'t\' and effectsglobal=\'t\' and b.id=d.systemid and c.id=d.groupid and c.userid='.$user_id; 
	else
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
	if($count == '')
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
	if($count == '')
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

function timeString($s) 
{
	$str=$s{8}.$s{9}.':'.$s{10}.$s{11}.':'.$s{12}.$s{13}.' '.$s{6}.$s{7}.'.'.$s{4}.$s{5}.'.'.$s{0}.$s{1}.$s{2}.$s{3};
	return $str;
}

function dateString($s) 
{
	$str=$s{6}.$s{7}.'.'.$s{4}.$s{5}.'.'.$s{0}.$s{1}.$s{2}.$s{3};
	return $str;
}

function OverviewForm()
{
	global $progName,$progNameAdm,$db,$ncolumns,$valid_user,$user_id,$lrb,$language;

	displayFormHeader($lrb['sisiya.system_overview.header']);

	$html='';
	$global_status=getSystemGlobalStatus();
	$html.='<table class="header2">'."\n";
	$html.="<tr><td><h2>";
	$html.=$lrb['sisiya.OverallSystemStatus'].' :</h2></td><td valign="middle"><img src="images/'.$global_status.'_big.gif" alt="" /></td>';
	$html.='<td><h2>'.$lrb['sisiya.status.'.strtolower($global_status)].'</h2></td>';
	$html.='<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right">';
	$html.='<a href="'.$progName.'?par_formName=system_detailed_view&amp;par_language='.$language.'">';
	$html.=$lrb['sisiya.system_detailed_view.header'].'</a></td><td>';
	$html.='&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>';
	$html.="</table>\n";

	if($valid_user != '') 
		$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,g.str,e.id from systemstatus a,status b,systems c left outer join systeminfo g on g.systemid=c.id and g.infoid=1,systemtypes d,groups e,groupsystem f where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and e.id=f.groupid and f.systemid=c.id and e.userid=".$user_id." order by e.sortid,e.str,c.effectsglobal desc,c.hostname";
	else
		$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,f.str,e.id from systemstatus a,status b,systems c left outer join systeminfo f on f.systemid=c.id and f.infoid=1,systemtypes d,locations e where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and c.locationid=e.id order by e.sortid,e.str,c.effectsglobal desc,c.hostname;";

	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);
	$Count=0;
	$old_group_str='';
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
			if("$old_group_str" != $row[4]) { // every time when the location is changed
				if("$old_group_str" != '') {
					$html.='</tr><tr class="footer"><td colspan="'.$ncolumns.'">';
					$html.=$lrb['sisiya.TotalSystems'].' : '.$Count.' (';
					$html.=getTotalNumberOfSystems2($old_group_str);
					$html.=')</td></tr>'."\n";

					$html.='</table>'."\n";
					$Count=0;
				}
				$html.='<ins><p /></ins><table class="system_overview">'."\n";
				$html.='<tr class="header"><td colspan="'.$ncolumns.'">';
				$html.='<a href="'.$progName.'?&amp;par_language='.$language;
				$html.='&amp;par_formName=system_detailed_view#'.$row[8].'">'.$row[4].'</a></td></tr>'."\n";
				$old_group_str=$row[4];
				$i=0; // starting a new table
			}
			if($i == 0)
				$html.='<tr class="row">'."\n";
			if($row[6] == 'f')
				$html.='<td class="effectsfalse">';
			else
				$html.='<td>';
			$html.='<a href="'.$progName.'?par_formName=system_services&amp;par_language='.$language.'&amp;par_systemID=';
			$html.=$row[5].'&amp;par_systemName='.$row[0].'&amp;par_systemType='.$row[3];
			$html.='" onmouseover="window.status=\''.$row[0].' ('.$row[7].') : '.$row[2];
			$html.='\'; return true;" onmouseout="window.status=\'\';" title="'.$row[0];
			$html.=' ('.$row[7].') : '.$row[2].'"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'" /></a></td>'."\n";
			$Count++;
		}
		$html.='</tr>'."\n";
	}
	if($row_count > 0) {
		$html.='<tr class="footer"><td colspan="'.$ncolumns.'">'.$lrb['sisiya.TotalSystems'].' : '.$Count.' (';
		$html.=getTotalNumberOfSystems2($row[4]);
		$html.=')</td></tr>'."\n";
	}
		
	$html.="</table>\n";
	
	$html.=getNumberOfNotViewedSystems();

	$html.='<ins><p /></ins>'."\n";
	$html.='<table class="info">'."\n";
	$html.='<tr><td>';
	$html.=getColorInfo();
	$html.='</td></tr>';
	$html.='<tr><td>';
	$html.=getSisIYA();
	$html.='</td></tr>';
	$html.='</table>';

	#$html.=getSisIYAandCompatable();
	echo $html;
}

function DetailedViewForm()
{
	global $progName,$db,$ncolumns,$valid_user,$user_id,$lrb,$language;

	displayFormHeader($lrb['sisiya.system_detailed_view.header']);

	$html='';
	$global_status=getSystemGlobalStatus();
	$html.='<table class="header2">'."\n";
	$html.="<tr><td><h2>";
	$html.=$lrb['sisiya.OverallSystemStatus'].' :</h2></td><td valign="middle"><img src="images/'.$global_status.'_big.gif" alt="" /></td>';
	$html.='<td><h2>'.$lrb['sisiya.status.'.strtolower($global_status)].'</h2></td>';
	$html.='<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$progName.'?par_formName=system_overview&amp;par_language='.$language.'">';
	$html.=$lrb['sisiya.system_overview.header'].'</a></td><td>';
	$html.='&nbsp;&nbsp;&nbsp;&nbsp;</td></tr>';
	$html.="</table>\n";


	if($valid_user != '') 
		$sql_str='select c.hostname,b.str,a.str,a.updatetime,a.changetime,d.str,e.str,c.id,c.effectsglobal from systemstatus a,status b,systems c,systemtypes d,groups e,groupsystem f where c.active=\'t\' and a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and e.id=f.groupid and f.systemid=c.id and e.userid='.$user_id.' order by e.sortid,e.str,c.effectsglobal desc,a.statusid desc,c.hostname'; 
	else
		$sql_str='select c.hostname,b.str,a.str,a.updatetime,a.changetime,d.str,e.str,c.id,c.effectsglobal,e.id from systemstatus a,status b,systems c,systemtypes d,locations e where c.active=\'t\' and a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.locationid=e.id order by e.sortid,e.str,c.effectsglobal desc,a.statusid desc,c.hostname'; 
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);
	$Count=0;
	$old_group_str='';
	$flag=TRUE;
	$row_index=0;
	while($flag ==  TRUE) {
		if($row_index >= $row_count) {
			$flag=FALSE;
			break;
		}
		$row=$db->fetchRow($result,$row_index);
		$row_index++;
		if("$old_group_str" != $row[6]) { # every time when the location is changed
			if("$old_group_str" != '') {
				$html.='<tr class="footer"><td colspan="6">';
				$html.=$lrb['sisiya.TotalSystems'].' : '.$Count.' (';
				$html.=getTotalNumberOfSystems2($old_group_str);
				$html.=')</td></tr>'."\n";
				$html.='</table><ins><p /></ins>'."\n";
				$Count=0;
			}
			$html.='<h1><a name="'.$row[9].'"></a></h1>'."\n";
			$html.='<table class="system_detailed_view">'."\n";
			$html.='<tr class="header"><td colspan="6">'.$row[6].'</td></tr>'."\n";
			$html.='<tr class="subheader">';
			$html.='<td>'.$lrb['sisiya.System'].'</td>';
			$html.='<td>'.$lrb['sisiya.Status'].'</td>';
			$html.='<td>'.$lrb['sisiya.Description'].'</td>';
			$html.='<td>'.$lrb['sisiya.UpdateTime'].'</td>';
			$html.='<td>'.$lrb['sisiya.StatusChangeTime'].'</td>';
			$html.='<td>'.$lrb['sisiya.StatusChangedSince'].'</td></tr>'."\n";
			$old_group_str=$row[6];
		}
		$html.='<tr class="row">';
		$html.='<td><a href="'.$progName.'?par_formName=system_services'.'&amp;par_language='.$language.'&amp;par_systemID='.$row[7];
		$html.='&amp;par_systemName='.$row[0].'&amp;par_systemType='.$row[5].'">';
		$html.='<img src="images/'.$row[5].'.gif" alt="'.$row[5].'" height="25" /><br />';
		$html.=$row[0].'</a></td>';
		if($row[8] == 'f')
			$html.='<td class="effectsfalse">';
		else
			$html.='<td>';
		$html.='<img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'" /></td>';
		#$html.='<td>'.parseHTML($row[2]).'</td>';
		$html.='<td>'.$row[2].'</td>';
		$html.='<td>'.timeString($row[3]).'</td>';
		$html.='<td>'.timeString($row[4]).'</td>';
		#$html.='<td class="ok">'.getChangedString($row[3],$row[4]).'</td>';
		$html.=getChangedString($row[3],$row[4]);
		$html.='</tr>'."\n";
		$Count++;
	} 
	$html.='<tr class="footer"><td colspan="6">';
	$html.=$lrb['sisiya.TotalSystems'].' : '.$Count.' (';
	$html.=getTotalNumberOfSystems2($row[6]);
	$html.=')</td></tr>'."\n";
	$html.='</table>'."\n";
	$html.=getNumberOfNotViewedSystems();
	$html.=getColorInfo();
	$html.=getSisIYA();
	echo $html;
}

function SystemServicesForm()
{
	global $progName,$db,$ncolumns,$lrb,$language;

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
	displayFormHeader($lrb['sisiya.system_services.header'].' ['.$par_systemName.']');

	$html='';
	$html.='<table class="header_system_services">'."\n";
	$html.='<tr><td align="left" rowspan="2">'."\n";
	$html.='<img src="images/'.$par_systemName.'.gif" alt="'.$par_systemName.'" />';
	$html.='<img src="images/'.$par_systemType.'.gif" alt="'.$par_systemType.'" /></td>'."\n";
	$html.='<td><a href="'.$progName.'?par_formName=system_overview'.'&amp;par_language='.$language.'">';
	$html.=$lrb['sisiya.system_overview.header'].'</a></td>';
	$html.='<td><a href="'.$progName.'?par_formName=system_detailed_view'.'&amp;par_language='.$language.'">';
	$html.=$lrb['sisiya.system_detailed_view.header'].'</a></td>';
	$html.='<td><a href="'.$progName.'?par_formName=system_info'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID.'&amp;';
	$html.='par_systemName='.$par_systemName.'&amp;par_systemType='.$par_systemType.'">'.$lrb['sisiya.system_info.header'].'</a></td>'."\n";
	$html.="</tr></table>\n";
	$html.='<table class="system_services">'."\n";
	$html.='<tr class="header">';
	$html.='<td>'.$lrb['sisiya.Service'].'</td>';
	$html.='<td>'.$lrb['sisiya.Status'].'</td>';
	$html.='<td>'.$lrb['sisiya.Description'].'</td>';
	$html.='<td>'.$lrb['sisiya.UpdateTime'].'</td>';
	$html.='<td>'.$lrb['sisiya.StatusChangeTime'].'</td>';
	$html.='<td>'.$lrb['sisiya.StatusChangedSince'].'</td></tr>'."\n";

	$sql_str="select d.str,b.str,a.str,a.updatetime,a.changetime,d.id,e.str from systemservicestatus a,status b,systems c,services d,systemtypes e where c.hostname='".$par_systemName."' and a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id and c.systemtypeid=e.id order by c.id,a.statusid desc,d.str";

	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	for($row_index=0;$row_index<$row_count;$row_index++) {
		$row=$db->fetchRow($result,$row_index);
		$html.='<tr class="row"><td><a href="'.$progName.'?par_formName=system_service_history'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID;
		$html.='&amp;par_systemName='.$par_systemName.'&amp;par_serviceID='.$row[5];
		$html.='&amp;par_serviceName='.$row[0].'&amp;startDate=0&amp;par_systemType=';
		$html.=$par_systemType.'">'.$row[0].'</a></td>';
		$html.='<td align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'" /></td>';
		#$html.='<td>'.$row[2].'</td>';
		$html.='<td>'.format_message($row[2]).'</td>';
		$html.='<td>'.timeString($row[3]).'</td>';
		$html.='<td>'.timeString($row[4]).'</td>';
		#$html.='<td>'.getChangedString($row[3],$row[4]).'</td></tr>'."\n"; 
		$html.=getChangedString($row[3],$row[4]).'</tr>'."\n"; 
	}
	$html.="</table>\n";
	$html.=getColorInfo();
	$html.=getSisIYA();
	echo $html;
}

function ServiceHistoryForm()
{
	global $progName,$db,$ncolumns,$today,$lrb,$language;

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
		$sql_str='select starttime,str from systemservice where systemid='.$par_systemID.' and serviceid='.$par_serviceID;
		$result=$db->query($sql_str);
		$str='';
		if($db->getRowCount($result) == 1) {
			$row=$db->fetchRow($result,0);
			$startDate=$row[0]{0}.$row[0]{1}.$row[0]{2}.$row[0]{3}.$row[0]{4}.$row[0]{5}.$row[0]{6}.$row[0]{7};
			$str=$row[1];
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
	
	displayFormHeader($lrb['sisiya.system_service_history.header'].' ['.$par_systemName.']');

	$html='';
	$html.='<table class="header">'."\n";
	$html.='<tr><td>'."\n";
	$html.='<img src="images/'.$par_systemName.'.gif" alt="'.$par_systemName.'" /><img src="images/'.$par_systemType.'.gif" alt="'.$par_systemType.'" /></td>'."\n";
	$html.='<td><a href="'.$progName.'?par_formName=system_overview'.'&amp;par_language='.$language.'">';
	$html.=$lrb['sisiya.system_overview.header'].'</a></td>'."\n";
	$html.='<td><a href="'.$progName.'?par_formName=system_detailed_view'.'&amp;par_language='.$language.'">';
	$html.=$lrb['sisiya.system_detailed_view.header'].'</a></td>'."\n";
	$html.='<td><a href="'.$progName.'?par_formName=system_services'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID.'&amp;par_systemName=';
	$html.=$par_systemName.'&amp;par_systemType='.$par_systemType.'">';
	$html.=$lrb['sisiya.system_services.header'].' ['.$par_systemName.']</a></td>'."\n";
	$html.='<td><a href="'.$progName.'?par_formName=system_info'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID.'&amp;par_systemName=';
	$html.=$par_systemName.'&amp;par_systemType='.$par_systemType.'">';
	$html.=$lrb['sisiya.system_info.header'].'</a></td></tr>'."\n";
	$html.='<tr><td>'.$lrb['sisiya.Service'].' : '.$par_serviceName.'</td>';
	$html.='<td colspan="3">'.$lrb['sisiya.ChooseADate'];
	$html.='<form method="post" action="'.$progName.'?par_formName=system_service_history'.'&amp;par_language='.$language;
	$html.='&amp;par_systemID='.$par_systemID;
	$html.='&amp;par_systemName='.$par_systemName.'&amp;par_serviceID='.$par_serviceID;
	$html.='&amp;par_serviceName='.$par_serviceName.'&amp;startDate='.$startDate.'&amp;par_systemType='.$par_systemType.'">'."\n";	
	$html.='<ins><select name="date_str">'."\n";
	$current_date=$today;
	while($d != $beforeStartDate) {
		$html.='<option ';
		if($date_str == $d) 
	 		$html.='selected="selected" ';
		$html.='value="'.$d.'">'.dateString($d).'</option>'."\n";
		$current_date=getdate(mktime(0,0,0,$current_date['mon'],$current_date['mday']-1,$current_date['year']));
		$d=$current_date['year'].echo_value($current_date['mon']).echo_value($current_date['mday']);
	}
	$html.='</select>';

#	$html.='<input type="hidden" name="startDate" value="'.$startDate.'" />'."\n";
	$html.='<input type="submit" name="button" value="'.$lrb['sisiya.Refresh'].'" />';
	$html.='<input type="hidden" name="par_systemType" value="'.$par_systemType.'" />'."\n";
	$html.='</ins></form>';
	$html.='</td></tr>'."\n";
	$html.='<tr><td colspan="5">';
	$html.=$lrb['sisiya.ServiceDescription'].'</td><td>'.$str.'</td></tr>'."\n";
	$html.='</table>'."\n";
	
	$html.='<table class="system_service_history">'."\n";
	$html.='<tr class="header">';
	$html.='<td>'.$lrb['sisiya.RecievedTime'].'</td>';
	$html.='<td>'.$lrb['sisiya.Status'].'</td>';
	$html.='<td>'.$lrb['sisiya.Description'].'</td>';
	$html.='<td>'.$lrb['sisiya.SendTime'].'</td></tr>'."\n";
	$sql_str="select a.recievetime,b.str,a.str,a.sendtime from systemhistorystatus a,status b where a.systemid=".$par_systemID." and a.serviceid=".$par_serviceID." and a.statusid=b.id and a.recievetime like '".$date_str."%' order by a.recievetime desc";
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);
	$flag=FALSE;
	for($row_index=0;$row_index<$row_count;$row_index++) {
		$row=$db->fetchRow($result,$row_index);
		$flag=TRUE;
		$html.='<tr><td>'.timeString($row[0]).'</td>';
		$html.='<td align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'" /></td>';
		#$html.='<td>'.$row[2].'</td>';
		$html.='<td>'.format_message($row[2]).'</td>';
		$html.='<td>'.timeString($row[3]).'</td></tr>'."\n";
	}		
	if($flag != TRUE) {
		$sql_str='select a.recievetime,b.str,a.str,a.sendtime from systemhistorystatus'.substr($date_str,0,6).' a,status b where a.systemid='.$par_systemID.' and a.serviceid='.$par_serviceID.' and a.statusid=b.id and a.sendtime like \''.$date_str.'%\' order by a.recievetime desc';
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);
		for($row_index=0;$row_index<$row_count;$row_index++) {
			$row=$db->fetchRow($result,$row_index);
		$html.='<tr><td>'.timeString($row[0]).'</td>';
		$html.='<td align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'" /></td>';
		#$html.='<td>'.$row[2].'</td>';
		$html.='<td>'.format_message($row[2]).'</td>';
		$html.='<td>'.timeString($row[3]).'</td></tr>'."\n";

		}
	}
	$html.='</table>';

	$html.='<ins><p /></ins>'."\n";
	$html.='<table class="info">'."\n";
	$html.='<tr><td>';
	$html.=getColorInfo();
	$html.='</td></tr>';
	$html.='<tr><td>';
	$html.=getSisIYA();
	$html.='</td></tr>';
	$html.='</table>';

	echo $html;
}

function SystemInfoForm()
{
	global $progName,$db,$ncolumns,$lrb,$language;

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

	displayFormHeader($lrb['sisiya.system_info.header'].' ['.$par_systemName.']');

	$html='';
	$html.='<table class="header_system_info">'."\n";
	$html.='<tr><td><img src="images/'.$par_systemName.'.gif" alt="'.$par_systemName.'" />';
	$html.='<img src="images/'.$par_systemType.'.gif" alt="'.$par_systemType.'" /></td>'."\n";
	$html.='<td><a href="'.$progName.'?par_formName=system_overview'.'&amp;par_language='.$language.'">';
	$html.=$lrb['sisiya.system_overview.header'].'</a></td>'."\n";
	$html.='<td><a href="'.$progName.'?par_formName=system_detailed_view'.'&amp;par_language='.$language.'">';
	$html.=$lrb['sisiya.system_detailed_view.header'].'</a></td>'."\n";
	$html.='<td><a href="'.$progName.'?par_formName=system_services'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID;
	$html.='&amp;par_systemName='.$par_systemName.'&amp;par_systemType='.$par_systemType.'">';
	$html.=$lrb['sisiya.system_services.header'].' ['.$par_systemName.']</a></td></tr>'."\n";
	$html.='</table>'."\n";
	$html.='<table class="system_info">'."\n";

	$sql_str='select a.hostname,a.fullhostname,a.effectsglobal,a.id from systems a,systemtypes b,locations c where a.hostname=\''.$par_systemName.'\' and a.systemtypeid=b.id and a.locationid=c.id';
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);
	
	if($row_count == 1) {
		$row=$db->fetchRow($result,0);
		$html.='<tr><td class="label">'.$lrb['sisiya.SystemName'].'</td>';
		$html.='<td>'.$row[0].'</td></tr>'."\n";
		$html.='<tr><td class="label">'.$lrb['sisiya.FullSystemName'].'</td>';
		$html.='<td>'.$row[1].'</td></tr>'."\n";
		$html.='<tr><td class="label">';
		$html.=$lrb['sisiya.QEffectsGlobalStatus'].'</td>';
		$html.='<td>';
		if($row[2] == 't')
			$html.=$lrb['sisiya.Yes'];
		else
			$html.=$lrb['sisiya.No'];
		$html.='</td></tr>'."\n";
		$sql_str='select b.str,a.str from systeminfo a,infos b where a.infoid=b.id and a.systemid='.$row[3].' order by b.sortid,b.str'; 
		$result2=$db->query($sql_str);
		$row_count2=$db->getRowCount($result2);
		for($i=0;$i<$row_count2;$i++) {
			$row2=$db->fetchRow($result2,$i);
			$html.='<tr><td class="label">'.$row2[0].'</td>';
			$html.='<td>'.$row2[1].'</td></tr>'."\n";
		}
	}
	$html.='</table>'."\n";

	$html.='<ins><p /></ins>'."\n";
	$html.='<table class="info">'."\n";
	$html.='<tr><td>';
	$html.=getSisIYA();
	$html.='</td></tr>';
	$html.='</table>';

	echo $html;
}

function DetailedSystemOverviewForm()
{
	global $progName,$db,$ncolumns;

	#$nservices=getMaxNumberOfServices();
	$services=getAllActiveServices();
	$nservices=count($services);
	echo '<tr><td colspan="3" align="center"><table border="0"><tr><td>';
	echo '<h2>Overall system status :</h2></td><td><img src="images/'.$global_status.'_big.gif" alt="" /></td><td><h2>'.$global_status.'</h2></td>';
	echo '<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$progName.'?par_formName=system_overview">System Overview</a></td><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$progName.'?par_formName=system_detailed_view">Detailed System View</a></td></tr></table></tr>'."\n";


	$sql_str='select e.str,a.effectsglobal,a.hostname,b.str,d.str,a.id,f.str,b.id from systems a,services b,systemservicestatus c,status d,locations e,systemtypes f where a.id=c.systemid and c.serviceid=b.id and d.id=c.statusid and a.locationid=e.id and a.systemtypeid=f.id order by e.str,a.effectsglobal desc,a.hostname,b.str';
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);
	$Count=0;
	$old_group_str='';
	$row_index=0;
	while($row_index < $row_count) {
		if($row_index == 0) {
			$row=$db->fetchRow($result,$row_index);
			$row_index++;
		}
		if("$old_group_str" != $row[0]) { # every time when the location or group is changed
			if("$old_group_str" != '') {
				echo '<tr><td colspan="'.($nservices+1).'" >';
				echo 'Total number of systems : '.$Count.' (';
				printTotalNumberOfSystems($old_group_str);
				echo ')</td></tr></table></center><br />'."\n";
				$Count=0;
			}
			echo '<a name="'.$row[0].'"><!--  --></a>'."\n";
			echo '<table border="1" width="100%" cellpadding="0" cellspacing="0">'."\n";
			echo '<tr><th colspan="'.($nservices+1).'" align="center">'.$row[0].'</th></tr>'."\n";
			echo '<tr><td align="center">Hostanme</td>';
			for($i=0;$i<$nservices;$i++) {
				echo '<td align="center">'.$services["$i"]['str'].'</td>';
			}
			echo '</tr>'."\n";
			$old_group_str=$row[0];
		}
		# print a table row with service statuses
		echo '<tr><td';
		if($row[1] == 'f')
			echo ' bgcolor="red"';
		else
			echo ' bgcolor="blue"';
		echo '><a href="'.$progName.'?par_formName=system_services&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[2].'&amp;par_systemType='.$row[6].'">'.$row[2].'</a></td>';
		$hostname=$row[2];
		for($i=0;$i<$nservices;$i++) {
			if($row[2] == $hostname) {
				if($services["$i"]['str'] == $row[3]) {
					echo '<td align="center"><a href="'.$progName.'?par_formName=system_service_history&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[2].'&amp;par_serviceID='.$row[7].'&amp;par_serviceName='.$row[3].'&amp;startDate=0&amp;par_systemType='.$row[6].'"><img src="images/'.$row[4].'.gif" alt="'.$row[4].'" /></a></td>';
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
	echo '<tr><td colspan="'.($nservices+1).'">Total number of systems : '.$Count.' (';
	printTotalNumberOfSystems($row[0]);
	echo ')</td></tr></table>'."\n";
	printColorInfo();
	printSisIYA();
}

###################################################################################
$today=getdate(); 
$hours=$today['hours'];
$minutes=$today['minutes'];
$seconds=$today['seconds'];
$month=$today['mon']; 
$day=$today['mday']; 
$year=$today['year']; 


$par_formName=getHTTPValue('par_formName');
if(! isset($_SESSION['valid_user']) && $par_formName == 'login') {
	loginForm($progName,$sessionName);
	exit;
}

if($par_formName == '') 
	$par_formName='system_overview';
if($par_formName == 'logout') {
	$par_formName='system_overview';
	if(isset($_SESSION['valid_user']))
		unset($_SESSION['valid_user']);
}

### read language info from $_SESSION
initLanguage();

$language=$_SESSION['language'];
$charset=$_SESSION['charset'];

if(isset($_SESSION['valid_user'])) {
	$user_name=$_SESSION['user_name'];
	$user_surname=$_SESSION['user_surname'];
	$valid_user=$_SESSION['valid_user'];
	$user_id=$_SESSION['user_id'];
	$is_admin=$_SESSION['is_admin'];
}
#else {
#	$valid_user='';
#	$user_id='';
#	$user_name='';
#	$user_surname='';
#	$is_admin='';
#}

####################################################################################
#if($par_formName == 'logout') {
#	#displayDocHeader(basename($progName),0);
#	header('Location: login.php');
#	exit();
#}
$_SESSION['formName']=$par_formName;
####################################################################################
$refresh=180; ### refresh every 3 minutes
displayDocHeader(basename($progName),$_SESSION['charset'],$refresh);

### check par_formName. If it is not set set it to an appropriate value
$defaultForm='personinfo';
if($par_formName == '') {
	$par_formName=$defaultForm;
}
#if($par_formName == 'logout') {
#	logoutForm($progName,6);
#	header('Location: login.php');
#	exit;
#}

$_SESSION['formName']=$par_formName;
#echo 'form='.$par_formName;
switch($par_formName) {
	case 'system_overview' :
		OverviewForm();
		break;
	case 'system_detailed_view' :
		DetailedViewForm();
		break;
	case 'system_services' :
		SystemServicesForm();
		break;
	case 'system_service_history' :
		ServiceHistoryForm();
		break;
	case 'system_info' :
		SystemInfoForm();
		break;
#	case '' :
#		DetailedSystemOverviewForm();
#		break;
#	case 'login' :
#		loginForm($progName,$sessionName);
#		exit;
#		break;
	default:
		echo "<title>SisIYA a System Monitoring Tool (by Erdal Mutlu)</title></head><body>\n";
		echo "<center><h2>Error : FormName=$par_formName is not defined!</h2></center>\n";
		printSisIYA();
		break;
}

# free the result
if(isset($result))
	$db->freeResult($result);
# close the db connection  
$db->close(); # this will not have an effect if the connection is persistent

echo "</body></html>\n";
?>
