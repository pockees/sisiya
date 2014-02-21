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
function getSystemImage($system_id,$system_str,$i)
{
	global $sisiyaImageDir,$linksImageDir,$mainProg,$lrb;

	if(is_link($linksImageDir.'/'.$system_str.'.gif')) {
		$disabled_str='';
		$title_str=$lrb['sisiya_admin.button.change_image.description'];
	}
	else {
		$disabled_str='_disabled';
		$title_str=$lrb['sisiya_admin.button.set_image.description'];
	}
	return '<a href="'.$mainProg.'?menu=change_system_image&amp;systemID='.$system_id.'"><img src="'.$sisiyaImageDir.'/icon_photo'.$disabled_str.'.png" alt="icon_photo'.$disabled_str.'.png" title="'.$title_str.'" /></a>';
}
### end of functions
###########################################################
$html='';
$table_name='systems';
$formName=$table_name.'Form';

$table_header_fields=array(
	0  => array('key'=>'a.id',		'label'=>$lrb['sisiya_admin.systems.label.id']), 
	1  => array('key'=>'a.hostname',	'label'=>$lrb['sisiya_admin.systems.label.hostname']), 
	2  => array('key'=>'a.fullhostname',	'label'=>$lrb['sisiya_admin.systems.label.fullhostname']), 
	3  => array('key'=>'a.ip',		'label'=>$lrb['sisiya_admin.systems.label.ip']), 
	4  => array('key'=>'a.mac',		'label'=>$lrb['sisiya_admin.systems.label.mac']), 
	5  => array('key'=>'b.str',		'label'=>$lrb['sisiya_admin.systems.label.systemtype']), 
	6  => array('key'=>'a.active',		'label'=>$lrb['sisiya_admin.systems.label.isactive']), 
	7  => array('key'=>'a.effectsglobal',	'label'=>$lrb['sisiya_admin.systems.label.effectsoverallstatus']), 
	8  => array('key'=>'d.str',		'label'=>$lrb['sisiya_admin.systems.label.systemlocation']) 
);

$fields=array(
	0 => array('field_name' => 'new_id',			'key' => 'a.id',		'value' => '',	'is_str' => false),
	1 => array('field_name' => 'new_system_name',		'key' => 'a.hostname',		'value' => '',	'is_str' => true),
	2 => array('field_name' => 'new_system_full_name',	'key' => 'a.fullhostname',	'value' => '',	'is_str' => true),
	3 => array('field_name' => 'new_system_ip',		'key' => 'a.ip',		'value' => '',	'is_str' => true),
	4 => array('field_name' => 'new_system_mac',		'key' => 'a.mac',		'value' => '',	'is_str' => true),
	5 => array('field_name' => 'new_system_type_id',	'key' => 'a.systemtypeid',	'value' => '',	'is_str' => false),
	6 => array('field_name' => 'new_location_id',		'key' => 'a.locationid',	'value' => '',	'is_str' => false),
	7 => array('field_name' => 'new_active',		'key' => 'a.active',		'value' => '',	'is_str' => true),
	8 => array('field_name' => 'new_effectsglobal',		'key' => 'a.effectsglobal',	'value' => '',	'is_str' => true)
);
$nrows=get_setNRows($table_name);

if(isset($_POST['add']))
	execSQLWrapper('add',"insert into ".$table_name." values(".getNewID('new_id',$table_name).",'".$_POST['new_active']."',".$_POST['new_system_type_id'].",".$_POST['new_location_id'].",'".$_POST['new_system_name']."','".$_POST['new_system_full_name']."','".$_POST['new_effectsglobal']."','".$_POST['new_system_ip']."','".$_POST['new_system_mac']."')");

if(isset($_POST['clear']))
	clearFields($formName,$fields);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i]))
			execSQLWrapper('delete','delete from '.$table_name.' where id='.$_POST['id'][$i]);
		else if(isset($_POST['update'][$i]))
			execSQLWrapper('update',"update ".$table_name." set hostname='".$_POST['system_name'][$i]."',fullhostname='".$_POST['system_full_name'][$i]."',active='".$_POST['active'][$i]."',effectsglobal='".$_POST['effectsglobal'][$i]."',locationid=".$_POST['location'][$i].",systemtypeid=".$_POST['system_type'][$i].",ip='".$_POST['system_ip'][$i]."',mac='".$_POST['system_mac'][$i]."' where id=".$_POST['id'][$i]);
		}
}
$table_header_parameters='';
processInputs($formName,$fields);
$search_str=generateSearchSQL($fields);
$orderby_id=get_setOrderbyID(count($fields));
$start_index=getStartIndex();
$system_types=getSQL2SelectArray('select id,str from systemtypes order by str');
$locations=getSQL2SelectArray("select a.id,c.str from locations a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='	<tr class="header">'.getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters);
if($_SESSION['is_admin'] == 't') 
	$html.='<th colspan="3">&nbsp;</th>';
$html.="	</tr>\n";
if($_SESSION['is_admin'] == 't') { 
	$html.='<tr class="row">'."\n";
	$html.='	<td><input class="id" type="text" name="new_id" value="'.getFieldValue($fields,'new_id').'" /></td>'."\n";
	$html.='	<td><input class="text_size100" type="text" name="new_system_name" value="'.getFieldValue($fields,'new_system_name').'" /></td>'."\n";
	$html.='	<td><input class="text_size300" type="text" name="new_system_full_name"	value="'.getFieldValue($fields,'new_system_full_name').'" /></td>'."\n";
	$html.='	<td><input class="text_size150" type="text" name="new_system_ip" value="'.getFieldValue($fields,'new_system_ip').'" /></td>'."\n";
	$html.='	<td><input class="text_size150" type="text" name="new_system_mac" value="'.getFieldValue($fields,'new_system_mac').'" /></td>'."\n";
	$html.='	<td>'.getSelect('new_system_type_id',getFieldValue($fields,'new_system_type_id'),$system_types)."</td>\n";
	$html.='	<td>'.getSelect('new_active',getFieldValue($fields,'new_active'),$true_false)."</td>\n";
	$html.='	<td>'.getSelect('new_effectsglobal',getFieldValue($fields,'new_effectsglobal'),$true_false)."</td>\n";
	$html.='	<td>'.getSelect('new_location_id',getFieldValue($fields,'new_location_id'),$locations)."</td>\n";
	$html.='	<td>'.getButtonIcon('add')."</td>\n";
	$html.='	<td>'.getButtonIcon('search')."</td>\n";
	$html.='	<td>'.getButtonIcon('clear')."</td>\n";
	$html.="</tr>\n";
}

$securitygroups_sql='';
if(!$_SESSION['hasAllSystems']) 
	$securitygroups_sql=' and a.id in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
####################################################################################################################################################
###		   0	  1		2 	  3	   4	5	6		7		8	  9	10
$sql_str="select a.id,a.hostname,a.fullhostname,a.active,b.str,d.str,a.effectsglobal,a.systemtypeid,a.locationid,a.ip,a.mac from ".$table_name." a,systemtypes b,locations c,";
$sql_str.="interface d,strkeys e,languages f where a.systemtypeid=b.id and a.locationid=c.id and c.keystr=e.keystr ";
$sql_str.=$securitygroups_sql." and f.code='".$_SESSION['language']."' and f.id=d.languageid and d.strkeyid=e.id ".$search_str;
$sql_str.=" order by ".$table_header_fields[$orderby_id]['key'].' '.$_SESSION['asc_desc'];
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
			$html.='	<td><input class="text_size100" type="text" name="system_name['.$i.']" value="'.$row[1].'" /></td>'."\n";
			$html.='	<td><input class="text_size300" type="text" name="system_full_name['.$i.']" value="'.$row[2].'" /></td>'."\n";
			$html.='	<td><input class="text_size150" type="text" name="system_ip['.$i.']" value="'.$row[9].'" /></td>'."\n";
			$html.='	<td><input class="text_size150" type="text" name="system_mac['.$i.']" value="'.$row[10].'" /></td>'."\n";
			$html.="	<td>\n";
			$html.='<!--			<img width="30" height="25" src="'.getSystemTypeImage($row[4]).'" alt="'.$row[4].'" /> -->'."\n";
			$html.=getSelect('system_type['.$i.']',$row[7],$system_types);
			$html.='	</td>'."\n";
			$html.='	<td>'.getSelect('active['.$i.']',$row[3],$true_false)."</td>\n";
			$html.='	<td>'.getSelect('effectsglobal['.$i.']',$row[6],$true_false)."</td>\n";
			$html.='	<td>'.getSelect('location['.$i.']',$row[8],$locations)."</td>\n";
			if($_SESSION['is_admin'] == 't') { 
				$html.='<td class="center">'.getButtonIcon('update',$i)."</td>\n";
				$html.='<td>'.getButtonIcon('delete',$i)."</td>\n";
				$html.='<td>'.getSystemImage($row[0],$row[1],$i)."</td>\n";
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
