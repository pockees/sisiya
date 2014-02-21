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
$table_name='userproperties';
$formName=$table_name.'Form';

$user_id=$_SESSION['user_id'];
if($_SESSION['is_admin'] == 't') { 
	if(isset($_POST['new_user_id']))
		$user_id=$_POST['new_user_id'];
	$table_header_fields=array(
		0=> array('key' => 'u.username',	'label' => $lrb['sisiya_admin.users.label.username']),
		1=> array('key' => 'i.str',		'label' => $lrb['sisiya_admin.properties.label.keystr']), 
		2=> array('key' => 'a.str',		'label' => $lrb['sisiya_admin.user_properties.label.property_value']) 
	);
	$fields=array(
		0 => array('field_name' => 'new_user_id',		'key' => 'a.userid',		'value' => '',	'is_str' => false),
		1 => array('field_name' => 'new_property_id',		'key' => 'a.propertyid',	'value' => '',	'is_str' => false),
		2 => array('field_name' => 'new_property_value',	'key' => 'a.str',		'value' => '',	'is_str' => true)
	);

}
else {
	$table_header_fields=array(
		0 => array('key'=>'i.str',	'label' => $lrb['sisiya_admin.properties.label.keystr']), 
		1 => array('key'=>'a.str',	'label' => $lrb['sisiya_admin.user_properties.label.property_value']) 
	);
	$fields=array(
		0 => array('field_name' => 'new_property_id',		'key' => 'a.propertyid',	'value' => '',	'is_str' => false),
		1 => array('field_name' => 'new_property_value',	'key' => 'a.str',		'value' => '',	'is_str' => true)
	);
}

$nrows=get_setNRows($table_name);
if(isset($_POST['add']))
	execSQLWrapper('add',"insert into ".$table_name." values(".$user_id.",".$_POST['new_property_id'].",'".$_POST['new_property_value']."')");
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i])) {
			if($_SESSION['is_admin'] == 't')
				$user_id=$_POST['user_id'][$i];
			execSQLWrapper('delete',"delete from ".$table_name." where userid=".$user_id." and propertyid=".$_POST['property_id'][$i]);
		}
		else if(isset($_POST['update'][$i])) {
			if($_SESSION['is_admin'] == 't')
				$user_id=$_POST['user_id'][$i];
			execSQLWrapper('update',"update ".$table_name." set str='".$_POST['property_value'][$i]."' where userid=".$user_id." and propertyid=".$_POST['property_id'][$i]);
		}
	}
}
$table_header_parameters='';
processInputs($formName,$fields);
$search_str=generateSearchSQL($fields);
$orderby_id=get_setOrderbyID(count($fields));
$start_index=getStartIndex();
if($_SESSION['is_admin'] == 't') 
	$users=getSQL2SelectArray("select id,concat(name,' ',surname,' (',username,')') from users order by username");
$properties=getSQL2SelectArray("select a.id,c.str from properties a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");
$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters).'<th colspan="3">&nbsp;</th></tr>'."\n";
$html.='<tr class="row">'."\n";
if($_SESSION['is_admin'] == 't') 
	$html.='<td>'.getSelect('new_user_id',getFieldValue($fields,'new_user_id'),$users).'</td>'."\n";
$html.='	<td>'.getSelect('new_property_id',getFieldValue($fields,'new_property_id'),$properties).'</td>'."\n";
$html.='	<td><input class="text" type="text" name="new_property_value" value="'.getFieldValue($fields,'new_property_value').'" /></td>'."\n";
$html.='	<td>'.getButtonIcon('add').'</td>'."\n";
$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
$html.="</tr>\n";
$sql_str="select a.propertyid,a.str,c.id,i.str";
if($_SESSION['is_admin'] == 't') 
	$sql_str.=",u.username,u.name,u.surname,a.userid";
$sql_str.=" from ".$table_name." a,";
$sql_str.="properties c";
$sql_str.=",interface i,strkeys s,languages l";
if($_SESSION['is_admin'] == 't') 
	$sql_str.=",users u";
$sql_str.=" where a.propertyid=c.id ";
if($_SESSION['is_admin'] == 't') 
 	$sql_str.=" and a.userid=u.id";
else
 	$sql_str.=" and a.userid=".$user_id;
### properties - language
$sql_str.=" and c.keystr=s.keystr  and s.id=i.strkeyid   and i.languageid=l.id   and l.code='".$_SESSION['language']."'";
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
				$html.='	<td>';
				$html.='		'.$row[5].' '.$row[6].' ('.$row[4].')';
				$html.='		<input type="hidden" name="user_id['.$i.']" value="'.$row[7].'" />'."\n";
				$html.='	</td>';
			}
			$html.='	<td>';
			$html.='		<input type="hidden" name="property_id['.$i.']" value="'.$row[0].'" />'."\n";
			$html.=$row[3];
			$html.='	</td>';
			$html.='<td><input class="text" type="text" name="property_value['.$i.']" value="'.$row[1].'" /></td>'."\n";
			$html.='<td colspan="2" class="center">'.getButtonIcon('update',$i)."</td>\n";
			$html.='<td>'.getButtonIcon('delete',$i)."</td>\n";
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
