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
$table_name='groupsystem';
$formName=$table_name.'Form';

$table_header_fields=array(
	0  => array('key'=>'a.groupid',	'label'=>$lrb['sisiya_admin.'.$menu.'.label.group_id']), 
	1  => array('key'=>'a.systemid','label'=>$lrb['sisiya_admin.systems.label.hostname'])
);
$fields=array(
	0 => array('field_name' => 'new_group_id',	'key' => 'a.groupid', 		'value' => '', 'is_str' => false),
	1 => array('field_name' => 'new_system_id',	'key' => 'a.systemid', 		'value' => '', 'is_str' => false)
);

$user_id=$_SESSION['user_id'];
if($_SESSION['is_admin'] == 't') {
	if(isset($_POST['new_user_id']))
		$user_id=$_POST['new_user_id'];
}
$nrows=get_setNRows($table_name);

if(isset($_POST['add']))
	execSQLWrapper('add',"insert into ".$table_name." values(".$_POST['new_group_id'].",".$_POST['new_system_id'].")");
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i])) 
			execSQLWrapper('delete','delete from '.$table_name.' where groupid='.$_POST['group_id'][$i].' and systemid='.$_POST['system_id'][$i]);
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
if($_SESSION['is_admin'] == 't') 
	$groups=getSQL2SelectArray("select a.id,concat(a.str,' (',u.username,')') from groups a,users u where a.userid=u.id and a.languageid=".$_SESSION['language_id']." order by a.str");
else
	$groups=getSQL2SelectArray("select a.id,a.str from groups a where a.userid=".$_SESSION['user_id']." and a.languageid=".$_SESSION['language_id']." order by a.str");

$securitygroups_sql='';
$securitygroups2_sql='';
if(!$_SESSION['hasAllSystems']) { 
	$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	$securitygroups2_sql=' where id in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
}
####################################################################################################################################################
$systems=getSQL2SelectArray('select id,hostname from systems'.$securitygroups2_sql.' order by hostname');

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters).'<th colspan="3">&nbsp;</th></tr>'."\n";
$html.='<tr class="row">'."\n";
$html.='	<td>'.getSelect('new_group_id',getFieldValue($fields,'new_group_id'),$groups)."</td>\n";
$html.='	<td>'.getSelect('new_system_id',getFieldValue($fields,'new_system_id'),$systems)."</td>\n";
$html.='	<td>'.getButtonIcon('add').'</td>'."\n";
$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
$html.="</tr>";
#			0	1	2	3	4	
$sql_str="select a.groupid,a.systemid,b.str,c.hostname,d.username from ".$table_name." a,groups b,systems c,users d";
$sql_str.=" where a.groupid=b.id and a.systemid=c.id and b.userid=d.id and b.languageid=".$_SESSION['language_id'];
if($_SESSION['is_admin'] == 'f') 
	$sql_str.=" and b.userid=".$_SESSION['user_id'];
$sql_str.=$securitygroups_sql.' '.$search_str." order by ".$table_header_fields[$orderby_id]['key'].' '.$_SESSION['asc_desc'];
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
			$html.='		<input type="hidden" name="group_id['.$i.']" value="'.$row[0].'" />'."\n";	
			$html.='		<input type="hidden" name="system_id['.$i.']" value="'.$row[1].'" />'."\n";	
			if($_SESSION['is_admin'] == 't') 
				$group_str=$row[2].' ('.$row[4].')';
			else
				$group_str=$row[2];
			$html.='		<input class="text readonly" readonly="readonly" type="text" name="" value="'.$group_str.'" />'."\n";
			$html.="	</td>\n";
			$html.='	<td><input class="text readonly" readonly="readonly" type="text" name="" value="'.$row[3].'" /></td>'."\n";
			$html.='	<td colspan="3" class="center">'.getButtonIcon('delete',$i)."</td>\n";
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
