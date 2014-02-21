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
###########################################################
###########################################################
### end of functions
###########################################################
$html='';
$table_name=getHTTPValue('table');
$formName=$table_name.'Form';

$table_header_fields=array(
	0 => array('key' => 'id',	'label' => $lrb['sisiya_admin.'.$table_name.'.label.id']),
	1 => array('key' => 'str',	'label' => $lrb['sisiya_admin.'.$table_name.'.label.str'])
);
$fields=array(
	0 => array('field_name' => 'new_id',	'key' => 'id', 		'value' => '', 'is_str' => false),
	1 => array('field_name' => 'new_str',	'key' => 'str', 	'value' => '', 'is_str' => true)
);

$nrows=get_setNRows($table_name);

if(isset($_POST['add']))
	execSQLWrapper('add',"insert into ".$table_name." values(".getNewID('new_id',$table_name).",'".$_POST['new_str']."')");
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i]))
			execSQLWrapper('delete','delete from '.$table_name.' where id='.$_POST['id'][$i]);
		else if(isset($_POST['update'][$i]))
			execSQLWrapper('update','update '.$table_name." set str='".$_POST['str'][$i]."' where id=".$_POST['id'][$i]);
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
	$html.='<th colspan="3">&nbsp;</th>';
$html.="</tr>";
if($_SESSION['is_admin'] == 't') {
	$html.='<tr class="row">'."\n";
	$html.='	<td><input class="id" type="text" name="new_id" value="'.getFieldValue($fields,'new_id').'" /></td>'."\n";
	$html.='	<td><input class="text" type="text" name="new_str" value="'.getFieldValue($fields,'new_str').'" /></td>'."\n";
	$html.='	<td>'.getButtonIcon('add').'</td>'."\n";
	$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
	$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
	$html.="</tr>\n";
}
### remove leading and from the $search_str
$search_str=preg_replace('/and /','where ',$search_str,1);

$sql_str='select id,str from '.$table_name.$search_str.' order by '.$table_header_fields[$orderby_id]['key'].' '.$_SESSION['asc_desc'];
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
			$html.='	<td><input class="text" type="text" name="str['.$i.']" value="'.$row[1].'" /></td>'."\n";
			if($_SESSION['is_admin'] == 't') {
				$html.='	<td colspan="2" class="center">'.getButtonIcon('update',$i).'</td>'."\n";
				$html.='	<td>'.getButtonIcon('delete',$i).'</td>'."\n";
			}
			$html.="</tr>\n";
		}
	} 
	$db->freeResult($result);
}
$html.="</table>\n";
$h->addContent($html);
include_once($libDir."/sisiya_admin_page_numbers.php");
$h->addContent("</form>\n");
?>
