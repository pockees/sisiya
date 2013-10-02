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

function encryptPassword($password)
{
	global $salt_length;

	$salt=makeSalt($salt_length);

	return crypt($password,$salt);
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

function printDocHeader($generator,$refresh) {
	global $language,$charset;

	$html='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">';
	$html.='<html><head><meta http-equiv="Content-Type" content="text/html; charset='.$charset.'">';
	$html.='<meta NAME="GENERATOR" CONTENT="'.$generator.'">';
	if($refresh > 0)
		$html.='<meta HTTP-EQUIV="Refresh" CONTENT="'.$refresh.'">'."\n";
	echo $html;
}

function printSisIYA()
{
	echo getSisIYA();
}


function getSisIYA()
{
	global $colors,$lrb;

	return '<center><h4><font color="'.$colors['h4'].'"><a href="http://sisiya.sourceforge.net">SisIYA</a> ('.$lrb['sisiya.description'].') &copy; Erdal Mutlu</font></h4></center>'."\n";
}

function printSisIYAandCompatable()
{
	global $colors;

	echo '<br><center><h4><font color="'.$colors['h4'].'"><a href="http://sisiya.sourceforge.net">SisIYA</a> ('.$lrb['sisiya.description'].') &copy; Erdal Mutlu&nbsp;&nbsp;'.getCompatable().'</font></h4></center>'."\n";
}

function execSQL($sql_str)
{
	global $db;

	$result=$db->query($sql_str) or die ('Invalid query: '.$sql_str);
	echo '<center><h4>Number of affected rows = '.$db->getAffectedRows($result).'</h4></center>'."\n";
}


function getCompatable()
{
	return '<a href="http://validator.w3.org/check/referer"><img border="0" src="images/valid-html401.png" alt="Valid HTML 4.01!" height="31" width="88"></a>'."\n";
}

function makeSalt($type=CRYPT_SALT_LENGTH) 
{
	#CRYPT_STD_DES - Standard DES-based encryption with a two character salt
	#CRYPT_EXT_DES - Extended DES-based encryption with a nine character salt
	#CRYPT_MD5 - MD5 encryption with a twelve character salt starting with $1$
	#CRYPT_BLOWFISH - Blowfish encryption with a sixteen character salt starting with $2$ or $2a$
	$saltlen=$type;
	$saltprefix='$1$';
	$saltsuffix='';
	switch($type) {
		case 9:		### Extended DES-based encryption with a nine character salt
			$saltprefix='';
			break;
		case 12:	###  CRYPT_MD5 : MD5 encryption with a 12 character salt starting with $1$
			$saltlen-=4;	# because of the suffix prefix
			$saltsuffix='$';
			break;
		case 16:		### Blowfish encryption with a 16 character salt starting with $2$ or $2a$
			$saltprefix='$2$';
			$saltsuffix='';
			break;
		case 2:
		default: ### by default, fall back on Standard DES (should work everywhere)
			$saltlen=2;
			$saltprefix='';
			$saltsuffix='';
			break;
	}
	$salt='';
	while(strlen($salt) < $saltlen) {
		$ch=chr(rand(64,126));
		#if($ch == '\\')
		if($ch == chr(92))
			continue;
		$salt.=$ch;
	}
	return $saltprefix.$salt.$saltsuffix;
}

                                                                                                                 
function loginForm($progName,$sessionName)
{
	$login_ok=false;
	$user=getHTTPValue('user');
	$password=getHTTPValue('password');

	if($user != '') { 
		$login_ok=checkLogin($user,$password,$sessionName);
#		if($login_ok) {
#			session_write_close();
#			header('Location: '.$progName);
#			exit;
#		}
	}

	$msg='';
	if($user != '' && ! $login_ok)
		$msg = '<tr><td align="center"><h4>Invalid login! Please try again.</h4></td></tr>';
	$html='<title>SisIYA a System Monitoring Tool (by Erdal Mutlu)</title></head>'."\n";
	$html.='<body bgcolor="#FFFFFF"><img src="images/SisIYA.gif" alt="SisIYA\'s Logo">'."\n";
	$html.='<table border="0" width="100%">'."\n";
	$html.='<tr> <td> <form action="'.$progName.'?par_formID=6" method="post">'."\n";
	$html.='<table border="0" width="100%"><tr><td align="left"></tr>'."\n";
	$html.='<tr><td align="center"><h1>Login</h1></td></tr>'."\n";
	#$html.='session_id='.session_id().' session_name='.session_name();
	$html.='<tr><td></td></tr>'.$msg;
	if($login_ok) {
		$html.='<tr><td colspan="2" align="center"><h3>Welcome '.$_SESSION['user_name'].' '.$_SESSION['user_surname'].'!';
		$html.='<br><a href="'.$progName.'">Click here to proceed.</a></h3></td></tr>'."\n";
	}
	else {	
		$html.='<tr><td align="center"><table border="1">'."\n";
		$html.='<tr><td bgcolor="#aabbff">User</td>';
		$html.='<td><input type="text" size="70" name="user" value="'.$user.'"/></td></tr>'."\n";
		$html.='<tr><td bgcolor="#aabbff">Password</td>';
		$html.='<td colspan="5"><input type="password" size="70" name="password" value=""/></td></tr></table>'."\n";
		$html.='</td></tr>'."\n";
		$html.='<tr><td align="center"><input type="submit" name="button" value="Login"></td></tr>'."\n";
	}
	$html.='<tr><td></td></tr><tr><td></td></tr></table>'."\n";
	$html.=getSisIYA();
	$html.='<center>'.getCompatable().'</center></form></body></html>';

#	printDocHeader(basename($progName),0);
	echo $html;
}


function logoutForm($progName,$loginFormID)
{
	destroySession();
 
	$html='<title>SisIYA a System Monitoring Tool (by Erdal Mutlu)</title></head><body bgcolor="#FFFFFF">'."\n";
	$html.='<form action="'.$progName.'" method="post">'."\n";
	$html.='<img src="images/SisIYA.gif" alt="SisIYA Logo">'."\n";
	$html.='<table border="0" width="100%"><tr><td align="left">'."\n";
	$html.='<tr><td align="center"><h1>Logout</h1></td></tr>'."\n";
	$html.='<tr><td></td></tr>'."\n";
	$html.='<tr><td align="center"><h3>You are logged out now! Bye!</h3></td></tr>'."\n";
	$html.='<tr><td align="center"><h3><a href="'.$progName.'?par_formID='.$loginFormID.'">Click here to login.</a></h3></td></tr>'."\n";
	$html.='<tr><td></td></tr>'."\n";
	$html.='<tr><td align="center"><h4>SisIYA (a System Monitoring Tool) &copy; Erdal Mutlu&nbsp;&nbsp;</h4></td></tr>'."\n";
	$html.='<tr><td align="center">'.getCompatable().'</td></tr>'."\n";
	$html.='</table></center>'."\n";
	$html.='</body></html>';
	echo $html;
}

?>
