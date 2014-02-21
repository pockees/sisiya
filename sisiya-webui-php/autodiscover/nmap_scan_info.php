#!/usr/bin/php
<?php
/*
    Copyright (C) 2003 - __YEAR__  Erdal Mutlu

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

if(count($argv) != 2) {
	echo 'Usage  : '.$argv[0]." target\n";
	echo 'Example: '.$argv[0]." 10.10.10.1 [10.10.10.1-19]\n";
	exit(1);
}

$target=$argv[1];

function getScanInfo($xml_file)
{
	$system_infos=array();
	### read XML file
	if(file_exists($xml_file)) {
		$xml=simplexml_load_file($xml_file);
		if($xml) {
			foreach($xml->host as $host) {
				#echo "host state=".$host->status['state']." reason=".$host->status['reason']."\n";
				if($host->status['state'] == "down") 
					continue;
				#echo "addres: ".$host->address[0]['addr']." type=".$host->address[0]['addrtype']."\n";
				#echo "addres: ".$host->address[1]['addr']." type=".$host->address[1]['addrtype']."\n";
				#echo "hostname: ".$host->hostnames->hostname[0]['name']." type=".$host->hostnames->hostname[0]['type']."\n";
				#echo "osmatch: ".$host->os->osmatch[0]['name']." accuracy=".$host->os->osmatch[0]['accuracy']."\n";
				
				$system_type=$host->os->osclass[0]['osfamily'];
				if($system_type == '')
					$system_type='unknown';
				$system_ip=$host->address[0]['addr'];
				$system_mac=$host->address[1]['addr'];
				$system_name=$host->hostnames->hostname[0]['name'];
				$short_system_name=$system_name;
				if(($pos=strpos($system_name,'.')) !== false)
					$short_system_name=substr($system_name,0,$pos);
				#echo "system_type=".$system_type." osclass=".$host->os->osclass[0]['osfamily']."\n";
				array_push($system_infos,array('short_system_name'=>$short_system_name,'system_name'=>$system_name,'system_ip'=>$system_ip,'system_mac'=>$system_mac,'system_type'=>$system_type));
			}
		}
	}
	return($system_infos);
}

function generateXML($s)
{
	$n=count($s);
	if($n == 0)
		return;
	echo '<?xml version="1.0" encoding="utf-8"?>'."\n";
	echo "<discoverd_systems>\n";
	for($i=0;$i<$n;$i++)
		echo "<record><short_system_name>".$s[$i]['short_system_name']."</short_system_name><system_name>".$s[$i]['system_name']."</system_name><system_ip>".$s[$i]['system_ip']."</system_ip><system_mac>".$s[$i]['system_mac']."</system_mac><system_type>".$s[$i]['system_type']."</system_type></record>\n";
	echo "</discoverd_systems>\n";
}

function runScan($target)
{
	$tmp_file=tempnam('.','tmp_nmap_');
	exec('sudo nmap -oX '.$tmp_file.' -O --osscan-limit --osscan-guess '.$target." 2>/dev/null",$results);
	#if(count($results) > 0) {
	#	echo "runScan: Error: ".$results."\n";
	#}
	return($tmp_file);
}
#####################################################################################################################
$xml_file=runScan($target);
generateXML(getScanInfo($xml_file));
### remove xml_file
if(unlink($xml_file) == false)
	echo "Could not delete file: ".$xml_file."\n";
?>
