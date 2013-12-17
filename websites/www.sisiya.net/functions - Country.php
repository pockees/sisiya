<?php
/*
    Copyright (C) 2010  Erdal Mutlu & Omer L. Cunbul

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

function displayCharset()
{
	echo getCharset();
}

function getCharset()
{
	return "utf-8";
}

function displayLanguageBar($prog_name,$params)
{
	echo getLanguageBar($prog_name,$params);
}

function getLanguageBar($prog_name,$params)
{
	global $rootDir;

	$str='';
	if(isset($_SESSION['langs'])) {
		foreach($_SESSION['langs'] as $lang) {
			$str.='<a class="language" href="'.$prog_name.'?menu='.$params.'&amp;language='.$lang.'">'.$lang.'</a>&nbsp;';
		}
	}
	return $str;
}

function displayTitle($title)
{
	echo getTitle($title);
}

function getTitle($title)
{
	### use: return $lrb[$title]; 
	return $title;
}

function startSession($sname)
{
	session_name($sname); 
	session_start();
}

function destroySession()
{
	## destroy the old session, if there was one
	session_destroy();
}
function checkUsername($username)
{
	global $db;

	if($username == '') return false;

	# get user information (does user exist in db?)
	$sql_str="select id from users where username='".$username."'";
	$result=$db->query($sql_str);
	if($db->getRowCount($result) > 0) 
		return true;
	return false;
}


function checkLogin($username,$password)
{
	global $db;

	# if user not specified, no login/special settings possible
	if($username == '') return false;

	# get user information (does user exist in db?)
	$sql_str='select u.id,u.password,u.name,u.surname,u.isadmin,u.isroot,u.companyid,c.str from users u,companies c where u.username=\''.$username.'\' and u.companyid=c.id';
	$result=$db->query($sql_str);

	while ($db->getRowCount($result)) {
		$row=$db->fetchRow($result,0);

		if(checkPasswords($password,$row[1]) == false) break;

		$_SESSION['auth']=true;
		$_SESSION['valid_user']=$username;
		$_SESSION['user_id']=$row[0];
		$_SESSION['user_name']=$row[2];
		$_SESSION['user_surname']=$row[3];
		$_SESSION['is_admin']=$row[4];
		$_SESSION['is_root']=$row[5];
		$_SESSION['company_id']=$row[6];
		$_SESSION['company_name']=$row[7];
		return true;
	} 
	return false;
}

function encryptPassword($password)
{
	global $salt_length;

	$salt=makeSalt($salt_length);

	return crypt($password,$salt);
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

function reloadLanguages()
{
	if(!setLanguage($_SESSION['language']))
		return(false);
	if(!initLanguageFromSession())
		return(false);
}

function initLanguageFromSession()
{
	global $lrb,$langs;

	if(!isset($_SESSION['lrb']) || count($_SESSION['lrb']) == 0) 
		return(false);
	foreach($_SESSION['lrb'] as $key=>$value)
		$lrb[$key]=$value;
	foreach($_SESSION['langs'] as $key=>$value)
		$langs[$key]=$value;
	return(true);
}

function setLanguage($language)
{
	global $defaultLanguage;

	if($language == '')
		$language=$defaultLanguage;
	$_SESSION['language']=$language;
	if(!loadLanguageFromDB2Session())
		return(false);
	setCharset();
	#### save session
	#session_write_close();
	return(true);
}

function initLanguage() 
{
	$language=getHTTPValue('language');
	if(isset($_SESSION['language'])) {
		if($language != '' && $language != $_SESSION['language']) {
			if(!setLanguage($language))
				return(false);
		}
	}
	else {
		if(!setLanguage($language))
			return(false);
	}
	if(!initLanguageFromSession())
		return(false);
	else
		return(true);
}

function debug($msg)
{
	global $debug;

	if($debug)
		#echo '<div class="div_debug">'.$msg."<br></div>\n";
		echo $msg."<br>\n";
}

function getNRows($table_name)
{
	global $db;

	$n=0;
	$sql_str="select count(*) from ".$table_name." where companyid=".$_SESSION['company_id'];
	$result=$db->query($sql_str);
	if($result) {
		$row=$db->fetchRow($result,0);
		$n=$row[0];
		$db->freeResult($result);
	}
	return($n);
}


function initialize()
{
	global $progName,$debug;

	$progName=$_SERVER['PHP_SELF'];
	#$progName=$_SERVER['REQUEST_URI'];

	if(getHTTPValue('debug') != '')
		$debug=true;

	### load language info from $_SESSION
	debug("initialize: initLanguage()...");
	if(!initLanguage()) {
		debug("initialize: Could not initialize language!");
		return(false);
	}
	debug("initialize: initLanguage()...OK");

	debug("initialize: initSwotIds()...");
	if(!initSwotIds()) {
		debug("initialize: Could not init initSwotIds!");
		return(false);
	}
	debug("initialize: initSwotIds()...OK");
	return(true);
}

function initSwotIds()
{
	global $db,$debug;
	
	debug("initSwotIds: Initializing swot ids...");
	$sql_str="select id,str from item_names";
	$result=$db->query($sql_str);
	if(!$result) {
		debug("initSwotIds: Could not get item names!");
		return(false);
	}
	$nrows=$db->getRowCount($result);
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
 		$_SESSION['swot_'.$row[1]]['id']=$row[0];
	}
	$db->freeResult($result);
	debug("initSwotIds: Initializing swot ids...OK");
	return(true);
}

function initLanguage_old() 
{
	global $defaultLanguage,$lrb,$langs;

	$language=getHTTPValue('language');
	if($language == '' && !isset($_SESSION['language']))
                $language=$defaultLanguage;
	
	if(!isset($_SESSION['language']) || ($language !='' && $language != $_SESSION['language'])) {
		$_SESSION['language']=$language;
		loadLanguageFromDB2Session();
		setCharset();
		### save session
		session_write_close();
	}
	if(!isset($_SESSION['lrb']) || count($_SESSION['lrb']) == 0) 
		return(false);
	
	foreach($_SESSION['lrb'] as $key=>$value) {
		$lrb[$key]=$value;
	}
	foreach($_SESSION['langs'] as $key=>$value) {
		$langs[$key]=$value;
	}
	return(true);
}

function loadLanguageFromDB2Session()
{
	global $db,$langs;

	### get supported languages
	$sql_str='select code from languages';
	$result=$db->query($sql_str);
	if(!$result) 
		return(false);
	$row_count=$db->getRowCount($result);
	if($row_count == 0) {
		$db->freeResult($result);
		return(false);
	}
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
	if(!$result) 
		return(false);

	$row_count=$db->getRowCount($result);
	$a=array();
	if($row_count == 0) {
		#return(false);
	}
	else {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$a[$row[0]]=$row[1];
		}
	}
	$db->freeResult($result);

	### check if all entries are translated. The reference is the English language. If something is
	### missing, put the English text instead
	$sql_str="select b.keystr,c.str from languages a,strkeys b,interface c where a.code='en'";
	$sql_str.=" and a.id=c.languageid and b.id=c.strkeyid";
	$result=$db->query($sql_str);
	if(!$result) 
		return(false);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) {
		$db->freeResult($result);
		return(false);
	}
	
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		if(!isset($a[$row[0]]))
			$a[$row[0]]=$row[1];
	}

	$db->freeResult($result);

	### save lrb to the session
	$_SESSION['lrb']=$a;
	return(true);
}

function setCharset()
{
	global $db,$defaultCharset;

	$_SESSION['charset']=$defaultCharset;
	$sql_str="select charset from  languages where code='".$_SESSION['language']."'";
	$result=$db->query($sql_str);
	if($result) {
		if($db->getRowCount($result) == 1) {
			$row=$db->fetchRow($result,0);
			$_SESSION['charset']=$row[0];
		}
		$db->freeResult($result);
	}
}

function getLanguageFileName($prefix,$suffix)
{
	global $defaultLanguage;

	$file_name=$prefix.$_SESSION['language'].$suffix;
	### check whether the specified language file exists or not. If does not exist, use the default language file.
	if(!file_exists($file_name))
		$file_name=$prefix.$defaultLanguage.$suffix;
	return($file_name);
}

function execSQL($sql_str)
{
	global $db;

	$result=$db->query($sql_str);
	if(! $result)
		 return -1;
	return $db->getAffectedRows($result);
}

function getNextID($table_name)
{
	global $db;

	$id=1; # default ID

	$sql_str='select max(id) from '.$table_name;
	$result=$db->query($sql_str);
	if($result) {
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$id=$row[0]+1;
		} 
		$db->freeResult($result);
	}
	return $id; 
}

function generateRandomPassword($length) { 
	srand(date("s")); 
	$possible_charactors = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"; 
	$string = "";
	while(strlen($string) < $length) { 
		$string .= substr($possible_charactors, rand()%(strlen($possible_charactors)),1); 
	} 
	return($string); 
} 

function eliminateSpecialCharacters($text) {
	
	if ($text == '') return($text);
	else {	
	
#	$text=str_replace("'", '&#039;', $text);
#	$text=str_replace('"', '&quot;', $text);
#	$text=str_replace('\', '&#092;', $text);

	$text=htmlspecialchars($text, ENT_QUOTES);
	
	return($text);
	}
	
}

function countryCityFromIP($ipAddr) {

//ip2long($ipAddr)== -1 || ip2long($ipAddr) === false ? trigger_error("Invalid IP", E_USER_ERROR) : "";
$ipDetail=array();
$xml = file_get_contents("http://api.hostip.info/?ip=".$ipAddr);
preg_match("@<Hostip>(\s)*<gml:name>(.*?)</gml:name>@si",$xml,$match);
$ipDetail['city']=$match[2]; 
preg_match("@<countryName>(.*?)</countryName>@si",$xml,$matches);
$ipDetail['<strong class="highlight">country</strong>']=$matches[1];
preg_match("@<countryAbbrev>(.*?)</countryAbbrev>@si",$xml,$cc_match);
$ipDetail['country_code']=$cc_match[1]; 
return $ipDetail;

}

?>

