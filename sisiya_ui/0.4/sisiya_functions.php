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

function startSession($sname)
{
	session_name($sname); 
	session_start();
}

function destroySession()
{
	## destroy the old session, if there was one
	session_destroy();
	#unset($_SESSION['valid_user']);
}

function checkLogin($user,$password,$sname)
{
	global $db;

	# if user not specified, no login/special settings possible
	if($user == '') return false;

	# get user information (does user exist in db?)
	$sql_str='select id,password,name,surname,isadmin from users where username=\''.$user.'\'';
	$result=$db->query($sql_str);

	while ($db->getRowCount($result)) {
		$row=$db->fetchRow($result,0);

		if(checkPasswords($password,$row[1]) == false) break;

		$_SESSION['auth']=true;
		$_SESSION['valid_user']=$user;
		$_SESSION['user_id']=$row[0];
		$_SESSION['user_name']=$row[2];
		$_SESSION['user_surname']=$row[3];
		$_SESSION['is_admin']=$row[4];
		return true;
	} 
	return false;
}

function checkPasswords($password,$encrypted_password)
{
	global $salt_length;
	
	$salt=substr($encrypted_password,0,$salt_length);
	if(crypt($password,$salt) == $encrypted_password) {
		return true;
	}
	return false;
}
 
function echo_value($value) 
{
	if($value < 10) 
		return "0$value";
	else 
		return "$value";
}

function getCopyright()
{
	global $lrb;

	return '<table class="copyright" border="0"><tr><td align="center">&copy; Erdal Mutlu</td></tr></table>'."\n";
}

function displayCopyright()
{
	echo getCopyright();
}


function getHTTPValue($key)
{
	$value='';
	if(isset($_POST[$key])) 
		$value=$_POST[$key]; 
	else if(isset($_GET[$key])) 
		$value=$_GET[$key]; 
 
	return $value;
	# more elegant
	return ((isset($_POST[$key])) ? $_POST[$key] : ((isset($_GET[$key])) ? $_GET[$key] : ''));
}

function displayDocHeader($generator,$charset,$refresh)
{
	echo getDocHeader($generator,$charset,$refresh);
}


function getDocHeader($generator,$charset,$refresh)
{
	$html='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'."\n";
	#$html.='<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'."\n";
	$html.='<html xmlns="http://www.w3.org/1999/xhtml">'."\n";
	$html.="<head>\n";
	$html.='<meta http-equiv="Content-Type" content="text/html;charset='.$charset.'" />'."\n";
	$html.='<link rel="stylesheet" type="text/css" href="style/style.css" />'."\n";
	$html.='<meta name="generator" content="'.$generator.'" />'."\n";
	$html.='<meta name="description" content="SisIYA system and network monitoring" />'."\n";
	$html.='<meta name="keywords" content="system monitoring,network monitoring,snmp traps,web based,free" />'."\n";
	if($refresh > 0)
		$html.='<meta http-equiv="refresh" content="'.$refresh.'" />'."\n";
	return $html;
}


function displayAdmFormHeader($header_str)
{
	echo getAdmFormHeader($header_str);
}

function getAdmFormHeader($header_str)
{
	#global $user_id,$user_name,$user_surname,$valid_user,$ma,$progName,$par_formName,$par_language,$lrb;
	global $par_formName,$lrb;


	$html='<title>'.$lrb['sisiya_adm.'.$par_formName.'.title'].'(FormName='.$par_formName.')</title>'."\n";
	$html.="</head>\n";
	$html.='<body>'."\n";
	$html.='<table class="header">'."\n";
	$html.='<tr><td>';
	$html.='<a href="http://sisiya.sourceforge.net">';
	$html.='<img src="images/SisIYA.gif" alt="SisIYA\'s logo" /></a><br />'."\n";
	$html.=getFlags();
	$html.='</td>';
	if($header_str != 'login') {
		$html.='<td class="center">';
		#$html.=$lrb['sisiya_adm.'.$header_str.'.header'];
		$html.='</td>'."\n";
		$html.=getUserInfo(false);
		$html.='</td>';
	}
	$html.='</tr>'."\n";
	$html.="</table>\n";

	return $html;
}

function displayFormHeader($header_str)
{
	global $user_id,$user_name,$user_surname,$valid_user,$ma,$progName,$par_formName,$par_language,$lrb;


	$html='<title>'.$lrb['sisiya.'.$par_formName.'.title'].'(FormName='.$par_formName.')</title>'."\n";
	$html.='<link rel="stylesheet" type="text/css" href="style/style.css" />'."\n";
	$html.="</head>\n";
	$html.='<body>'."\n";
#	$html.='<table class="headerbar" border="1"><tr>'."\n";
#	if($valid_user == true) {
#		$html.='<td align="left">'.$lrb['sisiya.companies.label.str'].' : '.$_SESSION['company_name'].'</td>';
#		if(isset($_SESSION['person_id'])) {
#			$html.='<td align="center">'.$lrb['sisiya.persons.label.name'].' : '.$_SESSION['person_name'].' '.$_SESSION['person_surname'].'('.getAge($_SESSION['person_birthday']).')</td>';
#		}
#		$html.='<td align="right">'.$user_name.' '.$user_surname.' ('.$_SESSION['valid_user'].')';
#		$html.=' <a href="'.$progName.'?par_formName=logout&amp;par_language='.$par_language.'">'.$lrb['sisiya.button.logout'].'</a>';
#	}
#	$html.='<br />'."\n";
#	$html.=getFlags();
#	$html.='</td></tr>'."\n";
#	$html.='</table>'."\n";

	$html.='<table class="header">'."\n";
	$html.='<tr><td align="left">';
	$html.='<a href="http://sisiya.sourceforge.net">';
	$html.='<img src="images/SisIYA.gif" alt="SisIYA\'s logo" /></a><br />'."\n";
	$html.=getFlags();
	$html.='</td><td align="right"><h1>';
	$html.=$header_str.'</h1></td>'."\n";
	$html.=getLastUpdatedAndUserInfo();
	$html.='<br /><a href="/sisiya_rss.xml"><img src="/images/rss_small.png" alt="SisIYA rss" /></a>';
	$html.='</td></tr>'."\n";
	$html.="</table>\n";

	echo $html;
}

function getLastUpdated()
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
	$update_str.='<br />'.$lrb['sisiya.ServerTime'].' : '.$now_str;
	return $update_str;
}

function printLastUpdated()
{
	echo getLastUpdated();
}


function getUserInfo()
{
	global $progName,$progNameAdm,$progNameLogin,$sessionName,$valid_user,$user_name,$user_surname,$user_id,$lrb;
	
	$html='<td class="right">';
	if(isset($_SESSION['valid_user'])) {
		$html.=$user_name.' '.$user_surname.' ('.$valid_user.') ';
		$html.='<br /><a href="'.$progName.'?par_formName=logout">'.$lrb['sisiya.Logout'].'</a>';
	}
	else {
		$html.='<br /><a href="'.$progName.'?par_formName=login">'.$lrb['sisiya.Login'].'</a>';
		$html.='&nbsp;&nbsp;<a href="'.$progNameAdm.'">'.$lrb['sisiya.Settings'].'</a>';
	}
	return $html;
}

function getLastUpdatedAndUserInfo()
{
	global $progName,$progNameAdm,$progNameLogin,$sessionName,$valid_user,$user_name,$user_surname,$user_id,$lrb;
	
	$html='';
	if(isset($_SESSION['valid_user'])) {
		$html.='<td align="right">';
		$html.=$user_name.' '.$user_surname.' ('.$valid_user.') ';
		$html.='<a href="'.$progName.'?par_formName=logout">'.$lrb['sisiya.Logout'].'</a>';
		$html.='&nbsp;&nbsp;<a href="'.$progNameAdm.'">'.$lrb['sisiya.Settings'].'</a>';
		$html.='<br />'.$lrb['sisiya.LastUpdated'].' : ';
	}
	else {
		$html.='<td align="right">';
		$html.='<a href="'.$progName.'?par_formName=login">'.$lrb['sisiya.Login'].'</a>';
		$html.='&nbsp;&nbsp;<a href="'.$progNameAdm.'">'.$lrb['sisiya.Settings'].'</a>';
		$html.='<br />'.$lrb['sisiya.LastUpdated'].' : ';
	}
	$html.=getLastUpdated();
	return $html;
}

/*
function parseHTML($str)
{
	$s=$str;
	$s=str_replace("<", "&lt;", $str);
	$str=$s;
	$s=str_replace(">", "&gt;", $str);
	return $s;
}
*/

function printLastUpdatedAndUserInfo()
{
	echo getLastUpdatedAndUserInfo();
}


function getColorInfo()
{
	global $lrb;

	$html="\n".'<table class="color_info">';
	$html.='<tr><td>'.$lrb['sisiya.SymbolInfo']. ':</td><td>';
	$html.='<img src="images/Info.gif" alt="Info.gif" /></td><td>'.$lrb['sisiya.status.info'].'</td><td>';
	$html.='<img src="images/Ok.gif" alt="Ok.gif" /></td><td>'.$lrb['sisiya.status.ok'].'</td><td>';
	$html.='<img src="images/Warning.gif" alt="Warning.gif" /></td><td>';
	$html.=$lrb['sisiya.status.warning'].'</td><td>';
	$html.='<img src="images/Error.gif" alt="Error.gif" /></td><td>';
	$html.=$lrb['sisiya.status.error'].'</td></tr></table>'."\n";
	return $html;
}


function printColorInfo()
{
	echo getColorInfo();
}

function getSisIYA()
{
	global $lrb;

	return "\n".'<table class="SisIYA"><tr><td><a href="http://sisiya.sourceforge.net">SisIYA</a> ('.$lrb['sisiya.description'].') &copy; Erdal Mutlu</td></tr></table>'."\n";
}

function printSisIYA()
{
	echo getSisIYA();
}


function getSisIYAandCompatable()
{
	global $lrb;

	return '<h4><a href="http://sisiya.sourceforge.net">SisIYA</a> ('.$lrb['sisiya.description'].') &copy; Erdal Mutlu&nbsp;&nbsp;'.getCompatable().'</h4>'."\n";
}


function printSisIYAandCompatable()
{
	echo getSisIYAandCompatable();
}

function execSQL($sql_str)
{
	global $db;

	#$result=$db->query($sql_str) or die ('Invalid query: '.$sql_str);
	$result=$db->query($sql_str);
	#if($result == NULL)
	if(! $result)
		 return -1;
	#echo '<center><h4>Number of affected rows = '.$db->getAffectedRows($result).'</h4></center>'."\n";
	return $db->getAffectedRows($result);
}


function getCompatable()
{
	return '<a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10-blue" alt="Valid XHTML 1.0 Strict" height="31" width="88" /></a>'."\n"; 
}

function getFlags()
{
	global $progName,$progNameAdm,$progNameLogin,$sessionName,$valid_user,$user_name,$user_surname,$user_id,$language,$lrb,$langs;

	
	$html='';
	for($i=0;$i<count($langs);$i++) {
		if($i > 0)
			$html.='&nbsp;'."\n";
		#$html.='<a href="'.$progName.'?par_formName=system_overview&amp;par_language='.$langs[$i].'">';
		$html.='<a href="'.$progName.'?par_language='.$langs[$i];
		if(isset($_SESSION['activeForm']))
			$html.='&amp;par_formName='.$_SESSION['activeForm'];
/*
		if(isset($_SESSION['formName']))
			#$html.='&amp;par_formName='.$_SESSION['formName'];
			#$html.='&amp;par_formName=system_overview';
			switch($_SESSION['formName']) {
				case 'login' :
				case 'system_overview' :
				case 'system_detailed_view' :
					$html.='&amp;par_formName='.$_SESSION['formName'];
					break;
				default :
					$html.='&amp;par_formName=system_overview';
					break;
			}
*/
		$html.='">';
		#$html.='<img src="images/flag-'.$langs[$i].'.png" alt="'.$langs[$i].'" /></a>';
		$html.=$langs[$i].'</a>';
	}
	
	return $html;
}

function printFlags()
{
	echo getFlags();
}


function initLanguage() 
{
	global $defaultLanguage,$par_language,$lrb,$langs;

	
	$par_language=getHTTPValue('par_language');
	if($par_language == '') 
		$par_language=$defaultLanguage;
	if(!isset($_SESSION['language']) || $_SESSION['language'] != $par_language) {
		$_SESSION['language']=$par_language;
		loadLanguageInfo();
		setCharset();
	}
	foreach($_SESSION['lrb'] as $key=>$value) {
		$lrb[$key]=$value;
	}
	foreach($_SESSION['langs'] as $key=>$value) {
		$langs[$key]=$value;
	}
}

function loadLanguageInfo()
{
	global $db,$langs;


	### get supported languages
	$sql_str='select code from languages';
	$result=$db->query($sql_str);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) 
		return;
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$langs[$i]=$row[0];
	}
	$db->freeResult($result);
	### save langs to the session
	$_SESSION['langs']=$langs;
	
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

	$db->freeResult($result);

	### save lrb to the session
	$_SESSION['lrb']=$a;
}


                                                                                                                 
function loginForm($progName,$sessionName)
{
	global $lrb,$language,$charset,$par_language,$par_formName;

	initLanguage();

	$login_ok=false;
	$user=getHTTPValue('user');
	$password=getHTTPValue('password');
	$par_language=getHTTPValue('par_language');
	$par_formName=getHTTPValue('par_formName');
	$button=getHTTPValue('button');

	$charset=$_SESSION['charset'];
#echo 'par_formName='.$par_formName;
	if($button == $lrb['sisiya.button.cancel']) { 
		### write session data to file or db
		session_write_close();
		### redirect
		header('Location: '.$progName.'?par_language='.$par_language);
		exit();
	}

	if($user != '') { 
		$login_ok=checkLogin($user,$password,$sessionName);
		if($login_ok) {
			### write session data to file or db
			session_write_close();
			### redirect
			header('Location: '.$progName.'?par_language='.$par_language);
			exit();
		}

	}

	$refresh=0; ### do not refresh
	$html=getDocHeader(basename($progName),$charset,$refresh);
	$msg='';
	if($button == $lrb['sisiya.button.login'] && $user != '' && ! $login_ok)
		$msg='<tr><td>'.$lrb['sisiya.login.invalid_login'].' '.$lrb['sisiya.login.try_again'].'</td></tr>';
/*
	$html='<title>'.$lrb['sisiya.login.title']."</title></head>\n";
	$html.='<body>';
	$html.='<table class="header" border="0" width="100%">'."\n";
	$html.='<tr><td align="right">'."\n";
	$html.=getFlags();
	$html.="</td></tr></table>\n";
*/
	$par_formName='login';
	$html.=getAdmFormHeader('login');	

	$html.='<form action="'.$_SERVER['PHP_SELF'].'?par_language='.$par_language.'&amp;par_formName=login" method="post">'."\n";
	$html.='<table class="login">'."\n";
	$html.='<caption class="login">'.$lrb['sisiya.login.header'].'</caption>'."\n";
	$html.='<tr><td class="label">'.$lrb['sisiya.login.label.user'].'</td>';
	$html.='<td><input type="text" size="20" name="user" value="'.$user.'" /></td></tr>'."\n";
	$html.='<tr><td class="label">'.$lrb['sisiya.login.label.password'].'</td>';
	$html.='<td><input type="password" size="20" name="password" value="" /></td></tr></table>'."\n";
		
	$html.='<table class="login_buttons"><tr>'."\n";
	$html.='<td><input type="submit" name="button" value="'.$lrb['sisiya.button.login'].'" /></td>'."\n";
	$html.='<td><input type="submit" name="button" value="'.$lrb['sisiya.button.cancel'].'" /></td>'."\n";
	$html.='</tr></table>'."\n";

	$html.="</form>\n";
	if($msg != '')
		$html.='<table class="login_failed"><tr><tr>'.$msg.'</td></tr></table>'."\n";
	$html.=getSisIYA();
	$html.="</body></html>\n";

	echo $html;
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

?>
