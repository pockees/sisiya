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

function initialize()
{
	global $progName, $force_login, $debug;

	$progName=$_SERVER['PHP_SELF'];

	if(getHTTPValue('debug') != '')
		$debug=true;

	### load language info from $_SESSION
	debug("initialize: initLanguage()...");
	if(!initLanguage()) {
		debug("initialize: Could not initialize language!");
		return(false);
	}
	debug("initialize: initLanguage()...OK");

	debug("initialize: hasAllSystems()...");
	if($force_login)
		hasAllSystems($_SESSION['user_id']);
	debug("initialize: hasAllSystems()...OK");

	return(true);
}

function getSystemGlobalStatusID()
{
	global $db;
 
	if(isset($_SESSION['valid_user']) && $_SESSION['valid_user'] != '')
		#$sql_str="select max(statusid) from systemstatus a,systems b,groups c,groupsystem d where a.systemid=b.id and b.active='t' and effectsglobal='t' and b.id=d.systemid and c.id=d.groupid and c.userid=".$_SESSION['user_id']; 
		$sql_str="select max(statusid) from systemstatus a,systems b where a.systemid=b.id and b.active='t' and effectsglobal='t' and statusid<>".STATUS_UNAVAILABLE; 
	else
		$sql_str="select max(statusid) from systemstatus a,systems b where a.systemid=b.id and b.active='t' and effectsglobal='t' and statusid<>".STATUS_UNAVAILABLE; 
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	if($row_count == 1) {
		$row=$db->fetchRow($result,0);
		$max_status=$row[0];
	} 
	if($max_status == "")
		$max_status=0;
	#debug('max_status='.$max_status);
	$db->freeResult($result);
	return $max_status;
}
 
function getTotalNumberOfSystems($location, $groups=0, $nsystems)
{
	global $db, $force_login;
 
	$securitygroups_sql='';
	if($force_login && !$_SESSION['hasAllSystems']) 
		$securitygroups_sql=' and a.id in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	####################################################################################################################################################
	if($groups == 1) {
		$sql_str="select c.str,count(*) as cc from systems a,groups b,systemtypes c,groupsystem g";
		$sql_str.=" where a.active='t' and a.systemtypeid=c.id "; 
		$sql_str.=$securitygroups_sql." and b.id=g.groupid and g.systemid=a.id and b.languageid='".$_SESSION['language_id']."' and b.userid=".$_SESSION['user_id'];
		$sql_str.=" and b.str='".$location."'";
		$sql_str.=" group by c.id order by cc desc,c.str";
	}
	else {
		$sql_str="select c.str,count(*) as cc from systems a,locations b,systemtypes c,interface i,strkeys s,languages l";
		$sql_str.=" where a.active='t' and a.systemtypeid=c.id and a.locationid=b.id "; 
		$sql_str.=$securitygroups_sql." and b.keystr=s.keystr and s.id=i.strkeyid and i.languageid=l.id and l.code='".$_SESSION['language']."'";
		$sql_str.=" and i.str='".$location."'";
		$sql_str.=" group by c.id order by cc desc,c.str";
	}
	$result=$db->query($sql_str);
	debug($sql_str);
	$row_count=$db->getRowCount($result);
	if($row_count == 0) 
		$str='0';
	else {
		$str='';
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			if($str == '')
				#$str .= $row[1].' '.$row[0].' %'.(int)(100 * $row[1] / $nsystems);
				#$str .= $row[1].' '.$row[0].' %'.round(100 * $row[1] / $nsystems, 0, PHP_ROUND_HALF_UP);
				$str .= $row[1].' (%'.round(100 * $row[1] / $nsystems, 0, PHP_ROUND_HALF_UP).') '.$row[0];
			else
				#$str .= ', '.$row[1].' '.$row[0].' %'.(int)(100 * $row[1] / $nsystems);
				#$str .= ', '.$row[1].' '.$row[0].' %'.round(100 * $row[1] / $nsystems, 0, PHP_ROUND_HALF_UP);
				$str .= ', '.$row[1].' (%'.round(100 * $row[1] / $nsystems, 0, PHP_ROUND_HALF_UP).') '.$row[0];
		}
	}
	$db->freeResult($result);
	return $str;
}
 
function echo_value($value) 
{
	if($value < 10) 
		return "0$value";
	else 
		return "$value";
}


function displayLastUpdated()
{
	echo getLastUpdated();
}

function getLastUpdated()
{
	global $db,$lrb;

	$update_str=$lrb['sisiya.label.last_updated'].' : '; 
	$sql_str='select updatetime from systemstatus order by updatetime desc'; 
	$result=$db->query($sql_str);

	# change this setting and put the default timezone into the conf file
	date_default_timezone_set('Europe/Istanbul');

	if($db->getRowCount($result) == 0) {
		$t=getdate(); 
		$update_str.=$t['hours'].':'.echo_value($t['minutes']).':'.echo_value($t['seconds']).' '.$t['mday'].'.'.echo_value($t['mon']).'.'.$t['year'];
	} 
	else {
		$r=$db->fetchRow($result,0);
		$update_str.=$r[0]{8}.$r[0]{9}.':'.$r[0]{10}.$r[0]{11}.':'.$r[0]{12}.$r[0]{13}.' '.$r[0]{6}.$r[0]{7}.'.'.$r[0]{4}.$r[0]{5}.'.'.$r[0]{0}.$r[0]{1}.$r[0]{2}.$r[0]{3};
	}
	$db->freeResult($result);
	$t=getdate();
	$now_str=echo_value($t['hours']).":".echo_value($t['minutes']).":".echo_value($t['seconds'])." ".echo_value($t['mday']).".".echo_value($t['mon']).".".echo_value($t['year']);
	$update_str.='<br />'."\n".$lrb['sisiya.label.server_time'].' : '.$now_str;
	return $update_str;
}

function getChangedString($a,$b)
{
	global $lrb;


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
		#$str=$days.' day';
		#if($days > 1)
		#	$str=$str.'s';
		if($days > 1)
			$str=$days.' '.$lrb['sisiya.label.time.days'];
		else
			$str=$days.' '.$lrb['sisiya.label.time.day'];
	} 
	if($hours > 0) {
		if($str != '')
			$str=$str.' ';
		#$str=$str.$hours.' hour';
		if($hours > 1)
			#$str=$str.'s';
			$str=$str.$hours.' '.$lrb['sisiya.label.time.hours'];
		else 
			$str=$str.$hours.' '.$lrb['sisiya.label.time.hour'];
	}
	if($minutes > 0) {
		if($str != '')
			$str=$str.' ';
		#$str=$str.$minutes.' minute';
		#if($minutes > 1)
		#	$str=$str.'s';
		if($minutes > 1)
			$str=$str.$minutes.' '.$lrb['sisiya.label.time.minutes'];
		else
			$str=$str.$minutes.' '.$lrb['sisiya.label.time.minute'];
	}
/*
	if($seconds > 0) {
		if($str != '')
			$str=$str.' ';
		#$str=$str.$seconds.' second';
		#if($seconds > 1)
		#	$str=$str.'s';
		if($seconds > 1)
			$str=$str.$seconds.' '.$lrb['sisiya.label.time.seconds'];
		else
			$str=$str.$seconds.' '.$lrb['sisiya.label.time.second'];
	} 
*/
	if($days > 5)
		$str='<td class="ok">'.$str;
	else if($days > 3)
		$str='<td class="warning">'.$str;
	else
		$str='<td class="error">'.$str;
	return $str.'</td>';
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


function format_message($msg_str)
{
	### 
	$str=$msg_str;

	$str=validateContent($str);
	
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
?>
