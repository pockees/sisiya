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

###########################################################
### begin of functions
### end of functions
###########################################################
$html='';
$table_name='groups';
$formName=$table_name.'Form';

$table_header_fields=array(
	0  => array('key' => 'a.id',		'label' => $lrb['sisiya_admin.'.$menu.'.label.group_id']), 
	1  => array('key' => 'a.sortid',	'label' => $lrb['sisiya_admin.label.sortid']),
	2  => array('key' => 'a.str',		'label' => $lrb['sisiya_admin.'.$menu.'.label.group_name']) 
);
$fields=array(
	0 => array('field_name' => 'new_id',		'key' => 'a.id', 		'value' => '', 'is_str' => false),
	1 => array('field_name' => 'new_sort_id',	'key' => 'a.id',	 	'value' => '', 'is_str' => false),
	2 => array('field_name' => 'new_str',		'key' => 'a.str', 		'value' => '', 'is_str' => true)
);

$user_id=$_SESSION['user_id'];
if($_SESSION['is_admin'] == 't') {
	if(isset($_POST['new_user_id']))
		$user_id=$_POST['new_user_id'];
	array_push($table_header_fields,array('key'=>'a.userid','label'=>$lrb['sisiya_admin.users.label.username'])); 
}
$nrows=get_setNRows($table_name);

if(isset($_POST['add']))
	execSQLWrapper('add',"insert into ".$table_name." values(".getNewID('new_id',$table_name).",".$_SESSION['language_id'].",".$user_id.",".$_POST['new_sort_id'].",'".$_POST['new_str']."')");
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i]))
			execSQLWrapper('delete','delete from '.$table_name.' where id='.$_POST['id'][$i]);
		else if(isset($_POST['update'][$i])) {
			if($_SESSION['is_admin'] == 't')
				$user_id=$_POST['user_id'][$i];
			execSQLWrapper('update',"update ".$table_name." set str='".$_POST['str'][$i]."',sortid=".$_POST['sort_id'][$i].",userid=".$user_id." where id=".$_POST['id'][$i]." and languageid=".$_SESSION['language_id']);
		}
	}
}
$table_header_parameters='';
processInputs($formName,$fields);
$search_str=generateSearchSQL($fields);
$orderby_id=get_setOrderbyID(count($fields));
$start_index=getStartIndex();
$users=getSQL2SelectArray("select id,concat(name,' ',surname,' (',username,')') from users order by username");

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters).'<th colspan="3">&nbsp;</th></tr>'."\n";
$html.='<tr class="row">'."\n";
$html.='	<td><input class="id" type="text" name="new_id" value="'.getFieldValue($fields,'new_id').'" /></td>'."\n";
$html.='	<td><input class="id" type="text" name="new_sort_id" value="'.getFieldValue($fields,'new_sort_id').'" /></td>'."\n";
$html.='	<td><input class="text" type="text" name="new_str" value="'.getFieldValue($fields,'new_str').'" /></td>'."\n";
if($_SESSION['is_admin'] == 't') 
	$html.='	<td>'.getSelect('new_user_id',getFieldValue($fields,'new_user_id'),$users)."</td>\n";
$html.='	<td>'.getButtonIcon('add').'</td>'."\n";
$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
$html.="</tr>";
#		   0	1	2	3	
$sql_str="select a.id,a.sortid,a.str,a.userid from ".$table_name." a,users b";
$sql_str.=" where  a.userid=b.id and a.languageid=".$_SESSION['language_id'];
if($_SESSION['is_admin'] == 'f')
	$sql_str.=" and a.userid=".$user_id;
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
			$html.='	<td><input class="id readonly" readonly="readonly" type="text" name="id['.$i.']" value="'.$row[0].'" /></td>'."\n";
			$html.='	<td><input class="id" type="text" name="sort_id['.$i.']" value="'.$row[1].'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="str['.$i.']" value="'.$row[2].'" /></td>'."\n";
			if($_SESSION['is_admin'] == 't') 
				$html.='	<td>'.getSelect('user_id['.$i.']',$row[3],$users)."</td>\n";
			$html.='	<td colspan="2" class="center">'.getButtonIcon('update',$i)."</td>\n";
			$html.='	<td>'.getButtonIcon('delete',$i)."</td>\n";
			$html.="</tr>\n";
		}
	} 
	$db->freeResult($result);
}
$html.="</table>\n";
$html.="</div> <!-- end of div_right -->\n";
$h->addContent($html);
include_once($libDir."/sisiya_admin_page_numbers.php");
$h->addContent("</form>\n");
?>
