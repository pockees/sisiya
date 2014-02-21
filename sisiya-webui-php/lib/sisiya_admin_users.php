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
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

*/
error_reporting(E_ALL);

###########################################################
### begin of functions
### end of functions
###########################################################
$html='';
$table_name='users';
$formName=$table_name.'Form';

if($_SESSION['is_admin'] == 't') { 
	$table_header_fields=array(
		0  => array('key'=>'id',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.id']), 
		1  => array('key'=>'username',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.username']), 
		2  => array('key'=>'name',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.name']), 
		3  => array('key'=>'surname',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.surname']), 
		4  => array('key'=>'email',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.email']), 
		5  => array('key'=>'isadmin',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.isadmin']) 
	);
	$fields=array(
		0 => array('field_name' => 'new_user_id',		'key' => 'id',		'value' => '',	'is_str' => false),
		1 => array('field_name' => 'new_username',		'key' => 'username',	'value' => '',	'is_str' => true),
		2 => array('field_name' => 'new_name',			'key' => 'name',	'value' => '',	'is_str' => true),
		3 => array('field_name' => 'new_surname',		'key' => 'surname',	'value' => '',	'is_str' => true),
		4 => array('field_name' => 'new_email',			'key' => 'email',	'value' => '',	'is_str' => true),
		5 => array('field_name' => 'new_isadmin',		'key' => 'isadmin',	'value' => '',	'is_str' => true)
	);
}
else {
	$table_header_fields=array(
		0  => array('key'=>'name',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.name']), 
		1  => array('key'=>'surname',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.surname']), 
		2  => array('key'=>'email',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.email'])
	);
	$fields=array(
		0 => array('field_name' => 'new_username',		'key' => 'username',	'value' => '',	'is_str' => true),
		1 => array('field_name' => 'new_name',			'key' => 'name',	'value' => '',	'is_str' => true),
		2 => array('field_name' => 'new_surname',		'key' => 'surname',	'value' => '',	'is_str' => true),
		3 => array('field_name' => 'new_email',			'key' => 'email',	'value' => '',	'is_str' => true),
		4 => array('field_name' => 'new_isadmin',		'key' => 'isadmin',	'value' => '',	'is_str' => true)
	);
}
$nrows=get_setNRows($table_name);
$password_str='11111111111';
if(isset($_POST['add'])) {
	if($_POST['new_isadmin'] == '-') 
		$_POST['new_isadmin']='f';
	execSQLWrapper('add',"insert into ".$table_name." values(".getNewID('new_id',$table_name).",'".$_POST['new_username']."','".$password_str."','".$_POST['new_name']."','".$_POST['new_surname']."','".$_POST['new_email']."','".$_POST['new_isadmin']."')");
}
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i]))
			execSQLWrapper('delete','delete from '.$table_name.' where id='.$_POST['id'][$i]);
		else if(isset($_POST['update'][$i])) {
			if($_SESSION['is_admin'] == 't') 
				execSQLWrapper('update',"update ".$table_name." set username='".$_POST['username'][$i]."',name='".$_POST['name'][$i]."',surname='".$_POST['surname'][$i]."',email='".$_POST['email'][$i]."',isadmin='".$_POST['isadmin'][$i]."' where id=".$_POST['id'][$i]);
			else {
				execSQLWrapper('update',"update ".$table_name." set name='".$_POST['name'][$i]."',surname='".$_POST['surname'][$i]."',email='".$_POST['email'][$i]."' where id=".$_SESSION['user_id']);
				$_SESSION['user_name']=$_POST['name'][$i];
				$_SESSION['user_surname']=$_POST['surname'][$i];
			}
		}
	}
}
$table_header_parameters='';
processInputs($formName,$fields);
$search_str=generateSearchSQL($fields);
$orderby_id=get_setOrderbyID(count($fields));
$start_index=getStartIndex();
$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters);
if($_SESSION['is_admin'] == 't') 
	$html.='<th colspan="4">&nbsp;</th>'."\n";
else
	$html.='<th colspan="3">&nbsp;</th>'."\n";
$html.="</tr>\n";
if($_SESSION['is_admin'] == 't') {
	$html.='<tr class="row">'."\n";
	$html.='	<td><input class="id" type="text" name="new_id" value="'.getFieldValue($fields,'new_id').'" /></td>'."\n";
	$html.='	<td><input class="text" type="text" name="new_username" value="'.getFieldValue($fields,'new_username').'" /></td>'."\n";
	$html.='	<td><input class="text" type="text" name="new_name" value="'.getFieldValue($fields,'new_name').'" /></td>'."\n";
	$html.='	<td><input class="text" type="text" name="new_surname" value="'.getFieldValue($fields,'new_surname').'" /></td>'."\n";
	$html.='	<td><input class="text" type="text" name="new_email" value="'.getFieldValue($fields,'new_email').'" /></td>'."\n";
	$html.='	<td>'.getSelect('new_isadmin',getFieldValue($fields,'new_isadmin'),$true_false)."</td>\n";
	$html.='	<td colspan="2">'.getButtonIcon('add').'</td>'."\n";
	$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
	$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
	$html.="</tr>\n";
}


### remove leading and from the $search_str
$search_str=preg_replace('/and /','where ',$search_str,1);

if($_SESSION['is_admin'] == 'f') {
       if($search_str == '')	
		$search_str.=' where ';
       else
		$search_str.=' and ';
      $search_str.=' id='.$_SESSION['user_id'].' ';
}


$sql_str="select id,username,name,surname,email,isadmin from ".$table_name." ";
$sql_str.=$search_str." order by ".$table_header_fields[$orderby_id]['key'].' '.$_SESSION['asc_desc'];

debug('sql_str='.$sql_str);
$result=$db->query($sql_str);
if(!$result)
	errorRecord('select');
else {
	$nrows=$db->getRowCount($result);
	if($nrows > 0) {
		$_SESSION['nrows_'.$table_name]=$nrows;
		for($i=$start_index;$i<$start_index + $nrecords_per_page;$i++) {
			### for the last page
			if($i >= $nrows)
				break;
			$row=$db->fetchRow($result,$i);
			$html.='<tr class="row">'."\n";
			if($_SESSION['is_admin'] == 't') { 
				$html.='	<td><input class="id readonly" readonly="readonly" type="text" name="id['.$i.']" value="'.$row[0].'" /></td>'."\n";
				$html.='	<td><input class="text" type="text" name="username['.$i.']" value="'.$row[1].'" /></td>'."\n";
			}
			$html.='	<td><input class="text" type="text" name="name['.$i.']" value="'.$row[2].'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="surname['.$i.']" value="'.$row[3].'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="email['.$i.']" value="'.$row[4].'" /></td>'."\n";
			if($_SESSION['is_admin'] == 't')
				$html.='	<td>'.getSelect('isadmin['.$i.']',$row[5],$true_false)."</td>\n";
			$html.='	<td colspan="2" class="center">'.getButtonIcon('update',$i)."</td>\n";
			if($_SESSION['is_admin'] == 't')
				$html.='	<td>'.getButtonIcon('delete',$i)."</td>\n";
				$html.='	<td>'.getLinkIcon('password',$progNameSisIYA_Admin.'?menu=change_password')."</td>\n";
			$html.="</tr>\n";
		}
	} 
	$db->freeResult($result);
}
$html.='</table>'."\n";
$h->addContent($html);
include_once($libDir."/sisiya_admin_page_numbers.php");
$h->addContent("</form>\n");
?>
