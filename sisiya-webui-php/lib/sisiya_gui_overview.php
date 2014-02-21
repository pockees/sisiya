<?php
/*
    Copyright (C) 2003 - 2012 Erdal Mutlu

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

$securitygroups_sql='';
if($force_login == true && !$_SESSION['hasAllSystems']) 
	$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
####################################################################################################################################################

$groups=getHTTPValue('groups');
$groups_link_str='';
if($groups == '1') {
	$groups_link_str='&amp;groups=1';
	#		    0		1	  2		3	    4	     5	    6	    7		8	9	10	      11
	$sql_str="select c.hostname,a.systemid,a.statusid,a.updatetime,a.changetime,a.str,b.keystr,d.str,c.locationid,e.str,c.effectsglobal,f.str ";
	$sql_str.="from systemstatus a,status b,systems c";
	$sql_str.=" left outer join systeminfo f on f.systemid=c.id and f.infoid=1 and f.languageid=".$_SESSION['language_id'].",";
	$sql_str.="groups d,systemtypes e,groupsystem g";
	$sql_str.=" where a.statusid=b.id and a.systemid=c.id and c.active='t' and c.systemtypeid=e.id";
	$sql_str.=$securitygroups_sql." and d.id=g.groupid and g.systemid=a.systemid and d.languageid='".$_SESSION['language_id']."' and d.userid=".$_SESSION['user_id'];
	$sql_str.=" order by d.sortid,d.str,c.effectsglobal desc,c.hostname";
}
else {
	#		    0		1	  2		3	    4	     5	    6	    7		8	9	10	      11
	$sql_str="select c.hostname,a.systemid,a.statusid,a.updatetime,a.changetime,a.str,b.keystr,i.str,c.locationid,e.str,c.effectsglobal,f.str ";
	$sql_str.="from systemstatus a,status b,systems c";
	$sql_str.=" left outer join systeminfo f on f.systemid=c.id and f.infoid=1 and f.languageid=".$_SESSION['language_id'].",";
	$sql_str.="locations d,systemtypes e";
	$sql_str.=",interface i,strkeys s,languages l ";
	$sql_str.=" where a.statusid=b.id and a.systemid=c.id and c.active='t' and c.locationid=d.id and c.systemtypeid=e.id";
	$sql_str.=$securitygroups_sql." and d.keystr=s.keystr and l.code='".$_SESSION['language']."'";
	$sql_str.=" and l.id=i.languageid and i.strkeyid=s.id ";
	$sql_str.=" order by d.sortid,i.str,c.effectsglobal desc,c.hostname";
}
/*
$global_status_id=getSystemGlobalStatusID();
$status_str='Status'.$global_status_id;#under cunstruction'; # =getStatusName($global_status_id);

$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=switch_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_switch_view.png" alt="'.$lrb['sisiya_gui.label.switch_view'].'" title="'.$lrb['sisiya_gui.label.switch_view'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_detailed_view.png" alt="'.$lrb['sisiya_gui.label.detailed_view'].'" title="'.$lrb['sisiya_gui.label.detailed_view'].'" /></a>';
$navigation_panel_str.=$lrb['sisiya_gui.label.OverallSystemStatus'].' : ';
$navigation_panel_str.='&nbsp;&nbsp;';
$navigation_panel_str.='<img src="'.getStatusImage($global_status_id).'" alt="'.$status_str.'" title="'.$lrb['sisiya_gui.label.OverallSystemStatus'].'" />';
$navigation_panel_str.=$lrb['sisiya.label.status.'.$status_str];
 */

debug('sql_str='.$sql_str);
$result=$db->query($sql_str);
if(!$result)
	errorRecord('select');
else {
	$nrows=$db->getRowCount($result);
	if($nrows > 0) {
		$h->addHeadContent('<meta http-equiv="cache-control" content="no-cache" />');
		$h->addHeadContent('<meta http-equiv="refresh" content="180" />');
		$nsystems=0;
		$old_group_str='';
		$flag=TRUE;
		$row_index=0;
		while($flag ==  TRUE) {
			for($i=0;$i<$ncolumns && $flag == TRUE;$i++) {
				if($row_index >= $nrows) {
					$flag=FALSE;
					break;
				}
				$row=$db->fetchRow($result,$row_index);
				$row_index++;
				if("$old_group_str" != $row[7]) { // every time when the location is changed
					if("$old_group_str" != '') {
						$html.='</tr><tr class="footer"><td colspan="'.$ncolumns.'">';
						$html.=$lrb['sisiya_gui.label.TotalNumberOfSystems'].' : '.$nsystems.' (';
						$html.=getTotalNumberOfSystems($old_group_str, $groups, $nsystems);
						$html.=')</td></tr>'."\n";
	
						$html.='</table>'."\n";
						$nsystems=0;
					}
					$html.="<ins><p /></ins>\n";
					$html.='<table class="system_overview">'."\n";
					$html.='<tr class="header"><td colspan="'.$ncolumns.'">';
					$html.='<a href="'.$mainProg.'?menu=detailed_view#'.$row[8].$groups_link_str.'">'.$row[7].'</a></td></tr>'."\n";
					$old_group_str=$row[7];
					$i=0; // starting a new table
				}
				if($i == 0)
					$html.='<tr class="row">'."\n";
				if($row[10] == 'f')
					$html.='<td class="effectsfalse">';
				else
					$html.='<td>';
				$html.='<a href="'.$mainProg.'?menu=system_services&amp;systemID=';
				$html.=$row[1].'&amp;systemName='.$row[0].'&amp;systemType='.$row[9].'"';
				$html.=' title="'.validateContent($row[0].' ('.$row[11].') : '.$row[5]).'">';
				$html.='<img src="'.getStatusImage($row[2]).'" alt="'.$lrb['sisiya.label.status.Status'.$row[2]].'" />';
				$html.='</a></td>'."\n";
				$nsystems++;
			}
			$html.='</tr>'."\n";
		}
		$html.='<tr class="footer"><td colspan="'.$ncolumns.'">'.$lrb['sisiya_gui.label.TotalNumberOfSystems'].' : '.$nsystems.' (';
		$html.=getTotalNumberOfSystems($row[7], $groups, $nsystems);
		$html.=')</td></tr>'."\n";
		$html.="</table>\n";
	}
	$db->freeResult($result);
}
$h->addContent($html);
?>
