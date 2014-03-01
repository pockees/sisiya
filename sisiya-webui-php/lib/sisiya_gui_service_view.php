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
###########################################################
### end of functions
###########################################################
$serviceID = getHTTPValue('serviceID');
$effectsglobal = getHTTPValue('effectsglobal');
$image_file = getHTTPValue('imageFile');
$withDailyHistory = getHTTPValue('withDailyHistory');
if($withDailyHistory == '')
		$withDailyHistory='f';
	
$statuses=getSQL2SelectArray("select a.id,c.str from status a,strkeys b,interface c,languages d where a.id in (1,2,4,8,16,32,64,128,256,512) and a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");
$statusID=getHTTPValue('status');

$effectsglobal_str='';
if($effectsglobal != '')
	$effectsglobal_str=" and c.effectsglobal='".$effectsglobal."'";
$status_str='';
if($statusID != '-' && $statusID != '')
	$status_str=' and a.statusid='.$statusID;

$serviceName=getServiceName($serviceID);
/*
$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=switch_view'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_switch_view.png" alt="'.$lrb['sisiya_gui.label.switch_view'].'" title="'.$lrb['sisiya_gui.label.switch_view'].'" /></a>'; 
$navigation_panel_str.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>'; 
$navigation_panel_str.='<a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_detailed_view.png" alt="'.$lrb['sisiya_gui.label.detailed_view'].'" title="'.$lrb['sisiya_gui.label.detailed_view'].'" /></a>';
*/

$h->addHeadContent('<meta http-equiv="cache-control" content="no-cache" />');
$h->addHeadContent('<meta http-equiv="refresh" content="180" />');
$html='';
$html.="<div>\n";
$html.='<form id="service_viewForm"  method="post" action="'.$progName.'">';
$html.='<table class="service_view_header">'."\n";
$html.='<tr class="row">'."\n";
$html.='<td class="left">';
$html.=$serviceName;
$html.='</td>';
$html.='<td class="left">';
$html.='<input type="hidden" name="serviceID" value="'.$serviceID.'" />';
$html.='<input type="hidden" name="imageFile" value="'.$image_file.'" />';
if($effectsglobal != '')
	$html.='<input type="hidden" name="effectsglobal" value="'.$effectsglobal.'" />';
$html.=getSelect('status',$statusID,$statuses,"document.forms['service_viewForm'].submit();");
$html.='</td>';
$html.='<td>';
$html.='<input type="checkbox" name="withDailyHistory" value="t"';
if($withDailyHistory == 't') 
	$html.=' checked="checked"';
$html.=' onchange="document.forms[\'service_viewForm\'].submit();" />';
$html.='<td class="center">';
if($image_file != '')
	$html.='<img src="'.$image_file.'" alt="image" />';
$html.='</td>';
$html.='<td class="right">';
$html.='</td>';
$html.="</tr>\n";
$html.="</table>\n";
$html.='</form>';
$html.="</div>\n";
 
$securitygroups_sql='';
if($force_login && !$_SESSION['hasAllSystems']) 
	$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
####################################################################################################################################################
#		     0      	  1        2        3       4            5         6   
$sql_str="select c.hostname,a.systemid,a.statusid,a.str,a.updatetime,a.changetime,e.str";
$sql_str.=" from systemservicestatus a,status b,systems c";
$sql_str.=",services d,systemtypes e";
$sql_str.=" where a.serviceid=".$serviceID." and a.statusid=b.id and a.systemid=c.id and c.active='t' and a.serviceid=d.id and c.systemtypeid=e.id".$effectsglobal_str.$status_str;
$sql_str.=$securitygroups_sql." order by a.statusid desc,c.hostname";

debug('sql_str='.$sql_str);
$result=$db->query($sql_str);
if(!$result)
	errorRecord('select');
else {
	$nrows=$db->getRowCount($result);
	if($nrows > 0) {
		$h=25;
		$w=800;
		$html.='<table class="system_services">'."\n";
		$html.='<tr class="header">';
		$html.='<td>'.$lrb['sisiya.label.system'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.status'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.description'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.update_time'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.status_change_time'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.status_changed_since'].'</td></tr>'."\n";

		for($row_index=0;$row_index<$nrows;$row_index++) {
			$row=$db->fetchRow($result,$row_index);
			#
			$image_file = '/system_service_history_status_'.$row[1].'_'.$serviceID.'.png';
			$system_link_str=$mainProg.'?menu=system_services'.'&amp;systemID='.$row[1].'&amp;systemName='.$row[0].'&amp;systemType='.$row[6];
			$link_str=$mainProg.'?menu=system_service_history'.'&amp;systemID='.$row[1].'&amp;systemName='.$row[0].'&amp;serviceID='.$serviceID.'&amp;serviceName='.$serviceName.'&amp;startDate=0&amp;systemType='.$row[6];
			$history_str='';
			if($withDailyHistory == 't') {
				createSystemServiceHistoryGraphMap($map_str,$link_str,$image_file,$row[1],$serviceID,$h,$w);
				$history_str='<br />';
				$history_str.='<img src="'TMP_IMG_URL.'/'.$image_file.'" alt="graph" usemap="#map_'.$row[1].'_'.$serviceID.'" />';
				$history_str.=$map_str;
			}
			#
			$html.='<tr class="row">';
			$html.='<td><a href="'.$system_link_str.'">'.$row[0].'</a>';
			$html.='</td>';
			$html.='<td align="center"><img src="'.getStatusImage($row[2]).'" alt="'.$statusNames[$row[2]].'" /></td>';
			$html.='<td>';
			$html.=format_message($row[3]);
			#
			$html.=$history_str;
			#
			$html.='</td>';
			$html.='<td>'.timeString($row[4]).'</td>';
			$html.='<td>'.timeString($row[5]).'</td>';
			$html.=getChangedString($row[4],$row[5]).'</tr>'."\n"; 
		}
		$html.="</table>\n";
	}
	$db->freeResult($result);	
}
$h=$_SESSION['h'];
$h->addContent($html);
?>	
