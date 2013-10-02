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

##############################################################################
error_reporting(E_ALL);
include_once("sisiya_admconf.php");

#session_start();
$progName=$_SERVER['PHP_SELF'];

startSession($sessionName);

$ma=array(
	0 => array(
		'strkey' => 'sisiya_adm.menu.label.main',
		'active' => 1,
		'submenu' => array(
				0 => array(
					'strkey' => 'sisiya_adm.menu.label.status',
					'used' => 0,
					'formName' => 'status',
					'foradmins' => 't'
					),
				1 => array(
					'strkey' => 'sisiya_adm.menu.label.services',
					'used' => 0,
					'formName' => 'services',
					'foradmins' => 't'
					),
				2 => array(
					'strkey' => 'sisiya_adm.menu.label.systemtypes',
					'used' => 0,
					'formName' => 'systemtypes',
					'foradmins' => 't'
					),
				3 => array(
					'strkey' => 'sisiya_adm.menu.label.alerttypes',
					'used' => 0,
					'formName' => 'alerttypes',
					'foradmins' => 't'
					),
				4 => array(
					'strkey' => 'sisiya_adm.menu.label.infos',
					'used' => 0,
					'formName' => 'infos',
					'foradmins' => 't'
					),
				5 => array(
					'strkey' => 'sisiya_adm.menu.label.locations',
					'used' => 0,
					'formName' => 'locations',
					'foradmins' => 't'
					),
				6 => array(
					'strkey' => 'sisiya_adm.menu.label.properties',
					'used' => 0,
					'formName' => 'properties',
					'foradmins' => 't'
					),
				7 => array(
					'strkey' => 'sisiya_adm.menu.label.systems',
					'used' => 0,
					'formName' => 'systems',
					'foradmins' => 't'
					),
				8 => array(
					'strkey' => 'sisiya_adm.menu.label.systeminfo',
					'used' => 0,
					'formName' => 'systeminfo',
					'foradmins' => 't'
					),
				9 => array(
					'strkey' => 'sisiya_adm.menu.label.systemservice',
					'used' => 0,
					'formName' => 'systemservice',
					'foradmins' => 't'
					),
				10 => array(
					'strkey' => 'sisiya_adm.menu.label.systemstatus',
					'used' => 0,
					'formName' => 'systemstatus',
					'foradmins' => 't'
					),
				11 => array(
					'strkey' => 'sisiya_adm.menu.label.systemservicestatus',
					'used' => 0,
					'formName' => 'systemservicestatus',
					'foradmins' => 't'
					),
				12 => array(
					'strkey' => 'sisiya_adm.menu.label.groups',
					'used' => 0,
					'formName' => 'groups',
					'foradmins' => 'f'
					),
				13 => array(
					'strkey' => 'sisiya_adm.menu.label.groupsystem',
					'used' => 0,
					'formName' => 'groupsystem',
					'foradmins' => 'f'
					),
				14 => array(
					'strkey' => 'sisiya_adm.menu.label.userproperties',
					'used' => 0,
					'formName' => 'userproperties',
					'foradmins' => 't'
					),
				15 => array(
					'strkey' => 'sisiya_adm.menu.label.usersystemalert',
					'used' => 0,
					'formName' => 'usersystemalert',
					'foradmins' => 'f'
					),
				16 => array(
					'strkey' => 'sisiya_adm.menu.label.usersystemservicealert',
					'used' => 0,
					'formName' => 'usersystemservicealert',
					'foradmins' => 'f'
					),
				17 => array(
					'strkey' => 'sisiya_adm.menu.label.sendmessage',
					'used' => 0,
					'formName' => 'sendmessage',
					'foradmins' => 'f'
					),
		),
	),
	1 => array(
		'strkey' => 'sisiya_adm.menu.label.webinterface',
		'active' => 0,
		'submenu' => array(
				0 => array(
					'strkey' => 'sisiya_adm.menu.label.languages',
					'used' => 0,
					'formName' => 'languages',
					'foradmins' => 't'
					),
				1 => array(
					'strkey' => 'sisiya_adm.menu.label.strkeys',
					'used' => 0,
					'formName' => 'strkeys',
					'foradmins' => 't'
					),
				2 => array(
					'strkey' => 'sisiya_adm.menu.label.webinterface',
					'used' => 0,
					'formName' => 'webinterface',
					'foradmins' => 't'
					),
				3 => array(
					'strkey' => 'sisiya_adm.menu.label.users',
					'used' => 0,
					'formName' => 'users',
					'foradmins' => 't'
					),
				4 => array(
					'strkey' => 'sisiya_adm.menu.label.changepassword',
					'used' => 0,
					'formName' => 'change_password',
					'foradmins' => 'f'
					),
			),
		),
	);
########################################################################################################################################
### Functions
########################################################################################################################################

########################################################################################################################################
###
########################################################################################################################################
### This functions is used to set menu collapse flags. This flags are used to collapse or not to collapse sub menus.
function collapseMenu()
{
	global $ma;

	if(! isset($_SESSION['sb'])) {
		$a=array();
		$menuCount=count($ma);
		for($i=0;$i<$menuCount;$i++) {
			$a[$i]=0;
		}
		$_SESSION['sb']=$a;
	}
	else {
		$a=array();
		foreach($_SESSION['sb'] as $key=>$value) {
                	$a[$key]=$value;
	#		echo "key=".$key." value=".$value."<br />";
		}
		$skey=getHTTPValue('par_skey');
		$svalue=getHTTPValue('par_svalue');
		if($svalue == 1)
			$a[$skey]=0;
		else
			$a[$skey]=1;
		$_SESSION['sb']=$a;
	}
}

function encryptPassword($password)
{
	global $salt_length;

	$salt=makeSalt($salt_length);

	return crypt($password,$salt);
}

function getButtons($formID,$buttons) {
	$count=count($buttons);
	####$html='<input type=hidden name="par_formName" value="'.$formID.'">';
	$html=' <table class="buttons"><tr>';
	for($i=0;$i<$count;$i++) 
		$html.='<td><input type="submit" name="button" value="'.$buttons[$i].'" /></td>';
	$html.='</tr></table>'."\n";
	return $html;
}

# the url_column is used to make a link. If it is -1 there is no such column. 
# fields : (column names,values,flag) 
# fields array is used to select the a row. flag is used to indicate if a column needs a quotation.
# value is the value of the input field on the form.
# start : start displaying from this record
# nrows : number of rows to print per page
# orderby: 
# button: button to be pressed
function displayTable($sql_str,$url_column,$fields,$start,$nrows,$orderby,$button)
{
	echo getTable($sql_str,$url_column,$fields,$start,$nrows,$orderby,$button); 
}

function getTable($sql_str,$url_column,$fields,$start,$nrows,$orderby,$button)
{
	global $db, $progName, $par_formName,$par_language,$lrb,$par_orderbyid;

	### do not print anything
	if($nrows < 1)
		return;

	### par_header is set to 1 when one hits table's column header 
	$par_header=getHTTPValue('par_header');
	if(! isset($_SESSION['asc_desc']))
		$_SESSION['asc_desc']='asc';
	if($par_header == 1) {
		if($_SESSION['asc_desc'] == 'asc')
			$_SESSION['asc_desc']='desc';
		else
			$_SESSION['asc_desc']='asc';
	}
	$sql_str.=' '.$_SESSION['asc_desc'];
#echo '<br />displayTable: sql_str='.$sql_str;

	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result); 
	$col_count=$db->getColumnCount($result);

	$nfields=count($fields);
	$html='<hr /><table class="sql"><tr>';
	### print table header
	for($j=0;$j<$col_count;$j++) {
		$html.='<th><a href="'.$progName.'?par_formName='.$par_formName.'&amp;button='.$button;
		$html.='&amp;par_language='.$par_language.'&amp;par_orderbyid='.$j.'&amp;par_header=1';
		for($k=0;$k<$nfields;$k++) 
			$html.='&amp;'.$fields[$k]['inputName'].'='.$fields[$k]['inputValue'];
		$html.='">';
		$html.=$fields[$j]['columnLabel'];
		if($par_orderbyid == $j) {
			if($_SESSION['asc_desc'] == 'asc')
				#$html.='>| ';
				$html.='&#9660; ';
			else
				#$html.='|< ';
				$html.='&#9650; ';
		}
		$html.='</a></th>';
	}
	$html.="</tr>\n";
	### print table data
	for($i=$start;$i<$start+$nrows;$i++) {
		if($i >= $row_count)
			break;
		$row=$db->fetchRow($result,$i);
		$html.='<tr>'."\n";
		for($j=0;$j<$col_count;$j++) {
			$html.='<td>';
			if($url_column == $j)
				$html.='<a href="'.$row[$j].'">'.$row[$j].'</a>';
			else {
				$html.='<a href="'.$progName.'?par_formName='.$par_formName.'&amp;button='.$lrb['sisiya_adm.button.find'];
				$html.='&amp;par_language='.$par_language;
				for($k=0;$k<$nfields;$k++) {
					$html.='&amp;'.$fields[$k]['inputName'].'=';
					if($fields[$k]['flag'] == 't')
						$html.="'".$row[$k]."'";
					else
						$html.=$row[$k];
				}
				$html.='">';
				$html.=$row[$j].'</a>';
			}
			$html.='</td>';
		}
		$html.="</tr>\n";
	}
	$html.='</table>'."\n";
	### display page numbers
	### d=total number of pages to be displayed at a time
	### 
	$d=10;
#$startPage=$start;
	if($nrows > 0)
		$npages=$row_count/$nrows;
	if($npages > 1) {
		$html.='<table class="sql_pages">'."\n";
		$html.="<tr><td>\n";
		$html.=''."\n";
		$currentPage=$start/$nrows;
		for($i=0;$i<=$npages;$i++) {
#	if($i == $d)
#		break;
			$html.='<a href="'.$progName.'?par_formName='.$par_formName.'&amp;button='.$lrb['sisiya_adm.button.find'];
			$html.='&amp;par_language='.$par_language.'&amp;par_start='.($i*$nrows).'&amp;par_orderbyid='.$par_orderbyid;
			$cols=count($fields);
			for($j=0;$j<$cols;$j++) {
				$html.='&amp;'.$fields[$j]['inputName'].'='.$fields[$j]['inputValue'];
			}
			if($currentPage == $i)
				$html.='"><b>'.($i+1).'</b></a>'."\n";
			else
				$html.='">'.($i+1).'</a>'."\n";
		}
/*
		if($i < $npages) {
			$html.='<a href="'.$progName.'?par_formName='.$par_formName.'&amp;button='.$lrb['sisiya_adm.button.find'];
			$html.='&amp;par_language='.$par_language.'&amp;par_start='.($i*$nrows).'&amp;par_orderbyid='.$par_orderbyid;
			$cols=count($fields);
			for($j=0;$j<$cols;$j++)
				$html.='&amp;'.$fields[$j]['inputName'].'='.$fields[$j]['inputValue'];
			$html.='">&gt;&gt;</a>'."\n";
		}
*/
		$html.=''."\n";
		$html.="</td></tr>\n";
		$html.="</table>\n";
	}
	#$html.=getCopyright();
	#$html.='<h3>Rows = '.$row_count.' Columns = '.$col_count.'</h3>';
	#$html.='nrows='.$nrows.' Number of pages '.$npages."\n";
	return $html;
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
########################################################################################################################################

function displayMenu()
{
	echo getMenu();
}

function getMenu()
{
	global $user_id,$user_name,$user_surname,$valid_user,$is_admin,$ma,$progName,$par_formName,$par_language,$lrb;
	
	$html='<table class="menu">'."\n";
	$menuCount=count($ma);
	for($i=0;$i<$menuCount;$i++) {
		#### bgcolor is not allowed here, remove it and find another way of displaying menu
		
#		$html.='<tr><td class="submenu">'.$lrb[$ma[$i]['strkey']].'</td></tr>'."\n";
		$a=array();
		foreach($_SESSION['sb'] as $key=>$value) 
                	$a[$key]=$value;
		if($a[$i] == 1)
			$html.='<tr><td class="submenu">'.$lrb[$ma[$i]['strkey']].' <a href="'.$progName.'?par_formName='.$_SESSION['activeForm'].'&amp;par_language='.$par_language.'&amp;par_skey='.$i.'&amp;par_svalue='.$a[$i].'"> &#9650;</a></td></tr>'."\n";
		else
			$html.='<tr><td class="submenu">'.$lrb[$ma[$i]['strkey']].' <a href="'.$progName.'?par_formName='.$_SESSION['activeForm'].'&amp;par_language='.$par_language.'&amp;par_skey='.$i.'&amp;par_svalue='.$a[$i].'"> &#9660;</a></td></tr>'."\n";
		#$html.='<tr><td>'.$ma[$i]['label'].'</td></tr>'."\n";
		$subCount=count($ma[$i]['submenu']);
		for($j=0;$j<$subCount;$j++) {
			if($is_admin == 'f' && $ma[$i]['submenu'][$j]['foradmins'] == 't')
				#$html.='<tr><td>&nbsp;&nbsp; '.$lrb[$ma[$i]['submenu'][$j]['strkey']].'</a></td></tr>'."\n";
				continue;
			else
				if($a[$i] == 1)
				$html.='<tr><td><a href="'.$progName.'?par_formName='.$ma[$i]['submenu'][$j]['formName'].'&amp;par_language='.$par_language.'">&nbsp;&nbsp; '.$lrb[$ma[$i]['submenu'][$j]['strkey']].'</a></td></tr>'."\n";
		}
	}
	$html.='</table>'."\n";
	return $html;
}

function getNextID($table_name)
{
	global $db;

	$id=1; # default ID

	$sql_str='select max(id) from '.$table_name;
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);

	if($row_count == 1) {
		$row=$db->fetchRow($result,0);
		$id=$row[0]+1;
	} 
	$db->freeResult($result);
	return $id; 
}

function id_sortid_str_Form($table_name)
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;

	$tableName=$table_name;
	$formName=$tableName;

	$orderbyarray=array(
		0=> array('key'=>'id','value'=>$lrb['sisiya_adm.label.id']), 
		1=> array('key'=>'sortid','value'=>$lrb['sisiya_adm.label.sortid']), 
		2=> array('key'=>'str','value'=>$lrb['sisiya_adm.'.$formName.'.label.str']) 
	); 
	$id=getHTTPValue('id');
	$sortid=getHTTPValue('sortid');
	$str=getHTTPValue('str');
	$orderbyid=getHTTPValue('orderbyid');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$id='';
		$sortid='';
		$str='';
	} 
	if($par_orderbyid == '')
		$par_orderbyid=0;

	$select_sql_str='select id,sortid, str from '.$table_name;
	$select_sql_str2='select * from '.$table_name;
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		if(is_numeric($id)) 
			$tmp_str=' where id='.$id;
		else {
			if(is_numeric($sortid)) {
				if($tmp_str == '') 
					$tmp_str=' where sortid='.$sortid;
				else 
					$tmp_str=' and sortid='.$sortid;
			}
			if($str != '') {
				if($tmp_str == '') 
					$tmp_str=' where str like \'%'.$str.'%\'';
				else 
					$tmp_str.=' and str like \'%'.$str.'%\'';
			}
		}
		if($tmp_str != '')
			$select_sql_str.=' '.$tmp_str;

		$result=$db->query($select_sql_str);
		$row_count=$db->getRowCount($result);

		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$id=$row[0];
			$sortid=$row[1];
			$str=$row[2];
		} 
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	# input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.id'];
	$html.='</td><td><input type="text" size="5" name="id" value="'.$id.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.sortid'];
	$html.='</td><td><input type="text" size="5" name="sortid" value="'.$sortid.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.str'].'</td>';
	$html.='<td><input type="text" size="70" name="str" value="'.$str.'" /></td></tr>'."\n"; 
	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);

	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($id))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($sortid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.sortid'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($str == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.str'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$table_name." set sortid=".$sortid.",str='".$str."' where id=".$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($id))
				$id=getNextID($formName);
			if($sortid == '')
				$sortid=0;
			if($str == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.str'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str="insert into ".$table_name." values(".$id.",".$sortid.",'".$str."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			}
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($id))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where id='.$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';
	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.id'],'inputName'=>'id','inputValue'=>$id,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.label.sortid'],'inputName'=>'sortid','inputValue'=>$sortid,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.str'],'inputName'=>'str','inputValue'=>$str,'flag'=>'f'),
	);
	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function idstrForm($table_name)
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;

	$tableName=$table_name;
	$formName=$tableName;

	### an array for ordering the sql result table
	$orderbyarray=array(
		0=> array('key'=>'id','value'=>$lrb['sisiya_adm.label.id']), 
		1=> array('key'=>'str','value'=>$lrb['sisiya_adm.'.$formName.'.label.str']) 
	); 

	### get form values
	$id=getHTTPValue('id');
	$str=getHTTPValue('str');
	$action=getHTTPValue('button');

	### clear
	if($action == $lrb['sisiya_adm.button.clear']) {
		$id='';
		$str='';
	} 
 
	if($par_orderbyid == '')
		$par_orderbyid=0;

	$select_sql_str='select * from '.$tableName;
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		if(is_numeric($id)) 
			$tmp_str=' where id='.$id;
		else {
			if($str != '') {
				if($tmp_str == '') 
					$tmp_str=" where str like '%".$str."%'";
				else 
					$tmp_str.=" and str like '%".$str."%'";
			}
		}
		if($tmp_str != '')
			$select_sql_str.=' '.$tmp_str;

		$result=$db->query($select_sql_str);
		$row_count=$db->getRowCount($result);

		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$id=$row[0];
			$str=$row[1];
		} 
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";

	# input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.id'];
	$html.='</td><td><input type="text" size="5" name="id" value="'.$id.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.str'].'</td>';
	$html.='<td><input type="text" size="70" name="str" value="'.$str.'" /></td></tr>'."\n"; 
	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);

	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($id))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($str == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.str'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$tableName." set str='".$str."' where id=".$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			}
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($id))
				$id=getNextID($formName);
			if($str == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.str'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str="insert into ".$tableName." values(".$id.",'".$str."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			}
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($id))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where id='.$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';
	#echo $html;
	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.id'],'inputName'=>'id','inputValue'=>$id,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.str'],'inputName'=>'str','inputValue'=>$str,'flag'=>'f'),
	);
	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

### Finds the first timestamp for this systemid,serviceid from systemhistorystatus or systemhistorystatusall
function getFirstTimestamp($systemid,$serviceid)
{
	global $db;

	$sql_str='select sendtime from systemhistorystatusall where systemid='.$systemid.' and serviceid='.$serviceid.' order by sendtime';
	$result=$db->query($sql_str);
	if($db->getRowCount($result) == 0) {	
		$sql_str='select sendtime from systemhistorystatus where systemid='.$systemid.' and serviceid='.$serviceid.' order by sendtime';
		$result=$db->query($sql_str);
	}
	$row=$db->fetchRow($result,0);
	return($row[0]);
}

### This function updates the systemservice table from systemhistorystatus and systemhistorystatusall
function update_systemservice()
{
	global $db;

	$sql_str='select a.id,b.serviceid from systems a,systemservicestatus b where a.id=b.systemid and a.active=\'t\' order by a.id,b.serviceid';
	$result=$db->query($sql_str);
	$row_count=$db->getRowCount($result);	
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$sql_str='select count(*) from systemservice where systemid='.$row[0].' and serviceid='.$row[1];
		$result2=$db->query($sql_str);
		$row2=$db->fetchRow($result2,0);
		if($row2[0] == 0) {
			$sql_str='insert into systemservice values('.$row[0].','.$row[1].',\'t\',\''.getFirstTimestamp($row[0],$row[1]).'\')';
			$db->query($sql_str);
		}
	}
}

function systemsForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='systems';
	$formName=$tableName;
 
	$orderbyarray=array(
		0  => array('key'=>'a.id','value'=>$lrb['sisiya_adm.label.id']), 
		1  => array('key'=>'a.hostname','value'=>$lrb['sisiya_adm.'.$formName.'.label.hostname']), 
		2  => array('key'=>'a.fullhostname','value'=>$lrb['sisiya_adm.'.$formName.'.label.fullhostname']), 
		3  => array('key'=>'b.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.systemtype']), 
		4  => array('key'=>'a.active','value'=>$lrb['sisiya_adm.label.isactive']), 
		5  => array('key'=>'c.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.effectsoverallstatus']) 
	); 

	$id=getHTTPValue('id');
	$active=getHTTPValue('active');
	$hostname=getHTTPValue('hostname');
	$fullhostname=getHTTPValue('fullhostname');
	$systemtype_name=getHTTPValue('systemtype_name');
	$systemtypeid=getHTTPValue('systemtypeid');
	$location_name=getHTTPValue('location_name');
	$locationid=getHTTPValue('locationid');
	$effectsglobal=getHTTPValue('effectsglobal');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear'] || $action == $lrb['sisiya_adm.button.showall']) {
		$id='';
		$active='t';
		$hostname='';
		$fullhostname='';
		$systemtypeid='';
		$locationid='';
		$effectsglobal='t';
	} 
	if($par_orderbyid == '')
		$par_orderbyid=0;

	$select_sql_str='select a.id,a.hostname,a.fullhostname,a.active,b.str,c.str,a.effectsglobal from systems a,systemtypes b,locations c where a.systemtypeid=b.id and a.locationid=c.id';
	$select_sql_str2='select * from '.$tableName." a where active='".$active."'";
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		$tmp_str2='';
		if($id != '') {
			$tmp_str=' and a.id='.$id;
		}
		else {
			if(is_numeric($systemtypeid)) 
				$tmp_str.=' and a.systemtypeid='.$systemtypeid;
			if(is_numeric($locationid)) 
				$tmp_str.=' and a.locationid='.$locationid;
			if($hostname != '') 
				$tmp_str.=" and a.hostname like '%".$hostname."%'";
			if($fullhostname != '') 
				$tmp_str.=" and a.fullhostname like '%".$fullhostname."%'";
			if($effectsglobal != '') 
				$tmp_str=$tmp_str." and a.effectsglobal='".$effectsglobal."'";
			if($active != '') 
				$tmp_str=$tmp_str." and a.active='".$active."'";
		}
		if($tmp_str != '') {
			$select_sql_str=$select_sql_str.' '.$tmp_str;
			$tmp_str2.=' '.$tmp_str;
			$select_sql_str2=$select_sql_str2.' '.$tmp_str2;
		}
	 
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$id=$row[0];
			$active=$row[1];
			$systemtypeid=$row[2];
			$locationid=$row[3];
			$hostname=$row[4];
			$fullhostname=$row[5];
			$effectsglobal=$row[6];
		} 
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];


	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
#$html.='select_sql_str='.$select_sql_str;
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.id'].'</td>';
	$html.='<td><input type="text" size="10" name="id" value="'.$id.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.hostname'].'</td>';
	$html.='<td><input type="text" size="40" name="hostname" value="'.$hostname.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.fullhostname'].'</td>';
	$html.='<td><input type="text" size="40" name="fullhostname" value="'.$fullhostname.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.systemtype'].'</td>'."\n";

	$result=$db->query("select str,id from systemtypes order by str");
	$row_count=$db->getRowCount($result);
	$html.='<td><select name="systemtypeid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($systemtypeid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($systemtype_name != '' && $systemtype_name == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $systemtypeid) {
				$html.='selected="selected" ';
				$systemtype_name=$row[0];
			}
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_admin.label.isactive'].'</td>'."\n";
	$html.='<td><select name="active">'."\n"; 
	if($active == 't') {
		$html.='<option selected="selected" value="t">'.$lrb['sisiya_admin.label.yes']."</option>\n";
		$html.='<option value="f">'.$lrb['sisiya_admin.label.no']."</option>\n";
	}
	else {
		$html.='<option selected="selected" value="f">'.$lrb['sisiya_admin.label.no']."</option>\n";
		$html.='<option value="t">'.$lrb['sisiya_admin.label.yes']."</option>\n";
	}
	$html.='</select></td></tr>'."\n";
 
	$html.='<tr><td class="label">'.$lrb['sisiya_admin.'.$formName.'.label.effectsoverallstatus'].'</td>'."\n";
	$html.='<td><select name="effectsglobal">'."\n"; 
	if($effectsglobal == 't') {
		$html.='<option selected="selected" value="t">'.$lrb['sisiya_admin.label.yes']."</option>\n";
		$html.='<option value="f">'.$lrb['sisiya_admin.label.no']."</option>\n";
	}
	else {
		$html.='<option selected="selected" value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
		$html.='<option value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.systemlocation'].'</td>'."\n";

	$result=$db->query('select str,id,sortid from locations order by sortid,str');
	$row_count=$db->getRowCount($result);
	$html.='<td><select name="locationid">'."\n"; 
	$html.='<option ';
	if($locationid == '-')
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
 
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($location_name != '' && $location_name == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $locationid) {
				$html.='selected="selected" ';
				$location_name=$row[0];
			}
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";
	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($id))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($systemtypeid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.systemtypeid'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($locationid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.locationid'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str='update '.$tableName." set active='".$active."',systemtypeid=".$systemtypeid.",locationid=".$locationid.",effectsglobal='".$effectsglobal."'";
				if($hostname != '')
					$sql_str=$sql_str.",hostname='".$hostname."'";
				if($fullhostname != '')
					$sql_str=$sql_str.",fullhostname='".$fullhostname."'";
				$sql_str=$sql_str." where id=$id";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($id))
				$id=getNextID($tableName);
			if(! is_numeric($systemtypeid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.systemtype'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($locationid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.systemlocation'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str="insert into ".$tableName." values($id,'".$active."',$systemtypeid,$locationid,'".$hostname."','".$fullhostname."','".$effectsglobal."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($id)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str="delete from ".$tableName." where id=$id";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.id'],'inputName'=>'id','inputValue'=>$id,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.hostname'],'inputName'=>'hostname','inputValue'=>$hostname,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.fullhostname'],'inputName'=>'fullhostname','inputValue'=>$fullhostname,'flag'=>'f'),
		3 => array('columnLabel'=>$lrb['sisiya_adm.label.isactive'],'inputName'=>'active','inputValue'=>$active,'flag'=>'f'),
		4 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.systemtype'],'inputName'=>'systemtype_name','inputValue'=>$systemtype_name,'flag'=>'f'),
		5 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.systemlocation'],'inputName'=>'location_name','inputValue'=>$location_name,'flag'=>'f'),
		6 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.effectsoverallstatus'],'inputName'=>'effectsglobal','inputValue'=>$effectsglobal,'flag'=>'f'),
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function groupsForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	global $is_admin,$user_id;
	
	$tableName='groups';
	$formName=$tableName;
 
	$orderbyarray=array(
		0  => array('key'=>'a.id','value'=>$lrb['sisiya_adm.'.$formName.'.label.groupid']), 
		1  => array('key'=>'a.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.groupname']), 
		2  => array('key'=>'a.sortid','value'=>$lrb['sisiya_adm.label.sortid']) 
	); 

	if($is_admin == 't') {
		$orderbyarray[3]=array('key'=>'b.id','value'=>$lrb['sisiya_adm.label.user']);
		$username=getHTTPValue('username');
	}

	$groupid=getHTTPValue('groupid');
	$userid=getHTTPValue('userid');
	$sortid=getHTTPValue('sortid');
	$groupname=getHTTPValue('groupname');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$groupid='';
		$groupname='';
		$userid='-';
		$sortid='';
		$orderno='';
	}
 
	if($par_orderbyid == '')
		$par_orderbyid=0;
	if($is_admin == 't') {
		$select_sql_str='select a.id,a.str,a.sortid,b.username from groups a,users b where a.userid=b.id';
		$select_sql_str2="select * from ".$tableName;
	}
	else {
		$select_sql_str='select a.id,a.str,a.sortid from groups a,users b where a.userid=b.id and b.id='.$user_id;
		$select_sql_str2="select * from ".$tableName;
	}
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($groupid)) {	
			$tmp_str=' and a.id='.$groupid;
			$tmp_str2=' id='.$groupid;
		}
		else {
			if(is_numeric($sortid)) {
				$tmp_str.=' and a.sortid='.$sortid;
				if($tmp_str2 != '')
					$tmp_str2.=' and sortid='.$sortid;
				else
					$tmp_str2=' orderno='.$sortid;
			}
		}
		if($tmp_str != '')
			$select_sql_str.=' '.$tmp_str;
		if($tmp_str2 != '')
			$select_sql_str2.=' where '.$tmp_str2;
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$groupid=$row[0];
			$userid=$row[1];
			$sortid=$row[2];
			$groupname=$row[3];
		}
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
#$html.='select_sql_str='.$select_sql_str;
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.groupid'].'</td>';
	$html.='<td><input type="text" size="10" name="groupid" value="'.$groupid.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.groupname'].'</td>';
	$html.='<td><input type="text" size="40" name="groupname" value="'.$groupname.'" /></td></tr>'."\n"; 
	if($is_admin == 't') {
		$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.user'].'</td>'."\n";
		$result=$db->query('select username,id,name,surname from users order by username');
		$row_count=$db->getRowCount($result);	
		$html.='<td><select name="userid">'."\n"; 
		$html.='<option ';
		if(! is_numeric($userid))
			$html.='selected="selected" ';
		$html.='value="-">-'."</option>\n";
		if($row_count > 0) {
			for($i=0;$i<$row_count;$i++) {
				$row=$db->fetchRow($result,$i);
				$html.='<option ';
				if($row[1] == $userid)
					$html.='selected="selected" ';
				$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
			}
		}
		$html.='</select></td></tr>'."\n";
	}
 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.sortid'].'</td>';
	$html.='<td><input type="text" size="10" name="sortid" value="'.$sortid.'" /></td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($groupid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.groupid'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($groupname == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.groupname'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($sortid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.sortid'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($is_admin == 't' && ! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				if($is_admin == 't')
					$u=$userid; ### the user chosen from the list
				else
					$u=$user_id; ### global user id, the user loged in
				$sql_str='update '.$tableName.' set id='.$groupid.',userid='.$u.',sortid='.$sortid.",str='".$groupname."' where id=".$groupid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($groupid))
				$groupid=getNextID($tableName);
			if(! is_numeric($sortid))
				$sortid=10;
			if($groupname == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.groupname'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($is_admin == 't' && ! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				if($is_admin == 't')
					$u=$userid; ### the user chosen from the list
				else
					$u=$user_id; ### global user id, the user loged in
				$sql_str='insert into '.$tableName.' values('.$groupid.','.$u.','.$sortid.",'".$groupname."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($groupid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.groupid'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where id='.$groupid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.groupid'],'inputName'=>'groupid','inputValue'=>$groupid,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.groupname'],'inputName'=>'groupname','inputValue'=>$groupname,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.label.sortid'],'inputName'=>'sortid','inputValue'=>$sortid,'flag'=>'f')
	);
	if($is_admin == 't')
		$fields[3]=array('columnLabel'=>$lrb['sisiya_adm.label.user'],'inputName'=>'username','inputValue'=>$username,'flag'=>'f');

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function groupsystemForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	global $user_id,$is_admin;
	
	$tableName='groupsystem';
	$formName=$tableName;
 
	$orderbyarray=array(
		0  => array('key'=>'b.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.groupname']), 
		1  => array('key'=>'c.hostname','value'=>$lrb['sisiya_adm.label.system'])
	); 


	$groupname=getHTTPValue('groupname');
	$systemname=getHTTPValue('systemname');

	$groupid=getHTTPValue('groupid');
	$systemid=getHTTPValue('systemid');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$groupname='';
		$systemname='';
		$groupid='-';
		$systemid='-';
	}
	if($par_orderbyid == '')
		$par_orderbyid=0;
 
	if($is_admin == 't') {
		$select_sql_str='select b.str,c.hostname from '.$tableName.' a,groups b,systems c where a.groupid=b.id and a.systemid=c.id';
	}
	else {
		$select_sql_str='select b.str,c.hostname from '.$tableName.' a,groups b,systems c where a.groupid=b.id and a.systemid=c.id and b.userid='.$user_id;
	}
	$select_sql_str2='select a.* from '.$tableName.' a,groups b,systems c where a.groupid=b.id and a.systemid=c.id';
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($groupid)) 
			$tmp_str=' and a.groupid='.$groupid;
		if(is_numeric($systemid))
			$tmp_str.=' and a.systemid='.$systemid;
		if($groupname != '')
			$tmp_str.=" and b.str='".$groupname."'";
		if($systemname != '')
			$tmp_str.=" and c.hostname='".$systemname."'";
		if($tmp_str != '') {
			$select_sql_str.=' '.$tmp_str;
			$select_sql_str2.=' '.$tmp_str;
		}
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$groupid=$row[0];
			$systemid=$row[1];
		}
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.groupname'].'</td>'."\n";
	if($is_admin == 't')
		$result=$db->query('select a.str,a.id,b.username from groups a,users b where a.userid=b.id order by str');
	else
		$result=$db->query('select str,id from groups where userid='.$user_id.' order by str');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="groupid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($groupid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($groupname != '' && $groupname == $row[0])
				$html.='selected="selected" ';
			if($row[1] == $groupid)
				$html.='selected="selected" ';
			if($is_admin == 't')
				$html.='value="'.$row[1].'">'.$row[0].' ('.$row[2].')'."</option>\n";
			else
				$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.system'].'</td>'."\n";
	$result=$db->query('select hostname,id from systems order by hostname');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="systemid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($systemid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($systemname != '' && $systemname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $systemid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.add'],
			4=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($groupid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.groupname'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($systemid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str='insert into '.$tableName.' values('.$groupid.','.$systemid.')';
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($groupid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.groupname'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($systemid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.systemname'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where groupid='.$groupid.' and systemid='.$systemid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.groupname'],'inputName'=>'groupname','inputValue'=>$groupname,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'systemname','inputValue'=>$systemname,'flag'=>'f')
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function systeminfoForm()
{
	global $user_id,$is_admin;
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='systeminfo';
	$formName=$tableName;

	$orderbyarray=array(
		0=> array('key'=>'c.hostname,b.str','value'=>$lrb['sisiya_adm.label.system']), 
		1=> array('key'=>'b.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.infoname']), 
		2=> array('key'=>'a.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.infovalue'])
	); 

	$systemname=getHTTPValue('systemname');
	$infoname=getHTTPValue('infoname');
	$infovalue=getHTTPValue('infovalue');

	$systemid=getHTTPValue('systemid');
	$infoid=getHTTPValue('infoid');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$systemname='';
		$infoname='';
		$infovalue='';
		$infoid='-';
		$systemid='-';
	}
	if($par_orderbyid == '')
		$par_orderbyid=0;
 
	$select_sql_str='select c.hostname,b.str,a.str from systeminfo a,infos b,systems c where a.systemid=c.id and a.infoid=b.id';
	$select_sql_str2='select a.* from '.$tableName.' a,infos b,systems c where a.systemid=c.id and a.infoid=b.id';
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($infoid)) 
			$tmp_str=' and a.infoid='.$infoid;
		if(is_numeric($systemid))
			$tmp_str.=' and a.systemid='.$systemid;
		if($infoname != '')
			$tmp_str.=" and b.str='".$infoname."'";
		if($systemname != '')
			$tmp_str.=" and c.hostname='".$systemname."'";
		if($infovalue != '') {
			if($infoid == '-')
				$tmp_str.=" and a.str like '%".$infovalue."%'";
		}
		if($tmp_str != '') {
			$select_sql_str.=' '.$tmp_str;
			$select_sql_str2.=' '.$tmp_str;
		}
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$systemid=$row[0];
			$infoid=$row[1];
			$infovalue=$row[2];
		}
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.system']."</td>\n";

	$result=$db->query('select hostname,id from systems order by hostname');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="systemid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($systemid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($systemname != '' && $systemname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $systemid) {
				$html.='selected="selected" ';
				$systemname=$row[0];
			}
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";
	
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.infoname']."</td>\n";

	$result=$db->query('select str,id from infos order by str');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="infoid">'."\n"; 
	$html.='<option ';
	if($infoid == '-')
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($infoname != '' && $infoname == $row[0])
				$html.='selected="selected" ';
			if($row[1] == $infoid) {
				$html.='selected="selected" ';
				$infoname=$row[0];
			}
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.infovalue'].'</td>'."\n";
	$html.='<td><input type="text" size="70" name="infovalue" value="'.$infovalue.'" /></td></tr>'."\n"; 
	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($infoid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.infoname'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($infovalue == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.infovalue'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$tableName." set str='".$infovalue."' where systemid=".$systemid." and infoid=".$infoid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($infoid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.infoname'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($infovalue == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.infovalue'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str="insert into ".$tableName." values(".$systemid.",".$infoid.",'".$infovalue."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($infoid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.infoname'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where infoid='.$infoid.' and systemid='.$systemid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'systemname','inputValue'=>$systemid,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.infoname'],'inputName'=>'infoname','inputValue'=>$infoname,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.infovalue'],'inputName'=>'infovalue','inputValue'=>$infovalue,'flag'=>'f'),
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}


function userpropertiesForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	global $user_id,$is_admin,$valid_user;
	
	$tableName='userproperties';
	$formName=$tableName;
 


	if($is_admin == 'f') {
		$userid=$user_id;
		$username=$valid_user;
		$orderbyarray=array(
			0  => array('key'=>'b.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.prpertykey']), 
			1  => array('key'=>'a.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.propertyvalue']) 
		); 
	}
	else {
		$orderbyarray=array(
			0  => array('key'=>'c.username','value'=>$lrb['sisiya_adm.label.username']), 
			1  => array('key'=>'c.name','value'=>$lrb['sisiya_adm.label.name']), 
			2  => array('key'=>'c.surname','value'=>$lrb['sisiya_adm.label.surname']), 
			3  => array('key'=>'b.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.propertyname']), 
			4  => array('key'=>'a.str','value'=>$lrb['sisiya_adm.'.$formName.'.label.propertyvalue']) 
		);
		$username=getHTTPValue('username');
		$userid=getHTTPValue('userid');
	}

	$propertyname=getHTTPValue('propertyname');
	$propertyvalue=getHTTPValue('propertyvalue');

	$propertyid=getHTTPValue('propertyid');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$propertyname='';
		$propertyvalue='';
		$propertyid='-';
		$userid='-';
	}
	if($par_orderbyid == '')
		$par_orderbyid=0;
 
	if($is_admin == 't') {
		$select_sql_str='select c.username,c.name,c.surname,b.str,a.str from '.$tableName.' a,properties b,users c where a.propertyid=b.id and a.userid=c.id';
	}
	else {
		$select_sql_str='select b.str,a.str from'.$tableName.' a,properties b,users c where a.propertyid=b.id and a.userid=c.id and a.userid='.$userid;
	}
	$select_sql_str2='select a.* from '.$formName.' a,properties b,users c where a.propertyid=b.id and a.userid=c.id';
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($userid)) 
			$tmp_str=' and a.userid='.$userid;
		if($username != '')
			$tmp_str.=" and c.username='".$username."'";

		if(is_numeric($propertyid)) 
			$tmp_str=' and a.propertyid='.$propertyid;
		if($propertyname != '')
			$tmp_str.=" and b.str='".$propertyname."'";
		if($propertyvalue != '') {
			if($propertyid == '-')
				$tmp_str.=" and a.str like '%".$propertyvalue."%'";
		}
		if($tmp_str != '') {
			$select_sql_str.=' '.$tmp_str;
			$select_sql_str2.=' '.$tmp_str;
		}
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$userid=$row[0];
			$propertyid=$row[1];
			$propertyvalue=$row[2];
		}
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	if($is_admin == 't') {
		$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.user'].'</td>'."\n";
		$result=$db->query('select username,id,name,surname from users order by username');
		$row_count=$db->getRowCount($result);	
		$html.='<td><select name="userid">'."\n"; 
		$html.='<option ';
		if(! is_numeric($userid))
			$html.='selected="selected" ';
		$html.='value="-">-'."</option>\n";
		if($row_count > 0) {
			for($i=0;$i<$row_count;$i++) {
				$row=$db->fetchRow($result,$i);
				$html.='<option ';
				if($username != '' && $username == $row[0])
					$html.='selected="selected" ';
				else if($row[1] == $userid)
					$html.='selected="selected" ';
				$html.='value="'.$row[1].'">'.$row[0].' - '.$row[2].' '.$row[3]."</option>\n";
			}
		}
		$html.='</select></td></tr>'."\n";
	}
 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.propertyname'].'</td>'."\n";
	$result=$db->query('select str,id from properties order by str');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="propertyid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($propertyid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($propertyname != '' && $propertyname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $propertyid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.propertyvalue'].'</td>'."\n";
	$html.='<td><input type="text" size="70" name="propertyvalue" value="'.$propertyvalue.'"</td></tr>'."\n"; 
	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($propertyid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.propertyname'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($propertyvalue == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.propertyvalue'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$tableName." set str='".$propertyvalue."' where userid=".$userid." and propertyid=".$propertyid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($propertyid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.propertyname'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($propertyvalue == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.propertyvalue'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str="insert into ".$tableName." values(".$userid.",".$propertyid.",'".$propertyvalue."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($userid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($propertyid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.propertyname'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where userid='.$userid.' and propertyid='.$propertyid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';


	if($is_admin == 'f')
		$fields=array(
			0 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.propertyname'],'inputName'=>'propertyname','inputValue'=>$propertyname,'flag'=>'f'),
			1 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.propertyvalue'],'inputName'=>'propertyvalue','inputValue'=>$propertyvalue,'flag'=>'f')
		);
	else
		$fields=array(
			0 => array('columnLabel'=>$lrb['sisiya_adm.label.username'],'inputName'=>'username','inputValue'=>$username,'flag'=>'f'),
			1 => array('columnLabel'=>$lrb['sisiya_adm.label.name'],'inputName'=>'','inputValue'=>'','flag'=>'f'),
			2 => array('columnLabel'=>$lrb['sisiya_adm.label.surname'],'inputName'=>'','inputValue'=>'','flag'=>'f'),
			3 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.propertyname'],'inputName'=>'propertyname','inputValue'=>$propertyname,'flag'=>'f'),
			4 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.propertyvalue'],'inputName'=>'propertyvalue','inputValue'=>$propertyvalue,'flag'=>'f')
		);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;

}



function usersystemalertForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	global $user_id,$is_admin,$valid_user;
	
	$tableName='usersystemalert';
	$formName=$tableName;
 


	### initial alert time used for insert
	$alerttime='19801231145648';
	
	if($is_admin == 'f') {
		$userid=$user_id;
		$username=$valid_user;
		$orderbyarray=array(
			0  => array('key'=>'b.hostname','value'=>$lrb['sisiya_adm.label.system']), 
			1  => array('key'=>'f.str','value'=>$lrb['sisiya_adm.label.status']), 
			2  => array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.alerttype']), 
			3  => array('key'=>'a.expire','value'=>$lrb['sisiya_adm.label.alertfrequency']) 
		); 
	}
	else {
		$orderbyarray=array(
			0  => array('key'=>'e.username','value'=>$lrb['sisiya_adm.label.username']), 
			1  => array('key'=>'e.name','value'=>$lrb['sisiya_adm.label.name']), 
			2  => array('key'=>'e.surname','value'=>$lrb['sisiya_adm.label.surname']), 
			3  => array('key'=>'b.hostname','value'=>$lrb['sisiya_adm.label.system']), 
			4  => array('key'=>'f.str','value'=>$lrb['sisiya_adm.label.status']), 
			5  => array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.alerttype']), 
			6  => array('key'=>'a.expire','value'=>$lrb['sisiya_adm.label.alertfrequency']) 
		); 
		$username=getHTTPValue('username');
		$userid=getHTTPValue('userid');
	}
	$systemname=getHTTPValue('systemname');
	$statusname=getHTTPValue('statusname');
	$alerttypename=getHTTPValue('alerttypename');

	$systemid=getHTTPValue('systemid');
	$alerttypeid=getHTTPValue('alerttypeid');
	$statusid=getHTTPValue('statusid');
	$enabled=getHTTPValue('enabled');
	$expire=(int)getHTTPValue('expire');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$username='';
		$systemname='';
		$userid='-';
		$systemid='-';
		$alerttypeid='-';
		$enabled='t';
		$statusid='-';
		$expire=0;
	}
	if($par_orderbyid == '')
		$par_orderbyid=0;

	if($expire < 0)
		$expire=0;
 
	if($is_admin == 't') {
		$select_sql_str="select e.username,e.name,e.surname,b.hostname,d.str,c.str,a.enabled,a.expire from ".$tableName." a,systems b,alerttypes c,status d,users e,status f where a.userid=e.id and a.systemid=b.id and a.alerttypeid=c.id and a.statusid=d.id and a.statusid=f.id";
	}
	else {
		$select_sql_str="select b.hostname,d.str,c.str,a.enabled,a.expire from ".$tableName." a,systems b,alerttypes c,status d,users e,status f where a.userid=".$userid." and a.userid=e.id and a.systemid=b.id and a.alerttypeid=c.id and a.statusid=d.id and a.statusid=f.id";
	}
	$select_sql_str2="select a.userid,a.systemid,a.alerttypeid,a.statusid,a.enabled,a.expire from ".$tableName." a,systems b,alerttypes c,status d,users e,status f where a.userid=e.id and a.systemid=b.id and a.alerttypeid=c.id and a.statusid=d.id and a.statusid=f.id";
	if($action == $lrb['sisiya_adm.button.find']) {
		$select_sql_str.=" and a.enabled='".$enabled."'";
		$select_sql_str2.=" and a.enabled='".$enabled."'";
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($userid)) 
			$tmp_str=' and a.userid='.$userid;
		if($username != '')
			$tmp_str.=" and e.username='".$username."'";
		if(is_numeric($systemid))
			$tmp_str.=' and a.systemid='.$systemid;
		if($systemname != '')
			$tmp_str.=" and b.hostname='".$systemname."'";
		if(is_numeric($statusid)) 
			$tmp_str.=' and a.statusid='.$statusid;
		if($statusname != '')
			$tmp_str.=" and d.str='".$statusname."'";
		if($tmp_str != '') {
			$select_sql_str.=' '.$tmp_str;
			$select_sql_str2.=' '.$tmp_str;
		}
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$userid=$row[0];
			$systemid=$row[1];
			$alerttypeid=$row[2];
			$statusid=$row[3];
			$enabled=$row[4];
			$expire=$row[5];
		}
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];


	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	if($is_admin == 't') {
		$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.user'].'</td>'."\n";
		$result=$db->query('select username,id,name,surname from users order by username');
		$row_count=$db->getRowCount($result);	
		$html.='<td><select name="userid">'."\n"; 
		$html.='<option ';
		if(! is_numeric($userid))
			$html.='selected="selected" ';
		$html.='value="-">-'."</option>\n";
		if($row_count > 0) {
			for($i=0;$i<$row_count;$i++) {
				$row=$db->fetchRow($result,$i);
				$html.='<option ';
				if($username != '' && $username == $row[0])
					$html.='selected="selected" ';
				else if($row[1] == $userid)
					$html.='selected="selected" ';
				$html.='value="'.$row[1].'">'.$row[0].' - '.$row[2].' '.$row[3]."</option>\n";
			}
		}
		$html.='</select></td></tr>'."\n";
	}
 

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.system'].'</td>'."\n";
	$result=$db->query('select hostname,id from systems order by hostname');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="systemid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($systemid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($systemname != '' && $systemname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $systemid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.status'].'</td>'."\n";
	$result=$db->query('select str,id from status order by id');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="statusid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($statusid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($statusname != '' && $statusname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $statusid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.alerttype'].'</td>'."\n";
	$result=$db->query('select str,id from alerttypes order by id');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="alerttypeid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($alerttypeid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($alerttypename != '' && $alerttypename == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $alerttypeid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.isactive'].'</td>'."\n";
	$html.='<td><select name="enabled">'."\n"; 
	if($enabled == 't') {
		$html.='<option selected="selected" value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
		$html.='<option value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
	}
	else {
		$html.='<option selected="selected" value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
		$html.='<option value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.alertfrequency'].'</td>';
	$html.='<td><input type="text" size="40" name="expire" value="'.$expire.'" />'; 
	$html.='&nbsp;'.$lrb['sisiya_adm.label.alertfrequencydescription'].'</td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($statusid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.status'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($alerttypeid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.alerttype'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$tableName." set enabled='".$enabled."',expire=".$expire." where userid=".$userid." and systemid=".$systemid." and alerttypeid=".$alerttypeid." and statusid=".$statusid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($statusid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.status'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($alerttypeid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.alerttype'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($expire))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.alertfrequency'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str='insert into '.$tableName.' values('.$userid.','.$systemid.','.$alerttypeid.','.$statusid.',\''.$enabled.'\','.$expire.',\''.$alerttime.'\')';
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($statusid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.status'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($alerttypeid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.alerttype'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where userid='.$userid.' and systemid='.$systemid.' and alerttypeid='.$alerttypeid.' and statusid='.$statusid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	if($is_admin == 'f')
		$fields=array(
			0 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'','inputValue'=>$systemname,'flag'=>'f'),
			1 => array('columnLabel'=>$lrb['sisiya_adm.label.status'],'inputName'=>'statusname','inputValue'=>$statusname,'flag'=>'f'),
			2 => array('columnLabel'=>$lrb['sisiya_adm.label.alerttype'],'inputName'=>'alerttypename','inputValue'=>$alerttypename,'flag'=>'f'),
			3 => array('columnLabel'=>$lrb['sisiya_adm.label.isactive'],'inputName'=>'enabled','inputValue'=>$enabled,'flag'=>'f'),
			4 => array('columnLabel'=>$lrb['sisiya_adm.label.alertfrequency'],'inputName'=>'expire','inputValue'=>$expire,'flag'=>'f')
		);
	else
		$fields=array(
			0 => array('columnLabel'=>$lrb['sisiya_adm.label.username'],'inputName'=>'username','inputValue'=>$username,'flag'=>'f'),
			1 => array('columnLabel'=>$lrb['sisiya_adm.label.name'],'inputName'=>'name','inputValue'=>'','flag'=>'f'),
			2 => array('columnLabel'=>$lrb['sisiya_adm.label.surname'],'inputName'=>'surname','inputValue'=>'','flag'=>'f'),
			3 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'systemname','inputValue'=>$systemname,'flag'=>'f'),
			4 => array('columnLabel'=>$lrb['sisiya_adm.label.status'],'inputName'=>'statusname','inputValue'=>$statusname,'flag'=>'f'),
			5 => array('columnLabel'=>$lrb['sisiya_adm.label.alerttype'],'inputName'=>'alerttypename','inputValue'=>$alerttypename,'flag'=>'f'),
			6 => array('columnLabel'=>$lrb['sisiya_adm.label.isactive'],'inputName'=>'enabled','inputValue'=>$enabled,'flag'=>'f'),
			7 => array('columnLabel'=>$lrb['sisiya_adm.label.alertfrequency'],'inputName'=>'expire','inputValue'=>$expire,'flag'=>'f')
		);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;


}


function usersystemservicealertForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	global $user_id,$is_admin,$valid_user;
	
	$tableName='usersystemservicealert';
	$formName=$tableName;
 


	### initial alert time used for insert
	$alerttime='19801231145648';
	
	if($is_admin == 'f') {
		$userid=$user_id;
		$username=$valid_user;
		$orderbyarray=array(
			0  => array('key'=>'b.hostname','value'=>$lrb['sisiya_adm.label.system']), 
			1  => array('key'=>'g.str','value'=>$lrb['sisiya_adm.label.service']), 
			2  => array('key'=>'f.str','value'=>$lrb['sisiya_adm.label.status']), 
			3  => array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.alerttype']), 
			4  => array('key'=>'a.expire','value'=>$lrb['sisiya_adm.label.alertfrequency']) 
		); 
	}
	else {
		$orderbyarray=array(
			0  => array('key'=>'e.username','value'=>$lrb['sisiya_adm.label.username']), 
			1  => array('key'=>'e.name','value'=>$lrb['sisiya_adm.label.name']), 
			2  => array('key'=>'e.surname','value'=>$lrb['sisiya_adm.label.surname']), 
			3  => array('key'=>'b.hostname','value'=>$lrb['sisiya_adm.label.system']), 
			4  => array('key'=>'g.str','value'=>$lrb['sisiya_adm.label.service']), 
			5  => array('key'=>'f.str','value'=>$lrb['sisiya_adm.label.status']), 
			6  => array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.alerttype']), 
			7  => array('key'=>'a.enabled','value'=>$lrb['sisiya_adm.label.isactive']), 
			8  => array('key'=>'a.expire','value'=>$lrb['sisiya_adm.label.alertfrequency']) 
		); 
		$username=getHTTPValue('username');
		$userid=getHTTPValue('userid');
	}
	$systemname=getHTTPValue('systemname');
	$servicename=getHTTPValue('servicename');
	$statusname=getHTTPValue('statusname');
	$alerttypename=getHTTPValue('alerttypename');

	$systemid=getHTTPValue('systemid');
	$serviceid=getHTTPValue('serviceid');
	$alerttypeid=getHTTPValue('alerttypeid');
	$statusid=getHTTPValue('statusid');
	$enabled=getHTTPValue('enabled');
	$expire=(int)getHTTPValue('expire');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$username='';
		$systemname='';
		$servicename='';
		$userid='-';
		$systemid='-';
		$serviceid='-';
		$alerttypeid='-';
		$enabled='t';
		$statusid='-';
		$expire=0;
	}
	if($par_orderbyid == '')
		$par_orderbyid=0;

	if($expire < 0)
		$expire=0;
 
	if($is_admin == 't') {
		$select_sql_str="select e.username,e.name,e.surname,b.hostname,g.str,d.str,c.str,a.enabled,a.expire from ".$tableName." a,systems b,alerttypes c,status d,users e,status f,services g where a.userid=e.id and a.systemid=b.id and a.serviceid=g.id and a.alerttypeid=c.id and a.statusid=d.id and a.statusid=f.id";
	}
	else {
		$select_sql_str="select b.hostname,g.str,d.str,c.str,a.enabled,a.expire from ".$tableName." a,systems b,alerttypes c,status d,users e,status f,services g where a.userid=".$userid." and a.userid=e.id and a.systemid=b.id and a.serviceid=g.id and a.alerttypeid=c.id and a.statusid=d.id and a.statusid=f.id";
	}
	$select_sql_str2="select a.userid,a.systemid,a.serviceid,a.alerttypeid,a.statusid,a.enabled,a.expire from ".$tableName." a,systems b,alerttypes c,status d,users e,status f,services g where a.userid=e.id and a.systemid=b.id and a.serviceid=g.id and a.alerttypeid=c.id and a.statusid=d.id and a.statusid=f.id";
	if($action == $lrb['sisiya_adm.button.find']) {
		$select_sql_str.=" and a.enabled='".$enabled."'";
		$select_sql_str2.=" and a.enabled='".$enabled."'";
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($userid)) 
			$tmp_str=' and a.userid='.$userid;
		if($username != '')
			$tmp_str.=" and e.username='".$username."'";
		if(is_numeric($systemid))
			$tmp_str.=' and a.systemid='.$systemid;
		if($systemname != '')
			$tmp_str.=" and b.hostname='".$systemname."'";
		if(is_numeric($serviceid))
			$tmp_str.=' and a.serviceid='.$serviceid;
		if($servicename != '')
			$tmp_str.=" and b.str='".$servicename."'";
		if(is_numeric($statusid)) 
			$tmp_str.=' and a.statusid='.$statusid;
		if($statusname != '')
			$tmp_str.=" and d.str='".$statusname."'";
		if($tmp_str != '') {
			$select_sql_str.=' '.$tmp_str;
			$select_sql_str2.=' '.$tmp_str;
		}
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$userid=$row[0];
			$systemid=$row[1];
			$serviceid=$row[2];
			$alerttypeid=$row[3];
			$statusid=$row[4];
			$enabled=$row[5];
			$expire=$row[6];
		}
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];


	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	if($is_admin == 't') {
		$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.user'].'</td>'."\n";
		$result=$db->query('select username,id,name,surname from users order by username');
		$row_count=$db->getRowCount($result);	
		$html.='<td><select name="userid">'."\n"; 
		$html.='<option ';
		if(! is_numeric($userid))
			$html.='selected="selected" ';
		$html.='value="-">-'."</option>\n";
		if($row_count > 0) {
			for($i=0;$i<$row_count;$i++) {
				$row=$db->fetchRow($result,$i);
				$html.='<option ';
				if($username != '' && $username == $row[0])
					$html.='selected="selected" ';
				else if($row[1] == $userid)
					$html.='selected="selected" ';
				$html.='value="'.$row[1].'">'.$row[0].' - '.$row[2].' '.$row[3]."</option>\n";
			}
		}
		$html.='</select></td></tr>'."\n";
	}
 

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.system'].'</td>'."\n";
	$result=$db->query('select hostname,id from systems order by hostname');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="systemid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($systemid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($systemname != '' && $systemname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $systemid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.service'].'</td>'."\n";
	$result=$db->query('select str,id from services order by str');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="serviceid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($serviceid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($servicename != '' && $servicename == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $serviceid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.status'].'</td>'."\n";
	$result=$db->query('select str,id from status order by id');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="statusid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($statusid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($statusname != '' && $statusname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $statusid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.alerttype'].'</td>'."\n";
	$result=$db->query('select str,id from alerttypes order by id');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="alerttypeid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($alerttypeid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($alerttypename != '' && $alerttypename == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $alerttypeid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.isactive'].'</td>'."\n";
	$html.='<td><select name="enabled">'."\n"; 
	if($enabled == 't') {
		$html.='<option selected="selected" value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
		$html.='<option value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
	}
	else {
		$html.='<option selected="selected" value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
		$html.='<option value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.alertfrequency'].'</td>';
	$html.='<td><input type="text" size="40" name="expire" value="'.$expire.'" />'; 
	$html.='&nbsp;'.$lrb['sisiya_adm.label.alertfrequencydescription'].'</td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($serviceid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.service'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($statusid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.status'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($alerttypeid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.alerttype'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$tableName." set enabled='".$enabled."',expire=".$expire." where userid=".$userid." and systemid=".$systemid." and serviceid=".$serviceid." and alerttypeid=".$alerttypeid." and statusid=".$statusid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($serviceid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.service'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($statusid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.status'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($alerttypeid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.alerttype'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($expire))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.alertfrequency'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str='insert into '.$tableName.' values('.$userid.','.$systemid.','.$serviceid.','.$alerttypeid.','.$statusid.",'".$enabled."',".$expire.",'".$alerttime."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($userid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.user'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($serviceid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.service'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($statusid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.status'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($alerttypeid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.alerttype'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where userid='.$userid.' and systemid='.$systemid.' and serviceid='.$serviceid.' and alerttypeid='.$alerttypeid.' and statusid='.$statusid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	if($is_admin == 'f')
		$fields=array(
			0 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'systemname','inputValue'=>$systemname,'flag'=>'f'),
			1 => array('columnLabel'=>$lrb['sisiya_adm.label.service'],'inputName'=>'servicename','inputValue'=>$servicename,'flag'=>'f'),
			2 => array('columnLabel'=>$lrb['sisiya_adm.label.status'],'inputName'=>'statusname','inputValue'=>$statusname,'flag'=>'f'),
			3 => array('columnLabel'=>$lrb['sisiya_adm.label.alerttype'],'inputName'=>'alerttypename','inputValue'=>$alerttypename,'flag'=>'f'),
			4 => array('columnLabel'=>$lrb['sisiya_adm.label.isactive'],'inputName'=>'enabled','inputValue'=>$enabled,'flag'=>'f'),
			5 => array('columnLabel'=>$lrb['sisiya_adm.label.alertfrequency'],'inputName'=>'expire','inputValue'=>$expire,'flag'=>'f')
		);
	else
		$fields=array(
			0 => array('columnLabel'=>$lrb['sisiya_adm.label.username'],'inputName'=>'username','inputValue'=>$username,'flag'=>'f'),
			1 => array('columnLabel'=>$lrb['sisiya_adm.label.name'],'inputName'=>'','inputValue'=>'','flag'=>'f'),
			2 => array('columnLabel'=>$lrb['sisiya_adm.label.surname'],'inputName'=>'','inputValue'=>'','flag'=>'f'),
			3 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'systemname','inputValue'=>$systemname,'flag'=>'f'),
			4 => array('columnLabel'=>$lrb['sisiya_adm.label.service'],'inputName'=>'servicename','inputValue'=>$servicename,'flag'=>'f'),
			5 => array('columnLabel'=>$lrb['sisiya_adm.label.status'],'inputName'=>'statusname','inputValue'=>$statusname,'flag'=>'f'),
			6 => array('columnLabel'=>$lrb['sisiya_adm.label.alerttype'],'inputName'=>'alerttypename','inputValue'=>$alerttypename,'flag'=>'f'),
			7 => array('columnLabel'=>$lrb['sisiya_adm.label.isactive'],'inputName'=>'enabled','inputValue'=>$enabled,'flag'=>'f'),
			8 => array('columnLabel'=>$lrb['sisiya_adm.label.alertfrequency'],'inputName'=>'expire','inputValue'=>$expire,'flag'=>'f')
		);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;


}

function sendSisIYAMessageForm()
{
	global $valid_user,$sendMessageProg;
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;

	$tableName='systemservicestatus';
	$formName='sendmessage';
 
	$orderbyarray=array(
		0  => array('key'=>'b.hostname','value'=>$lrb['sisiya_adm.label.system']), 
		1  => array('key'=>'d.str','value'=>$lrb['sisiya_adm.label.service']), 
		2  => array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.status']), 
		3  => array('key'=>'a.expires','value'=>$lrb['sisiya_adm.label.expire']), 
		4  => array('key'=>'a.str','value'=>$lrb['sisiya_adm.label.message']) 
	); 

	$systemname=getHTTPValue('systemname');
	$servicename=getHTTPValue('servicename');
	$statusname=getHTTPValue('statusname');

	$systemid=getHTTPValue('systemid');
	$serviceid=getHTTPValue('serviceid');
	$statusid=getHTTPValue('statusid');
	$message=getHTTPValue('message');
	$expire=(int)getHTTPValue('expire');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$systemname='';
		$servicename='';
		$message='';
		$systemid='-';
		$serviceid='-';
		$statusid='-';
	}
	if($expire == '')
		$expire=0;

	if($par_orderbyid == '')
		$par_orderbyid=0;
 
	$select_sql_str="select b.hostname,d.str,c.str,a.expires,a.str from ".$tableName." a,systems b,status c,services d where a.systemid=b.id and a.serviceid=d.id and a.statusid=c.id and b.active='t'";
	$select_sql_str2="select a.systemid,a.serviceid,a.statusid,a.str,b.hostname from ".$tableName." a,systems b,status c,services d where a.systemid=b.id and a.serviceid=d.id and a.statusid=c.id and b.active='t'";
	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.send']) {
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($systemid))
			$tmp_str.=' and a.systemid='.$systemid;
		if($systemname != '')
			$tmp_str.=" and b.hostname='".$systemname."'";
		if(is_numeric($serviceid))
			$tmp_str.=' and a.serviceid='.$serviceid;
		if($servicename != '')
			$tmp_str.=" and d.str='".$servicename."'";
		if($action == $lrb['sisiya_adm.button.find']) {
			if(is_numeric($statusid)) 
				$tmp_str.=' and a.statusid='.$statusid;
			if($statusname != '')
				$tmp_str.=" and c.str='".$statusname."'";
		}
		if($tmp_str != '') {
			$select_sql_str.=' '.$tmp_str;
			$select_sql_str2.=' '.$tmp_str;
		}
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$systemid=$row[0];
			$serviceid=$row[1];
			if($action == $lrb['sisiya_adm.button.find']) {
				$statusid=$row[2];
				$message=$row[3];
			}
			$systemname=$row[4];
		}
		else if($row_count == 0) {
			### this is the very first message, in this case there are no records in systemservicestatus table and we only need the systemname
			$result=$db->query('select hostname from systems where id='.$systemid);
			$row_count=$db->getRowCount($result);
			if($row_count == 1) {
				$row=$db->fetchRow($result,0);
				$systemname=$row[0];
			}
		}
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];
	
	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.system'].'</td>'."\n";
	$result=$db->query('select hostname,id from systems order by hostname');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="systemid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($systemid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($systemname != '' && $systemname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $systemid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.service'].'</td>'."\n";
	$result=$db->query('select str,id from services order by str');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="serviceid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($serviceid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($servicename != '' && $servicename == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $serviceid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.status'].'</td>'."\n";
	$result=$db->query('select str,id from status order by id');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="statusid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($statusid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($statusname != '' && $statusname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $statusid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.expire'].'</td>';
	$html.='<td><input type="text" size="40" name="expire" value="'.$expire.'" />'; 
	$html.='&nbsp;'.$lrb['sisiya_adm.label.expiredescription'].'</td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.message'].'</td>';
	$html.='<td><input type="text" size="70" name="message" value="'.$message.'" /></td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.send']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.send']:
			if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.send'].' operation!</h4>'."\n";
			else if(! is_numeric($serviceid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.service'].' for '.$lrb['sisiya_adm.button.send'].' operation!</h4>'."\n";
			else if(! is_numeric($statusid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.status'].' for '.$lrb['sisiya_adm.button.send'].' operation!</h4>'."\n";
			else if(! is_numeric($expire))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.expire'].' for '.$lrb['sisiya_adm.button.send'].' operation!</h4>'."\n";
			else if($message == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.message'].' for '.$lrb['sisiya_adm.button.send'].' operation!</h4>'."\n";
			else {
				$message=$valid_user.':'.$message;
				#echo "systemname=[".$systemname."] systemid=".$systemid."<br>";
				#$sql_msg.=$sendMessageProg.' '.$systemname.' '.$serviceid.' '.$statusid.' '.$expire.' '.$message;
				exec($sendMessageProg.' '.$systemname.' '.$serviceid.' '.$statusid.' '.$expire.' "'.$message.'"',$output,$retcode);
				if($retcode == 0)
					$sql_msg.='<h4>Message has been successfully sent to the SisIYA server.</h4>';
				else {
					$sql_msg.='<h4>Error occured while sending the message to SisIYA server (retcode='.$retcode.' :<br /></h4>';
					for($i=0;$i<count($output);$i++)
						$sql_msg.=$output[$i].'<br>';
					$sql_msg.='</h4'."\n";
				}
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'systemname','inputValue'=>$systemname,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.label.service'],'inputName'=>'servicename','inputValue'=>$servicename,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.label.status'],'inputName'=>'statusname','inputValue'=>$statusname,'flag'=>'f'),
		3 => array('columnLabel'=>$lrb['sisiya_adm.label.expire'],'inputName'=>'expire','inputValue'=>$expire,'flag'=>'f'),
		4 => array('columnLabel'=>$lrb['sisiya_adm.label.message'],'inputName'=>'message','inputValue'=>$message,'flag'=>'f')
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function systemserviceForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='systemservice';
	$formName=$tableName;

	$orderbyarray=array(
		0=> array('key'=>'a.active','value'=>$lrb['sisiya_adm.label.isactive']), 
		1=> array('key'=>'b.hostname','value'=>$lrb['sisiya_adm.label.system']), 
		2=> array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.service']), 
		3=> array('key'=>'a.starttime','value'=>$lrb['sisiya_adm.label.starttime']), 
		4=> array('key'=>'a.str','value'=>$lrb['sisiya_adm.label.description']) 
	); 

	$hostname=getHTTPValue('hostname');
	$servicename=getHTTPValue('servicename');

	$systemid=getHTTPValue('systemid');
	$serviceid=getHTTPValue('serviceid');
	$isactive=getHTTPValue('isactive');
	$starttime=getHTTPValue('starttime');
	$str=getHTTPValue('str');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$hostname='';
		$servicename='';
		$systemid='-';
		$serviceid='-';
		$isactive='t';
		$starttime='';
		$str='';
	} 
	if($par_orderbyid == '')
		$par_orderbyid=0;

	$select_sql_str='select b.hostname,c.str,a.active,a.starttime,a.str from '.$tableName.' a,systems b,services c where a.systemid=b.id and a.serviceid=c.id';
	$select_sql_str2="select a.* from ".$tableName." a,systems b,services c where a.systemid=b.id and a.serviceid=c.id and a.active='".$isactive."'";
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($systemid)) {
			$tmp_str=' and a.systemid='.$systemid;
			$tmp_str2=' and systemid='.$systemid;
		}
		if($hostname != '') {
			$tmp_str2.=" and b.hostname='".$hostname."'";
		}
		if($servicename != '') {
			$tmp_str2.=" and c.str='".$servicename."'";
		}
		if(is_numeric($serviceid)) {
			$tmp_str.=" and a.serviceid=".$serviceid;
			$tmp_str2.=" and serviceid=".$serviceid;
		}
		$select_sql_str.=' '.$tmp_str." and a.active='".$isactive."'";
		if($tmp_str2 != '')
			$select_sql_str2.=' '.$tmp_str2;

		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$systemid=$row[0];
			$serviceid=$row[1];
			$isactive=$row[2];
			$starttime=$row[3];
			$str=$row[4];
		} 
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#$html.='select_sql_str='.$select_sql_str."<br />";
	#$html.='select_sql_str2='.$select_sql_str2;
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.system'].'</td>';

	$result=$db->query('select hostname,id from systems order by hostname');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="systemid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($systemid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($hostname != '' && $hostname == $row[0]) {
				$html.='selected="selected" ';
				$hostname=$row[0];
			}
			else if($row[1] == $systemid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.service']."</td>\n";
	$result=$db->query('select str,id from services order by str');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="serviceid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($serviceid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($servicename != '' && $servicename == $row[0]) {
				$html.='selected="selected" ';
				$servicename=$row[0];
			}
			if($row[1] == $serviceid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.isactive']."</td>\n";
	$html.='<td><select name="isactive">'."\n"; 
	if($isactive == 't') {
		$html.='<option selected="selected" value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
		$html.='<option value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
	}
	else {
		$html.='<option selected="selected" value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
		$html.='<option value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.starttime'].'</td>';
	$html.='<td><input type="text" size="70" name="starttime" value="'.$starttime.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.description'].'</td>';
	$html.='<td><input type="text" size="70" name="str" value="'.$str.'" /></td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($serviceid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.service'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str='update '.$tableName." set active='".$isactive."'";
				if($starttime != '')
					$sql_str=$sql_str.",starttime='".$starttime."'";
				if($str != '')
					$sql_str=$sql_str.",str='".$str."'";
				$sql_str=$sql_str.' where systemid='.$systemid.' and serviceid='.$serviceid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			}
		 	break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($systemid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($serviceid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.service'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($isactive == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.isactive'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($starttime == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.starttime'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($str == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.description'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str='insert into '.$tableName.' values('.$systemid.','.$serviceid.",'".$isactive."','".$starttime."','".$str."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($systemid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($serviceid))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.service'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where systemid='.$systemid.' and serviceid='.$serviceid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			}
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'hostname','inputValue'=>$hostname,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.label.service'],'inputName'=>'servicename','inputValue'=>$servicename,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.label.isactive'],'inputName'=>'isactive','inputValue'=>$isactive,'flag'=>'f'),
		3 => array('columnLabel'=>$lrb['sisiya_adm.label.starttime'],'inputName'=>'starttime','inputValue'=>$starttime,'flag'=>'f'),
		4 => array('columnLabel'=>$lrb['sisiya_adm.label.description'],'inputName'=>'str','inputValue'=>$str,'flag'=>'f')
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}


function systemstatusForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='systemstatus';
	$formName=$tableName;

	$orderbyarray=array(
		0=> array('key'=>'b.hostname','value'=>$lrb['sisiya_adm.label.system']), 
		1=> array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.status']), 
		2=> array('key'=>'a.updatetime','value'=>$lrb['sisiya_adm.label.updatetime']), 
		3=> array('key'=>'a.changetime','value'=>$lrb['sisiya_adm.label.changetime']), 
		4=> array('key'=>'a.str','value'=>$lrb['sisiya_adm.label.message']) 
	); 

	$systemname=getHTTPValue('systemname');
	$systemid=getHTTPValue('systemid');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$systemname='';
		$systemid='';
	}
	if($par_orderbyid == '')
		$par_orderbyid=0;

	$select_sql_str='select b.hostname,c.str,a.updatetime,a.changetime,a.str from systemstatus a,systems b,status c where a.systemid=b.id and a.statusid=c.id';
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		if(is_numeric($systemid))
			$tmp_str=' and systemid='.$systemid;
		if($systemname != '') 
			$tmp_str=$tmp_str." and b.hostname='".$systemname."'";
		if($tmp_str != '')
			$select_sql_str=$select_sql_str.' '.$tmp_str;
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];


	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.system'].'</td>';

	$result=$db->query('select hostname,id from systems order by hostname');
	$row_count=$db->getRowCount($result);	
	if($row_count > 0) {
		$html.='<td><select name="systemid">'."\n"; 
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($systemname != '' && $systemname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $systemid)
				$html.='selected="selected" ';
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
		$html.='</select></td></tr>'."\n";
	}
	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.showall'],
			1=>$lrb['sisiya_adm.button.find'],
			2=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';


	if($action == $lrb['sisiya_adm.button.delete']) {
		if(! is_numeric($systemid))
			$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
		else {
			$sql_str='delete from '.$tableName.' where systemid='.$systemid;
			$n=execSQL($sql_str);
			if($n == 1) 
				$sql_msg.=$action.' : '.$n.' OK.';
			else
				$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
		} 
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'systemname','inputValue'=>$systemname,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.label.status'],'inputName'=>'x','inputValue'=>'','flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.label.updatetime'],'inputName'=>'x','inputValue'=>'','flag'=>'f'),
		3 => array('columnLabel'=>$lrb['sisiya_adm.label.changetime'],'inputName'=>'x','inputValue'=>'','flag'=>'f'),
		4 => array('columnLabel'=>$lrb['sisiya_adm.label.message'],'inputName'=>'x','inputValue'=>'','flag'=>'f')
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function systemservicestatusForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='systemservicestatus';
	$formName=$tableName;

	$orderbyarray=array(
		0=> array('key'=>'b.hostname','value'=>$lrb['sisiya_adm.label.system']), 
		1=> array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.service']), 
		2=> array('key'=>'d.str','value'=>$lrb['sisiya_adm.label.status']), 
		3=> array('key'=>'a.updatetime','value'=>$lrb['sisiya_adm.label.updatetime']), 
		4=> array('key'=>'a.changetime','value'=>$lrb['sisiya_adm.label.changetime']), 
		5=> array('key'=>'a.expires','value'=>$lrb['sisiya_adm.label.expires']), 
		6=> array('key'=>'a.str','value'=>$lrb['sisiya_adm.label.message']) 
	); 

	$systemname=getHTTPValue('systemname');
	$servicename=getHTTPValue('servicename');

	$systemid=getHTTPValue('systemid');
	$serviceid=getHTTPValue('serviceid');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear']) {
		$systemname='';
		$servicename='';
		$systemid='';
		$serviceid='';
	}

	if($par_orderbyid == '')
		$par_orderbyid=0;

	$select_sql_str='select b.hostname,c.str,d.str,a.updatetime,a.changetime,a.expires,a.str from '.$tableName.' a,systems b,services c,status d where a.systemid=b.id and a.serviceid=c.id and a.statusid=d.id';
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		if(is_numeric($systemid))
			$tmp_str.=' and a.systemid='.$systemid;
		if(is_numeric($serviceid))
			$tmp_str.=' and a.serviceid='.$serviceid;
		if($systemname != '') 
			$tmp_str.=" and b.hostname='".$systemname."'";
		if($servicename != '') 
			$tmp_str.=" and c.str='".$servicename."'";
		if($tmp_str != '')
			$select_sql_str.=' '.$tmp_str;
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.system'].'</td>';

	$result=$db->query('select hostname,id from systems order by hostname');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="systemid">'."\n"; 
	$html.='<option ';
	if($systemid == '-')
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($systemname != '' && $systemname == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $systemid) {
				$html.='selected="selected" ';
				$systemname=$row[0];
			}
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";
 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.service'].'</td>';

	$result=$db->query('select str,id from services order by str');

	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="serviceid">'."\n"; 
	$html.='<option ';
	if($serviceid == '-')
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($servicename != '' && $servicename == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $serviceid) {
				$html.='selected="selected" ';
				$servicename=$row[0];
			}
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";
	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.showall'],
			1=>$lrb['sisiya_adm.button.find'],
			2=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';


	if($action == $lrb['sisiya_adm.button.delete']) {
		if(! is_numeric($systemid))
			$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.system'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
		else if(! is_numeric($serviceid))
			$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.service'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
		else {
			$sql_str='delete from '.$tableName.' where systemid='.$systemid.' and serviceid='.$serviceid;
			$n=execSQL($sql_str);
			if($n == 1) 
				$sql_msg.=$action.' : '.$n.' OK.';
			else
				$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
		} 
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.system'],'inputName'=>'systemname','inputValue'=>$systemname,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.label.service'],'inputName'=>'servicename','inputValue'=>$servicename,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.label.status'],'inputName'=>'x','inputValue'=>'','flag'=>'f'),
		3 => array('columnLabel'=>$lrb['sisiya_adm.label.updatetime'],'inputName'=>'x','inputValue'=>'','flag'=>'f'),
		4 => array('columnLabel'=>$lrb['sisiya_adm.label.changetime'],'inputName'=>'x','inputValue'=>'','flag'=>'f'),
		5 => array('columnLabel'=>$lrb['sisiya_adm.label.expires'],'inputName'=>'x','inputValue'=>'','flag'=>'f'),
		6 => array('columnLabel'=>$lrb['sisiya_adm.label.message'],'inputName'=>'x','inputValue'=>'','flag'=>'f')
	);


	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}
  
function SisIYAUsersForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid,$min_password_length;
	
	$tableName='users';
	$formName=$tableName;
 
	$orderbyarray=array(
		0  => array('key'=>'id','value'=>$lrb['sisiya_adm.label.id']), 
		1  => array('key'=>'username','value'=>$lrb['sisiya_adm.label.username']), 
		2  => array('key'=>'name','value'=>$lrb['sisiya_adm.label.name']), 
		3  => array('key'=>'surname','value'=>$lrb['sisiya_adm.label.surname']), 
		4  => array('key'=>'email','value'=>$lrb['sisiya_adm.label.email']), 
		5  => array('key'=>'is_admin','value'=>$lrb['sisiya_adm.label.isadmin']) 
	); 

	$id=getHTTPValue('id');
	$username=getHTTPValue('username');
	$password=getHTTPValue('password');
	$name=getHTTPValue('name');
	$surname=getHTTPValue('surname');
	$email=getHTTPValue('email');
	$isadmin=getHTTPValue('isadmin');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear'] || $action == $lrb['sisiya_adm.button.showall']) {
		$id='';
		$username='';
		$password='';
		$name='';
		$surname='';
		$email='';
		$isadmin='f';
	} 
	if($par_orderbyid == '')
		$par_orderbyid=0;


	$select_sql_str='select id,username,name,surname,email,isadmin from '.$tableName;
	$select_sql_str2='select * from '.$tableName;
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		$tmp_str2='';
		if($id != '') {
			$tmp_str=' id='.$id;
			$tmp_str2=' id='.$id;
		}
		else {
			if($username != '') {
				if($tmp_str == '') {
					$tmp_str=" username like '%".$username."%'";
					$tmp_str2=" username like '%".$username."%'";
				}
				else {
					$tmp_str.=" username like '%".$username."%'";
					$tmp_str2.=" username like '%".$username."%'";
				}
			}
			if($name != '') {
				if($tmp_str == '') {
					$tmp_str=" name like '%".$name."%'";
					$tmp_str2=" name like '%".$name."%'";
				}
				else {
					$tmp_str.=" name like '%".$name."%'";
					$tmp_str2.=" name like '%".$name."%'";
				}
			}
			if($surname != '') {
				if($tmp_str == '') {
					$tmp_str=" surname like '%".$surname."%'";
					$tmp_str2=" surname like '%".$surname."%'";
				}
				else {
					$tmp_str.=" surname like '%".$surname."%'";
					$tmp_str2.=" surname like '%".$surname."%'";
				}
			}
			if($email != '') {
				if($tmp_str == '') {
					$tmp_str=" email like '%".$email."%'";
					$tmp_str2=" email like '%".$email."%'";
				}
				else {
					$tmp_str.=" email like '%".$email."%'";
					$tmp_str2.=" email like '%".$email."%'";
				}
			}
			if($tmp_str == '') {
				$tmp_str=" isadmin='".$isadmin."'";
				$tmp_str2=" isadmin='".$isadmin."'";
			}
			else {
				$tmp_str.=" isadmin='".$isadmin."'";
				$tmp_str2.=" isadmin='".$isadmin."'";
			}
		}
		if($tmp_str != '') {
			$select_sql_str.=' where '.$tmp_str;
			$select_sql_str2.=' where '.$tmp_str2;
		}

		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$id=$row[0];
			$username=$row[1];
			$password=$row[2];
			$name=$row[3];
			$surname=$row[4];
			$email=$row[5];
			$isadmin=$row[6];
		} 
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
#$html.='select_sql_str='.$select_sql_str;
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.id'].'</td>';
	$html.='<td><input type="text" size="10" name="id" value="'.$id.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.username'].'</td>';
	$html.='<td><input type="text" size="70" name="username" value="'.$username.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.name'].'</td>';
	$html.='<td><input type="text" size="70" name="name" value="'.$name.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.surname'].'</td>';
	$html.='<td><input type="text" size="70" name="surname" value="'.$surname.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.email'].'</td>';
	$html.='<td><input type="text" size="70" name="email" value="'.$email.'" /></td></tr>'."\n"; 
 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.isactive'].'</td>'."\n";
	$html.='<td><select name="isadmin">'."\n"; 
	if($isadmin == 't') {
		$html.='<option selected="selected" value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
		$html.='<option value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
	}
	else {
		$html.='<option selected="selected" value="f">'.$lrb['sisiya_adm.label.no']."</option>\n";
		$html.='<option value="t">'.$lrb['sisiya_adm.label.yes']."</option>\n";
	}
	$html.='</select></td></tr>'."\n";
	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($id))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			if($username == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.username'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($name == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.name'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($surname == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.surname'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($email == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.email'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
#			else if($password == '' || strlen($password) < $min_password_length) 
#				echo '<center><h4>Error : You must specify an Password which has minimum length of '.$min_password_length.' for an Update operation!</h4></center>'."\n";
			else {
				#$sql_str='update '.$table_name.' set username=\''.$username.'\',password=\''.encryptPassword($password).'\',name=\''.$name.'\',surname=\''.$surname.'\',email=\''.$email.'\',isadmin=\''.$isadmin.'\' where id='.$id;
				$sql_str="update ".$tableName." set username='".$username."',name='".$name."',surname='".$surname."',email='".$email."',isadmin='".$isadmin."' where id=".$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($id))
				$id=getNextID($tableName);
			if(! is_numeric($id)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($username == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.username'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($name == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.name'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($surname == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.surname'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($email == '')
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.email'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";

#			else if($password == '' || strlen($password) < $min_password_length) 
#				echo '<center><h4>Error : You must specify an Password which has minimum length of '.$min_password_length.' for an Insert operation!</h4></center>'."\n";
			else {
				#$sql_str='insert into '.$table_name.' values('.$id.',\''.$username.'\',\''.encryptPassword($password).'\',\''.$name.'\',\''.$surname.'\',\''.$email.'\',\''.$isadmin.'\')';
				$sql_str="insert into ".$tableName." (id,username,name,surname,email,isadmin) values(".$id.",'".$username."','".$name."','".$surname."','".$email."','".$isadmin."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($id)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if($id == -1)
				$sql_msg.='<h4>Error : You cannot delete the System Administrator account!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where id='.$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.id'],'inputName'=>'id','inputValue'=>$id,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.label.username'],'inputName'=>'username','inputValue'=>$username,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.label.name'],'inputName'=>'name','inputValue'=>$name,'flag'=>'f'),
		3 => array('columnLabel'=>$lrb['sisiya_adm.label.surname'],'inputName'=>'surname','inputValue'=>$surname,'flag'=>'f'),
		4 => array('columnLabel'=>$lrb['sisiya_adm.label.email'],'inputName'=>'email','inputValue'=>$email,'flag'=>'f'),
		5 => array('columnLabel'=>$lrb['sisiya_adm.label.isadmin'],'inputName'=>'isadmin','inputValue'=>$isadmin,'flag'=>'f')
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function changePasswordForm()
{
	global $min_password_length,$user_id,$user_name,$user_surname,$valid_user,$is_admin;
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='users';
	$formName='change_password';
 
	$userid=getHTTPValue('userid');
	if(! is_numeric($userid))
		$userid=$user_id; ### this must be admin
#	else if($userid == '')
#		$userid=$user_id;
	$old_password=getHTTPValue('old_password');
	$password1=getHTTPValue('password1');
	$password2=getHTTPValue('password2');
	$action=getHTTPValue("button");

	if($action == $lrb['sisiya_adm.button.clear']) {
		$old_password='';
		$password1='';
		$password2='';
	} 
	if($par_orderbyid == '')
		$par_orderbyid=0;

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
#$html.='select_sql_str='.$select_sql_str;
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";

	if($is_admin == 'f') {
		$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.oldpassword'].'</td>';
		$html.='<td><input type="password" size="70" name="old_password" value="" /></td></tr>'."\n"; 
	}
	else {
		$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.user'].'</td>'."\n";
		$result=$db->query('select username,id,name,surname from users order by username');
		$row_count=$db->getRowCount($result);	
		$html.='<td><select name="userid">'."\n"; 
		$html.='<option ';
		if(! is_numeric($userid))
			$html.='selected="selected" ';
		$html.='value="-">-'."</option>\n";
		if($row_count > 0) {
			for($i=0;$i<$row_count;$i++) {
				$row=$db->fetchRow($result,$i);
				$html.='<option ';
				if($row[1] == $userid)
					$html.='selected="selected" ';
				$html.='value="'.$row[1].'">'.$row[0].' - '.$row[2].' '.$row[3]."</option>\n";
			}
		}
		$html.='</select></td></tr>'."\n";
	}
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.newpassword'].'</td>';
	$html.='<td><input type="password" size="70" name="password1" value="" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.renewpassword'].'</td>';
	$html.='<td><input type="password" size="70" name="password2" value="" /></td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.change']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	if($action == $lrb['sisiya_adm.button.change']) {
		if($is_admin == 'f' && $old_password == '') 
			$sql_msg.='<h4>'.$lrb['sisiya_adm.label.error'].' :'.$lrb['sisiya_adm.'.$formName.'.msg.no_old_password'].'</h4>'."\n";
		else if($password1 != $password2)
			$sql_msg.='<h4>'.$lrb['sisiya_adm.label.error'].' : '.$lrb['sisiya_adm.'.$formName.'.msg.password_missmatch'].'</h4>'."\n";
		else if(strlen($password1) < $min_password_length) 
			$sql_msg.='<h4>'.$lrb['sisiya_adm.label.error'].' : '.$lrb['sisiya_adm.'.$formName.'.msg.password_length'].' ('.$min_password_length.')</h4>'."\n";
		else {
			if($is_admin == 'f') {
				$sql_str="select password from ".$tableName." where id='".$user_id."'";
				$result=$db->query($sql_str);
				$row_count=$db->getRowCount($result);
				if($row_count == 1) {
					$row=$db->fetchRow($result,0);
					if(checkPasswords($old_password,$row[0]) == false)
						$sql_msg.='<h4>'.$lrb['sisiya_adm.label.error'].' :'.$lrb['sisiya_adm.'.$formName.'.msg.invalid_old_password'].'</h4>'."\n";
					else {
						$sql_str="update ".$tableName." set password='".encryptPassword($password1)."' where id=$userid";
						$n=execSQL($sql_str);
						if($n == 1) 
							$sql_msg.=$action.' : '.$n.' OK.';
					}
				}
				else 
					$sql_msg.="<center><h4>Error : ".$valid_user." was not found in the ".$tableName." table! This should not have happened!<h4></center>\n";
			}
			else {
				$sql_str="update ".$tableName." set password='".encryptPassword($password1)."' where id=$userid";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			}
		}
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';
	return $html;
}

function keystrForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='strkeys';
	$formName=$tableName;
 
	$orderbyarray=array(
		0  => array('key'=>'id','value'=>$lrb['sisiya_adm.label.id']), 
		1  => array('key'=>'keystr','value'=>$lrb['sisiya_adm.'.$formName.'.label.keystr']), 
		2  => array('key'=>'str','value'=>$lrb['sisiya_adm.'.$formName.'.label.str'])
	); 

	$id=getHTTPValue('id');
	$keystr=getHTTPValue('keystr');
	$str=getHTTPValue('str');
	$action=getHTTPValue('button');


	if($action == $lrb['sisiya_adm.button.clear'] || $action == $lrb['sisiya_adm.button.showall']) {
		$id='';
		$keystr='';
		$str='';
	} 
	if($par_orderbyid == '')
		$par_orderbyid=0;

	$select_sql_str='select id,keystr,str from '.$tableName;
	$select_sql_str2='select * from '.$tableName;
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		if(is_numeric($id)) 
			$tmp_str=' where id='.$id;
		else {
			if($keystr != '') {
				if($tmp_str == '') 
					$tmp_str=" where keystr like '%".$keystr."%'";
				else 
					$tmp_str=" and keystr like '%".$keystr."%'";
			}
			if($str != '') {
				if($tmp_str == '') 
					$tmp_str=" where str like '%".$str."%'";
				else 
					$tmp_str.=" and str like '%".$str."%'";
			}
		}
		if($tmp_str != '')
			$select_sql_str.=' '.$tmp_str;

		$result=$db->query($select_sql_str);
		$row_count=$db->getRowCount($result);

		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$id=$row[0];
			$keystr=$row[1];
			$str=$row[2];
		} 
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.id'].'</td>';
	$html.='<td><input type="text" size="10" name="id" value="'.$id.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.keystr'].'</td>';
	$html.='<td><input type="text" size="70" name="keystr" value="'.$keystr.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.str'].'</td>';
	$html.='<td><input type="text" size="70" name="str" value="'.$str.'" /></td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";


	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($id))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($keystr == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.keystr'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($str == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.str'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$tableName." set keystr='".$keystr."',str='".$str."' where id=".$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break; 
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($id))
				$id=getNextID($tableName);
			if(! is_numeric($id)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($keystr == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.keystr'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($str == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.str'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str="insert into ".$tableName." values(".$id.",'".$keystr."','".$str."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			}
			break; 
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($id)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where id='.$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			}
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.id'],'inputName'=>'id','inputValue'=>$id,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.keystr'],'inputName'=>'keystr','inputValue'=>$keystr,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.str'],'inputName'=>'str','inputValue'=>$str,'flag'=>'f')
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function languagesForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='languages';
	$formName=$tableName;
 
	$orderbyarray=array(
		0  => array('key'=>'id','value'=>$lrb['sisiya_adm.label.id']), 
		1  => array('key'=>'code','value'=>$lrb['sisiya_adm.'.$formName.'.label.code']), 
		2  => array('key'=>'str','value'=>$lrb['sisiya_adm.'.$formName.'.label.str']), 
		3  => array('key'=>'charset','value'=>$lrb['sisiya_adm.'.$formName.'.label.charset']) 
	); 
 
	$id=getHTTPValue('id');
	$code=getHTTPValue('code');
	$str=getHTTPValue('str');
	$charset=getHTTPValue('charset');
	$action=getHTTPValue('button');


	if($action == $lrb['sisiya_adm.button.clear'] || $action == $lrb['sisiya_adm.button.showall']) {
		$id='';
		$code='';
		$str='';
		$charset='';
	} 
 
	if($par_orderbyid == '')
		$par_orderbyid=0;

	$select_sql_str='select id,code,str,charset from '.$tableName;
#	$select_sql_str2='select * from '.$tableName;
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		if(is_numeric($id)) 
			$tmp_str=' where id='.$id;
		else {
			if($code != '') {
				if($tmp_str == '') 
					$tmp_str=" where code like '%".$code."%'";
				else 
					$tmp_str=" and code like '%".$code."%'";
			}
			if($str != '') {
				if($tmp_str == '') 
					$tmp_str=" where str like '%".$str."%'";
				else 
					$tmp_str.=" and str like '%".$str."%'";
			}
			if($charset != '') {
				if($tmp_str == '') 
					$tmp_str=" where charset like '%".$charset."%'";
				else 
					$tmp_str.=" and charset like '%".$charset."%'";
			}

		}
		if($tmp_str != '')
			$select_sql_str.=' '.$tmp_str;

		$result=$db->query($select_sql_str);
		$row_count=$db->getRowCount($result);

		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$id=$row[0];
			$code=$row[1];
			$str=$row[2];
			$charset=$row[3];
		} 
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.id'].'</td>';
	$html.='<td><input type="text" size="10" name="id" value="'.$id.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.code'].'</td>';
	$html.='<td><input type="text" size="10" name="code" value="'.$code.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.str'].'</td>';
	$html.='<td><input type="text" size="70" name="str" value="'.$str.'" /></td></tr>'."\n"; 
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.'.$formName.'.label.charset'].'</td>';
	$html.='<td><input type="text" size="70" name="charset" value="'.$charset.'" /></td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";


	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($id))
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($code == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.code'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($str == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.str'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($charset == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.charset'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$tableName." set code='".$code."',str='".$str."',charset='".$charset."' where id=".$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			}
			break; 
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($id))
				$id=getNextID($tableName);
			if(! is_numeric($id)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($code == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.code'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($str == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.str'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($charset == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.'.$formName.'.label.charset'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str="insert into ".$tableName." values(".$id.",'".$code."','".$str."','".$charset."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($id)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.id'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where id='.$id;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			}
			break; 
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.id'],'inputName'=>'id','inputValue'=>$id,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.code'],'inputName'=>'code','inputValue'=>$code,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.str'],'inputName'=>'str','inputValue'=>$str,'flag'=>'f'),
		3 => array('columnLabel'=>$lrb['sisiya_adm.'.$formName.'.label.charset'],'inputName'=>'charset','inputValue'=>$charset,'flag'=>'f')
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;

}

function webinterfaceForm()
{
	global $db,$par_formName,$progName,$par_language,$lrb,$par_start,$par_orderbyid;
	
	$tableName='webinterface';
	$formName=$tableName;
 
	$orderbyarray=array(
		0  => array('key'=>'c.str','value'=>$lrb['sisiya_adm.label.language']), 
		1  => array('key'=>'b.str','value'=>$lrb['sisiya_adm.strkeys.label.keystr']), 
		2  => array('key'=>'a.str','value'=>$lrb['sisiya_adm.label.text']) 
	); 

	$languagename=getHTTPValue('languagename');
	$keystrname=getHTTPValue('keystrname');
	$keystrvalue=getHTTPValue('keystrvalue');

	$languageid=getHTTPValue('languageid');
	$strkeyid=getHTTPValue('strkeyid');
	$action=getHTTPValue('button');

	if($action == $lrb['sisiya_adm.button.clear'] || $action == $lrb['sisiya_adm.button.showall']) {
		$languagename='';
		$keystrname='';
		$keystrvalue='';
		$strkeyid='-';
		$languageid='-';
	}
	if($par_orderbyid == '')
		$par_orderbyid=0;
 
	$select_sql_str='select c.str,b.str,a.str from '.$tableName.' a,strkeys b,languages c where a.languageid=c.id and a.strkeyid=b.id';
	$select_sql_str2='select a.* from '.$tableName.' a,strkeys b,languages c where a.languageid=c.id and a.strkeyid=b.id';
	if($action == $lrb['sisiya_adm.button.find']) {
		$tmp_str='';
		$tmp_str2='';
		if(is_numeric($strkeyid)) 
			$tmp_str=' and a.strkeyid='.$strkeyid;
		if(is_numeric($languageid))
			$tmp_str.=' and a.languageid='.$languageid;
		if($keystrname != '')
			$tmp_str.=" and b.str='".$keystrname."'";
		if($languagename != '')
			$tmp_str.=" and c.str='".$languagename."'";
		if($keystrvalue != '') {
			if($strkeyid == '-')
				$tmp_str.=" and a.str like '%".$keystrvalue."%'";
		}
		if($tmp_str != '') {
			$select_sql_str.=' '.$tmp_str;
			$select_sql_str2.=' '.$tmp_str;
		}
		$result=$db->query($select_sql_str2);
		$row_count=$db->getRowCount($result);
		if($row_count == 1) {
			$row=$db->fetchRow($result,0);
			$languageid=$row[0];
			$strkeyid=$row[1];
			$keystrvalue=$row[2];
		}
	}
	$select_sql_str.=' order by '.$orderbyarray[$par_orderbyid]['key'];

	$html='<form action="'.$progName.'?par_formName='.$par_formName.'&amp;par_language='.$par_language.'&amp;par_start='.$par_start.'&amp;par_orderbyid='.$par_orderbyid.'" method="post">'."\n";
	#input fields
	$html.='<table class="form">'."\n";
	$html.='<caption class="form">'.$lrb['sisiya_adm.'.$formName.'.header']."</caption>\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.language'].'</td>'."\n";

	$result=$db->query('select str,id from languages order by str');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="languageid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($languageid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($languagename != '' && $languagename == $row[0])
				$html.='selected="selected" ';
			else if($row[1] == $languageid) {
				$html.='selected="selected" ';
				$languagename=$row[0];
			}
			$html.='value="'.$row[1].'">'.$row[0]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";

	$html.='<tr><td class="label">'.$lrb['sisiya_adm.strkeys.label.keystr'].'</td>'."\n";
	#$result=$db->query('select str,id from strkeys a order by str');
	# show the English text if any, otherwise show the strkey's text
	$result=$db->query('select a.str,a.id,b.str,a.keystr from strkeys a left outer join webinterface b on (a.id=b.strkeyid and b.languageid=0) order by a.str');
	$row_count=$db->getRowCount($result);	
	$html.='<td><select name="strkeyid">'."\n"; 
	$html.='<option ';
	if(! is_numeric($strkeyid))
		$html.='selected="selected" ';
	$html.='value="-">-'."</option>\n";
	if($row_count > 0) {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$html.='<option ';
			if($keystrname != '' && $keystrname == $row[0])
				$html.='selected="selected" ';
			if($row[1] == $strkeyid) {
				$html.='selected="selected" ';
				$keystrname=$row[0];
			}
			if($row[2] != '')
				$html.='value="'.$row[1].'">'.$row[0].': '.$row[2]."</option>\n";
			else 
				$html.='value="'.$row[1].'">'.$row[2]."</option>\n";
		}
	}
	$html.='</select></td></tr>'."\n";
	$html.='<tr><td class="label">'.$lrb['sisiya_adm.label.text'].'</td>'."\n";
	$html.='<td><input type="text" size="70" name="keystrvalue" value="'.$keystrvalue.'" /></td></tr>'."\n"; 

	$html.='<tr><td colspan="2" align="center">'."\n";

	$buttons=array(
			0=>$lrb['sisiya_adm.button.clear'],
			1=>$lrb['sisiya_adm.button.showall'],
			2=>$lrb['sisiya_adm.button.find'],
			3=>$lrb['sisiya_adm.button.update'],
			4=>$lrb['sisiya_adm.button.add'],
			5=>$lrb['sisiya_adm.button.delete']
		);

	$html.=getButtons($par_formName,$buttons);
	$html.='</td></tr></table>'."\n";
	$html.='</form>'."\n";

	$sql_msg='';
	switch($action) {
		case $lrb['sisiya_adm.button.update']:
			if(! is_numeric($languageid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.language'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if(! is_numeric($strkeyid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.strkeys.label.keystr'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else if($keystrvalue == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.text'].' for '.$lrb['sisiya_adm.button.update'].' operation!</h4>'."\n";
			else {
				$sql_str="update ".$tableName." set str='".$keystrvalue."' where languageid=".$languageid." and strkeyid=".$strkeyid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
			} 
			break;
		case $lrb['sisiya_adm.button.add']:
			if(! is_numeric($languageid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.language'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if(! is_numeric($strkeyid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.strkeys.label.keystr'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else if($keystrvalue == '') 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.text'].' for '.$lrb['sisiya_adm.button.add'].' operation!</h4>'."\n";
			else {
				$sql_str='insert into '.$tableName.' values('.$languageid.','.$strkeyid.",'".$keystrvalue."')";
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
		case $lrb['sisiya_adm.button.delete']:
			if(! is_numeric($languageid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.label.language'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else if(! is_numeric($strkeyid)) 
				$sql_msg.='<h4>Error : You must specify '.$lrb['sisiya_adm.strkeys.label.keystr'].' for '.$lrb['sisiya_adm.button.delete'].' operation!</h4>'."\n";
			else {
				$sql_str='delete from '.$tableName.' where strkeyid='.$strkeyid.' and languageid='.$languageid;
				$n=execSQL($sql_str);
				if($n == 1) 
					$sql_msg.=$action.' : '.$n.' OK.';
				else
					$sql_msg.=$action.' : '.$n.' '.$lrb['sisiya_adm.label.failed'];
			} 
			break;
	}
	if($sql_msg != '')
		$html.='<table class="sql_msg"><tr><td>'.$sql_msg.'</td></tr></table>';

	$fields=array(
		0 => array('columnLabel'=>$lrb['sisiya_adm.label.language'],'inputName'=>'languagename','inputValue'=>$languagename,'flag'=>'f'),
		1 => array('columnLabel'=>$lrb['sisiya_adm.strkeys.label.keystr'],'inputName'=>'keystrname','inputValue'=>$keystrname,'flag'=>'f'),
		2 => array('columnLabel'=>$lrb['sisiya_adm.label.text'],'inputName'=>'keystrvalue','inputValue'=>$keystrvalue,'flag'=>'f')
	);

	if($action == $lrb['sisiya_adm.button.find'] || $action == $lrb['sisiya_adm.button.showall'])
		$html.=getTable($select_sql_str,-1,$fields,$par_start,10,$orderbyarray,$action);
	return $html;
}

function isForAdmins($formName)
{
	global $ma;

	### find the form in the array
	$menuCount=count($ma);
	for($i=0;$i<$menuCount;$i++) {
		$subCount=count($ma[$i]['submenu']);
		for($j=0;$j<$subCount;$j++) 
			if($ma[$i]['submenu'][$j]['formName'] == $formName) {
				if($ma[$i]['submenu'][$j]['foradmins'] == 't')
					return true;
				else
					return false;
			}
	}
	return false;
}
########################################################################################################################################
### end of Functions
########################################################################################################################################

###################################################################################
### valid_user contains the username value from the users table
### If it is set, then user_id, user_name, user_surname and is_admin parameters are also set.
if(! isset($_SESSION['valid_user'])) {
	loginForm($progName,$sessionName);
	exit();
}

$user_name=$_SESSION['user_name'];
$user_surname=$_SESSION['user_surname'];
$valid_user=$_SESSION['valid_user'];
$user_id=$_SESSION['user_id'];
$is_admin=$_SESSION['is_admin'];

$par_orderbyid=getHTTPValue('par_orderbyid');
$par_start=getHTTPValue('par_start');

$par_formName=getHTTPValue('par_formName');
## the par_formName is not defined after sucessfull login
if($par_formName == '') {
	if($is_admin == 'f')
		$par_formName='change_password';
	else
		$par_formName='status';
}

### read language info from $_SESSION
initLanguage();

if($par_formName == 'logout') {
	$par_formName='login';
	if(isset($_SESSION['valid_user']))
		unset($_SESSION['valid_user']);
	loginForm($progName,$sessionName);
	exit;
}

### check if the user tries to specify a form id which he does not have access to
if($is_admin == 'f' && isForAdmins($par_formName))
	$par_formName='change_password';
if($par_formName == 'test') {
	$par_formName='change_password';
}

$_SESSION['activeForm']=$par_formName;
collapseMenu();
	

$refresh=0; ### do not refresh
$html=getDocHeader(basename($progName),$_SESSION['charset'],$refresh);
$html.=getAdmFormHeader($par_formName);

$html.='<table class="layout">'."\n";
$html.='<tr><td valign="top">'."\n";
$html.=getMenu();
$html.='</td>';
$html.='<td valign="top">'."\n";

switch($par_formName) {
	case 'status' :
	case 'services' :
	case 'systemtypes' :
	case 'alerttypes' :
	case 'properties' :
		$html.=idstrForm($par_formName);
		break;
	case 'infos' :
	case 'locations' :
		$html.=id_sortid_str_Form($par_formName);
		break;
	case 'languages' :
		$html.=languagesForm();
		break;
		break;
	case 'strkeys' :
		$html.=keystrForm();
		break;
	case 'webinterface' :
		$html.=webinterfaceForm();
		break;
	case 'users' :
		$html.=SisIYAUsersForm();
		break;
	case 'systems' :
		$html.=systemsForm();
		break;
	case 'systeminfo' :
		$html.=systeminfoForm();
		break;
	case 'systemservice' :
		$html.=systemserviceForm();
		break;
	case 'systemstatus' :
		$html.=systemstatusForm();
		break;
	case 'systemservicestatus' :
		$html.=systemservicestatusForm();
		break;
	case 'change_password' :
		$html.=changePasswordForm();
		break;
	case 'groups' :
		$html.=groupsForm();
		break;
	case 'groupsystem' :
		$html.=groupsystemForm();
		break;
	case 'usersystemalert' :
		$html.=usersystemalertForm();
		break;
	case 'usersystemservicealert' :
		$html.=usersystemservicealertForm();
		break;
	case 'sendmessage' :
		$html.=sendSisIYAMessageForm();
		break;
	case 'userproperties' :
		$html.=userpropertiesForm();
		break;
}

$html.='</td></tr>';
$html.='</table>'."\n";

# free the result
if(isset($result))
	$db->freeResult($result);
# close the db connection  
$db->close(); # this will not have an effect if the connection is persistent

$html.=getSisIYA();
$html.='</body></html>';

### display the form
echo $html;
?>
