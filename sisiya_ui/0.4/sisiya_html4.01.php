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

$progNameAdm='sisiya_adm.php';
$progNameLogin='sisiya_login.php';




startSession($sessionName);

/*
 formID : 	0 Overview index page
		1 Detailed index page
		2 Service status for a host. Params : systemID, systemType
		3 Service status history for a host. Params : systemID, serviceID, systemType
		4 System info. Params : systemID, systemType
		5 Detailed overview.
*/
$formIDs=array(0,1,2,3,4);

$ncolumns=22; // number of columns to be displayed

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
	#$colors['tableFooterBg']='#AACCFF';
	$colors['tableFooterBg']='#DDDDDD';
	$colors['tableFooterFont']='#000000';
	#$colors['tableHeaderBg']='#AABBFF';
	$colors['tableHeaderBg']='#DDDDDD';
	$colors['tableHeaderFont']='#000000';
	#$colors['nonCriticalSystem']='#00FFAA';
	$colors['nonCriticalSystem']='#00DDAA';
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
	global $colors,$lrb;

	$html='<br><center><table border="0">';
	$html.='<tr><td><font color="'.$colors['font'].'">'.$lrb['SymbolInfo']. ':</font></td><td>';
	$html.='<img src="images/Info.gif" alt="Info.gif"></td><td><font color="'.$colors['font'].'">'.$lrb['status.info'].'</font></td><td>';
	$html.='<img src="images/Ok.gif" alt="Ok.gif"></td><td><font color="'.$colors['font'].'">'.$lrb['status.ok'].'</font></td><td>';
	$html.='<img src="images/Warning.gif" alt="Warning.gif"></td><td>';
	$html.='<font color="'.$colors['font'].'">'.$lrb['status.warning'].'</font></td><td>';
	$html.='<img src="images/Error.gif" alt="Error.gif"></td><td>';
	$html.='<font color="'.$colors['font'].'">'.$lrb['status.error'].'</font></td></tr></table></center>'."\n";
	echo $html;
}

function printTotalNumberOfSystems2($location)
{
	global $db,$valid_user,$user_id;
 
	if($valid_user != '')
		$sql_str='select c.str,count(*) as cc from systems a,groups b,systemtypes c,groupsystem d where a.active=\'t\' and a.systemtypeid=c.id and a.id=d.systemid and b.id=d.groupid and b.userid='.$user_id.' and b.str=\''.$location.'\' group by c.id order by cc desc';
	else
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

function printNumberOfNotViewedSystems()
{
	global $db,$colors,$valid_user;
 
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
	if($str != '0') {
		echo '<center><table border="0">'."\n";
		echo '<tr><td bgcolor="'.$colors['tableFooterBg'].'">';
		echo '<font color="'.$colors['tableFooterFont'].'">Not viewed systems: '.$str.'</font></td><tr>';
		echo '</table></center>'."\n";
	}
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

function printLastUpdated()
{
	global $db,$hours,$minutes,$seconds,$month,$day,$year,$lrb;
 
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
	$now_str=echo_value($hours).":".echo_value($minutes).":".echo_value($seconds)." ".echo_value($day).".".echo_value($month).".".echo_value($year);
	$update_str.='<br>'.$lrb['ServerTime'].' : '.$now_str;
	echo $update_str;
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

function printLastUpdatedAndUserInfo()
{
	global $progName,$progNameAdm,$progNameLogin,$sessionName,$colors,$valid_user,$user_name,$user_surname,$user_id,$lrb;

	if(isset($_SESSION['valid_user'])) {
		echo '<td align="right"><font color="'.$colors['font'].'">';
		echo $user_name.' '.$user_surname.' ('.$valid_user.') ';
		echo '<a href="'.$progName.'?par_formID=-1">'.$lrb['Logout'].'</a>';
		echo '&nbsp;&nbsp;<a href="'.$progNameAdm.'">'.$lrb['Preferences'].'</a>';
		echo '<br>'.$lrb['LastUpdated'].' : ';
	}
	else {
		echo '<td align="right"><font color="'.$colors['font'].'">';
		echo '<a href="'.$progName.'?par_formID=6">'.$lrb['Login'].'</a>';
		echo '&nbsp;&nbsp;<a href="'.$progNameAdm.'">'.$lrb['Preferences'].'</a>';
		echo '<br>'.$lrb['LastUpdated'].' : ';
	}
	printLastUpdated();
}

function printFlags()
{
	global $progName,$progNameAdm,$progNameLogin,$sessionName,$colors,$valid_user,$user_name,$user_surname,$user_id,$language,$lrb,$langs;

	
	$html='';
	for($i=0;$i<count($langs);$i++) {
		if($i > 0)
			$html.='&nbsp;';
		$html.='<a href="'.$progName.'?par_formID=0&par_language='.$langs[$i].'">';
		$html.='<img border="0" src="images/flag-'.$langs[$i].'.png" alt="'.$langs[$i].'"></a>';
	}
	
	echo $html;
}


function OverviewForm()
{
	global $progName,$progNameAdm,$db,$colors,$ncolumns,$valid_user,$user_id,$lrb,$language;


	echo '<title>'.$lrb['sisiya.f0.title'].'</title></head>';
	echo '<body bgcolor="'.$colors['bg'].'">'."\n";
	echo '<center><table border="0" width="100%"><tr><td align="left">'."\n";
	echo '<a href="http://sisiya.sourceforge.net">';
	echo '<img border="0" src="images/SisIYA.gif" alt="SisIYA\'s logo"></a><br>'."\n";
	printFlags();
	echo '</td><td align="right"><h1><font color="'.$colors['h1'].'">';
	echo $lrb['sisiya.f0.header'].'</font></h1></td>'."\n";
	printLastUpdatedAndUserInfo();
	echo '</font></td></tr>'."\n";
	$global_status=getSystemGlobalStatus();
	echo '<tr><td colspan="3" align="center"><table border="0"><tr><td><h2><font color="'.$colors['h2'].'">';
	echo $lrb['sisiya.OverallSystemStatus'].' :</font></h2></td><td valign="top"><img src="images/'.$global_status.'_big.gif" alt=""></td>';
	echo '<td><h2><font color="'.$colors['h2'].'">'.$lrb['status.'.strtolower($global_status)].'</font></h2></td>';
	echo '<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$progName.'?par_formID=1&par_language='.$language.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f1.header'].'</font></a></td><td>';
	echo '&nbsp;&nbsp;&nbsp;&nbsp;</td></tr></table></tr>';

	if($valid_user != '') 
		#$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,c.servicesstr from systemstatus a,status b,systems c,systemtypes d,groups e,groupsystem f where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and e.id=f.groupid and f.systemid=c.id and e.userid=".$user_id." order by e.sortid,e.str,c.effectsglobal desc,a.statusid desc,c.hostname"; 
		#$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,g.str from systemstatus a,status b,systems c left outer join systeminfo g on g.systemid=c.id and g.infoid=1,systemtypes d,groups e,groupsystem f where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and e.id=f.groupid and f.systemid=c.id and e.userid=".$user_id." order by e.sortid,e.str,c.effectsglobal desc,a.statusid desc,c.hostname";
		$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,g.str from systemstatus a,status b,systems c left outer join systeminfo g on g.systemid=c.id and g.infoid=1,systemtypes d,groups e,groupsystem f where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and e.id=f.groupid and f.systemid=c.id and e.userid=".$user_id." order by e.sortid,e.str,c.effectsglobal desc,c.hostname";
	else
		#$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,c.servicesstr from systemstatus a,status b,systems c,systemtypes d,locations e where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and c.locationid=e.id order by e.sortid,e.str,c.effectsglobal desc,a.statusid desc,c.hostname"; 
		#$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,f.str from systemstatus a,status b,systems c left outer join systeminfo f on f.systemid=c.id and f.infoid=1,systemtypes d,locations e where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and c.locationid=e.id order by e.sortid,e.str,c.effectsglobal desc,a.statusid desc,c.hostname;";
		$sql_str="select c.hostname,b.str,a.str,d.str,e.str,c.id,c.effectsglobal,f.str from systemstatus a,status b,systems c left outer join systeminfo f on f.systemid=c.id and f.infoid=1,systemtypes d,locations e where a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.active='t' and c.locationid=e.id order by e.sortid,e.str,c.effectsglobal desc,c.hostname;";
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
					echo '<tr><td colspan="'.$ncolumns.'" bgcolor="'.$colors['tableFooterBg'];
					echo '"><font color="'.$colors['tableFooterFont'].'">';
					echo $lrb['TotalSystems'].' : '.$Count.' (';
					printTotalNumberOfSystems2($old_group_str);
					echo ')</font></td></tr>'."\n";

					echo '</table><br>'."\n";
					$Count=0;
				}
				echo '<tr><td colspan="3" align="center"><table border="0" bgcolor="'.$colors['tableBg'].'" cellpadding="1" cellspacing="0">'."\n";
				#echo '<tr><th colspan="'.$ncolumns.'" bgcolor="'.$colors['tableHeaderBg'].'"><font color="'.$colors['tableHeaderFont'].'">'.$row[4].'</font>&nbsp;&nbsp;<a href="'.$progName.'?par_formID=1#'.$row[4].'"><font color="'.$colors['link'].'">(detailed view)</font></a></th></tr>'."\n";
				echo '<tr><th colspan="'.$ncolumns.'" bgcolor="'.$colors['tableHeaderBg'].'"><a href="'.$progName.'?&amp;par_language='.$language.'&amp;par_formID=1#'.$row[4].'"><font color="'.$colors['tableHeaderFont'].'">'.$row[4].'</font></a></th></tr>'."\n";
				$old_group_str=$row[4];
				$i=0; // starting a new table
			}
			if($i == 0)
				echo '<tr bgcolor="'.$colors['tableBg'].'">'."\n";
			if($row[6] == 'f')
				echo '<td bgcolor="'.$colors['nonCriticalSystem'].'">';
			else
				echo '<td>';
			echo '<a href="'.$progName.'?par_formID=2&amp;par_language='.$language.'&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[0].'&amp;par_systemType='.$row[3].'" onmouseover="window.status=\''.$row[0].' ('.$row[7].') : '.$row[2].'\'; return true;" onmouseout="window.status=\'\';" title="'.$row[0].' ('.$row[7].') : '.$row[2].'"><img border="0" src="images/'.$row[1].'_big.gif" alt="'.$row[1].'"></a></td>'."\n";
			$Count++;
		}
		echo '</tr>'."\n";
	}
	echo '<tr><td colspan="'.$ncolumns.'" bgcolor="'.$colors['tableFooterBg'].'"><font color="'.$colors['tableFooterFont'].'">'.$lrb['TotalSystems'].' : '.$Count.' (';
	printTotalNumberOfSystems2($row[4]);
	echo ')</font></td></tr>'."\n";
		
	echo '</table></td></tr></table></center>'."\n";
	
	printNumberOfNotViewedSystems();
	
	printColorInfo();
	printSisIYA();
	#printSisIYAandCompatable();
}

function DetailedViewForm()
{
	global $progName,$db,$colors,$ncolumns,$valid_user,$user_id,$lrb,$language;

	echo '<title>'.$lrb['sisiya.f1.title'].'</title></head>';
	echo '<body bgcolor="'.$colors['bg'].'" text="'.$colors['font'].'" link="';
	echo $colors['link'].'" vlink="'.$colors['vlink'].'" alink="'.$colors['alink'].'">'."\n";
	echo '<table border="0" width="100%"><tr><td align="left">'."\n";
	echo '<a href="http://sisiya.sourceforge.net">';
	echo '<img border="0" src="images/SisIYA.gif" alt="SisIYA\'s logo"></a><br>'."\n";
	printFlags();
	echo '</td><td align="right"><h1><font color="'.$colors['h1'].'">';
	echo $lrb['sisiya.f1.header'].'</font></h1></td>'."\n";	
	printLastUpdatedAndUserInfo();
	echo '</font></td></tr>'."\n";
	$global_status=getSystemGlobalStatus();
	echo '<tr><td colspan="3" align="center"><table border="0"><tr><td>';
	echo '<h2><font color="'.$colors['h2'].'">'.$lrb['sisiya.OverallSystemStatus'].' :';
	echo '</font></h2></td><td valign="top"><img src="images/'.$global_status.'_big.gif" alt="">';
	echo '</td><td><h2><font color="'.$colors['h2'].'">'.$lrb['status.'.strtolower($global_status)].'</font></h2></td>';
	echo '<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$progName.'?par_formID=0'.'&amp;par_language='.$language.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f0.header'].'</font></a></td></tr></table></td></tr></table>'."\n";

	if($valid_user != '') 
		$sql_str='select c.hostname,b.str,a.str,a.updatetime,a.changetime,d.str,e.str,c.id,c.effectsglobal from systemstatus a,status b,systems c,systemtypes d,groups e,groupsystem f where c.active=\'t\' and a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and e.id=f.groupid and f.systemid=c.id and e.userid='.$user_id.' order by e.sortid,e.str,c.effectsglobal desc,a.statusid desc,c.hostname'; 
	else
		$sql_str='select c.hostname,b.str,a.str,a.updatetime,a.changetime,d.str,e.str,c.id,c.effectsglobal from systemstatus a,status b,systems c,systemtypes d,locations e where c.active=\'t\' and a.statusid=b.id and a.systemid=c.id and c.systemtypeid=d.id and c.locationid=e.id order by e.sortid,e.str,c.effectsglobal desc,a.statusid desc,c.hostname'; 
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
				echo '<tr><td colspan="6" bgcolor="'.$colors['tableFooterBg'].'">';
				echo '<font color="'.$colors['tableFooterFont'].'">';
				echo $lrb['TotalSystems'].' : '.$Count.' (';
				printTotalNumberOfSystems2($old_group_str);
				echo ')</font></td></tr>'."\n";
				echo '</table><br>'."\n";
				$Count=0;
			}
			echo '<a name="'.$row[6].'"><!--  --></a>'."\n";
			echo '<table border="1" width="100%" cellpadding="1" cellspacing="0">'."\n";
			echo '<tr><th colspan="6" bgcolor="'.$colors['tableHeaderBg'].'">';
			echo '<font color="'.$colors['tableHeaderFont'].'">'.$row[6].'</font>';
			echo '</th></tr>'."\n";
			echo '<tr bgcolor="'.$colors['tableHeaderBg'].'">';
			echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['System'].'</font></th>';
			echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['Status'].'</font></th>';
			echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['Description'].'</font></th>';
			echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['UpdateTime'].'</font></th>';
			echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['StatusChangeTime'].'</font></th>';
			echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['StatusChangedSince'].'</font></th></tr>'."\n";
			$old_group_str=$row[6];
		}
		echo '<tr bgcolor="'.$colors['tableBg'].'">';
		echo '<td><a href="'.$progName.'?par_formID=2'.'&amp;par_language='.$language.'&amp;par_systemID='.$row[7];
		echo '&amp;par_systemName='.$row[0].'&amp;par_systemType='.$row[5].'">';
		echo '<img src="images/'.$row[5].'.gif" alt="'.$row[5].'" border="0" height="25"><br>';
		echo $row[0].'</a></td>';
		if($row[8] == 'f')
			echo '<td bgcolor="'.$colors['nonCriticalSystem'].'"';
		else
			echo '<td bgcolor="'.$colors['tableBg'].'"';
		echo ' align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'"></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.$row[2].'</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.timeString($row[3]).'</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.timeString($row[4]).'</font></td>';
		echo '<td>'.getChangedString($row[3],$row[4]).'</td>';
		echo '</tr>'."\n";
		$Count++;
	} 
	echo '<tr><td colspan="6" bgcolor="'.$colors['tableFooterBg'].'">';
	echo '<font color="'.$colors['tableFooterFont'].'">'.$lrb['TotalSystems'].' : '.$Count.' (';
	printTotalNumberOfSystems2($row[6]);
	echo ')</font></td></tr>'."\n";
	echo '</table>'."\n";
	printNumberOfNotViewedSystems();
	printColorInfo();
	printSisIYA();
}

function SystemServicesForm()
{
	global $progName,$db,$colors,$ncolumns,$lrb,$language;

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

	echo '<title>'.$lrb['sisiya.f2.title'].'</title></head>';
	echo '<body bgcolor="'.$colors['bg'].'" text="'.$colors['font'].'" link="';
	echo $colors['link'].'" vlink="'.$colors['vlink'].'" alink="'.$colors['alink'].'">'."\n";
	echo '<table border="0" width="100%"><tr><td align="left">'."\n";
	echo '<a href="http://sisiya.sourceforge.net">';
	echo '<img border="0" src="images/SisIYA.gif" alt="SisIYA\'s logo"></a><br>'."\n";
	printFlags();
	echo '</td><td align="center"><h1><font color="'.$colors['h1'].'">';
	echo $lrb['sisiya.f2.header'].' ['.$par_systemName.']</font></h1></td>'."\n";	
	printLastUpdatedAndUserInfo();
	echo '</font></td></tr></table>'."\n";
	echo '<table border="0" width="100%"><tr><td align="left" rowspan="2">'."\n";
	echo '<img src="images/'.$par_systemName.'.gif" alt="'.$par_systemName.'">';
	echo '<img src="images/'.$par_systemType.'.gif" alt="'.$par_systemType.'"></td>'."\n";
	echo '<td><a href="'.$progName.'?par_formID=0'.'&amp;par_language='.$language.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f0.header'].'</font></a></td>';
	echo '<td><a href="'.$progName.'?par_formID=1'.'&amp;par_language='.$language.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f1.header'].'</font></a></td>';
	echo '<td><a href="'.$progName.'?par_formID=4'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID.'&amp;';
	echo 'par_systemName='.$par_systemName.'&amp;par_systemType='.$par_systemType.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f4.header'].'</font></a></td></table>'."\n";
	echo '<center><table border=1 cellpadding="1" cellspacing="0" bgcolor="'.$colors['tableBg'].'">'."\n";
	echo '<tr bgcolor="'.$colors['tableHeaderBg'].'">';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['Service'].'</font></th>';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['Status'].'</font></th>';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['Description'].'</font></th>';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['UpdateTime'].'</font></th>';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['StatusChangeTime'].'</font></th>';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['StatusChangedSince'].'</font></th></tr>'."\n";

	$sql_str='select d.str,b.str,a.str,a.updatetime,a.changetime,d.id,e.str from systemservicestatus a,status b,systems c,services d,systemtypes e where c.hostname=\''.$par_systemName.'\' and a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id and c.systemtypeid=e.id order by c.id,a.statusid desc,d.str';

	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	for($row_index=0;$row_index<$row_count;$row_index++) {
		$row=$db->fetchRow($result,$row_index);
		echo '<tr><td><a href="'.$progName.'?par_formID=3'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID;
		echo '&amp;par_systemName='.$par_systemName.'&amp;par_serviceID='.$row[5];
		echo '&amp;par_serviceName='.$row[0].'&amp;startDate=0&amp;par_systemType=';
		echo $par_systemType.'">'.$row[0].'</a></td>';
		echo '<td align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'"></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.$row[2].'</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.timeString($row[3]).'</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.timeString($row[4]).'</font></td>';
		echo '<td>'.getChangedString($row[3],$row[4]).'</td></tr>'."\n"; 
	}
	echo "</table></center>\n";
	printColorInfo();
	printSisIYA();
}

function ServiceHistoryForm()
{
	global $progName,$db,$colors,$ncolumns,$today,$lrb,$language;

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
	echo '<title>'.$lrb['sisiya.f3.title'].'</title></head>';
	echo '<body bgcolor="'.$colors['bg'].'" text="'.$colors['font'].'" link="';
	echo $colors['link'].'" vlink="'.$colors['vlink'].'" alink="'.$colors['alink'].'">'."\n";
	echo '<form action="'.$progName.'?par_formID=3'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID;
	echo '&amp;par_systemName='.$par_systemName.'&amp;par_serviceID='.$par_serviceID;
	echo '&amp;par_serviceName='.$par_serviceName.'&amp;startDate='.$date_str;
	echo '&amp;par_systemType='.$par_systemType.'" method="post">'."\n";
	echo '<table border="0" width="100%" cellpadding="1" cellspacing="1" bgcolor="'.$colors['bg'].'">'."\n";
	echo '<tr><td align="left">'."\n";
	echo '<a href="http://sisiya.sourceforge.net">';
	echo '<img border="0" src="images/SisIYA.gif" alt="SisIYA\'s logo"></a><br>'."\n";
	printFlags();
	echo '</td><td align="center" colspan="3">';
	echo '<h1><font color="'.$colors['h1'].'">'.$lrb['sisiya.f3.header'].' ['.$par_systemName.']</font></h1></td>'."\n";
	printLastUpdatedAndUserInfo();
	echo '</td></tr>'."\n";
	echo '<tr><td align="left" rowspan="2">'."\n";
	echo '<img src="images/'.$par_systemName.'.gif" alt="'.$par_systemName.'"><img src="images/'.$par_systemType.'.gif" alt="'.$par_systemType.'"></td>'."\n";
	echo '<td><a href="'.$progName.'?par_formID=0'.'&amp;par_language='.$language.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f0.header'].'</font></a></td>'."\n";
	echo '<td><a href="'.$progName.'?par_formID=1'.'&amp;par_language='.$language.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f1.header'].'</font></a></td>'."\n";
	echo '<td><a href="'.$progName.'?par_formID=2'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID.'&amp;par_systemName=';
	echo $par_systemName.'&amp;par_systemType='.$par_systemType.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f2.header'].' ['.$par_systemName.']</font></a></td>'."\n";
	echo '<td><a href="'.$progName.'?par_formID=4'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID.'&amp;par_systemName=';
	echo $par_systemName.'&amp;par_systemType='.$par_systemType.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f4.header'].'</font></a></td></tr>'."\n";
	echo '<tr><td><font color="'.$colors['font'].'">'.$lrb['Service'].' : '.$par_serviceName.'</font></td>';
	echo '<td colspan="3"><font color="'.$colors['font'].'">'.$lrb['ChooseADate'].'</font> <select name="date_str">'."\n";
	$current_date=$today;
	while($d != $beforeStartDate) {
		echo '<option ';
		if($date_str == $d) 
	 		echo 'selected ';
		echo 'value="'.$d.'">'.dateString($d)."\n"; 
		$current_date=getdate(mktime(0,0,0,$current_date['mon'],$current_date['mday']-1,$current_date['year']));
		$d=$current_date['year'].echo_value($current_date['mon']).echo_value($current_date['mday']);
	}
	echo '</select>&nbsp;<input type="submit" name="button" value="'.$lrb['Refresh'].'"></td></tr>'."\n";
	echo '<tr><td colspan="5">';
	echo '<table border="1" width="100%" cellpadding="1" cellspacing="0" bgcolor="'.$colors['tableBg'].'">'."\n";
	echo '<tr bgcolor="'.$colors['tableHeaderBg'].'">';
	echo '<td><font color="'.$colors['tableHeaderFont'].'">'.$lrb['ServiceDescription'].'</font></td><td>'.$str.'</td></tr>'."\n";
	echo '</table></td></tr>'."\n";
	
	echo '<tr><td colspan="5">';
	echo '<table border="1" width="100%" cellpadding="1" cellspacing="0" bgcolor="'.$colors['tableBg'].'">'."\n";
	echo '<tr bgcolor="'.$colors['tableHeaderBg'].'">';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['RecieveTime'].'</font></th>';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['Status'].'</font></th>';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['Description'].'</font></th>';
	echo '<th><font color="'.$colors['tableHeaderFont'].'">'.$lrb['SendTime'].'</font></th></tr>'."\n";

	$sql_str='select a.recievetime,b.str,a.str,a.sendtime from systemhistorystatus a,status b where a.systemid='.$par_systemID.' and a.serviceid='.$par_serviceID.' and a.statusid=b.id and a.recievetime like \''.$date_str.'%\' order by a.recievetime desc';
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);
	$flag=FALSE;
	for($row_index=0;$row_index<$row_count;$row_index++) {
		$row=$db->fetchRow($result,$row_index);
		$flag=TRUE;
		echo '<tr><td><font color="'.$colors['tableFont'].'">'.timeString($row[0]).'</font></td>';
		echo '<td align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'"></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.$row[2].'</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.timeString($row[3]).'</font></td></tr>'."\n";
	}		
	if($flag != TRUE) {
		$sql_str='select a.recievetime,b.str,a.str,a.sendtime from systemhistorystatus'.substr($date_str,0,6).' a,status b where a.systemid='.$par_systemID.' and a.serviceid='.$par_serviceID.' and a.statusid=b.id and a.sendtime like \''.$date_str.'%\' order by a.recievetime desc';
		$result=$db->query($sql_str);
		$row_count=$db->getRowCount($result);
		for($row_index=0;$row_index<$row_count;$row_index++) {
			$row=$db->fetchRow($result,$row_index);
#			echo '<tr><td>'.timeString($row[0]).'</td><td align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'"></td><td>'.$row[2].'</td><td>'.timeString($row[3]).'</td></tr>'."\n";
		echo '<tr><td><font color="'.$colors['tableFont'].'">'.timeString($row[0]).'</font></td>';
		echo '<td align="center"><img src="images/'.$row[1].'_big.gif" alt="'.$row[1].'"></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.$row[2].'</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.timeString($row[3]).'</font></td></tr>'."\n";

		}
	}
	echo '</table></td></tr></table>'."\n";
	echo '<input type="hidden" name="startDate" value="'.$startDate.'">'."\n";
	echo '<input type="hidden" name="par_systemType" value="'.$par_systemType.'">'."\n";
	printColorInfo();
	printSisIYA();
	echo '</form>'."\n";
}

function SystemInfoForm()
{
	global $progName,$db,$colors,$ncolumns,$lrb,$language;

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

	echo '<title>'.$lrb['sisiya.f4.title'].'</title></head>';
	echo '<body bgcolor="'.$colors['bg'].'" text="'.$colors['font'].'" link="';
	echo $colors['link'].'" vlink="'.$colors['vlink'].'" alink="'.$colors['alink'].'">'."\n";
	echo '<table border="0" width="100%"><tr><td align="left">'."\n";
	echo '<a href="http://sisiya.sourceforge.net">';
	echo '<img border="0" src="images/SisIYA.gif" alt="SisIYA\'s logo"></a><br>'."\n";
	printFlags();
	echo '</td><td align="center" colspan="2"><h1><font color="'.$colors['h1'].'">';
	echo $lrb['sisiya.f4.header'].' ['.$par_systemName.']</font></h1></td>'."\n";
	printLastUpdatedAndUserInfo();
	echo '<tr><td align="left">'."\n";
	echo '<img src="images/'.$par_systemName.'.gif" alt="'.$par_systemName.'">';
	echo '<img src="images/'.$par_systemType.'.gif" alt="'.$par_systemType.'"></td>'."\n";
	echo '<td><a href="'.$progName.'?par_formID=0'.'&amp;par_language='.$language.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f0.header'].'</font></a></td>';
	echo '<td><a href="'.$progName.'?par_formID=1'.'&amp;par_language='.$language.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f1.header'].'</font></a></td>';
	echo '<td><a href="'.$progName.'?par_formID=2'.'&amp;par_language='.$language.'&amp;par_systemID='.$par_systemID;
	echo '&amp;par_systemName='.$par_systemName.'&amp;par_systemType='.$par_systemType.'">';
	echo '<font color="'.$colors['link'].'">'.$lrb['sisiya.f2.header'].' ['.$par_systemName.']</font></a></td></tr>'."\n";
	echo '<tr><td align="center" colspan="4">';
	echo '<center><table border="1" cellpadding="1" cellspacing="0" bgcolor="'.$colors['tableBg'].'">'."\n";

	$sql_str='select a.hostname,a.fullhostname,a.effectsglobal,a.id from systems a,systemtypes b,locations c where a.hostname=\''.$par_systemName.'\' and a.systemtypeid=b.id and a.locationid=c.id';
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);
	
	if($row_count == 1) {
		$row=$db->fetchRow($result,0);
		echo '<tr><td><font color="'.$colors['tableFont'].'">Hostname</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.$row[0].'</font></td></tr>'."\n";
		echo '<tr><td><font color="'.$colors['tableFont'].'">Full Hostname</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">'.$row[1].'</font></td></tr>'."\n";
		echo '<tr><td><font color="'.$colors['tableFont'].'">';
		echo 'Does the system effects the overall status?</font></td>';
		echo '<td><font color="'.$colors['tableFont'].'">';
		if($row[2] == 't')
			echo 'Yes';
		else
			echo 'No';
		$sql_str='select b.str,a.str from systeminfo a,infos b where a.infoid=b.id and a.systemid='.$row[3].' order by b.sortid,b.str'; 
		$result2=$db->query($sql_str);
		$row_count2=$db->getRowCount($result2);
		for($i=0;$i<$row_count2;$i++) {
			$row2=$db->fetchRow($result2,$i);
			echo '<tr><td><font color="'.$colors['tableFont'].'">'.$row2[0].'</font></td>';
			echo '<td><font color="'.$colors['tableFont'].'">'.$row2[1].'</font></td></tr>'."\n";
		}
		echo '</font></td></tr>'."\n";
	}
	echo '</table></td></tr></table>'."\n";
	printSisIYA();
}

function DetailedSystemOverviewForm()
{
	global $progName,$db,$colors,$ncolumns;

	echo '<title>SISIYA a System Monitoring Tool (by Erdal Mutlu) Detailed System Overview</title></head>';
	echo '<body bgcolor="'.$colors['bg'].'" text="'.$colors['font'].'" link="';
	echo $colors['link'].'" vlink="'.$colors['vlink'].'" alink="'.$colors['alink'].'">'."\n";
	echo '<table border="0" width="100%"><tr><td align="left">'."\n";
	echo '<a href="http://sisiya.sourceforge.net">';
	echo '<img border="0" src="images/SisIYA.gif" alt="SisIYA\'s logo"></a>'."\n";
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
	echo '<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$progName.'?par_formID=0">System Overview</a></td><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="right"><a href="'.$progName.'?par_formID=1">Detailed System View</a></td></tr></table></tr>'."\n";


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
				echo '<tr><td colspan="'.($nservices+1).'" bgcolor="'.$colors['tableHeaderBg'].'">';
				echo '<font color="'.$colors['tableFooterFont'].'">Total number of systems : '.$Count.' (';
				printTotalNumberOfSystems($old_group_str);
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
			$old_group_str=$row[0];
		}
		# print a table row with service statuses
		echo '<tr><td';
		if($row[1] == 'f')
			echo ' bgcolor="'.$colors['nonCriticalSystem'].'"';
		else
			echo ' bgcolor="'.$colors['tableBg'].'"';
		echo '><a href="'.$progName.'?par_formID=2&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[2].'&amp;par_systemType='.$row[6].'">'.$row[2].'</a></td>';
		$hostname=$row[2];
		for($i=0;$i<$nservices;$i++) {
			if($row[2] == $hostname) {
				if($services["$i"]['str'] == $row[3]) {
					echo '<td align="center"><a href="'.$progName.'?par_formID=3&amp;par_systemID='.$row[5].'&amp;par_systemName='.$row[2].'&amp;par_serviceID='.$row[7].'&amp;par_serviceName='.$row[3].'&amp;startDate=0&amp;par_systemType='.$row[6].'"><img src="images/'.$row[4].'.gif" alt="'.$row[4].'" border="0"></a></td>';
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
	printSisIYA();
}

function loadLanguageInfo()
{
	global $db;

	$sql_str="select b.keystr,c.str from languages a,strkeys b,interface c where a.code='".$_SESSION['language']."'";
	$sql_str.=" and a.id=c.languageid and b.id=c.strkeyid";
	$result=$db->query($sql_str);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) 
		return;
	
	$a=array();
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$a[$row[0]]=$row[1];
	}
	$db->freeResult($result);

	### check if all entries are translated. The reference is the English language. If something is
	### missing, put the English text instead
	$sql_str="select b.keystr,c.str from languages a,strkeys b,interface c where a.code='en'";
	$sql_str.=" and a.id=c.languageid and b.id=c.strkeyid";
	$result=$db->query($sql_str);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) 
		return;
	
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		if(!isset($a[$row[0]]))
			$a[$row[0]]=$row[1];
	}

	$_SESSION['lrb']=$a;
	$db->freeResult($result);
}

function setCharset()
{
	global $db,$defaultCharset;

	$sql_str="select charset from  languages where code='".$_SESSION['language']."'";
	$result=$db->query($sql_str);

	$row_count=$db->getRowCount($result);
	$_SESSION['charset']=$defaultCharset;
	if($row_count == 1) {
		$row=$db->fetchRow($result,0);
		$_SESSION['charset']=$row[0];
	}
	$db->freeResult($result);
}

function initLanguage() 
{
	global $par_language,$defaultLanguage,$lrb;
	
	$par_language=getHTTPValue('par_language');
	if($par_language == '') 
		$par_language=$defaultLanguage;
	if(!isset($_SESSION['language']) || $_SESSION['language'] != $par_language) {
#		echo "Language change occured (SESSION[language]=".$_SESSION['language']." != par_language=".$par_language.") default=".$defaultLanguage."<br>";
		$_SESSION['language']=$par_language;
		loadLanguageInfo();
		setCharset();
	}
#echo "new lang=".$language."\n";
	foreach($_SESSION['lrb'] as $key=>$value) {
		$lrb[$key]=$value;
	}
}

###################################################################################
$today=getdate(); 
$hours=$today['hours'];
$minutes=$today['minutes'];
$seconds=$today['seconds'];
$month=$today['mon']; 
$day=$today['mday']; 
$year=$today['year']; 


#if(! isset($_SESSION['valid_user'])) {
#	loginForm($progName,$sessionName);
#	exit;
#}

$par_formID=getHTTPValue('par_formID');
if($par_formID == '') 
	$par_formID=0;

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

if($par_formID == 6)
	printDocHeader(basename($progName),0);
else
	printDocHeader(basename($progName),300);
setColors();


if($par_formID == -1) {
	logoutForm($progName,6);
	exit;
}

switch($par_formID) {
	case 0 :
		OverviewForm();
		break;
	case 1 :
		DetailedViewForm();
		break;
	case 2 :
		SystemServicesForm();
		break;
	case 3 :
		ServiceHistoryForm();
		break;
	case 4 :
		SystemInfoForm();
		break;

	case 5 :
		DetailedSystemOverviewForm();
		break;
	case 6 :
		loginForm($progName,$sessionName);
		exit;
		break;

	default:
		echo "<title>SisIYA a System Monitoring Tool (by Erdal Mutlu)</title></head><body>\n";
		echo "<center><h2>Error : FormID=$par_formID is not defined!</h2></center>\n";
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
