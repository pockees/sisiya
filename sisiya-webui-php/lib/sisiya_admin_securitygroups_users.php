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
if($_SESSION['is_admin'] == 'f') 
       return;	
$html='';
$table_name='securitygroupuser';
$formName=$table_name.'Form';

$table_header_fields=array(
	0  => array('key' => 'a.securitygroupid',	'label' => $lrb['sisiya_admin.securitygroups.label.keystr']), 
	1  => array('key' => 'a.userid',		'label' => $lrb['sisiya_admin.users.label.username'])
);
$fields=array(
	0 => array('field_name' => 'new_securitygroup_id',	'key' => 'a.securitygroupid', 	'value' => '', 'is_str' => false),
	1 => array('field_name' => 'new_user_id',		'key' => 'a.userid', 		'value' => '', 'is_str' => false)
);
$nrows=get_setNRows($table_name);

if(isset($_POST['add'])) {
	execSQLWrapper('add',"insert into ".$table_name." values(".$_POST['new_securitygroup_id'].",".$_POST['new_user_id'].")");
	#if($_POST['new_securitygroup_id'] == 0)
	#	$_SESSION['hasAllSystems']=true;
}
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i])) {
			execSQLWrapper('delete','delete from '.$table_name.' where securitygroupid='.$_POST['securitygroup_id'][$i].' and userid='.$_POST['user_id'][$i]);
			#if($_POST['new_securitygroup_id'] == 0)
			#	$_SESSION['hasAllSystems']=false;
		}
	}
}
$table_header_parameters='';
processInputs($formName,$fields);
$search_str=generateSearchSQL($fields);
$orderby_id=get_setOrderbyID(count($fields));
$start_index=getStartIndex();
$securitygroups=getSQL2SelectArray("select a.id,c.str from securitygroups a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");
$users=getSQL2SelectArray("select id,concat(name,' ',surname,' (',username,')') from users order by username");

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters).'<th colspan="3">&nbsp;</th></tr>'."\n";
$html.='<tr class="row">'."\n";
$html.='	<td>'.getSelect('new_securitygroup_id',getFieldValue($fields,'new_securitygroup_id'),$securitygroups)."</td>\n";
$html.='	<td>'.getSelect('new_user_id',getFieldValue($fields,'new_user_id'),$users)."</td>\n";
$html.='	<td>'.getButtonIcon('add').'</td>'."\n";
$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
$html.="</tr>";
#			0		1	2	3	4	5	
$sql_str="select a.securitygroupid,a.userid,i.str,c.username,c.name,c.surname from securitygroupuser a,securitygroups b,users c,strkeys s,interface i,languages l";
$sql_str.=" where a.securitygroupid=b.id and a.userid=c.id ";
$sql_str.=" and b.keystr=s.keystr and l.code='".$_SESSION['language']."' ";
$sql_str.=" and l.id=i.languageid and i.strkeyid=s.id ".$search_str." order by ".$table_header_fields[$orderby_id]['key'].' '.$_SESSION['asc_desc'];
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
			$html.='		<input type="hidden" name="securitygroup_id['.$i.']" value="'.$row[0].'" />'."\n";	
			$html.='		<input type="hidden" name="user_id['.$i.']" value="'.$row[1].'" />'."\n";	
			$html.='		<input class="text readonly" readonly="readonly" type="text" name="" value="'.$row[2].'" />'."\n";
			$html.="	</td>\n";
			$html.='	<td>	'.$row[4].' '.$row[5].' ('.$row[3].')</td>'."\n";
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
