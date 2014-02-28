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
$table_name='usersystemalert';
$alerttime='19801231145648'; ### initial value
$formName=$table_name.'Form';

$user_id=$_SESSION['user_id'];
if($_SESSION['is_admin'] == 't') { 
	if(isset($_POST['new_user_id']))
		$user_id=$_POST['new_user_id'];
	$table_header_fields=array(
		0 => array('key' => 'u.username',	'label' => $lrb['sisiya_admin.users.label.username']),
		1 => array('key' => 'b.hostname',	'label' => $lrb['sisiya_admin.label.system']), 
		2 => array('key' => 'i.str',		'label' => $lrb['sisiya_admin.label.status']), 
		3 => array('key' => 'i2.str',		'label' => $lrb['sisiya_admin.alerttypes.label.keystr']), 
		4 => array('key' => 'a.enabled',	'label' => $lrb['sisiya_admin.label.isactive']), 
		5 => array('key' => 'a.expire',		'label' => $lrb['sisiya_admin.label.alert_frequency'])
	);
	$fields=array(
		0 => array('field_name' => 'new_user_id',	'key' => 'a.userid', 		'value' => '', 'is_str' => false),
		1 => array('field_name' => 'new_system_id',	'key' => 'a.systemid', 		'value' => '', 'is_str' => false),
		2 => array('field_name' => 'new_status_id',	'key' => 'a.statusid',	 	'value' => '', 'is_str' => false),
		3 => array('field_name' => 'new_alerttype_id',	'key' => 'a.alerttypeid',	'value' => '', 'is_str' => false),
		4 => array('field_name' => 'new_active',	'key' => 'a.enabled', 		'value' => '', 'is_str' => true),
		5 => array('field_name' => 'new_expire',	'key' => 'a.expire', 		'value' => '', 'is_str' => true)
	);
}
else {
	$table_header_fields=array(
		0 => array('key'=>'b.hostname',	'label'=>$lrb['sisiya_admin.label.system']), 
		1 => array('key'=>'i.str',	'label'=>$lrb['sisiya_admin.label.status']), 
		2 => array('key'=>'i2.str',	'label'=>$lrb['sisiya_admin.alerttypes.label.keystr']), 
		3 => array('key'=>'a.enabled',	'label'=>$lrb['sisiya_admin.label.isactive']), 
		4 => array('key'=>'a.expire',	'label'=>$lrb['sisiya_admin.label.alert_frequency'])
	);
	$fields=array(
		0 => array('field_name' => 'new_system_id',	'key' => 'a.systemid', 		'value' => '', 'is_str' => false),
		1 => array('field_name' => 'new_status_id',	'key' => 'a.statusid',	 	'value' => '', 'is_str' => false),
		2 => array('field_name' => 'new_alerttype_id',	'key' => 'a.alerttypeid',	'value' => '', 'is_str' => false),
		3 => array('field_name' => 'new_active',	'key' => 'a.enabled', 		'value' => '', 'is_str' => true),
		4 => array('field_name' => 'new_expire',	'key' => 'a.expire', 		'value' => '', 'is_str' => true)
	);
}

$nrows=get_setNRows($table_name);
if(isset($_POST['add']))
	execSQLWrapper('add',"insert into ".$table_name." values(".$user_id.",".$_POST['new_system_id'].",".$_POST['new_alerttype_id'].",".$_POST['new_status_id'].",'".$_POST['new_active']."',".$_POST['new_expire'].",'".$alerttime."')");
else if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i])) {
			if($_SESSION['is_admin'] == 't')
				$user_id=$_POST['user_id'][$i];
			execSQLWrapper('delete',"delete from ".$table_name." where userid=".$user_id." and systemid=".$_POST['system_id'][$i]." and alerttypeid=".$_POST['alerttype_id'][$i]." and statusid=".$_POST['status_id'][$i]);
		}
		else if(isset($_POST['update'][$i])) {
			if($_SESSION['is_admin'] == 't')
				$user_id=$_POST['user_id'][$i];
			execSQLWrapper('update',"update ".$table_name." set expire=".$_POST['expire'][$i].",enabled='".$_POST['active'][$i]."' where userid=".$user_id." and systemid=".$_POST['system_id'][$i]." and alerttypeid=".$_POST['alerttype_id'][$i]." and statusid=".$_POST['status_id'][$i]);
		}
	}
}
$alert_str=$lrb['sisiya_admin.label.description_alert_frequency'];
$table_header_parameters='';
processInputs($formName,$fields);
$search_str=generateSearchSQL($fields);
$orderby_id=get_setOrderbyID(count($fields));
$start_index=getStartIndex();
if($_SESSION['is_admin'] == 't') 
	$users=getSQL2SelectArray("select id,concat(name,' ',surname,' (',username,')') from users order by username");
$securitygroups_sql='';
$securitygroups2_sql='';
if(!$_SESSION['hasAllSystems']) { 
	$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	$securitygroups2_sql=' where id in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
}
####################################################################################################################################################
$systems=getSQL2SelectArray('select id,hostname from systems'.$securitygroups2_sql.' order by hostname');
$status=getSQL2SelectArray("select a.id,c.str from status a,strkeys b,interface c,languages d where a.id in (1,2,4,8,16,32,64,128,256,512) and a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");
$alert_types=getSQL2SelectArray("select a.id,c.str from alerttypes a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters).'<th colspan="3">&nbsp;</th></tr>'."\n";
$html.='<tr class="row">'."\n";
if($_SESSION['is_admin'] == 't') 
	$html.='	<td>'.getSelect('new_user_id',getFieldValue($fields,'new_user_id'),$users).'</td>';

$html.='	<td>'.getSelect('new_system_id',getFieldValue($fields,'new_system_id'),$systems).'</td>'."\n";
$html.='	<td>'.getSelect('new_status_id',getFieldValue($fields,'new_status_id'),$status).'</td>'."\n";
$html.='	<td>'.getSelect('new_alerttype_id',getFieldValue($fields,'new_alerttype_id'),$alert_types)."</td>\n";
$html.='	<td>'.getSelect('new_active',getFieldValue($fields,'new_active'),$true_false)."</td>\n";
$html.='	<td><input class="id" type="text" name="new_expire" value="'.getFieldValue($fields,'new_expire').'"'.' onmouseover="window.status='."'".$alert_str."'; return true;".'" onmouseout="window.status='."'';".'" title="'.$alert_str.'" /></td>'."\n";
$html.='	<td>'.getButtonIcon('add').'</td>'."\n";
$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
$html.="</tr>\n";
#		      0		1		2	3	4	5	     6	    7	 8	9
$sql_str="select a.systemid,a.alerttypeid,a.statusid,a.enabled,a.expire,b.hostname,i.str,i2.str,d.str,u.username,";
$sql_str.="u.name,u.surname,c.id,a.userid";
$sql_str.=" from ".$table_name." a,";
$sql_str.="systems b,status c,systemtypes d,alerttypes e,users u,";
$sql_str.="interface i,strkeys s,languages l,interface i2,strkeys s2,languages l2";
$sql_str.=" where a.systemid=b.id and b.systemtypeid=d.id and a.statusid=c.id and a.alerttypeid=e.id and a.userid=u.id";
if($_SESSION['is_admin'] == 'f') 
	$sql_str.=" and a.userid=".$_SESSION['user_id'];
### status - language
$sql_str.=" and c.keystr=s.keystr  and s.id=i.strkeyid   and i.languageid=l.id   and l.code='".$_SESSION['language']."'";
### alertype - language
$sql_str.=" and e.keystr=s2.keystr and s2.id=i2.strkeyid and i2.languageid=l2.id and l2.code=l.code ";
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
			if($_SESSION['is_admin'] == 't')
				$html.='	<td>'.$row[10].' '.$row[11].' ('.$row[9].')'."</td>\n";
			$html.='	<td><img height="25" src="'.getSystemTypeImage($row[8]).'" alt="'.$row[8].'" />&nbsp;'.$row[5]."</td>\n";
			$html.='	<td class="center"><img src="'.getStatusImage($row[12]).'" alt="'.$statusNames[$row[12]].'" /></td>'."\n";
			$html.="	<td>\n";
			$html.='		<input type="hidden" name="user_id['.$i.']" value="'.$row[13].'" />'."\n";	
			$html.='		<input type="hidden" name="system_id['.$i.']" value="'.$row[0].'" />'."\n";	
			$html.='		<input type="hidden" name="alerttype_id['.$i.']" value="'.$row[1].'" />'."\n";	
			$html.='		<input type="hidden" name="status_id['.$i.']" value="'.$row[2].'" />'."\n";	
			$html.=$row[7];
			$html.="	</td>\n";
			$html.='	<td>'.getSelect('active['.$i.']',$row[3],$true_false)."</td>\n";
			$html.='	<td><input class="id" type="text" name="expire['.$i.']" value="'.$row[4].'" onmouseover="window.status='."'".$alert_str."'; return true;".'" onmouseout="window.status='."'';".'" title="'.$alert_str.'" /></td>'."\n";
			$html.='	<td colspan="2" class="center">'.getButtonIcon('update',$i)."</td>\n";
			$html.='	<td>'.getButtonIcon('delete',$i).'</td>'."\n";
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
