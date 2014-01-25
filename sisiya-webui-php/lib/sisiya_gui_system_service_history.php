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
function getParameters(&$parameters)
{
	foreach($parameters as $key => $value ) {
		$value=getHTTPValue($key);
		### save the value in the array (foreach works on a copy of the original key,value pairs)
		$parameters[$key]=$value;
		if($value == '') {
			setParameterError($key);
			return false;
		}
#	echo "parameter: ".$key."=".$value."<br />";
	}
	return true;
}

function getStartDate($system_id,$service_id,&$service_str)
{
	global $db;

	$startDate=getHTTPValue('startDate');
	if($startDate == '' || $startDate == '0') {
		$startDate='0';
		$sql_str='select starttime,str from systemservice where systemid='.$system_id.' and serviceid='.$service_id.' and languageid=0';
		debug($sql_str);
		$result=$db->query($sql_str);
		if(!$result)
			errorRecord('select');
		else {	
			$str='';
			if($db->getRowCount($result) == 1) {
				$row=$db->fetchRow($result,0);
				$startDate=$row[0]{0}.$row[0]{1}.$row[0]{2}.$row[0]{3}.$row[0]{4}.$row[0]{5}.$row[0]{6}.$row[0]{7};
				$service_str=$row[1];
			}
			$db->freeResult($result);
		}
	}
	return($startDate);
}
###########################################################
### end of functions
###########################################################
$today=getdate(); 
#$parameters=array('systemName','systemID','systemType','serviceID','serviceName');
$parameters=array(
		'systemName'	=>'',
		'systemID'	=>'',
		'systemType'	=>'',
		'serviceID'	=>'',
		'serviceName'	=>''
	);
if(getParameters($parameters) == false)
	return;
$serviceDescription=getHTTPValue('serviceDescription');
$startDate=getStartDate($parameters['systemID'],$parameters['serviceID'],$serviceDescription);
# maybe there are no records in the systemservice table for this system
$d=$today['year'].echo_value($today['mon']).echo_value($today['mday']);
if($startDate == '0' )
	$startDate=$d;
### generate one day early as the startDate
$a_date=getdate(mktime(0,0,0,$startDate{4}.$startDate{5},$startDate{6}.$startDate{7}-1,$startDate{0}.$startDate{1}.$startDate{2}.$startDate{3}));
$beforeStartDate=$a_date['year'].echo_value($a_date['mon']).echo_value($a_date['mday']);
###
$date_str=getHTTPValue('date_str');
if($date_str == '') 
	$date_str=$d;
$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=switch_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_switch_view.png" alt="'.$lrb['sisiya_gui.label.switch_view'].'" title="'.$lrb['sisiya_gui.label.switch_view'].'" /></a>'; 
$navigation_panel_str.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>'; 
$navigation_panel_str.='<a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_detailed_view.png" alt="'.$lrb['sisiya_gui.label.detailed_view'].'" title="'.$lrb['sisiya_gui.label.detailed_view'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=system_services'.'&amp;systemID='.$parameters['systemID'];
$navigation_panel_str.='&amp;systemName='.$parameters['systemName'].'&amp;systemType='.$parameters['systemType'].'">';
#$navigation_panel_str.='<img src="'.$sisiyaImageDir.'/icon_system_services.png" alt="'.$lrb['sisiya_gui.system_services.header'].'" title="'.$lrb['sisiya_gui.system_services.header'].'" />['.$systemName.']</a>'."\n";
$navigation_panel_str.='<img src="'.$sisiyaImageDir.'/icon_system_services.png" alt="'.$lrb['sisiya_gui.system_services.header'].'" title="'.$lrb['sisiya_gui.system_services.header'].'" />'."\n";

$h=$_SESSION['h'];
$h->addContent('<div class="div_container">');
$h->addContent('	<div class="div_subheader_center">');
$h->addContent('		<table class="tx0">');
$h->addContent('		<tr>');
$h->addContent('			<td class="left">');
$h->addContent('				<img src="'.$linksImageDir.'/'.$parameters['systemName'].'.gif" alt="'.$parameters['systemName'].'" />');
$h->addContent('				<img src="'.$systemsImageDir.'/'.$parameters['systemType'].'.gif" alt="'.$parameters['systemType'].'" />');
$h->addContent('			</td>');
$h->addContent('			<td class="left">');
$h->addContent('				<h2>['.$parameters['systemName'].']</h2>');
$h->addContent('			</td>');
$h->addContent('			<td class="right">');
$h->addContent('			</td>');
$h->addContent('		</tr>');
$h->addContent('		</table>');
$h->addContent('	</div>');
$h->addContent('</div>');

$h->addContent('	<table class="tx1">');
$h->addContent('	<tr>');
$h->addContent('		<td class="left">'.$lrb['sisiya.label.service'].' : '.$parameters['serviceName'].'</td>');
$h->addContent('		<td class="left">');
$h->addContent('		<form id="system_service_historyForm"  method="post" action="'.$progName.'&amp;systemID='.$parameters['systemID'].'&amp;systemName='.$parameters['systemName'].'&amp;serviceID='.$parameters['serviceID'].'&amp;serviceName='.$parameters['serviceName'].'&amp;startDate='.$startDate.'&amp;systemType='.$parameters['systemType'].$debug_str.'&amp;serviceDescription='.$serviceDescription.'">');
$h->addContent('		<ins>');
$h->addContent('		'.$lrb['sisiya_gui.label.choose_a_date']);
$h->addContent('			<select name="date_str" onchange="document.forms['."'".'system_service_historyForm'."'".'].submit();">');
$current_date=$today;
while($d != $beforeStartDate) {
	$h->addContent('			<option ');
	if($date_str == $d) 
		$h->addContent('selected="selected"'); 
		$h->addContent(' value="'.$d.'">'.dateString($d));
		$h->addContent('	</option>');
		$current_date=getdate(mktime(0,0,0,$current_date['mon'],$current_date['mday']-1,$current_date['year']));
		$d=$current_date['year'].echo_value($current_date['mon']).echo_value($current_date['mday']);
}
$h->addContent('		</select>');
$h->addContent('		</ins>');
$h->addContent('		</form>');
$h->addContent('		</td>');
$h->addContent('	</tr>');
$h->addContent('	<tr><td colspan="2" class="left">'.$lrb['sisiya_gui.label.service_description'].' : '.$serviceDescription.'</td></tr>');
$h->addContent('	</table>');
$h->addContent('	<table class="system_service_history">');
$h->addContent('		<tr class="header">');
$h->addContent('			<td>'.$lrb['sisiya.label.recieved_time'].'</td>');
$h->addContent('			<td>'.$lrb['sisiya.label.status'].'</td>');
$h->addContent('			<td>'.$lrb['sisiya.label.description'].'</td>');
$h->addContent('			<td>'.$lrb['sisiya.label.send_time'].'</td>');
$h->addContent('		</tr>');
for($j=0;$j<2;$j++) {
	### choose the systemhistorystatus table
	$table_name='systemhistorystatus';
	if($j == 1)
		$table_name='systemhistorystatus'.substr($date_str,0,6);
		
	$sql_str="select a.recievetime,a.statusid,a.str,a.sendtime from ".$table_name." a where a.systemid=".$parameters['systemID']." and a.serviceid=".$parameters['serviceID']." and a.recievetime like '".$date_str."%' order by a.recievetime desc";
	debug($sql_str);
	$result=$db->query($sql_str);
	if(!$result) {
		if($j == 0)
			continue;
		errorRecord('select');
	}
	else {
		$row_count=$db->getRowCount($result);
		for($row_index=0;$row_index<$row_count;$row_index++) {
			$row=$db->fetchRow($result,$row_index);
			$h->addContent('		<tr>');
			$h->addContent('			<td><a name="'.$row_index.'"></a>'.timeString($row[0]).'</td>');
			$h->addContent('			<td align="center"><img src="'.getStatusImage($row[1]).'" alt="'.$row[1].'" /></td>');
			$h->addContent('			<td>'.format_message($row[2]).'</td>');
			$h->addContent('			<td>'.timeString($row[3]).'</td>');
			$h->addContent('		</tr>');
		}
		$db->freeResult($result);
	}
}
$h->addContent('</table>');
?>
