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
$parameters=array('systemName','systemID','systemType');
foreach($parameters as $p) {
	${$p}=getHTTPValue($p);
	if(${$p} == '') {
		setParameterError($p);
		return;
	}
}
/*
$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=switch_view'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_switch_view.png" alt="'.$lrb['sisiya_gui.label.switch_view'].'" title="'.$lrb['sisiya_gui.label.switch_view'].'" /></a>'; 
$navigation_panel_str.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>'; 
$navigation_panel_str.='<a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_detailed_view.png" alt="'.$lrb['sisiya_gui.label.detailed_view'].'" title="'.$lrb['sisiya_gui.label.detailed_view'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=system_services'.'&amp;systemID='.$systemID;
$navigation_panel_str.='&amp;systemName='.$systemName.'&amp;systemType='.$systemType.'">';
#$navigation_panel_str.='<img src="'.SISIYA_IMG_URL.'/icon_system_services.png" alt="'.$lrb['sisiya_gui.system_services.header'].'" title="'.$lrb['sisiya_gui.system_services.header'].'" />['.$systemName.']</a>'."\n";
$navigation_panel_str.='<img src="'.SISIYA_IMG_URL.'/icon_system_services.png" alt="'.$lrb['sisiya_gui.system_services.header'].'" title="'.$lrb['sisiya_gui.system_services.header'].'" />'."\n";
*/

$html='';
$html.='<div>';
$html.='</h2>';
$html.='</div>';

	$html.='<table class="header_system_info">'."\n";
	$html.='<tr><td><img src="'.LINKS_IMG_URL.'/'.$systemName.'.gif" alt="'.$systemName.'" />';
	$html.='<img src="'.SYSTEMS_IMG_URL.'/'.$systemType.'.gif" alt="'.$systemType.'" /></td>'."\n";
	$html.='<td>';
	$html.='<a href="'.$mainProg.'?menu=system_services'.'&amp;systemID='.$systemID;
	$html.='&amp;systemName='.$systemName.'&amp;systemType='.$systemType.'">';
	$html.='<img src="'.SISIYA_IMG_URL.'/icon_system_services.png" alt="'.$lrb['sisiya_gui.system_services.header'].'" title="'.$lrb['sisiya_gui.system_services.header'].'" />'."\n";
	$html.='</td></tr></table>'."\n";

$html.='<table class="system_infos">'."\n";

$securitygroups_sql='';
if($force_login && !$_SESSION['hasAllSystems']) 
	$securitygroups_sql=' and a.id in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
####################################################################################################################################################
#		   0                 1        2             3      
$sql_str="select a.hostname,a.fullhostname,a.effectsglobal,a.id from systems a where a.id=".$systemID.$securitygroups_sql;
debug('sql_str='.$sql_str);

$result=$db->query($sql_str);
if(!$result)
	errorRecord('select');
else {
	$nrows=$db->getRowCount($result);
	if($nrows == 1) {
		$row=$db->fetchRow($result,0);
		$html.='<tr><td class="label">'.$lrb['sisiya_gui.label.system_name'].'</td>';
		$html.='<td>'.$row[0].'</td></tr>'."\n";
		$html.='<tr><td class="label">'.$lrb['sisiya_gui.label.full_system_name'].'</td>';
		$html.='<td>'.$row[1].'</td></tr>'."\n";
		$html.='<tr><td class="label">';
		$html.=$lrb['sisiya_gui.label.q_effects_global_status'].'</td>';
		$html.='<td>';
		if($row[2] == 't')
			$html.=$lrb['sisiya_gui.label.yes'];
		else
			$html.=$lrb['sisiya_gui.label.no'];
		$html.='</td></tr>'."\n";
		$db->freeResult($result);

		$sql_str='select i.str,a.str from systeminfo a,infos b,interface i,strkeys s,languages l';
		$sql_str.=' where a.infoid=b.id and a.systemid='.$systemID;
		$sql_str.=' and a.languageid='.$_SESSION['language_id']; 
		$sql_str.=' and b.keystr=s.keystr and a.languageid=l.id and l.id=i.languageid and i.strkeyid=s.id ';
		$sql_str.=' order by b.sortid,i.str'; 
		debug('sql_str='.$sql_str);
		$result=$db->query($sql_str);
		if(!$result)
			errorRecord('select');
		else {
			$nrows=$db->getRowCount($result);
			if($nrows > 0) {
					$result=$db->query($sql_str);
					for($i=0;$i<$nrows;$i++) {
						$row=$db->fetchRow($result,$i);
						$html.='<tr><td class="label">'.$row[0].'</td>';
						$html.='<td>'.$row[1].'</td></tr>'."\n";
					}
			}
			$db->freeResult($result);
		}

	}
	$html.="</table>\n";
}

$h=$_SESSION['h'];
$h->addContent($html);
?>
