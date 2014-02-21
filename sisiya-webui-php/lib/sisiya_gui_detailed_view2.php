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
###########################################################
###########################################################
### end of functions
###########################################################
$effectsglobal=getHTTPValue('effectsglobal');
$statuses=getSQL2SelectArray("select a.id,c.str from status a,strkeys b,interface c,languages d where a.id in (1,2,4,8,16,32,64,128,256,512) and a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");
$statusID=getHTTPValue('statusID');
$effectsglobal_str='';
if($effectsglobal != '')
	$effectsglobal_str=" and c.effectsglobal='".$effectsglobal."' ";
/*
$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=switch_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_switch_view.png" alt="'.$lrb['sisiya_gui.label.switch_view'].'" title="'.$lrb['sisiya_gui.label.switch_view'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>';
 */

$h->addHeadContent('<meta http-equiv="cache-control" content="no-cache" />');
$h->addHeadContent('<meta http-equiv="refresh" content="180" />');
$html='';
$html.="<div>\n";
$html.='<form id="detailed_view2Form"  method="post" action="'.$progName.'">';
if($effectsglobal != '')
	$html.='<input type="hidden" name="effectsglobal" value="'.$effectsglobal.'" />';
$html.=getSelect('statusID',$statusID,$statuses,"document.forms['detailed_view2Form'].submit();");
$html.='</form>'."\n";
$html.="</div>\n";

$securitygroups_sql='';
if($force_login && !$_SESSION['hasAllSystems']) 
	$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
####################################################################################################################################################
#		   0            1        2           3            4          5     6        7      8              9  
$sql_str="select c.hostname,a.systemid,a.statusid,a.updatetime,a.changetime,a.str,b.keystr,e.str,c.effectsglobal,f.str";
$sql_str.=" from systemstatus a,status b,systems c";
$sql_str.=" left outer join systeminfo f on f.systemid=c.id and f.infoid=1 and f.languageid=".$_SESSION['language_id'].",";
$sql_str.="systemtypes e";
$sql_str.=" where a.statusid=b.id and a.systemid=c.id and c.active='t' and c.systemtypeid=e.id";
$sql_str.=$securitygroups_sql.$effectsglobal_str;
$sql_str.=" order by c.effectsglobal desc,a.statusid desc,c.hostname";
debug('sql_str='.$sql_str);
$result=$db->query($sql_str);
if(!$result)
	errorRecord('select');
else {
	$nrows=$db->getRowCount($result);
	if($nrows > 0) {
		$html.='<table class="system_detailed_view">'."\n";
		$html.='<tr class="subheader">';
		$html.='<td>'.$lrb['sisiya.label.system'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.status'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.description'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.update_time'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.status_change_time'].'</td>';
		$html.='<td>'.$lrb['sisiya.label.status_changed_since'].'</td></tr>'."\n";

		for($row_index=0;$row_index<$nrows;$row_index++) {
			$row=$db->fetchRow($result,$row_index);
			if($statusID != '' && $statusID != '-' && $statusID != getBaseSTatusID($row[2]))
				continue;
			$html.='<tr class="row">'."\n";
			$html.='<td><a href="'.$mainProg.'?menu=system_services'.'&amp;systemID='.$row[1];
			$html.='&amp;systemName='.$row[0].'&amp;systemType='.$row[7].'">';
			$html.='<img src="'.$systemsImageDir.'/'.$row[7].'.gif" alt="'.$row[7].'" height="25" /><br />';
			$html.=$row[0].'</a></td>';
			if($row[8] == 'f')
				$html.='<td class="effectsfalse center">';
			else
				$html.='<td class="center">';
			$html.='<img src="'.getStatusImage($row[2]).'" alt="'.$lrb['sisiya.label.status.Status'.$row[2]].'" /></td>';
			$html.='<td>'.$row[5].'</td>';
			$html.='<td>'.timeString($row[3]).'</td>';
			$html.='<td>'.timeString($row[4]).'</td>';
			$html.=getChangedString($row[3],$row[4]);
			$html.="</tr>\n";
		}
		$html.="</table>\n";
	}
	$db->freeResult($result);	
	$h->addContent($html);
}
?>	
