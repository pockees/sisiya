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
$table_name='systemstatus';
$formName=$table_name.'Form';

$table_header_fields=array(
	0=> array('key'=>'b.hostname',	'label'=>$lrb['sisiya_admin.label.system']), 
	1=> array('key'=>'i.str',	'label'=>$lrb['sisiya_admin.label.status']), 
	2=> array('key'=>'a.str',	'label'=>$lrb['sisiya_admin.label.message']), 
	3=> array('key'=>'a.updatetime','label'=>$lrb['sisiya_admin.label.update_time']), 
	4=> array('key'=>'a.changetime','label'=>$lrb['sisiya_admin.label.change_time']) 
);
$fields=array(
	0 => array('field_name' => 'new_system_id',	'key' => 'a.systemid', 		'value' => '', 'is_str' => false),
	1 => array('field_name' => 'new_status_id',	'key' => 'c.id',	 	'value' => '', 'is_str' => false),
	2 => array('field_name' => 'new_str',		'key' => 'a.str', 		'value' => '', 'is_str' => true)
);


$nrows=get_setNRows($table_name);

if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i]))
			execSQLWrapper('delete','delete from '.$table_name.' where systemid='.$_POST['system_id'][$i]);
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
$status=getSQL2SelectArray("select a.id,c.str from status a,strkeys b,interface c,languages d where a.id in (1,2,4,8,16,32,64,128,256,512) and a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters);
if($_SESSION['is_admin'] == 't') 
	$html.='	<th colspan="2">&nbsp;</th>';
$html.="</tr>";
if($_SESSION['is_admin'] == 't') {
	$html.='<tr class="row">'."\n";
	$html.='	<td>'.getSelect('new_system_id',getFieldValue($fields,'new_system_id'),$systems).'</td>'."\n";
	$html.='<td>'.getSelect('new_status_id',getFieldValue($fields,'new_status_id'),$status).'</td>'."\n";
	$html.='<td colspan="3"><input class="text_wide" type="text" name="new_str" value="'.getFieldValue($fields,'new_str').'" /></td>'."\n";
	$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
	$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
	$html.="</tr>\n";
}
#			0	1	2	3		4	5      6    7
$sql_str="select a.systemid,b.hostname,i.str,a.updatetime,a.changetime,a.str,c.id,d.str from ".$table_name." a,systems b,status c,systemtypes d, interface i,strkeys s,";
$sql_str.="languages l where a.systemid=b.id and b.systemtypeid=d.id and a.statusid=c.id and c.keystr=s.keystr and s.id=i.strkeyid and i.languageid=l.id ";
$sql_str.=$securitygroups_sql."and l.code='".$_SESSION['language']."'".$search_str." order by ".$table_header_fields[$orderby_id]['key'].' '.$_SESSION['asc_desc'];
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
			$html.='		<img height="25" src="'.getSystemTypeImage($row[7]).'" alt="'.$row[7].'" />&nbsp;'.$row[1];
			$html.="	</td>\n";
			$html.='	<td class="center"><img src="'.getStatusImage($row[6]).'" alt="'.$statusNames[getBaseStatusID($row[6])].'" /></td>'."\n";
			$html.='<td>'.$row[5].'</td>'."\n";
			$html.='<td>'.$row[3].'</td>'."\n";
			$html.='<td>'.$row[4].'</td>'."\n";
			if($_SESSION['is_admin'] == 't') 
				$html.='<td colspan="2" class="center">'.getButtonIcon('delete',$i).'</td>'."\n";
			$html.="</tr>\n";
		}
	} 
	$db->freeResult($result);
}
$html.="</table>\n";
$h->addContent($html);
include_once(LIB_DIR."/sisiya_admin_page_numbers.php");
$h->addContent("</form>\n");
?>
