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

function displayTitle($title)
{
	echo getTitle($title);
}

function getTitle($title)
{
	### use: return $lrb[$title]; 
	return $title;
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
	$sql_str="select id,password,name,surname,isadmin from users where username='".$username."'";
	$result=$db->query($sql_str);

	while($db->getRowCount($result)) {
		$row=$db->fetchRow($result,0);

		if(checkPasswords($password,$row[1]) == false) break;

		$_SESSION['auth']=true;
		$_SESSION['valid_user']=$username;
		$_SESSION['user_id']=$row[0];
		$_SESSION['user_name']=$row[2];
		$_SESSION['user_surname']=$row[3];
		$_SESSION['is_admin']=$row[4];
		$db->freeResult($result);
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
function divide_round_up($x,$y)
{				
	if($y == 0 || $x == 0)
		return(0);
	$s=(int) ($x / $y);
	if(($x % $y) > 0)
		$s++;
	return($s);
}

function calculate_start_page($start_index,$npages,$nrecords_per_page,$max_pages)
{
###################################################################################################################
# p = page number; 			1,2,3...                                        1 th record
# r = number of records per page 	example:10                                      2 nd record
# i = the start index for records on the page                                            
#           -----------------        ----------------                                   
# 	=> | i = (p - 1) * r |  =>  | p = (i / r) +1 |                                  10 th record
#           -----------------        ----------------                                   |< << 1 2 3 4 5 >> >|
#	i=0,10,20,30,...                                                                       \-----/
#	p=1, 2, 3, 3,...                                                                          k : the Nth page set
# q = total number of records example:108
# t = total number of pages => t = [q / r ]  && if( (q % r) > 0) t++   => t=11
# m = maximum number of pages to be shown example : 5 
# s = start page, the page number to started for the page set, eg 1 for 1 2 3 4 5 and 6 for 6 7 8 9 10 
# w = page sets => [ t / m ] && if( (t % m) > 0) w++  => 3
# p1= the first page number of the page set p1 = 1, 6 etc ( p1 = m * (k -1) +1 )
# p2= the  last page number of the page set p2 = p1 + m -1
#
# |< = the first page set =>	i = 0 
#				s = 1
# >| = the  last page set =>	i = (t - 1 ) * r  => 100
#				s = m * (w -1) + 1  => 5 * (3 -1) + 1  = 11
# << = previous page set	=> s -= m && if(s < 0) s=0
# >> = next page set		=> s += m 
###################################################################################################################
	if(!isset($_SESSION['start_page']))
		$_SESSION['start_page']=1;
	$start_page=$_SESSION['start_page'];

	$next_page_set=getHTTPValue('next_page_set');
	$prev_page_set=getHTTPValue('prev_page_set');
	### this if clear start_page set from another page
	if($start_index == '' && $next_page_set == '' && $prev_page_set == '')
		$start_page=1;
	else if($next_page_set == 1) {
		$start_page+=$max_pages;
		if($start_index == (($npages-1) * $nrecords_per_page)) {
			$w=divide_round_up($npages,$max_pages);
			$start_page=$max_pages * ($w -1) + 1;
			#echo "w=".$w." start_index=".$start_index." q=".(($npages-1) * $nrecords_per_page)."<br />";
		}
	}
	else if($prev_page_set == 1) {
		$start_page-=$max_pages;
		if($start_page < 0 || $start_index == 0)
			$start_page=1;
	}
	#echo "start_page=".$start_page."<br />";
	$_SESSION['start_page']=$start_page;
	return($start_page);
}

function getNRows($table_name)
{
	global $db;

	$n=0;
	$sql_str="select count(*) from ".$table_name;
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

	if(getHTTPValue('debug') != '')
		$debug=true;

	### load language info from $_SESSION
	debug("initialize: initLanguage()...");
	if(!initLanguage()) {
		debug("initialize: Could not initialize language!");
		return(false);
	}
	debug("initialize: initLanguage()...OK");

	if(isset($_SESSION['user_id'])) {
		debug("initialize: hasAllSystems()...");
		hasAllSystems($_SESSION['user_id']);
		debug("initialize: hasAllSystems()...OK");
	}
	return(true);
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

function getStrkeys($table_name)
{
	global $db,$lrb,$progName;

	$strkeys=array();
	$sql_str="select id,keystr,str from strkeys where keystr like 'sisiya.records.".$table_name."%' order by keystr";
	debug('sql_str='.$sql_str);
	$result=$db->query($sql_str);
	if(!$result)
		errorRecord('select');
	else {
		$n=$db->getRowCount($result);
		for($i=0;$i<$n;$i++) {
			$row=$db->fetchRow($result,$i);
			$strkeys[$i]['id']=$row[0];
			$strkeys[$i]['keystr']=$row[1];
			$strkeys[$i]['str']=$row[2];
		}
		$db->freeResult($result);
	}
	return($strkeys);
}

function getSystems()
{
	global $db,$lrb,$progName,$systems;

	$sql_str="select id,hostname from systems where active='t' order by hostname";
	debug('sql_str='.$sql_str);
	$result=$db->query($sql_str);
	if(!$result) {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$progName.': '.$lrb['sisiya_admin.msg.sql_select_error'];
	}
	else {
		$n=$db->getRowCount($result);
		for($i=0;$i<$n;$i++) {
			$row=$db->fetchRow($result,$i);
			$systems[$i]['id']=$row[0];
			$systems[$i]['str']=$row[1];
		}
		$db->freeResult($result);
	}
}

function displaySystemTypeImage($system_type)
{
	echo getSystemTypeImage($system_type);
}

function getSystemTypeImage($system_type)
{
	global $systemsImageDir;

	return($systemsImageDir.'/'.$system_type.'.gif');
}

function displayPageNumbers($orderby_id,$max_pages,$start_index)
{
	echo getPageNumbers($orderby_id,$max_pages,$start_index);
}

function getPageNumbers($orderby_id,$nrows,$start_index)
{
	global $progName,$nrecords_per_page,$max_pages;

	$s='<div class="div_page_numbers">'."\n";
	$npages=divide_round_up($nrows,$nrecords_per_page);
	if($npages > 1) {
		$start_page=calculate_start_page($start_index,$npages,$nrecords_per_page,$max_pages);
		if($start_page > 1) {
			$s.='<a href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index=0&amp;prev_page_set=1">|&lt;</a>&nbsp;'."\n";
			$s.='<a href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index='.($start_page-2)*$nrecords_per_page.'&amp;prev_page_set=1">&laquo;</a>&nbsp;'."\n";
		}
		for($i=0;$i<$max_pages;$i++) {
			if(($i + $start_page) > $npages)
				break;
			$s.='<a href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index='.(($start_page+$i-1)*$nrecords_per_page).'">';
			if($start_index == (($start_page+$i-1)*$nrecords_per_page))
				$s.='<strong>'.($start_page+$i).'</strong>';
			else
				$s.=($start_page+$i);
			$s.='</a>&nbsp;'."\n";
		}
		if(($start_page+$max_pages) <= $npages) {
			$s.='<a href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index='.(($start_page+$max_pages-1)*$nrecords_per_page).'&amp;next_page_set=1">&raquo;</a>&nbsp;'."\n";
			$s.='<a href="'.$progName.'&amp;orderby_id='.$orderby_id.'&amp;start_index='.(($npages-1)*$nrecords_per_page).'&amp;next_page_set=1">&gt;|</a>&nbsp;'."\n";
		}
	}
	$s.='</div> <!-- end of div_page_numbers -->'."\n";
	return($s);
}

function displayTableHeader($orderby_id,$fields,$start_index,$header_parameters)
{
	echo getTableHeader($orderby_id,$fields,$start_index,$header_parameters);
}

function getTableHeader($orderby_id,$fields,$start_index,$header_parameters)
{
	global $progName;

	$s='';
	$nfields=count($fields);
	for($k=0;$k<$nfields;$k++) { 
		$s.='	<th><a href="'.$progName.'&amp;orderby_id='.$k.'&amp;start_index='.$start_index.'&amp;table_header=1'.$header_parameters.'">'.$fields[$k]['label'];
		if($orderby_id == $k) {
			if($_SESSION['asc_desc'] == 'asc')
				#$s.='>| ';
				$s.=' &#9660;';
			else
				#$s.='|< ';
				$s.=' &#9650;';
		}
		$s.='</a></th>'."\n";
	}
	return($s);
}


function get_setNRows($table_name)
{
	$nrows=-1;
	if(isset($_SESSION['nrows_'.$table_name]))
		$nrows=$_SESSION['nrows_'.$table_name];
	else
		$nrows=getNRows($table_name);
	return($nrows);
}

/*
Gets the orderby_id from HTTP POST or GET and sets asc_desc in the SESSION if table_header==1. 
 */
function get_setOrderbyID($max_orderid)
{
	$table_header=getHTTPValue('table_header');
	$orderby_id=getHTTPValue('orderby_id');
	if($orderby_id == '' || $orderby_id > $max_orderid) {
		$orderby_id=0;
		$_SESSION['asc_desc']='asc';
	}
	else {
		if(! isset($_SESSION['asc_desc']))
			$_SESSION['asc_desc']='asc';
		if($table_header == 1) {
			if($_SESSION['asc_desc'] == 'asc')
				$_SESSION['asc_desc']='desc';
			else
				$_SESSION['asc_desc']='asc';
		}
	}
	return $orderby_id;
}

/*
Gets start_index from HTTP POST or GET.
*/
function getStartIndex()
{
	$start_index=getHTTPValue('start_index');
	if($start_index == '')
		$start_index=0;
	return($start_index);
}

function displayTrueFalseSelect($name,$value)
{
	echo getTrueFalseSelect($name,$value);
}

function getTrueFalseSelect($name,$value)
{
	global $lrb;

	$values=array('-' => '-','t' => 'yes','f' => 'no');
	$s='<select name="'.$name.'">'."\n";
	foreach($values as $x => $y) {
			$s.='<option ';
			if($value == $x)
				$s.='selected="selected" ';
			$label_str=$y;
			if($x != '-')
				$label_str=$lrb['sisiya_admin.label.'.$y];
			$s.='value="'.$x.'">'.$label_str.'</option>'."\n";
	}
/*	switch($value) {
		case 't' :
			$s.='<option value="-">-</option>'."\n";
			$s.='<option selected="selected" value="t">'.$lrb['sisiya_admin.label.yes']."</option>\n";
			$s.='<option value="f">'.$lrb['sisiya_admin.label.no']."</option>\n";
			break;
		case 'f' :
			$s.='<option value="-">-</option>'."\n";
			$s.='<option selected="selected" value="f">'.$lrb['sisiya_admin.label.no']."</option>\n";
			$s.='<option value="t">'.$lrb['sisiya_admin.label.yes']."</option>\n";
			break;
		default:
			$s.='<option selected="selected" value="-">-</option>'."\n";
			$s.='<option value="f">'.$lrb['sisiya_admin.label.no']."</option>\n";
			$s.='<option value="t">'.$lrb['sisiya_admin.label.yes']."</option>\n";
			break;
	}
*/
	$s.='</select>'."\n";
	return($s);
}
### select_array is of the form 
###	array(
###		0 => array(id => 4,str => 'xxxxx'),
###		1 => array(id => 2,str => 'yyyyy'),
###		...
###	)
###
function displayIdStrSelect($name,$key,$select_array)
{
	echo getIdStrSelect($name,$key,$select_array); 
}

function getIdStrSelect($name,$key,$select_array)
{
	$s='<select name="'.$name.'">'."\n";
	$s.='<option selected="selected" value="-" >-</option>'."\n";
	for($j=0;$j<count($select_array);$j++) {
		$s.='<option ';
		if($key == $select_array[$j]['id'])
			$s.='selected="selected" ';
		$s.='value="'.$select_array[$j]['id'].'">'.$select_array[$j]['str']."</option>\n";
	}
	$s.='</select>'."\n";
	return($s);
}

function generateSearchSQLPart2($field_name,$value,$sql_field_name,$isString)
{
	global $table_header_parameters;

	if($isString) 
		$str=" and ".$sql_field_name." like '%".$value."%'";
	else
		$str=" and ".$sql_field_name." =".$value."";
	$table_header_parameters.='&amp;'.$field_name.'='.$value;
	return $str;
}

function generateSearchSQL($fields)
{
	$s='';
	for($i=0;$i<count($fields);$i++) {
		#echo 'generating Search SQL for : field_name='.$fields[$i]['field_name'].' key='.$fields[$i]['key'].' is string='.$fields[$i]['is_str'].'<br />';
		$s.=generateSearchSQLPart($fields[$i]['field_name'],$fields[$i]['value'],$fields[$i]['key'],$fields[$i]['is_str']);
	}
	return($s);
}

function generateSearchSQLPart($field_name,$value,$sql_field_name,$isString,$formName='')
{
	global $table_header_parameters;

	$str='';
	if(!($value == '' || $value == '-')) {
		if($isString) 
			$str=" and ".$sql_field_name." like '%".$value."%'";
		else
			$str=" and ".$sql_field_name." =".$value."";
		$table_header_parameters.='&amp;'.$field_name.'='.$value;
	}
	return $str;
}

function generateSearchSQLPart_old($field_name,$sql_field_name,$isString,$formName='')
{
	$s=getHTTPValue($field_name);
	$session_str=$formName.'_'.$field_name;
	$str='';
	if(!($s == '' || $s == '-')) {
		# save to session
		$_SESSION[$session_str]=$s;
		$str=generateSearchSQLPart2($field_name,$s,$sql_field_name,$isString);
	}
	else {
		# read from session
		if(isset($_SESSION[$session_str])) {
			$s=$_SESSION[$session_str];
			if(!($s == '' || $s == '-')) {
				$str=generateSearchSQLPart2($field_name,$s,$sql_field_name,$isString);
			}
		}	
	}
	return $str;
}
### Generates an array from a given table. The table must have the id,keystr fields. These are linked to the language tables.
### Then the array is converted into a select array, which is used in select HTML.
function getStrkeysAsSelectArray($table_name)
{
	global $lrb;

	$strkeys=getStrkeys($table_name);
	$select_array=array();
	for($i=0;$i<count($strkeys);$i++) {
		$select_array[$i]['value']=$strkeys[$i]['keystr'];
		#$select_array[$i]['option']=$lrb[$strkeys[$i]['keystr']].' ('.$strkeys[$i]['str'].')';
		$select_array[$i]['option']=$lrb[$strkeys[$i]['keystr']];
	}
	return($select_array);
}

function getNewID($id_field,$table_name)
{
	$id=getHTTPValue($id_field);
	if($id == '')
		$id=getNextID($table_name);
	return($id);
}
function sendSisIYAMessage($system_name,$service_id,$status_id,$expire,$message_str)
{				
	global $lrb,$sendMessageProg;
	exec($sendMessageProg.' '.$system_name.' '.$service_id.' '.$status_id.' '.$expire.' "'.$message_str.'"',$output,$retcode);
	if($retcode == 0) {
		setStatusMessage(STATUS_OK,$lrb['sisiya.msg.ok.send']);
		return(true);
	}
	else {
		$s=$lrb['sisiya.msg.error.send'].' (';
		for($i=0;$i<count($output);$i++)
			$s.=$output[$i].' ';
		$s.=')';
		setStatusMessage(STATUS_ERROR,$s);
		return(false);
	}
}

function change_password($userid,$old_password,$new_password,$renew_password)
{
	global $db,$lrb,$min_password_length;
	#debug('userid='.$userid.' old_password='.$old_password.' new_password='.$new_password.' renew_password='.$renew_password);

	if($_SESSION['is_admin'] == 'f' and $old_password == '') {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$lrb['sisiya_admin.msg.no_old_password'];
	}
	else if($new_password == '') {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$lrb['sisiya_admin.msg.no_new_password'];
	}
	else if($new_password != $renew_password) {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$lrb['sisiya_admin.msg.password_missmatch'];
	}
	else if(strlen($new_password) < $min_password_length) {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$lrb['sisiya_admin.msg.min_password_length'].' Min '.$min_password_length;
	}
	else {
		if($_SESSION['is_admin'] == 'f') {
			$sql_str="select password from users where id=".$_SESSION['user_id'];
			$result=$db->query($sql_str);
			if($result) {
				$nrows=$db->getRowCount($result);
				if($nrows == 1) {
					$row=$db->fetchRow($result,0);
					if(checkPasswords($old_password,$row[0]) == false) {
						$_SESSION['status_type']=STATUS_ERROR;
						$_SESSION['status_message']=$lrb['sisiya_admin.msg.invalid_old_password'];
					}
					else {
						$sql_str="update users set password='".encryptPassword($new_password)."' where id=".$_SESSION['user_id'];
						$n=execSQL($sql_str);
						if($n == 1) {
							$_SESSION['status_type']=STATUS_OK;
							$_SESSION['status_message']=$lrb['sisiya_admin.msg.password_changed'];
						}
						else {
							$_SESSION['status_type']=STATUS_ERROR;
							$_SESSION['status_message']=$lrb['sisiya_admin.msg.couldnot_change_password'];
						}
					}
				}
				else {
					$_SESSION['status_type']=STATUS_ERROR;
					$_SESSION['status_message']=' The user '.$_SESSION['valid_user'].' was not found in the users table!. This should not have happened!';
				}
				$db->freeResult($result);
			}
		}
		else {
			if($userid == '' || $userid == '-')
				$userid=$_SESSION['user_id'];
			#debug('userid='.$userid.' old_password='.$old_password.' new_password='.$new_password.' renew_password='.$renew_password);
			$sql_str="update users set password='".encryptPassword($new_password)."' where id=".$userid;
			#debug('sql='.$sql_str);
			$n=execSQL($sql_str);
			if($n == 1) { 
				$_SESSION['status_type']=STATUS_OK;
				$_SESSION['status_message']=$lrb['sisiya_admin.msg.password_changed'];
			}
			else {
				$_SESSION['status_type']=STATUS_ERROR;
				$_SESSION['status_message']=$lrb['sisiya_admin.msg.couldnot_change_password'];
			}
		}
	}
}

function getInterfaceStrKeyValue($languageid,$strkeyid)
{
	global $db;
	
	$value='';
	$sql_str="select str from interface where languageid=".$languageid." and strkeyid=".$strkeyid;
	$result=$db->query($sql_str);
	if($result) {
		$nrows=$db->getRowCount($result);
		if($nrows == 1) {
			$row=$db->fetchRow($result,0);
			$value=$row[0];
		}
		$db->freeResult($result);
	}
	return($value);
}

function getStrKeyValue($languageid,$strkeyid)
{
	$value=getInterfaceStrKeyValue($languageid,$strkeyid);
	if($value == '') 
		$value=getInterfaceStrKeyValue(0,$strkeyid);	### get from English
	return($value);
}


function getInterfaceStrkeyAndValue($languageid,$strkeyid,&$keystr,&$keystr_value)
{
	global $db;
	
	$keystr_value='';
	$keystr='';
	$sql_str="select s.keystr,i.str from interface i,strkeys s where i.strkeyid=s.id and i.languageid=".$languageid." and i.strkeyid=".$strkeyid;
	$result=$db->query($sql_str);
	if($result) {
		$nrows=$db->getRowCount($result);
		if($nrows == 1) {
			$row=$db->fetchRow($result,0);
			$keystr=$row[0];
			$keystr_value=$row[1];
		}
		$db->freeResult($result);
	}
}


function getStrkeyAndValue($languageid,$strkeyid,&$keystr,&$keystr_value)
{
	getInterfaceStrkeyAndValue($languageid,$strkeyid,$keystr,$keystr_value);
	if($keystr == '') 
		getInterfaceStrkeyAndValue(0,$strkeyid,$keystr,$keystr_value);	### get from English
}

function file_upload_error_message($error_code) 
{
	global $lrb;

	switch ($error_code) {
		case UPLOAD_ERR_INI_SIZE :
			return $error_code.' : '.$lrb['sisiya_admin.msg.upload_err_ini_size'];
		case UPLOAD_ERR_FORM_SIZE :
			return $error_code.' : '.$lrb['sisiya_admin.msg.upload_err_form_size'];
		case UPLOAD_ERR_PARTIAL :
			return $error_code.' : '.$lrb['sisiya_admin.msg.upload_err_partial'];
		case UPLOAD_ERR_NO_FILE :
			return $error_code.' : '.$lrb['sisiya_admin.msg.upload_err_no_file'];
		case UPLOAD_ERR_NO_TMP_DIR :
			return $error_code.' : '.$lrb['sisiya_admin.msg.upload_err_no_tmp_dir'];
		case UPLOAD_ERR_CANT_WRITE :
			return $error_code.' : '.$lrb['sisiya_admin.msg.upload_err_cant_write'];
		#case UPLOAD_ERR_EXTENSION :
		#	return $error_code.' : '.$lrb['sisiya_admin.msg.upload_err_extension'];
		default :
			return $error_code.' : '.$lrb['sisiya_admin.msg.upload_err_unknown'];
	}
} 


function removeImageFile($file)
{
	global $systemsImageDir,$lrb;

	if(!unlink($systemsImageDir.'/'.$file)) {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$lrb['sisiya.msg.error.delete'].' ('.$file.')';
	}
	else {
		$_SESSION['status_type']=STATUS_OK;
		$_SESSION['status_message']=$lrb['sisiya.msg.ok.delete'].' ('.$file.')';
	}
}

function checkUploadFileType($file_type,$types)
{
	global $lrb;

	for($i=0;$i<count($types);$i++)
		if($types[$i] == $file_type)
			return(true);
	
	$_SESSION['status_type']=STATUS_ERROR;
	$_SESSION['status_message']=$lrb['sisiya_admin.msg.not_allowed_file_type'].'('.$file_type.')';
	return(false);
}

function checkUploadFileError($error_code)
{
	global $lrb;

	if($error_code != UPLOAD_ERR_OK) {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$lrb['sisiya_admin.msg.upload_error'].'('.$lrb['sisiya.label.error'].' : '.file_upload_error_message($error_code).')';
		return(false);
	}
	return(true);
}

function checkUploadFileSize($size)
{
	global $lrb,$max_upload_files_size;

	if($size > $max_upload_files_size) {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$lrb['sisiya_admin.msg.upload_size_error'].' ('.$size.'>'.$max_upload_files_size.')';
		return(false);
	}
	return(true);
}

/*
 Clears the values in the $fields and in the $_POST arrays.
 $formName 	: the ID of the web page
 $fields 	: an array of form array(0 => array('field_name' => 'field1', value => 'value1'),...)
 */
function clearFields($formName,&$fields)
{
	for($i=0;$i<count($fields);$i++) {
		$key=$fields[$i]['field_name'];
		$_POST[$key]='';
		$fields[$i]['value']='';
		$key_str=$formName.'_'.$key;
		if(isset($_SESSION[$key_str]))
			unset($_SESSION[$key_str]);
	}
}

# Get input values from POST or GET and save into $_SESSION
function processInputs($formName,&$fields)
{
	for($i=0;$i<count($fields);$i++) {
		$fields[$i]['value']=getInputValue($formName,$fields[$i]['field_name']);
		#save into session
		$_SESSION[$formName.'_'.$fields[$i]['field_name']]=$fields[$i]['value'];
	}	
}

# Get the value from an array of the form array(0 => array('field_name' => 'field1', 'value' => 'value1'), ...)
function getFieldValue($fields,$field_name)
{
	for($i=0;$i<count($fields);$i++) {
		if($fields[$i]['field_name'] == $field_name)
			return $fields[$i]['value'];
	}
	return '';
}

?>
