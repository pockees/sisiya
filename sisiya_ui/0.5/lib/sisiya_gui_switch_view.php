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
function getSwitchInfo($switch_name)
{
	global $db;

	$result_str='';
/*
	$info_id=1; # description
	$sql_str="select c.hostname,a.str from systeminfo a,infos b, systems c, interface i, strkeys s, languages l";
	$sql_str.=" where a.infoid=b.id and a.systemid=c.id and c.hostname='".$switch_name."'";
	$sql_str.=" and a.infoid=".$info_id;
	$sql_str.=" and a.languageid=".$_SESSION['language_id'];
	$sql_str.=" and b.keystr=s.keystr and a.languageid=l.id and l.id=i.languageid and i.strkeyid=s.id";
	debug('sql_str='.$sql_str);
	$result=$db->query($sql_str);
	if(!$result)
		errorRecord('select');
	else {
		$nrows=$db->getRowCount($result);
		if($nrows > 0) {
			$row=$db->fetchRow($result,0);
			$result_str=$row[0].' ('.$row[1].')';
		}
	}
*/
	$sql_str="select c.hostname,a.str from systeminfo a,infos b, systems c, interface i, strkeys s, languages l";
	$sql_str.=" where a.infoid=b.id and a.systemid=c.id and c.hostname='".$switch_name."'";
	$sql_str.=" and (a.infoid=1 or a.infoid=23 or a.infoid=24)"; # 1=description, 23=contact, 24=location
	$sql_str.=" and a.languageid=".$_SESSION['language_id'];
	$sql_str.=" and b.keystr=s.keystr and a.languageid=l.id and l.id=i.languageid and i.strkeyid=s.id";
	debug('sql_str='.$sql_str);
	$result=$db->query($sql_str);
	if(!$result)
		errorRecord('select');
	else {
		$nrows=$db->getRowCount($result);
		if($nrows > 0) {
			for($i=0;$i<$nrows;$i++) {
				$row=$db->fetchRow($result,$i);
				$result_str.=$row[1].'; ';
			}
		}
	}
	$result_str=$row[0].' ('.$result_str.')';
	return($result_str);
}


function getSwitchTable(&$switch,$switch_info)
{
	global $mainProg,$lrb,$sisiyaImageDir;

	$nports=count($switch);
	$html='';
	if($nports == 0)
		return($html);
	$ncolumns=ceil($nports/2);
	$nsystems=0;
	$html.="<ins><p /></ins>\n";
	$html.='<table class="switch_view">'."\n";
	$html.='<tr class="header"><td colspan="'.$ncolumns.'">'.$switch_info;
	$html.='</td></tr>'."\n";
	$t=0;
	for($i=0;$i<4;$i++) {
		$r=$i%2;
		if($r == 0) {
			$html.='<tr class="row">'."\n";
			for($j=0;$j<$ncolumns;$j++) {
				$k=$t*$ncolumns+$j;
				if($k >= $nports)
					continue;
				$html.='<td class="empty">'.($k+1);
				$row=$switch[$k];
				# isuplink
				if($row[15] == 't')
					$html.='u';
				$html.='</td>'."\n";
			}
			$html.='</tr>'."\n";
		}
		else {
			$t++;
			$html.='<tr class="row">'."\n";
		for($j=0;$j<$ncolumns;$j++) {
			$k=($t-1)*$ncolumns+$j;
			if($k >= $nports)
				continue;
			$row=$switch[$k];
			/*
			if($row == null) {
#				$html.='<td class="empty">'.($k+1).'<br />';
				$html.='<td class="empty">'.($k+1).'<br />';
				$html.='<img src="'.$sisiyaImageDir.'/icon_empty_port.png'.'" alt="'.$lrb['sisiya.label.empty_port'].'" />';
				$html.='</td>'."\n";
			}
			else {
			*/
			if($row != null) {
				$nsystems++;
				# isknown
				if($row[14] == 't') {
					if($row[6] == 'f')
						$html.='<td class="effectsfalse">';
					else
						$html.='<td>';
					
					$html.='<a href="'.$mainProg.'?menu=system_services&amp;systemID=';
					$html.=$row[1].'&amp;systemName='.$row[0].'&amp;systemType='.$row[9].'"';
					$html.=' title="'.$row[0];
					$html.=' ('.$row[11].$row[12].' vlan:'.$row[16].') : '.$row[3].'">';
					$html.='<img src="'.getStatusImage($row[2]).'" alt="'.$lrb['sisiya.label.status.Status'.$row[2]].'" />';
					$html.='</a></td>'."\n";
				}
				else {
					# port status
					if($row[13] == 'f') {
						$html.='<td class="empty">';
						$html.='<img src="'.$sisiyaImageDir.'/icon_empty_port.png'.'" alt="'.$lrb['sisiya.label.empty_port'].'" title="vlan='.$row[16].'" />';
						$html.='</td>'."\n";
					}
					else {
						$html.='<td class="empty">';
						$html.='<img src="'.$sisiyaImageDir.'/icon_port_up.png'.'" alt="'.$lrb['sisiya.label.empty_port'].'" title="vlan='.$row[16].'" />';
						$html.='</td>'."\n";
					}
				}
			}
			else {
				$html.='<td class="empty">';
				$html.='<img src="'.$sisiyaImageDir.'/icon_empty_port.png'.'" alt="'.$lrb['sisiya.label.empty_port'].'" />';
				$html.='</td>'."\n";
			}
			}
			$html.='</tr>'."\n";
		}
	}
	$html.='<tr class="footer"><td colspan="'.$ncolumns.'">'.$lrb['sisiya_gui.label.TotalNumberOfSystems'].' : '.$nsystems;
	$html.='</table>';
	return($html);
}

function createEmptySwitch(&$switch,$nports)
{
	$switch=array();
	for($i=0;$i<$nports;$i++) {
		$switch[$i]=null;
	}
}
###########################################################
### end of functions
###########################################################
$h->addHeadContent('<meta http-equiv="cache-control" content="no-cache" />');
$h->addHeadContent('<meta http-equiv="refresh" content="180" />');
$html='';

/*
$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_detailed_view.png" alt="'.$lrb['sisiya_gui.label.detailed_view'].'" title="'.$lrb['sisiya_gui.label.detailed_view'].'" /></a>';
 */

$securitygroups_sql='';
if(!$_SESSION['hasAllSystems']) 
	$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
####################################################################################################################################################
$sql_str="select
        c.hostname,		/* 0 */
        a.systemid,		/* 1 */
        a.statusid,		/* 2 */
        a.str,                 	/* 3  System status description*/
        b.keystr,             	/* 4  Status keystr */
        e.str,                  /* 5  System type */
        c.effectsglobal,        /* 6  */
        f.str as port,          /* 7  Number of ports */
        h.switchid,             /* 8  Switch id */
        d.hostname as switch,   /* 9  Switch name */
        h.port,			/* 10 */
        h.speed,		/* 11 */
        h.duplex,		/* 12 */
	h.status,		/* 13 port status */
	h.isknown,		/* 14 is in SisIYA */
	h.isuplink,		/* 15 uplink or not */
	h.vlan			/* 16 vlan id */
from    systemstatus a,
        status b,
        systems c,
        systems d,
        systeminfo f,
        systemtypes e,
        systemswitch h
where
        a.statusid=b.id         and
	a.systemid=c.id";
$sql_str.=$securitygroups_sql."
        and c.active='t'        and
        c.systemtypeid=e.id     and
        h.switchid=d.id         and
        h.systemid=a.systemid   and
        d.active='t'            and
        h.switchid=f.systemid   and
        f.infoid=22             and
        f.languageid=1
order by d.hostname,h.port,c.effectsglobal desc,c.hostname;";
debug('sql_str='.$sql_str);
$result=$db->query($sql_str);
if(!$result)
	errorRecord('select');
else {
	$nrows=$db->getRowCount($result);
	if($nrows > 0) {
		$switch=array();
		$nsystems=0;
		$old_group_str='';
		$switch_info='';
		$row_index=0;
		for($i=0;$i<$nrows;$i++) {
			$row=$db->fetchRow($result,$i);
			if("$old_group_str" != $row[9]) { // every time when the switch is changed
				if("$old_group_str" != '') {
					$switch_info=getSwitchInfo($old_group_str);
					$html.=getSwitchTable($switch,$switch_info);
					$nsystems=0;
				}
				createEmptySwitch($switch,$row[7]);
				$old_group_str=$row[9];
				$switch_info=$old_group_str;
			}
			$switch[$row[10]-1]=$row;
			$nsystems++;
		}
		# show the last switch
		$html.=getSwitchTable($switch,$row[9]);
	}
	$h->addContent($html);
	$db->freeResult($result);
}
