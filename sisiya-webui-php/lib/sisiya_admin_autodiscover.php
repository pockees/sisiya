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
/*
 * function displaySystemImage($system_id,$system_str,$i)
{
	global $mainProg,$lrb;

	if(is_link(SYSTEMS_IMG_DIR.'/'.$system_str.'.gif')) {
		$disabled_str = '';
		$title_str = $lrb['sisiya_admin.button.change_image.description'];
	}
	else {
		$disabled_str='_disabled';
		$title_str=$lrb['sisiya_admin.button.set_image.description'];
	}
	echo '<a href="'.$mainProg.'?menu=change_system_image&amp;systemID='.$system_id.'"><img src="'.SISIYA_IMG_URL.'/icon_photo'.$disabled_str.'.png" alt="icon_photo'.$disabled_str.'.png" title="'.$title_str.'" /></a>';
}
 */
function checkPID($pid)
{
	exec("ps -Aeo pid | grep ".$pid, $pids);
	if(count($pids) > 0) {
		return(true);
	}
	return(false);
}

function runInBackground($command,$priority=0)
{
#echo "runInBackground: Executing: ".$command;
	if($priority)
		$pid=shell_exec("nohup nice -n $priority $command > /dev/null & echo $!");
	else
		$pid=shell_exec("nohup $command > /dev/null & echo $!");
	return($pid);
}


function getTarget()
{
	$target = '';
	$target_file = '/autodiscover/discover_'.$_SESSION['user_id'].'_target.txt';
	if(!is_file($target_file)) {
		return($target);
	}
	$lines=file($target_file);
	if($lines) {
		foreach($lines as $line_no => $line) {
			$target=$line;
			break;
		}
	}
	return($target);
}


function isRunning()
{
	$pid_file='/autodiscover/discover_'.$_SESSION['user_id'].'_pid.txt';
	if(!is_file($pid_file)) {
		#echo "dosya yok=".$pid_file;
		return(false);
	}
	$lines=file($pid_file);
	$pid='';
	if($lines) {
		foreach($lines as $line_no => $line) {
			$pid=$line;
			break;
		}
	}
	#echo "pid=".$pid;
	if(checkPID($pid)) {
		#echo "pid=".$pid." is running.";
		return(true);
	}
	#else
		#echo "pid=".$pid." not running.";
	return(false);
}


function checkResults()
{
	$results_file='/autodiscover/discover_'.$_SESSION['user_id'].'_results.xml';
	if(!is_file($results_file)) {
		#echo "<br />dosya yok=".$results_file;
		return false;
	}
	#else
	#	echo "<br />dosya var=".$results_file;
	return true;
}


function checkDiscover()
{
	$pid_file='/discover_'.$_SESSION['user_id'].'_pid.txt';
	if(!is_file($pid_file)) {
	echo "dosya yok=".$pid_file;
		return;
	}
	$lines=file($pid_file);
	$pid='';
	if($lines) {
		foreach($lines as $line_no => $line) {
			$pid=$line;
			break;
		}
	}
	echo "pid=".$pid;
	if(checkPID($pid)) {
		echo "pid=".$pid." is running.";
	}
	else
		echo "pid=".$pid." not running!";
}

function getSystemTypeID($system_type)
{
	global $db;

	### default to Linux
	$system_type_id=1;
	$sql_str="select id from systemtypes where str='".$system_type."'";
	#debug('getSystemTypeID: sql_str='.$sql_str);
	$result=$db->query($sql_str);
	if(!$result)
		errorRecord('select');
	else {
		$nrows=$db->getRowCount($result);
		if($nrows == 1) {
			$row=$db->fetchRow($result,0);
			$system_type_id=$row[0];
			$db->freeResult($result);
		}
	}
	return($system_type_id);
}

function processResults()
{
	### read XML file
	$results_file='/autodiscover/discover_'.$_SESSION['user_id'].'_results.xml';
	if(file_exists($results_file)) {
		#echo '<br />Processing '.$results_file.'...';
		$xml=simplexml_load_file($results_file);
		#echo "<br />";
		if($xml) {
			foreach($xml->record as $record) {
				#echo 'short_system_name='.$record->short_system_name.' system_name='.$record->system_name. " ip=".$record->system_ip.' system_type='.$record->system_type.'<br />';
				$short_system_name=$record->short_system_name;
				$system_name=$record->system_name;
				if($record->system_ip != '') {
					if($short_system_name == '') 
						$short_system_name=$record->system_ip;
					if($system_name == '') 
						$system_name=$record->system_ip;
					$system_type_id=getSystemTypeID($record->system_type);
					$sql_str="insert into scannedsystems values(".$_SESSION['user_id'].",".$system_type_id.",'".$short_system_name."','".$system_name."','".$record->system_ip."','".$record->system_mac."');";
					execSQLWrapper('add',$sql_str);
				}
			}
		}
		if(!unlink($results_file)) {
			echo "processResults: Could not unlink file: ".$results_file;
		}

	}
}
### end of functions
###########################################################
if($_SESSION['is_admin'] != 't') 
	return;

$html='';
$table_name='scannedsystems';
$formName=$table_name.'Form';

$table_header_fields=array(
	0  => array('key'=>'a.hostname',	'label'=>$lrb['sisiya_admin.systems.label.hostname']), 
	1  => array('key'=>'a.fullhostname',	'label'=>$lrb['sisiya_admin.systems.label.fullhostname']), 
	2  => array('key'=>'a.ip',		'label'=>$lrb['sisiya_admin.systems.label.ip']), 
	3  => array('key'=>'a.mac',		'label'=>$lrb['sisiya_admin.systems.label.mac']), 
	4  => array('key'=>'b.str',		'label'=>$lrb['sisiya_admin.systems.label.systemtype']),
	5  => array('key'=>'',			'label'=>$lrb['sisiya_admin.systems.label.isactive']), 
	6  => array('key'=>'',			'label'=>$lrb['sisiya_admin.systems.label.effectsoverallstatus']), 
	7  => array('key'=>'',			'label'=>$lrb['sisiya_admin.systems.label.systemlocation']) 

);
$fields=array(
	0 => array('field_name' => 'new_system_name',		'key' => 'a.hostname', 		'value' => '', 'is_str' => true),
	1 => array('field_name' => 'new_system_full_name',	'key' => 'a.fullhostname', 	'value' => '', 'is_str' => true),
	2 => array('field_name' => 'new_system_ip',		'key' => 'a.ip',	 	'value' => '', 'is_str' => true),
	3 => array('field_name' => 'new_system_mac',		'key' => 'a.mac', 		'value' => '', 'is_str' => true),
	4 => array('field_name' => 'new_system_mac',		'key' => 'a.systemtypeid',	'value' => '', 'is_str' => false)
);

$nrows=get_setNRows($table_name);
$isRunning=false;

$target=getFieldValue($fields,'target');
if(isRunning()) {
	$isRunning=true;
	$_SESSION['nrows_'.$table_name]=0;
	$target=getTarget();
}
	
if(checkResults()) {
	processResults();
}

if(isset($_POST['clear']))
	clearFields($formName,$fields);
else if(isset($_POST['discover'])) {
	if(!$isRunning) {
		### run autodiscover
		$cmd_str="./autodiscover/discover_systems.sh ".$target." ".$_SESSION['user_id'];
		$pid=runInBackground($cmd_str);
		$isRunning=true;
		$_SESSION['nrows_'.$table_name]=0;
	}
}
else if(isset($_POST['delete']))
	execSQLWrapper('delete','delete from '.$table_name.' where userid='.$_SESSION['user_id']);
else {
	for($i=0;$i<$nrows;$i++) {
		if(isset($_POST['delete'][$i]))
			execSQLWrapper('delete','delete from '.$table_name.' where userid='.$_SESSION['user_id']." and hostname='".$_POST['system_name'][$i]."'");
		else if(isset($_POST['add'][$i]))
			execSQLWrapper('add',"insert into systems values(".getNewID('','systems').",'".$_POST['active'][$i]."',".$_POST['system_type'][$i].",".$_POST['location'][$i].",'".$_POST['system_name'][$i]."','".$_POST['system_full_name'][$i]."','".$_POST['effectsglobal'][$i]."','".$_POST['system_ip'][$i]."','".$_POST['system_mac'][$i]."')");
		}
}
$loading_str='';
if($isRunning)
	$loading_str='<p><img src="'.SISIYA_IMG_URL.'/progress.gif" alt="In Progress" /></p>'."\n";
else {
	$table_header_parameters='';
	processInputs($formName,$fields);
	$search_str=generateSearchSQL($fields);
	$orderby_id=get_setOrderbyID(count($fields));
	$start_index=getStartIndex();
	$system_types=getSQL2SelectArray('select id,str from systemtypes order by str');
	$locations=getSQL2SelectArray("select a.id,c.str from locations a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid order by c.str");
}

if(!$isRunning) {
###		    0	      1		   2 	     3	      4		  5	6
$sql_str="select a.userid,a.hostname,a.fullhostname,b.str,a.systemtypeid,a.ip,a.mac from ".$table_name." a,systemtypes b";
$sql_str.=" where a.userid=".$_SESSION['user_id']." and a.systemtypeid=b.id ".$search_str;
$sql_str.=" order by ".$table_header_fields[$orderby_id]['key'].' '.$_SESSION['asc_desc'];
debug('sql_str='.$sql_str);
$result=$db->query($sql_str);
if(!$result)
	errorRecord('select');
else
	$nrows=$db->getRowCount($result);
}

$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
$html.='<tr class="row">'."\n";
$html.='	<td class="label right">'.$lrb['sisiya.label.target'].'</td>'."\n";
$html.='	<td><input class="text" name="target" value="'.$target.'" title="'.$lrb['sisiya.label.target.description'].'" /></td>'."\n";
if($isRunning)
	$html.='	<td class="center">'.getButtonIcon('refresh')."</td>\n";
else  {
	$html.='	<td class="center">'.getButtonIcon('discover')."</td>\n";
	if($nrows > 0)
		$html.='	<td class="center">'.getButtonIcon('delete')."</td>\n";
}
$html.="</tr>\n";
if(!$isRunning) {
	if($nrows > 0) {
		$html.='<tr class="header">'."\n";
		$html.=getTableHeader($orderby_id,$table_header_fields,$start_index,$table_header_parameters);
		if($_SESSION['is_admin'] == 't') 
			$html.='<th colspan="3">&nbsp;</th>'."\n";
		$html.="</tr>\n";
		if($_SESSION['is_admin'] == 't') {
			$html.='<tr class="row">'."\n";
			$html.='	<td><input class="text" type="text" name="new_system_name" value="'.getFieldValue($fields,'new_system_name').'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="new_system_full_name"	value="'.getFieldValue($fields,'new_system_full_name').'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="new_system_ip"	value="'.getFieldValue($fields,'new_system_ip').'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="new_system_mac"	value="'.getFieldValue($fields,'new_system_mac').'" /></td>'."\n";
			$html.='	<td>'.getSelect('new_system_type_id',getFieldValue($fields,'new_system_type_id'),$system_types)."</td>\n";
			$html.='	<td colspan="3">&nbsp;</td>'."\n";
			$html.='	<td>'.getButtonIcon('search').'</td>'."\n";
			$html.='	<td>'.getButtonIcon('clear').'</td>'."\n";
			$html.="</tr>\n";
		}
		$_SESSION['nrows_'.$table_name]=$nrows;
		for($i=$start_index;$i<$start_index + $nrecords_per_page;$i++) {
			### for the last page
			if($i >= $nrows)
				break;
			$row=$db->fetchRow($result,$i);
			$html.='<tr class="row">'."\n";
			$html.='	<td><input class="text" type="text" name="system_name['.$i.']" value="'.$row[1].'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="system_full_name['.$i.']" value="'.$row[2].'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="system_ip['.$i.']" value="'.$row[5].'" /></td>'."\n";
			$html.='	<td><input class="text" type="text" name="system_mac['.$i.']" value="'.$row[6].'" /></td>'."\n";
			$html.="	<td>\n";
			$html.=getSelect('system_type['.$i.']',$row[4],$system_types);
			$html.="	</td>\n";
			$html.='	<td>'.getSelect('active['.$i.']','-',$true_false)."</td>\n";
			$html.='	<td>'.getSelect('effectsglobal['.$i.']','-',$true_false)."</td>\n";
			$html.='<td>'.getSelect('location['.$i.']','-',$locations)."</td>\n";
			if($_SESSION['is_admin'] == 't') { 
				$html.='<td class="center">'.displayButtonIcon('add',$i)."</td>\n";
				$html.='<td>'.getButtonIcon('delete',$i)."</td>\n";
			}
			$html.="</tr>\n";
		}
	} 
	$db->freeResult($result);
}
$html.="</table>\n";
if($loading_str != '') {
	$html.=$loading_str;
	$h->addContent($html);
}
else {
	$h->addContent($html);
	include_once(LIB_DIR."/sisiya_admin_page_numbers.php");
} 
$h->addContent("</form>\n");
?>
