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
function findSystemName($id,$systems)
{
	$s='';
	for($i=0;$i<count($systems);$i++) 
		if($id == $systems[$i]['value'])
			$s=$systems[$i]['option'];
	return($s);
}
### end of functions
###########################################################
$html='';
$table_name='usersystemservicealert';
$alert_str=$lrb['sisiya_admin.label.description_alert_frequency'];
$securitygroups_sql='';
if(!$_SESSION['hasAllSystems']) 
	$securitygroups_sql=' where id in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
####################################################################################################################################################
$systems=getSQL2SelectArray('select id,hostname from systems'.$securitygroups_sql.' order by hostname');
if(isset($_POST['send'])) {
	$system_name=findSystemName($_POST['new_system_id'],$systems);
	$message_str=$_SESSION['valid_user'].': '.$_POST['new_message'];
	sendSisIYAMessage($system_name,$_POST['new_service_id'],$_POST['new_status_id'],$_POST['new_expire'],$message_str);
}

$services=getSQL2SelectArray("select a.id,c.str from services a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");
$status=getSQL2SelectArray("select a.id,c.str from status a,strkeys b,interface c,languages d where a.id in (1,2,4,8,16,32,64,128,256,512) and a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");
$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="row">'."\n";
$html.='	<td class="label">'.$lrb['sisiya_admin.label.system']."</td>\n";
$html.='	<td>'.getSelect('new_system_id',getHTTPValue('new_system_id'),$systems)."</td>\n";
$html.="</tr>\n";
$html.='<tr class="row">'."\n";
$html.='	<td class="label">'.$lrb['sisiya_admin.services.label.keystr']."</td>\n";
$html.='	<td>'.getSelect('new_service_id',getHTTPValue('new_service_id'),$services)."</td>\n";
$html.="</tr>\n";
$html.='<tr class="row">'."\n";
$html.='	<td class="label">'.$lrb['sisiya_admin.label.status']."</td>\n";
$html.='	<td>'.getSelect('new_status_id',getHTTPValue('new_status_id'),$status)."</td>\n";
$html.="</tr>\n";
$html.='<tr class="row">'."\n";
$html.='	<td class="label">'.$lrb['sisiya_admin.label.alert_frequency']."</td>\n";
$html.='	<td><input class="text" type="text" name="new_expire" value="'.getHTTPValue('new_expire').'" onmouseover="window.status='."'".$alert_str."'; return true;".'" onmouseout="window.status='."'';".'" title="'.$alert_str.'" /></td>'."\n";
$html.="</tr>\n";
$html.='<tr class="row">'."\n";
$html.='	<td class="label">'.$lrb['sisiya_admin.label.message']."</td>\n";
$html.='	<td><input class="text_wide" type="text" name="new_message" value="'.getHTTPValue('new_message').'" /></td>'."\n";
$html.="</tr>\n";
$html.='</table>'."\n";
$html.='<div>'.getButtonIcon('send')."</div>\n";
$html.="</form>\n";
$h->addContent($html);
?>
