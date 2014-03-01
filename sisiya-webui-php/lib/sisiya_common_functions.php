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

function debug($msg)
{
	global $debug;

	if($debug)
		echo $msg."<br />\n";
}

function getHTTPValue($key)
{
	$value='';
	if(isset($_POST[$key])) 
		$value=$_POST[$key]; 
	else if(isset($_GET[$key])) 
		$value=$_GET[$key]; 
 
	return $value;
	# more elegant
	return ((isset($_POST[$key])) ? $_POST[$key] : ((isset($_GET[$key])) ? $_GET[$key] : ''));
}

function getInputValue($formName,$key)
{
	$value=getHTTPValue($key);
	if($value == '') {
		$form_key=$formName.'_'.$key;
		if(isset($_SESSION[$form_key]))
			$value=$_SESSION[$form_key];
	}
	return $value;
}



function startSession($sname)
{
	session_name($sname); 
	session_start();
}

function destroySession()
{
	## destroy the old session, if there was one
	session_destroy();
}

function displayCharset()
{
	echo getCharset();
}

function getCharset()
{
	return "utf-8";
}

function reloadLanguages()
{
	if(!setLanguage($_SESSION['language']))
		return(false);
	if(!initLanguageFromSession())
		return(false);
}

function initLanguageFromSession()
{
	global $lrb,$langs;

	if(!isset($_SESSION['lrb']) || count($_SESSION['lrb']) == 0) {
		debug('initLanguageFromSession: lrb is not set or does not have any entries!');
		return(false);
	}
	foreach($_SESSION['lrb'] as $key=>$value)
		$lrb[$key]=$value;
	foreach($_SESSION['langs']['language_code'] as $key=>$value)
		$langs['language_code'][$key]=$value;
	foreach($_SESSION['langs']['language_id'] as $key=>$value)
		$langs['language_id'][$key]=$value;
	initLanguageSpecificData();

	return(true);
}

function initLanguageSpecificData()
{
	global $lrb,$true_false;

	debug('initLanguageSpecificData: initializing...');
	$true_false=array(
		0 => 	array ('value' 	=> 't','option' 	=> $lrb['sisiya_admin.label.yes']),
		1 => 	array ('value' 	=> 'f','option' 	=> $lrb['sisiya_admin.label.no'])
	);
	debug('initLanguageSpecificData: initializing...OK');
}

function initLanguage() 
{
	$language=getHTTPValue('language');
	if(isset($_SESSION['language'])) {
		if($language != '' && $language != $_SESSION['language']) {
			if(!setLanguage($language)) {
				debug('initLanguage: Could not set language!');
				return(false);
			}
		}
	}
	else {
		if(!setLanguage($language)) {
			debug('initLanguage: Could not set language!');
			return(false);
		}
	}
	if(!initLanguageFromSession()) {
		debug('initLanguage: Could not initialize language from session!');
		return(false);
	}
	else
		return(true);
}


function getLanguageID($language_code)
{
	global $db;

	$language_id=-1;
	$sql_str="select id from languages where code='".$language_code."'";
	$result=$db->query($sql_str);
	if($result) {
		$row=$db->fetchRow($result,0);
		$language_id=$row[0];
		$db->freeResult($result);
	}
	return($language_id);
}

function displayLanguageBar_old($prog_name,$params)
{
	echo getLanguageBar_old($prog_name,$params);
}

function getLanguageBar_old($prog_name,$params)
{
	$str='';
	if(isset($_SESSION['langs'])) {
		foreach($_SESSION['langs']['language_code'] as $language_code) {
			$str.='<a onmouseover="window.status=';
			$str.="'Change language'; return true;";
			$str.='"'.' onmouseout="window.status='."'';".'"';
			$str.=' class="language" href="'.$prog_name.'?'.$params.'&amp;language='.$language_code.'">';
			if($language_code == $_SESSION['language'])
				$str.='<b>'.$language_code.'</b>';
			else
				$str.=$language_code;
			$str.='</a>&nbsp;';
		}
	}
	return $str;
}


function displayLanguageBar()
{
	echo getLanguageBar();
}


function getLanguageBar()
{
	$str = '';
	if(strpos($_SERVER['REQUEST_URI'],'?') == false)
		$link_prog=$_SERVER['REQUEST_URI'].'?';
	else {
		$s=preg_replace('/.language=../','',$_SERVER['REQUEST_URI']);
		if(strpos($s,'?') == false)
			$link_prog=$s.'?';
		else {
			$s=preg_replace('/&/','&amp;',$s);
			$link_prog=$s.'&amp;';
		}
	}
	if(isset($_SESSION['langs'])) {
		foreach($_SESSION['langs']['language_code'] as $language_code) {
			#$str.='<a onmouseover="window.status=';
			#$str.="'Change language'; return true;";
			#$str.='"'.' onmouseout="window.status='."'';".'"';
			#######$str.=' class="language" href="'.preg_replace('/&/','&amp;',$_SERVER['REQUEST_URI']).'&amp;language='.$language_code.'">';
			#$str.=' class="language" href="'.$link_prog.'language='.$language_code.'">';
			$str.='<a class="language" href="'.$link_prog.'language='.$language_code.'">';
			if($language_code == $_SESSION['language'])
				$str.='<b>'.$language_code.'</b>';
			else
				$str.=$language_code;
			$str.='</a>&nbsp;';
		}
	}
	return $str;
}



function setLanguage($language)
{
	global $defaultLanguage;

	if($language == '')
		$language=$defaultLanguage;
	$_SESSION['language']=$language;
	$_SESSION['language_id']=getLanguageID($language);
	if(!loadLanguageFromDB2Session())
		return(false);
	setCharset();
	#### save session
	#session_write_close();
	return(true);
}

function loadLanguageFromDB2Session()
{
	global $db,$langs;

	### get supported languages
	$sql_str='select id,code from languages';
	$result=$db->query($sql_str);
	if(!$result) 
		return(false);
	$row_count=$db->getRowCount($result);
	if($row_count == 0) {
		$db->freeResult($result);
		return(false);
	}
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		$langs['language_id'][$i]=$row[0];
		$langs['language_code'][$i]=$row[1];
	}
	$db->freeResult($result);

	### save langs to the session
	$_SESSION['langs']=$langs;
	
	### get language strings
	$sql_str="select b.keystr,c.str from languages a,strkeys b,interface c where a.code='".$_SESSION['language']."'";
	$sql_str.=" and a.id=c.languageid and b.id=c.strkeyid";
	$result=$db->query($sql_str);
	if(!$result) 
		return(false);

	$row_count=$db->getRowCount($result);
	$a=array();
	if($row_count == 0) {
		#return(false);
	}
	else {
		for($i=0;$i<$row_count;$i++) {
			$row=$db->fetchRow($result,$i);
			$a[$row[0]]=$row[1];
		}
	}
	$db->freeResult($result);

	### Check if all entries are translated. The reference is the English language. If something is
	### missing, put the English text instead
	$sql_str="select b.keystr,c.str from languages a,strkeys b,interface c where a.code='en'";
	$sql_str.=" and a.id=c.languageid and b.id=c.strkeyid";
	$result=$db->query($sql_str);
	if(!$result) 
		return(false);

	$row_count=$db->getRowCount($result);
	if($row_count == 0) {
		$db->freeResult($result);
		return(false);
	}
	
	for($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		if(!isset($a[$row[0]]))
			$a[$row[0]]=$row[1];
	}

	$db->freeResult($result);

	### save lrb to the session
	$_SESSION['lrb']=$a;
	return(true);
}

function setCharset()
{
	global $db,$defaultCharset;

	$_SESSION['charset']=$defaultCharset;
	$sql_str="select charset from  languages where code='".$_SESSION['language']."'";
	$result=$db->query($sql_str);
	if($result) {
		if($db->getRowCount($result) == 1) {
			$row=$db->fetchRow($result,0);
			$_SESSION['charset']=$row[0];
		}
		$db->freeResult($result);
	}
}


function setStatusMessage($status_type,$status_message)
{
	$_SESSION['status_type']=$status_type;
	$_SESSION['status_message']=$status_message;
}

function okRecord($str)
{
	global $lrb;

	setStatusMessage(STATUS_INFO,$lrb['sisiya.label.'.$str].': '.$lrb['sisiya.msg.ok.'.$str]);
}

function errorRecord($str)
{
	global $lrb;
	
	setStatusMessage(STATUS_ERROR,$lrb['sisiya.label.'.$str].': '.$lrb['sisiya.msg.error.'.$str]);
}

function displayButtonIcon($action_str,$rowid='-1')
{
	echo getButtonIcon($action_str,$rowid);
}

### If you need to specify value, use hidden input instead
function getButtonIcon($action_str,$rowid='-1')
{
	global $lrb;
	
	$s=$lrb['sisiya_admin.button.'.$action_str.'.description'];
	$html='<input name="'.$action_str;
	if($rowid != -1)  
		$html.='['.$rowid.']';
	$html.='" type="submit" value="" class="picture_button_'.$action_str.'" onmouseover="window.status='."'".$s."'".'; return true;" onmouseout="window.status='."''".';" title="'.$s.'" />';
	return($html);
}

function displayLinkIcon($action,$url_str)
{
	echo getLinkIcon($action,$url_str);
}

function getLinkIcon($action,$url_str)
{
	global $lrb;

	$s='<a href="'.$url_str.'"><img src="'.SISIYA_IMG_URL.'/icon_'.$action.'.png" alt="'.$lrb['sisiya_admin.button.'.$action].'" title="'.$lrb['sisiya_admin.button.'.$action.'.description'].'" /></a>';
	return $s;
}

# Returns reduction to a base (info,ok,warning,error or noreport for statusid16,32 or 48) statusid.
function getBaseStatusID2($status_id)
{
	$result_id=STATUS_INFO;
	switch($status_id) {
		case STATUS_NOREPORT				: 
		case STATUS_UNAVAILABLE				: 
		case (STATUS_NOREPORT + STATUS_UNAVAILABLE)	: 
								$result_id=STATUS_NOREPORT;		break;
		default						:
								$result_id=getBaseStatusID($status_id);	break;
	}
	#echo "status_id=".$status_id." result_id=".$result_id."<br />";
	return($result_id);
}

# Returns a reduction to a base (info,ok,warning,error,no report,unavailable) statusid.	
function getBaseStatusID($status_id)
{
	if($status_id == STATUS_INFO)
		return(STATUS_INFO);
	else if($status_id > STATUS_INFO and $status_id < STATUS_WARNING)
		return(STATUS_OK);
	else if($status_id >= STATUS_WARNING and $status_id < STATUS_ERROR)
		return(STATUS_WARNING);
	else if($status_id >= STATUS_ERROR and $status_id < STATUS_NOREPORT)
		return(STATUS_ERROR);
	else if($status_id < STATUS_UNAVAILABLE) {
		$t=$status_id-STATUS_NOREPORT;
		if($status_id == STATUS_NOREPORT)
			return(STATUS_NOREPORT);
		else if($t < STATUS_WARNING)
			return(STATUS_NOREPORT); 
		else if($t < STATUS_ERROR)
			return(STATUS_NOREPORT); 
		else 
			return(STATUS_ERROR); 	
	}
	else if($status_id < STATUS_MWARNING) {
		$t=$status_id-STATUS_UNAVAILABLE;
		if($status_id == STATUS_UNAVAILABLE)
			return(STATUS_UNAVAILABLE);	
		else if($t < STATUS_WARNING)
			return(STATUS_UNAVAILABLE);	
		else if($t < STATUS_ERROR)
			return(STATUS_UNAVAILABLE);	
		else
			return(STATUS_ERROR);		
	}
	else if($status_id < 128) {
		$t=$status_id-STATUS_MWARNING;
		if($status_id == STATUS_MWARNING)
			return(STATUS_WARNING);		
		else if($t < STATUS_WARNING)
			return(STATUS_WARNING);		
		else if($t < STATUS_ERROR)
			return(STATUS_WARNING);		
		else
			return(STATUS_ERROR);		
	}
	else if($status_id < STATUS_MNOREPORT) {
		$t=$status_id-STATUS_MERROR;
		if($status_id == STATUS_MERROR)
			return(STATUS_ERROR);
		else if($t < STATUS_WARNING)
			return(STATUS_ERROR);
		else if($t < STATUS_ERROR)
			return(STATUS_ERROR);
		else
			return(STATUS_ERROR);
	}
	else if($status_id < STATUS_MUNAVAILABLE) {
		$t=$status_id-STATUS_MNOREPORT;
		if($status_id == STATUS_MNOREPORT)
			return(STATUS_ERROR);
		else if($t < STATUS_WARNING)
			return(STATUS_ERROR);
		else if($t < STATUS_ERROR)
			return(STATUS_ERROR);
		else
			return(STATUS_ERROR);
	}
	else {
		$t=$status_id-STATUS_MUNAVAILABLE;
		if($status_id == STATUS_MUNAVAILABLE)
			return(STATUS_ERROR);
		else if($t < STATUS_WARNING)
			return(STATUS_ERROR);
		else if($t < STATUS_ERROR)
			return(STATUS_ERROR);
		else
			return(STATUS_ERROR);
	}
}


function displayStatusImage($status_id)
{
	echo getStatusImage($status_id);
}

function getStatusImage($status_id)
{
	global $statusNames;
	
	if($status_id == 1)
		return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_INFO].'_big.png');
	else if($status_id > 1 and $status_id < 4)
		return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_OK].'_big.png');
	else if($status_id >= 4 and $status_id < 8)
		return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_WARNING].'_big.png');
	else if($status_id >= 8 and $status_id < 16)
		return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_ERROR].'_big.png');
	else if($status_id < 32) {
		$t=$status_id-STATUS_NOREPORT;
		if($status_id == STATUS_NOREPORT)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_NOREPORT].'_big.png');
		else if($t < STATUS_WARNING)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_NOREPORT].'Green_big.png');
		else if($t < STATUS_ERROR)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_NOREPORT].'Yellow_big.png');
		else 
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_NOREPORT].'Red_big.png');
	}
	else if($status_id < 64) {
		$t=$status_id-STATUS_UNAVAILABLE;
		if($status_id == STATUS_UNAVAILABLE)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_UNAVAILABLE].'_big.png');
		else if($t < STATUS_WARNING)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_UNAVAILABLE].'Green_big.png');
		else if($t < STATUS_ERROR)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_UNAVAILABLE].'Yellow_big.png');
		else
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_UNAVAILABLE].'Red_big.png');
	}
	else if($status_id < 128) {
		$t=$status_id-STATUS_MWARNING;
		if($status_id == STATUS_MWARNING)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MWARNING].'_big.png');
		else if($t < STATUS_WARNING)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MWARNING].'Green_big.png');
		else if($t < STATUS_ERROR)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MWARNING].'_big.png');
		else
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MWARNING].'Red_big.png');
	}
	else if($status_id < 256) {
		$t=$status_id-STATUS_MERROR;
		if($status_id == STATUS_MERROR)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MERROR].'_big.png');
		else if($t < STATUS_WARNING)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MERROR].'Green_big.png');
		else if($t < STATUS_ERROR)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MERROR].'_big.png');
		else
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MERROR].'_big.png');
	}
	else if($status_id < 512) {
		$t=$status_id-STATUS_MNOREPORT;
		if($status_id == STATUS_MNOREPORT)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MNOREPORT].'_big.png');
		else if($t < STATUS_WARNING)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MNOREPORT].'Green_big.png');
		else if($t < STATUS_ERROR)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MNOREPORT].'Yellow_big.png');
		else
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MNOREPORT].'Red_big.png');
	}
	else {
		$t=$status_id-STATUS_MUNAVAILABLE;
		if($status_id == STATUS_MUNAVAILABLE)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MUNAVAILABLE].'_big.png');
		else if($t < STATUS_WARNING)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MUNAVAILABLE].'Green_big.png');
		else if($t < STATUS_ERROR)
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MUNAVAILABLE].'Yellow_big.png');
		else
			return(SISIYA_IMG_URL.'/'.$statusNames[STATUS_MUNAVAILABLE].'Red_big.png');
	}
}

function setParameterError($parameter_str)
{
	global $lrb;

	$_SESSION['status_type']=STATUS_ERROR;
	$_SESSION['status_message']=$lrb['sisiya_admin.msg.undefined_parameter'].' ('.$parameter_str.')';
}

### only includes regular files
function getFilesByExtension($path,$extension='')
{
	$list = array();
	$dir_handle=opendir($path);
	if($dir_handle == false) {
		echo 'Could not open directory : '.$path."!\n";
		return(false);
	}
	while($file = readdir($dir_handle)) { 
		if($file == '.' || $file == '..')
			continue;
		### skip links
		if(is_link($path.'/'.$file))
			continue;
		$filename=explode('.',$file);
		$ext=$filename[count($filename) - 1];
		if($ext == $extension) 
			array_push($list,$file);
	}
	if(count($list) > 0) {
		sort($list,SORT_STRING);
		return($list);
	}
	else
		return false;
}

function execSQL($sql_str)
{
	global $db;

	$result=$db->query($sql_str);
	if(! $result)
		 return -1;
	return $db->getAffectedRows($result);
}


### Calls execSQL and sets a status message.
function execSQLWrapper($action_str,$sql_str)
{
	debug('execSQLWrapper: action='.$action_str.' sql='.$sql_str);
	$n=execSQL($sql_str);
	debug('n='.$n);
	if($n < 1) 	errorRecord($action_str);
	else 		okRecord($action_str);
}

function getSystemName($systemID,$systems)
{
	for($i=0;$i<count($systems);$i++)
		if($systems[$i]['value'] == $systemID)
			return($systems[$i]['option']);
	return('');
}

function createSystemServiceHistoryGraphMap(&$map_str,$link_str,$image_file,$system_id,$service_id,$h,$w)
{
	global $db;

	$sql_str="select a.recievetime, a.statusid from systemhistorystatus a where a.systemid=".$system_id." and a.serviceid=".$service_id." order by a.recievetime desc";
	#echo $sql_str;
	$result=$db->query($sql_str);
	if(!$result)
		return;

	$map_str='<map id="map_'.$system_id.'_'.$service_id.'" name="map_'.$system_id.'_'.$service_id.'">';	
	$font_size=1;
	$dx=$w/(24*60); # x axis is 24 hours	timeline
	$dy=$h;
	#### y=m * x + n
	#### (0,23*60) -> (0,w)  => y=[w/23*60]*x  => m=w/23*60 n=0
	$m=$w/(24*60);
	$x_max=$w;
	$y_max=$h;
	$im = @ImageCreate ($x_max, $y_max) //canvas
			or die ("Cannot Initialize new GD image stream");
	### the first call to ImageColorAllocate sets the background color
	#$background_color = ImageColorAllocate ($im, 0, 255, 255);
	$background_color = ImageColorAllocate ($im, 255, 255, 255);
#	imagefilledrectangle($im,0,0,$w,$h,$background_color);

	$text_color 		= ImageColorAllocate ($im, 0, 0,0);
	$line_color 		= ImageColorAllocate ($im, 0, 0,0);
	$graph_color_blue	= ImageColorAllocate ($im,30,30,250);
	$graph_color_green 	= ImageColorAllocate ($im,70,190,70);
	$graph_color_red 	= ImageColorAllocate ($im,240,15,90);
	$graph_color_yellow	= ImageColorAllocate ($im,230,230,10);
	$x1=0;
	$y1=0;
	//end of graph
	$nrows=$db->getRowCount($result);
	$y1=0;
	$y2=$dy;
	$xp=-1;
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$hour=intval(substr($row[0],8,2));
		$min=intval(substr($row[0],10,2));
		$x1=$m*($hour*60+$min);
		$x2=$x1+$dx;
		switch(getBaseStatusID($row[1])) {
			case STATUS_INFO:
				$color_g=$graph_color_blue;
				break;
			case STATUS_OK:
				$color_g=$graph_color_green;
				break;
			case STATUS_WARNING:
				$color_g=$graph_color_yellow;
				break;
			case STATUS_ERROR:
				$color_g=$graph_color_red;
				break;
			default:
				$color_g=$graph_color_blue;
				break;
		}
		imagefilledrectangle($im,$x1,$y1,$x2,$y2,$color_g);
		if($xp != -1) {
			imagefilledrectangle($im,$xp,$y1,$x1,$y2,$color_g);
			$map_str.='<area shape="rect" coords="'.$xp.','.$y1.','.$x1.','.$y2.'" alt="map_link" href="'.$link_str.'#'.$i.'" />';
		}
		
		### save the previous x1
		$xp=$x1;
		debug($x1."-".$y1);
	}
	$map_str.='</map>';

	imageline($im,0,$dy/2,$w,$dy/2,$line_color);
	for($i=0;$i<25;$i++) {
		$x1=$m*$i*60;	
		if($i == 24)
			$x1=$x1-1;
		$xf1=$x1;
		$str=$i;
		if($i == 24)
			$xf1=$xf1-9;
		if(intval($i % 6) == 0) {
			imagestring($im,$font_size,$xf1,2*$dy/3,$str,$text_color);
			imageline($im,$x1,3*$dy/8,$x1,5*$dy/8,$line_color);
		}
		else {
			imageline($im,$x1,5*$dy/12,$x1,7*$dy/12,$line_color);
		}
	}

	# output image
	# Header('Content-type: image/png');
	if(imagepng($im,$image_file) == false)
		debug("ERROR: Yaratamadim");
	else
		debug("OK: Yarattim.");
	# clean up 
	ImageDestroy($im);
	$db->freeResult($result);
}


function createSystemServiceHistoryGraph1($image_file,$system_id,$service_id,$h,$w)
{
	global $db;

	$sql_str="select a.recievetime, a.statusid from systemhistorystatus a where a.systemid=".$system_id." and a.serviceid=".$service_id." order by a.recievetime desc";
	#echo $sql_str;
	$result=$db->query($sql_str);
	if(!$result)
		return;
	
	$font_size=1;
	$dx=$w/(24*60); # x axis is 24 hours	timeline
	$dy=$h;
	#### y=m * x + n
	#### (0,23*60) -> (0,w)  => y=[w/23*60]*x  => m=w/23*60 n=0
	$m=$w/(24*60);
	$x_max=$w;
	$y_max=$h;
	$im = @ImageCreate ($x_max, $y_max) //canvas
			or die ("Cannot Initialize new GD image stream");
	### the first call to ImageColorAllocate sets the background color
	#$background_color = ImageColorAllocate ($im, 0, 255, 255);
	$background_color = ImageColorAllocate ($im, 255, 255, 255);
#	imagefilledrectangle($im,0,0,$w,$h,$background_color);

	$text_color 		= ImageColorAllocate ($im, 0, 0,0);
	$line_color 		= ImageColorAllocate ($im, 0, 0,0);
	$graph_color_blue	= ImageColorAllocate ($im,30,30,250);
	$graph_color_green 	= ImageColorAllocate ($im,70,190,70);
	$graph_color_red 	= ImageColorAllocate ($im,240,15,90);
	$graph_color_yellow	= ImageColorAllocate ($im,230,230,10);
	$x1=0;
	$y1=0;
	//end of graph
	$nrows=$db->getRowCount($result);
	$y1=0;
	$y2=$dy;
	$xp=-1;
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$hour=intval(substr($row[0],8,2));
		$min=intval(substr($row[0],10,2));
		$x1=$m*($hour*60+$min);
		$x2=$x1+$dx;
		switch($row[1]) {
			case 0:
				$color_g=$graph_color_blue;
				break;
			case 1:
				$color_g=$graph_color_green;
				break;
			case 2:
				$color_g=$graph_color_yellow;
				break;
			case 3:
				$color_g=$graph_color_red;
				break;
		}
		imagefilledrectangle($im,$x1,$y1,$x2,$y2,$color_g);
		if($xp != -1) {
			imagefilledrectangle($im,$xp,$y1,$x1,$y2,$color_g);
		}
		
		### save the previous x1
		$xp=$x1;
		debug($x1."-".$y1);
	}

	imageline($im,0,$dy/2,$w,$dy/2,$line_color);
	for($i=0;$i<25;$i++) {
		$x1=$m*$i*60;	
		if($i == 24)
			$x1=$x1-1;
		$xf1=$x1;
		$str=$i;
		if($i == 24)
			$xf1=$xf1-9;
		if(intval($i % 6) == 0) {
			imagestring($im,$font_size,$xf1,2*$dy/3,$str,$text_color);
			imageline($im,$x1,3*$dy/8,$x1,5*$dy/8,$line_color);
		}
		else {
			imageline($im,$x1,5*$dy/12,$x1,7*$dy/12,$line_color);
		}
	}

	# output image
	# Header('Content-type: image/png');
	if(imagepng($im,$image_file) == false)
		debug("ERROR: Yaratamadim");
	else
		debug("OK: Yarattim.");
	# clean up 
	ImageDestroy($im);
	$db->freeResult($result);
}


function createSystemServiceHistoryGraph($result,$image_file,$system_id,$service_id,$h,$w)
{
	global $db;

	$sql_str="select a.recievetime, a.statusid from systemhistorystatus a where a.systemid=".$system_id." and a.serviceid=".$service_id." order by a.recievetime desc";
	#echo $sql_str;
	$result=$db->query($sql_str);
	
	$font_size=1;
	$dx=$w/(24*60); # x axis is 24 hours	timeline
	$dy=$h;
	#### y=m * x + n
	#### (0,23*60) -> (0,w)  => y=[w/23*60]*x  => m=w/23*60 n=0
	$m=$w/(24*60);
	$x_max=$w;
	$y_max=$h;
	$im = @ImageCreate ($x_max, $y_max) //canvas
			or die ("Cannot Initialize new GD image stream");
	### the first call to ImageColorAllocate sets the background color
	#$background_color = ImageColorAllocate ($im, 0, 255, 255);
	$background_color = ImageColorAllocate ($im, 255, 255, 255);
#	imagefilledrectangle($im,0,0,$w,$h,$background_color);

	$text_color 		= ImageColorAllocate ($im, 0, 0,0);
	$line_color 		= ImageColorAllocate ($im, 0, 0,0);
	$graph_color_blue	= ImageColorAllocate ($im,30,30,250);
	$graph_color_green 	= ImageColorAllocate ($im,70,190,70);
	$graph_color_red 	= ImageColorAllocate ($im,240,15,90);
	$graph_color_yellow	= ImageColorAllocate ($im,230,230,10);
	$x1=0;
	$y1=0;
	//end of graph
	$nrows=$db->getRowCount($result);
	$y1=0;
	$y2=$dy;
	$xp=-1;
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$hour=intval(substr($row[0],8,2));
		$min=intval(substr($row[0],10,2));
		$x1=$m*($hour*60+$min);
		$x2=$x1+$dx;
		switch($row[1]) {
			case 0:
				$color_g=$graph_color_blue;
				break;
			case 1:
				$color_g=$graph_color_green;
				break;
			case 2:
				$color_g=$graph_color_yellow;
				break;
			case 3:
				$color_g=$graph_color_red;
				break;
		}
		imagefilledrectangle($im,$x1,$y1,$x2,$y2,$color_g);
		if($xp != -1) {
			imagefilledrectangle($im,$xp,$y1,$x1,$y2,$color_g);
		}
		
		### save the previous x1
		$xp=$x1;
		debug($x1."-".$y1);
	}

	imageline($im,0,$dy/2,$w,$dy/2,$line_color);
	for($i=0;$i<25;$i++) {
		$x1=$m*$i*60;	
		if($i == 24)
			$x1=$x1-1;
		imageline($im,$x1,$dy/3,$x1,2*$dy/3,$line_color);
		$str=$i;
		if($i == 24)
			$x1=$x1-9;
		imagestring($im,$font_size,$x1,2*$dy/3,$str,$text_color);
	}

	# output image
	# Header('Content-type: image/png');
	if(imagepng($im,$image_file) == false)
		debug("ERROR: Yaratamadim");
	else
		debug("OK: Yarattim.");
	# clean up 
	ImageDestroy($im);
}
### Generates an array from a given select SQL. The array is used in select HTML.
function getSQL2SelectArray($sql_str)
{
	global $db;

	$select_array=array();

	debug('sql_str='.$sql_str);
	$result=$db->query($sql_str);
	if(!$result) {
		errorRecord('select');
	}
	else {
		$n=$db->getRowCount($result);
		for($i=0;$i<$n;$i++) {
			$row=$db->fetchRow($result,$i);
			$select_array[$i]['value']=$row[0];
			$select_array[$i]['option']=$row[1];
		}
		$db->freeResult($result);
	}
	return($select_array);
}


### select_array is of the form 
###	array(
###		0 => array('value' => 4, 'option' => 'xxxxx'),
###		1 => array('value' => 2, 'option' => 'yyyyy'),
###		...
###	)
###
function displaySelect($select_name,$key,$select_array,$onchange_str='')
{
	echo getSelect($select_name,$key,$select_array,$onchange_str); 
}

function getSelect($select_name,$key,$select_array,$onchange_str='')
{
	$s='<select name="'.$select_name.'"';
	if($onchange_str != '')
		$s.=' onchange="'.$onchange_str.'"';
	$s.='>'."\n";
	$s.='<option selected="selected" value="-" >-</option>'."\n";
	for($j=0;$j<count($select_array);$j++) {
		$s.='<option ';
		if($key == $select_array[$j]['value'])
			$s.='selected="selected" ';
		$s.='value="'.$select_array[$j]['value'].'">'.$select_array[$j]['option']."</option>\n";
	}
	$s.='</select>'."\n";
	return($s);
}

function getServiceName($serviceID)
{
	global $db;

	$serviceName='';

	$sql_str="select i.str from services a";
	$sql_str.=",interface i,strkeys s,languages l ";
	$sql_str.=" where a.id=".$serviceID;
	$sql_str.=" and a.keystr=s.keystr and l.code='".$_SESSION['language']."'";
	$sql_str.=" and l.id=i.languageid and i.strkeyid=s.id";
	debug($sql_str);
	$result=$db->query($sql_str);
	if($result) {
		$row=$db->fetchRow($result,0);
		$serviceName=$row[0];
		$db->freeResult($result);
	}
	return($serviceName);
}

function displayStatusMessage()
{
	echo getStatusMessage();
}

function getStatusMessage()
{
	#debug("status_message.php: status_type=".$_SESSION['status_type']." status_message=".$_SESSION['status_message']);
	$html='';
	if(isset($_SESSION['status_message']) && isset($_SESSION['status_type'])) {
		switch($_SESSION['status_type']) {
			case STATUS_INFO	:
				$html='<script type="text/javascript">window.status="'.$_SESSION['status_message'].'";</script>'."\n";
				break;
			case STATUS_OK		:
			case STATUS_WARNING	:
			case STATUS_ERROR	:
				$html.='<script type="text/javascript">alert("'.$_SESSION['status_message'].'");</script>'."\n";
				break;
		}
		unset($_SESSION['status_type']);
		unset($_SESSION['status_message']);
	}
	#if(isset($_SESSION['refresh']))
	#	echo '<script type="text/javascript">timedRefresh('.$_SESSION['refresh'].');</script>'."\n";
	return($html);
}

function getLanguageFileName($prefix,$suffix)
{
	global $defaultLanguage;

	$file_name=$prefix.$_SESSION['language'].$suffix;
	### check whether the specified language file exists or not. If does not exist, use the default language file.
	if(!file_exists($file_name))
		$file_name=$prefix.$defaultLanguage.$suffix;
	return($file_name);
}

/*
Sets the $_SESSION['hasAllSystems'] to true or false depending on wheter the user is in the All Systems security group or not.
If the $_SESSION['hasAllSystems'] is already set, the it just returns its value. 
*/
function hasAllSystems($userid)
{
	global $db,$force_login;

	# the login script calls this function witout a valid userid
	if($userid == '') {
		if($force_login)
			return false;
		else {
			$_SESSION['hasAllSystems']=true;
			return true;
		}	
	}	

	if(isset($_SESSION['hasAllSystems']))
		return $_SESSION['hasAllSystems'];
	$n=0;
	# groupid == 0 is the All Systems group
	$sql_str="select count(*) from securitygroups a,securitygroupuser b where a.id=0 and a.id=b.securitygroupid and b.userid=".$userid;
	$result=$db->query($sql_str);
	if($result) {
		$row=$db->fetchRow($result,0);
		$n=$row[0];
		$db->freeResult($result);
	}
	if($n == 1)
		$_SESSION['hasAllSystems']=true;
	else
		$_SESSION['hasAllSystems']=false;
	return $_SESSION['hasAllSystems'];
}

# validate the HTML content
function validateContent($html_str)
{
	$patterns=array('/</'		,'/>/');
	$replacements=array('&lt;'	,'&gt;');

	return preg_replace($patterns,$replacements,$html_str);
}


?>
