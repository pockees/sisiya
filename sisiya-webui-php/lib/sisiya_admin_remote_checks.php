<?php
/*
    Copyright (C) 2003 - 2013 Erdal Mutlu

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
function getConfXMLFields($xml)
{
	$fields=array();
	foreach($xml->children() as $record) {
		foreach($record->children() as $child) {
			array_push($fields,array('name'=>$child->getName()));
		}
		break;
	}
	return($fields);
}

function loadXMLConf($conf_file_name)
{
	$conf_file = BASE_DIR.'/xmlconf/'.$conf_file_name;
	if(file_exists($conf_file))
		return(simplexml_load_file($conf_file));
	return(false);
}


function getConfXML($conf_file_name,$systems,$fields)
{
	global $db;

	$html='';
	$conf_file = BASE_DIR.'/xmlconf/'.$conf_file_name;
	if(file_exists($conf_file)) {
		$xml=simplexml_load_file($conf_file);
		if($xml) {
			#$fields=getConfXMLFields($xml);
			$html.='<table class="general">'."\n";
			$html.='<tr class="row">'."\n";
			for($i=0;$i<count($fields);$i++) {
				$html.='<td class="label"';
				if($i == (count($fields)-1))
					$html.=' colspan="3"';
				$html.='>';
				$html.=$fields[$i]['name']."</td>\n";
			}
			$html.="</tr>\n";
			$html.='<tr class="row">';
			$html.='<td>'.getSelect('new_system_id',getHTTPValue('new_system_id'),$systems)."</td>\n";
			$html.='<td>'.getTrueFalseSelect('new_isactive',getHTTPValue('new_isactive'))."</td>\n";
			# the first 2 fields are always system_name and isactive
			for($i=2;$i<count($fields);$i++) {
				$html.='<td class="text"><input type="text" name="new_'.$fields[$i]['name'].'" value="" /></td>'."\n";
			}
			$html.='<td>'.getButtonIcon('add').'</td><td>'.getButtonIcon('clear').'</td>';
			$html.="</tr>\n";
			$i=0;
			foreach($xml->children() as $record) {
				$html.='<tr class="row">';
				$j=0;
				foreach($record->children() as $child) {
					if($j == 1)
						$html.='<td>'.getTrueFalseSelect('isactive['.$i.']',$child)."</td>\n";
					else
						$html.='<td><input class="text" type="text" name="'.$child->getName().'['.$i.']" value="'.$child.'" /></td>'."\n";
					$j++;
				}
				$html.='<td colspan="2" class="center">'.getButtonIcon('delete',$i).'</td>';
				$html.='</tr>';
				$i++;
			}
		}

		/*
		foreach($xml->children() as $record) {
				$html.='<tr class="row">';
				foreach($record->children() as $child) {
					$html.='<td class="label">'.$child->getName()."</td>\n";
				}
				break;
				$html.='</tr>';
			}
			foreach($xml->children() as $record) {
				$html.='<tr>';
				foreach($record->children() as $child) {
					$html.='<td><input class="text" type="text" name="'.$child->getName().'" value="'.$child.'" /></td>'."\n";
				}
				$html.='</tr>';
			}
		}
		*/
	}
	$html.="</table>\n";
	return $html;
}

function addToXMLConf($nrows,$fields,$conf_file_name,$systems)
{
	$conf_file = BASE_DIR.'/xmlconf/'.$conf_file_name;
	$str='<?xml version="1.0" encoding="utf-8"?>'."\n";
	$str.='<systems>'."\n";
	### add at the begging of the file
	$str.='<record>';
	$str.='<system_name>'.getSystemName($_POST['new_system_id'],$systems).'</system_name>';
	### the first field is always SisIYA system name
	for($j=1;$j<count($fields);$j++) {
		$str.='<'.$fields[$j]['name'].'>'.$_POST['new_'.$fields[$j]['name']].'</'.$fields[$j]['name'].'>';
	}
	$str.='</record>'."\n";
	for($i=0;$i<$nrows;$i++) {
		$str.='<record>';
		for($j=0;$j<count($fields);$j++) {
			$str.='<'.$fields[$j]['name'].'>'.$_POST[$fields[$j]['name']][$i].'</'.$fields[$j]['name'].'>';
		}
		$str.='</record>'."\n";
	}
	$str.='</systems>'."\n";
	file_put_contents($conf_file,$str);
}


function deleteFromXMLConf($k,$nrows,$fields,$conf_file_name)
{
	$conf_file = BASE_DIR.'/xmlconf/'.$conf_file_name;
	$str='<?xml version="1.0" encoding="utf-8"?>'."\n";
	$str.='<systems>'."\n";
	for($i=0;$i<$nrows;$i++) {
		### deleting means skipping the record
		if($i == $k)
			continue;
		$str.='<record>';
		for($j=0;$j<count($fields);$j++) {
			$str.='<'.$fields[$j]['name'].'>'.$_POST[$fields[$j]['name']][$i].'</'.$fields[$j]['name'].'>';
		}
		$str.='</record>'."\n";
	}
	$str.='</systems>'."\n";
	file_put_contents($conf_file,$str);
}


function updateXMLConf($nrows,$fields,$conf_file_name)
{
	$conf_file = BASE_DIR.'/xmlconf/'.$conf_file_name;
	$str='<?xml version="1.0" encoding="utf-8"?>'."\n";
	$str.='<systems>'."\n";
	for($i=0;$i<$nrows;$i++) {
		$str.='<record>';
		for($j=0;$j<count($fields);$j++) {
			$str.='<'.$fields[$j]['name'].'>'.$_POST[$fields[$j]['name']][$i].'</'.$fields[$j]['name'].'>';
		}
		$str.='</record>'."\n";
	}
	$str.='</systems>'."\n";
	file_put_contents($conf_file,$str);
}

function getAllConfs()
{
	# build this array using ls *_systems.xml command
	$confs=array(
			0  => array('value' => 'airport',		'option' => 'airport'),
			1  => array('value' => 'pdu',			'option' => 'apc'),
			2  => array('value' => 'dbs',			'option' => 'dbs'),
			3  => array('value' => 'dns',			'option' => 'dns'),
			4  => array('value' => 'ftp',			'option' => 'ftp'),
			5  => array('value' => 'hpilo',			'option' => 'hpilo'),
			6  => array('value' => 'https',			'option' => 'https'),
			7  => array('value' => 'http',			'option' => 'http'),
			8  => array('value' => 'idrac',			'option' => 'idrac'),
			9  => array('value' => 'imap',			'option' => 'imap'),
			10  => array('value' => 'ping',			'option' => 'ping'),
			11 => array('value' => 'pop3',			'option' => 'pop3'),
			12 => array('value' => 'printer',		'option' => 'printer'),
			13 => array('value' => 'qnap',			'option' => 'qnap'),
			14 => array('value' => 'sensor',		'option' => 'sensor'),
			15 => array('value' => 'smb',			'option' => 'smb'),
			16 => array('value' => 'smtp',			'option' => 'smtp'),
			17 => array('value' => 'ssh',			'option' => 'ssh'),
			18 => array('value' => 'switch',		'option' => 'switch'),
			19 => array('value' => 'telekutu',		'option' => 'telekutu'),
			20 => array('value' => 'telnet',		'option' => 'telnet'),
			21 => array('value' => 'ups',			'option' => 'ups'),
			22 => array('value' => 'ups_netagent',		'option' => 'ups_netagent'),
			23 => array('value' => 'vmware',		'option' => 'vmware')
	);
	return $confs;
}
### end of functions
###########################################################
$html='';
if($_SESSION['is_admin'] == 't') {
	$conf=getHTTPValue('conf');
	$xmlconfs=getAllConfs();
	$systems=getSQL2SelectArray("select id,hostname from systems where active='t' order by hostname");
	if($conf != '') {
		#$conf='http';
		$conf_file=$conf.'_systems.xml';
		$xml=loadXMLConf($conf_file);
		if($xml) {
			$fields=getConfXMLFields($xml);
			$nrows=count($xml);
			#echo 'nrows='.$nrows."<br />";
			if(isset($_POST['add']))
				addToXMLConf($nrows,$fields,$conf_file,$systems);
			else if(isset($_POST['updateall']))
				#echo 'Update All<br />';
				updateXMLConf($nrows,$fields,$conf_file);
			for($i=0;$i<$nrows;$i++) {
				if(isset($_POST['delete'][$i]))
					deleteFromXMLConf($i,$nrows,$fields,$conf_file);
				else if(isset($_POST['update'][$i])) {
					#echo 'update:'.$i;
					updateXMLConf($nrows,$fields,$conf_file);
				}
			}
		}
	}
	$html.='<form action="'.$progName.'" method="post" id="remote_checksForm">'."\n";
	$html.='<table class="general">'."\n";
	$html.="<tr>\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.remote_checks.label.conf_type'].'</td>'."\n";
	$html.='	<td>'.getSelect('conf',$conf,$xmlconfs,"document.forms['remote_checksForm'].submit();")."</td>\n";
	$html.='	<td class="center">'.getButtonIcon('updateall')."</td>\n";
	$html.='	<td class="center">'.getButtonIcon('refresh')."</td>\n";
	$html.="</tr>\n";
	$html.="</table>\n";
	if($conf != '' && $xml) 
		$html.=getConfXML($conf_file,$systems,$fields);
	$html.="</form>\n";
}
$h->addContent($html);
?>
