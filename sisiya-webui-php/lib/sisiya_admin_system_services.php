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
$table_name='systemservice';
$formName=$table_name.'Form';

$table_header_fields=array(
	0=> array('key'=>'b.hostname',	'label'=>$lrb['sisiya_admin.label.system']), 
	1=> array('key'=>'i.str',	'label'=>$lrb['sisiya_admin.label.service']), 
	2=> array('key'=>'a.active',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.isactive']), 
	3=> array('key'=>'a.starttime',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.starttime']), 
	4=> array('key'=>'a.str',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.str']) 
);
$fields=array(
	0 => array('field_name' => 'new_system_id',	'key' => 'a.systemid', 		'value' => '', 'is_str' => false),
	1 => array('field_name' => 'new_service_id',	'key' => 'a.serviceid',	 	'value' => '', 'is_str' => false),
	2 => array('field_name' => 'new_active',	'key' => 'a.active', 		'value' => '', 'is_str' => true),
	3 => array('field_name' => 'new_starttime',	'key' => 'a.starttime', 	'value' => '', 'is_str' => true),
	4 => array('field_name' => 'new_str',		'key' => 'a.str', 		'value' => '', 'is_str' => true)
);

$nrows=get_setNRows($table_name);

if(isset($_POST['add']))
	execSQLWrapper('add',"insert into ".$table_name." values(".$_POST['new_system_id'].",".$_POST['new_service_id'].",".$_SESSION['language_id'].",'".$_POST['new_active']."','".$_POST['new_starttime']."','".$_POST['new_str']."')");
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i]))
			execSQLWrapper('delete',"delete from ".$table_name." where systemid=".$_POST['system_id'][$i]." and serviceid=".$_POST['service_id'][$i]." and languageid=".$_SESSION['language_id']);
		else if(isset($_POST['update'][$i]))
			execSQLWrapper('update',"update ".$table_name." set str='".$_POST['str'][$i]."',starttime='".$_POST['starttime'][$i]."',active='".$_POST['active'][$i]."' where systemid=".$_POST['system_id'][$i]." and serviceid=".$_POST['service_id'][$i]);
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
	$securitygroups_sql=' and a.systemid 	in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	$securitygroups2_sql=' where id 	in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
}
####################################################################################################################################################
$systems=getSQL2SelectArray('select id,hostname from systems'.$securitygroups2_sql.' order by hostname');
$services=getSQL2SelectArray("select a.id,c.str from services a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters);
if($_SESSION['is_admin'] == 't') 
	$html.='<th colspan="3">&nbsp;</th>';
$html.="</tr>";
if($_SESSION['is_admin'] == 't') {
	$html.='<tr class="row">'."\n";
	$html.='	<td>'.getSelect('new_system_id',getFieldValue($fields,'new_system_id'),$systems).'</td>'."\n";
	$html.='	<td>'.getSelect('new_service_id',getFieldValue($fields,'new_service_id'),$services).'</td>'."\n";
	$html.='	<td>'.getSelect('new_active',getFieldValue($fields,'new_active'),$true_false).'</td>'."\n";
	$html.='	<td><input class="text" type="text" name="new_starttime" value="'.getFieldValue($fields,'new_starttime').'" /></td>'."\n";
	$html.='	<td><input class="text" type="text" name="new_str" value="'.getFieldValue($fields,'new_str').'" /></td>'."\n";
	$html.='	<td>'.getButtonIcon('add').'</td>'."\n";
	$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
	$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
	$html.="</tr>\n";
}
#			0	1	   2	    3	   4	 5	    6	     7	
$sql_str="select a.systemid,a.serviceid,b.hostname,i.str,a.str,a.active,a.starttime,d.str from ".$table_name." a,";
$sql_str.="systems b,services c,systemtypes d,";
$sql_str.="interface i,strkeys s,languages l ";
$sql_str.="where a.systemid=b.id ".$securitygroups_sql." and b.systemtypeid=d.id and a.serviceid=c.id and ";
### service - language
$sql_str.="c.keystr=s.keystr  and s.id=i.strkeyid   and i.languageid=l.id   and l.code='".$_SESSION['language']."' ";
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
			$html.="	<td>\n";
			$html.='		<input type="hidden" name="system_id['.$i.']" value="'.$row[0].'" />'."\n";	
			$html.='		<input type="hidden" name="service_id['.$i.']" value="'.$row[1].'" />'."\n";	
			$html.='		<img height="25" src="'.getSystemTypeImage($row[7]).'" alt="'.$row[7].'" />&nbsp;'.$row[2]."\n";
			$html.="	</td>\n";
			$html.='	<td>'.$row[3].'</td>'."\n";
			$html.='	<td>'.getSelect('active['.$i.']',$row[5],$true_false).'</td>'."\n";
			$html.='	<td><input class="text" type="text" name="starttime['.$i.']" value="'.$row[6].'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="str['.$i.']" value="'.$row[4].'" /></td>'."\n";
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
