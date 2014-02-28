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

### begin of functions
### end of functions
###########################################################
$html='';
$table_name='systeminfo';
$formName=$table_name.'Form';

### table header fields
$table_header_fields=array(
	0  => array('key'=>'b.hostname',	'label'=>$lrb['sisiya_admin.systems.label.hostname']), 
	1  => array('key'=>'i.str',		'label'=>$lrb['sisiya_admin.'.$menu.'.label.info_name']), 
	2  => array('key'=>'a.str',		'label'=>$lrb['sisiya_admin.'.$menu.'.label.info_value']) 
);

$fields=array(
	0 => array('field_name' => 'new_system_id',	'key' => 'a.systemid', 		'value' => '', 'is_str' => false),
	1 => array('field_name' => 'new_info_id',	'key' => 'a.infoid',	 	'value' => '', 'is_str' => false),
	2 => array('field_name' => 'new_info_value',	'key' => 'a.str', 		'value' => '', 'is_str' => true)
);
$nrows=get_setNRows($table_name);

if(isset($_POST['add']))
	execSQLWrapper('add',"insert into ".$table_name." values(".$_POST['new_system_id'].",".$_POST['new_info_id'].",".$_SESSION['language_id'].",'".$_POST['new_info_value']."')");
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i]))
			execSQLWrapper('delete',"delete from ".$table_name." where systemid=".$_POST['system_id'][$i]." and infoid=".$_POST['info_id'][$i]." and languageid=".$_SESSION['language_id']);
		else if(isset($_POST['update'][$i]))
			execSQLWrapper('update',"update ".$table_name." set str='".$_POST['info_value'][$i]."' where systemid=".$_POST['system_id'][$i]." and infoid=".$_POST[
'info_id'][$i]." and languageid=".$_SESSION['language_id']);
		}
}
$table_header_parameters='';
processInputs($formName,$fields);
$search_str=generateSearchSQL($fields);
$orderby_id=get_setOrderbyID(count($fields));
$start_index=getStartIndex();

$securitygroups_sql='';
$securitygroups2_sql='';
if(!$_SESSION['hasAllSystems']) { 
	$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	$securitygroups2_sql=' where id in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
}
####################################################################################################################################################
$systems=getSQL2SelectArray('select id,hostname from systems'.$securitygroups2_sql.' order by hostname');
$system_infos=getSQL2SelectArray("select a.id,c.str from infos a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");

$active=getFieldValue($fields,'active');
$effectsglobal=getFieldValue($fields,'effectsglobal');

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='	<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters);
if($_SESSION['is_admin'] == 't') 
	$html.='		<th colspan="3">&nbsp;</th>'."\n";
$html.="	</tr>\n";
if($_SESSION['is_admin'] == 't') { 
	$html.='<tr class="row">'."\n";
	$html.='	<td>'.getSelect('new_system_id',getFieldValue($fields,'new_system_id'),$systems).'</td>';
	$html.='	<td>'.getSelect('new_info_id',getFieldValue($fields,'new_info_id'),$system_infos).'</td>';
	$html.='	<td><input class="text" type="text" name="new_info_value" value="'.getFieldValue($fields,'new_info_value').'" /></td>';
	$html.='	<td>'.getButtonIcon('add').'</td>';
	$html.='	<td>'.getButtonIcon('search').'</td>';
	$html.='	<td>'.getButtonIcon('clear').'</td>';
	$html.="</tr>\n";
}

#			0	1	2	3	4    5		
$sql_str="select a.systemid,a.infoid,b.hostname,i.str,a.str,d.str from ".$table_name." a,systems b,infos c,systemtypes d,";
$sql_str.="interface i,strkeys s,languages l where a.systemid=b.id and b.systemtypeid=d.id and a.infoid=c.id";
$sql_str.=$securitygroups_sql." and c.keystr=s.keystr and l.code='".$_SESSION['language']."' ";
$sql_str.=" and l.id=i.languageid and a.languageid=i.languageid and i.strkeyid=s.id ".$search_str." order by ".$table_header_fields[$orderby_id]['key'].' '.$_SESSION['asc_desc'];
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
			$html.='	<td>';
			$html.='		<input type="hidden" name="system_id['.$i.']" value="'.$row[0].'" />';	
			$html.='		<input type="hidden" name="info_id['.$i.']" value="'.$row[1].'" />';	
			$html.='		<img height="25" src="'.getSystemTypeImage($row[5]).'" alt="'.$row[2].'" />&nbsp;'.$row[2];
			$html.='	</td>';
			$html.='	<td>'.$row[3].'</td>';
			$html.='	<td><input class="text" type="text" name="info_value['.$i.']" value="'.$row[4].'" /></td>';
			if($_SESSION['is_admin'] == 't') { 
				$html.='	<td colspan="2" class="center">'.getButtonIcon('update',$i).'</td>';
				$html.='	<td>'.getButtonIcon('delete',$i).'</td>';
			}
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
