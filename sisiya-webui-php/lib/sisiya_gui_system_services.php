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
###########################################################
function setDefaultParameters(&$systemName,&$systemID,&$systemType,&$withDailyHistory,$securitygroups_sql)
{
	global $db;

	if($withDailyHistory == '')
		$withDailyHistory='f';
	$sql_str="select a.hostname,a.id,b.str from systems a,systemtypes b where a.systemtypeid=b.id ".$securitygroups_sql." and a.active='t' order by a.hostname";
	$result=$db->query($sql_str);
	if(!$result)
		return;
	$row=$db->fetchRow($result,0);
	$systemName=$row[0];
	$systemID=$row[1];
	$systemType=$row[2];
	$db->freeResult($result);

}

function setSystemNameAndType(&$systemName,$systemID,&$systemType,$securitygroups_sql)
{
	global $db;

	$sql_str="select a.hostname,b.str from systems a,systemtypes b where a.systemtypeid=b.id ".$securitygroups_sql." and a.id=".$systemID;
	$result=$db->query($sql_str);
	if(!$result)
		return;
	$row=$db->fetchRow($result,0);
	$systemName=$row[0];
	$systemType=$row[1];
	$db->freeResult($result);

}

###########################################################
### end of functions
###########################################################
$securitygroups_sql='';
$securitygroups2_sql='';
if($force_login && !$_SESSION['hasAllSystems']) { 
	$securitygroups_sql=' and a.systemid 	in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	$securitygroups2_sql=' and a.id 	in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
}
####################################################################################################################################################
$systems=getSQL2SelectArray("select a.id,a.hostname from systems a where a.active='t' ".$securitygroups2_sql." order by a.hostname");
/*
$parameters=array('systemName','systemID','systemType');
foreach($parameters as $p) {
	${$p}=getHTTPValue($p);
	if(${$p} == '') {
		#setParameterError($p);
		#return;
		setDefaultParameters($systemName,$systemID,$systemType);
		break;
	}
}
*/
$systemID=getHTTPValue('systemID');
$systemName=getHTTPValue('systemName');
$systemType=getHTTPValue('systemType');
$withDailyHistory=getHTTPValue('withDailyHistory');
if($systemID == '')
	setDefaultParameters($systemName,$systemID,$systemType,$withDailyHistory,$securitygroups_sql);
else {
	setSystemNameAndType($systemName,$systemID,$systemType,$securitygroups_sql);
	if($withDailyHistory == '')
		$withDailyHistory='f';
}

$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=switch_view'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_switch_view.png" alt="'.$lrb['sisiya_gui.label.switch_view'].'" title="'.$lrb['sisiya_gui.label.switch_view'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_detailed_view.png" alt="'.$lrb['sisiya_gui.label.detailed_view'].'" title="'.$lrb['sisiya_gui.label.detailed_view'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=system_infos'.'&amp;systemID='.$systemID.'&amp;';
$navigation_panel_str.='systemName='.$systemName.'&amp;systemType='.$systemType.'">';
$navigation_panel_str.='<img src="'.SISIYA_IMG_URL.'/icon_system_infos.png" alt="'.$lrb['sisiya_gui.system_infos.header'].'" title="'.$lrb['sisiya_gui.system_infos.header'].'" /></a>';

$h->addHeadContent('<meta http-equiv="cache-control" content="no-cache" />');
$h->addHeadContent('<meta http-equiv="refresh" content="180" />');
$html='';
#$html.='<form id="system_servicesForm"  method="post" action="'.$progName.'&amp;systemID='.$systemID.'&amp;systemName='.$systemName.'&amp;systemType='.$systemType.'">';
$html.='<form id="system_servicesForm"  method="post" action="'.$progName.'">';
$html.='<table class="general">'."\n";
$html.='<tr class="row">';
$html.='<td class="label">';
$html.=$lrb['sisiya_admin.label.system'];
$html.='</td>';
$html.='<td>';
$html.=getSelect('systemID',$systemID,$systems,"document.forms['system_servicesForm'].submit();");
$html.='</td>';
$html.='<td>';
$html.='<input type="checkbox" name="withDailyHistory" value="t"';
if($withDailyHistory == 't') 
	$html.=' checked="checked"';
$html.=' onchange="document.forms[\'system_servicesForm\'].submit();" />';
$html.='</td>';
$html.='<td>';
$html.='<a href="'.$mainProg.'?menu=system_infos'.'&amp;systemID='.$systemID.'&amp;';
$html.='systemName='.$systemName.'&amp;systemType='.$systemType.'">';
$html.='<img src="'.SISIYA_IMG_URL.'/icon_system_infos.png" alt="'.$lrb['sisiya_gui.system_infos.header'].'" title="'.$lrb['sisiya_gui.system_infos.header'].'" /></a>';
$html.='</td>';
$html.='</tr>';
$html.='</table>';
$html.='</form>';

$html.='<table class="header_system_services">'."\n";
$html.='<tr><td align="left" rowspan="2">'."\n";
$html.='<img src="'.getSystemNameImageURL($systemName).'" alt="'.$systemName.'" />';
$html.='<img src="'.SYSTEMS_IMG_URL.'/'.$systemType.'.png" alt="'.$systemType.'" /></td>'."\n";
$html.='<td>';
$html.="</td></tr></table>\n";

$html.='<table class="system_services">'."\n";
$html.='<tr class="header">';
$html.='<td>'.$lrb['sisiya.label.service'].'</td>';
$html.='<td>'.$lrb['sisiya.label.status'].'</td>';
$html.='<td>'.$lrb['sisiya.label.description'].'</td>';
$html.='<td>'.$lrb['sisiya.label.update_time'].'</td>';
$html.='<td>'.$lrb['sisiya.label.status_change_time'].'</td>';
$html.='<td>'.$lrb['sisiya.label.status_changed_since'].'</td></tr>'."\n";

#		   0      1        2           3            4          5
$sql_str="select i.str,a.statusid,a.str,a.updatetime,a.changetime,a.serviceid";
$sql_str.=" from systemservicestatus a,status b,systems c";
$sql_str.=",services d,systemtypes e";
$sql_str.=",interface i,strkeys s,languages l ";
$sql_str.=" where a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id and c.systemtypeid=e.id";
$sql_str.=$securitygroups_sql." and d.keystr=s.keystr and l.code='".$_SESSION['language']."'";
$sql_str.=" and l.id=i.languageid and i.strkeyid=s.id and a.systemid=".$systemID;
$sql_str.=" order by a.statusid desc,i.str";
debug('sql_str='.$sql_str);

$result=$db->query($sql_str);
if(!$result)
	errorRecord('select');
else {
	$nrows=$db->getRowCount($result);
	$h=25;
	$w=800;
	if($nrows > 0) {
		for($row_index=0;$row_index<$nrows;$row_index++) {
			$row=$db->fetchRow($result,$row_index);
			#
			$link_str=$mainProg.'?menu=system_service_history'.'&amp;systemID='.$systemID.'&amp;systemName='.$systemName.'&amp;serviceID='.$row[5].'&amp;serviceName='.$row[0].'&amp;startDate=0&amp;systemType='.$systemType;
			$history_str='';
			if($withDailyHistory == 't') {
				$image_file='system_service_history_status_'.$systemID.'_'.$row[5].'.png';
				createSystemServiceHistoryGraphMap($map_str,$link_str, TMP_IMG_DIR.'/'.$image_file,$systemID,$row[5],$h,$w);
				$history_str='<br /><img src="'.TMP_IMG_URL.'/'.$image_file.'" alt="graph" usemap="#map_'.$systemID.'_'.$row[5].'" />';
				$history_str.=$map_str."\n";
			}
			#
			$html.='<tr class="row">';
			$html.='<td><a href="'.$link_str.'">'.$row[0].'</a>';
			$html.='</td>';
			$html.='<td align="center"><img src="'.getStatusImage($row[1]).'" alt="'.$statusNames[$row[1]].'" /></td>';
			#$html.='<td>'.$row[2].'</td>';
			$html.='<td>';
			$html.=format_message($row[2]);
			#
			$html.=$history_str;
			#
			$html.='</td>';
			$html.='<td>'.timeString($row[3]).'</td>';
			$html.='<td>'.timeString($row[4]).'</td>';
				#$html.='<td>'.getChangedString($row[3],$row[4]).'</td></tr>'."\n"; 
		$html.=getChangedString($row[3],$row[4]).'</tr>'."\n"; 
		}
		$html.="</table>\n";
	}
	$db->freeResult($result);
}
$h=$_SESSION['h'];
$h->addContent($html);
?>
