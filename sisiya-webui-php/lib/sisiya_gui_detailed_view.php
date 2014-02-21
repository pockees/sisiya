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
$html='';
$h->addHeadContent('<meta http-equiv="cache-control" content="no-cache" />');
$h->addHeadContent('<meta http-equiv="refresh" content="180" />');

/*
$global_status_id=getSystemGlobalStatusID();
$status_str='Status'.$global_status_id;
$html.=$lrb['sisiya_gui.label.OverallSystemStatus'].' : ';
$html.='<img src="'.getStatusImage($global_status_id).'" alt="'.$status_str.'" />';
$html.=$lrb['sisiya.label.status.'.$status_str];

$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=switch_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_switch_view.png" alt="'.$lrb['sisiya_gui.label.switch_view'].'" title="'.$lrb['sisiya_gui.label.switch_view'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>';
*/

$html.="</div>\n";

$securitygroups_sql='';
if ($force_login && !$_SESSION['hasAllSystems']) 
	$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
####################################################################################################################################################
$groups=getHTTPValue('groups');
if ($groups == '1') {
	#		   0            1        2           3            4          5     6        7      8           9      10             11 
	$sql_str="select c.hostname,a.systemid,a.statusid,a.updatetime,a.changetime,a.str,b.keystr,d.str,c.locationid,e.str,c.effectsglobal,f.str";
	$sql_str.=" from systemstatus a,status b,systems c";
	$sql_str.=" left outer join systeminfo f on f.systemid=c.id and f.infoid=1 and f.languageid=".$_SESSION['language_id'].",";
	$sql_str.="groups d,systemtypes e,groupsystem g";
	$sql_str.=" where a.statusid=b.id and a.systemid=c.id and c.active='t' and c.systemtypeid=e.id";
	$sql_str.=$securitygroups_sql." and d.id=g.groupid and g.systemid=a.systemid and d.languageid='".$_SESSION['language_id']."' and d.userid=".$_SESSION['user_id'];
	$sql_str.=" order by d.sortid,c.effectsglobal desc,d.str,a.statusid desc,c.hostname";
}
else {
	#		   0            1        2           3            4          5     6        7      8           9      10             11 
	$sql_str="select c.hostname,a.systemid,a.statusid,a.updatetime,a.changetime,a.str,b.keystr,i.str,c.locationid,e.str,c.effectsglobal,f.str";
	$sql_str.=" from systemstatus a,status b,systems c";
	$sql_str.=" left outer join systeminfo f on f.systemid=c.id and f.infoid=1 and f.languageid=".$_SESSION['language_id'].",";
	$sql_str.="locations d,systemtypes e";
	$sql_str.=",interface i,strkeys s,languages l ";
	$sql_str.=" where a.statusid=b.id and a.systemid=c.id and c.active='t' and c.locationid=d.id and c.systemtypeid=e.id";
	$sql_str.=$securitygroups_sql." and d.keystr=s.keystr and l.code='".$_SESSION['language']."'";
	$sql_str.=" and l.id=i.languageid and i.strkeyid=s.id ";
	$sql_str.=" order by d.sortid,c.effectsglobal desc,i.str,a.statusid desc,c.hostname";
}
debug('sql_str='.$sql_str);
$result = $db->query($sql_str);
if (!$result)
	errorRecord('select');
else {
	$nsystems = 0;
	$nrows = $db->getRowCount($result);
	if ($nrows > 0) {
		$old_group_str='';
		$flag=TRUE;
		$row_index=0;
		while($flag ==  TRUE) {
			if ($row_index >= $nrows) {
				$flag=FALSE;
				break;
			}
			$row=$db->fetchRow($result,$row_index);
			$row_index++;
			if ("$old_group_str" != $row[7]) { // every time when the location is changed
				if ("$old_group_str" != '') {
					$html.='<tr class="footer"><td colspan="6">';
					$html.=$lrb['sisiya_gui.label.TotalNumberOfSystems'].' : '.$nsystems.' (';
					$html.=getTotalNumberOfSystems($old_group_str, $groups, $nsystems);
					$html.=')</td></tr>'."\n";

					$html.='</table>'."\n";
					$nsystems=0;
				}
				$html.='<h1><a name="'.$row[8].'"></a></h1>'."\n";
				$html.='<table class="system_detailed_view">'."\n";
				$html.='<tr class="header"><td colspan="6">'.$row[7].'</td></tr>'."\n";
				$html.='<tr class="subheader">';
				$html.='<td>'.$lrb['sisiya.label.system'].'</td>';
				$html.='<td>'.$lrb['sisiya.label.status'].'</td>';
				$html.='<td>'.$lrb['sisiya.label.description'].'</td>';
				$html.='<td>'.$lrb['sisiya.label.update_time'].'</td>';
				$html.='<td>'.$lrb['sisiya.label.status_change_time'].'</td>';
				$html.='<td>'.$lrb['sisiya.label.status_changed_since'].'</td></tr>'."\n";
				$old_group_str=$row[7];
			}
			$html.='<tr class="row">'."\n";
			$html.='<td><a href="'.$mainProg.'?menu=system_services'.'&amp;systemID='.$row[1];
			$html.='&amp;systemName='.$row[0].'&amp;systemType='.$row[9].'">';
			$html.='<img src="'.$systemsImageDir.'/'.$row[9].'.gif" alt="'.$row[9].'" height="25" /><br />';
			$html.=$row[0].'</a></td>';
			if ($row[10] == 'f')
				$html.='<td class="effectsfalse center">';
			else
				$html.='<td class="center">';
			$html.='<img src="'.getStatusImage($row[2]).'" alt="'.$lrb['sisiya.label.status.Status'.$row[2]].'" /></td>';
			$html.='<td>'.$row[5].'</td>';
			$html.='<td>'.timeString($row[3]).'</td>';
			$html.='<td>'.timeString($row[4]).'</td>';
			$html.=getChangedString($row[3],$row[4]);
			$html.="</tr>\n";
			$nsystems++;
		}
	}
	$html.='<tr class="footer"><td colspan="6">'.$lrb['sisiya_gui.label.TotalNumberOfSystems'].' : '.$nsystems.' (';
	$html.=getTotalNumberOfSystems($row[7], $groups, $nsystems);
	$html.=')</td></tr>'."\n";
	$html.="</table>\n";
	$db->freeResult($result);	
	$h->addContent($html);
}
?>	
