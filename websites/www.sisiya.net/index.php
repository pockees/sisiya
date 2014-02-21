<?php
/*
    Copyright (C) 2010  Erdal Mutlu & Omer Lutfu Cunbul

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

global $rootDir;
$rootDir=".";
include_once($rootDir."/functions.php");
startSession($sessionName);

$user_ip=$_SERVER['REMOTE_ADDR'];

//$user_country=iptocountry($user_ip);

// This code demonstrates how to lookup the country, region, city,
// postal code, latitude, and longitude by IP Address.
// It is designed to work with GeoIP/GeoLite City

// Note that you must download the New Format of GeoIP City (GEO-133).
// The old format (GEO-132) will not work.

include("./geoip/geoipcity.inc");
//include("geoipregionvars.php");

// uncomment for Shared Memory support
// geoip_load_shared_mem("/usr/local/share/GeoIP/GeoIPCity.dat");
// $gi = geoip_open("/usr/local/share/GeoIP/GeoIPCity.dat",GEOIP_SHARED_MEMORY);

$gi = geoip_open("./geoip/GeoLiteCity.dat",GEOIP_STANDARD);
global $record;
$record = geoip_record_by_addr($gi,$user_ip);

$user_country = $record->country_code;
$user_country_code = $record->country_code3;
$user_country_name =$record->country_name;
//$user_region = $record->region . " " . $GEOIP_REGION_NAME[$record->country_code][$record->region] . "\n";
$user_city = $record->city . "\n";
//$user_postal_code = $record->postal_code . "\n";
//$user_latitude = $record->latitude . "\n";
//$user_longitude = $record->longitude . "\n";
//$user_metro_code = $record->metro_code . "\n";
//$user_area_code = $record->area_code . "\n";

geoip_close($gi);


$menu=getHTTPValue('menu');
if($menu == '')
	$menu="introduction";

global $language;
$language=getHTTPValue('language'); 
if($language == '') {
	if ($user_country == "TR")
	$language="tr";
	else
	$language="en";
}

$url="http://".$_SERVER['SERVER_NAME'].$_SERVER['PHP_SELF']."?menu=".$menu;  //."&amp;language=".$language;

include_once($rootDir."/menu_array.php");

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="tr" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />

<meta name="author" content="root" />
<meta name="generator" content="Bluefish 2.0.0" />
<meta name="description" content="SisIYA system and network monitoring" />
<meta name="keywords" content="sisiya,system monitoring,network monitoring,snmp traps,web based system monitoring,free system monitoring, computer systems monitoring" />

<!-- for arul: http://aruljohn.com/ -->
<link rel="icon" href="favicon.ico" type="image/x-icon" />
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<script src="./javascript/arul.js" type="text/javascript"></script>

<!-- for scrolling text-->
<script src="./javascript/scroll.js" type="text/javascript"></script>

<link rel="stylesheet" type="text/css" href="./style/style_common.css" />
<link rel="stylesheet" type="text/css" href="./style/style_gui.css" />
<!-- including GUI menu javascript files -->
<link rel="stylesheet" type="text/css" href="./style/gui_menu.css" />
<script type="text/javascript" src="./javascript/gui_menu.js"></script>
<script type="text/javascript" src="<?php echo './javascript/gui_menu_items_'.$language.'.js'; ?>"></script>
<script type="text/javascript" src="./javascript/gui_menu_tpl.js"></script>
<!-- included GUI menu javascript files -->
<script type="text/javascript" src="./javascript/un.js"></script>

<title><?php if ($language=='tr') echo 'Sistem İzleme ve Yönetim Araçları'; else echo 'System Monitoring and Management Tools'; ?></title>

</head>
<body>
<div class="div_container">
<div id="style_header">
 
<div id="style_header_before ">
</div>
 
<div id="style_header_main">

<div id="style_header_main_left">
<a href="http://www.sisiya.net/index.php?menu=yourinfo">
<img height="60" alt="SisIYA" src="images/SisIYA.png" />
</a>
</div>

<div id="style_header_main_center"> 	
<strong><?php if ($language=='tr') echo 'Sistem İzleme ve Yönetim Araçları'; else echo 'System Monitoring and Management Tools'; ?></strong><br />
<?php echo $subheader[$language][$menu]; ?>
</div>

<div id="style_header_main_right">
<strong><?php if ($language=='tr') echo 'Sisteminiz: '; else echo 'Your system: '; ?></strong>&nbsp;
<script type="text/javascript">document.write(yourOS()+"")</script>
&nbsp;&nbsp;<br />
<strong><?php if ($language=='tr') echo 'Tarayıcınız: '; else echo 'Your browser: '; ?></strong>&nbsp;
<script type="text/javascript">
//window.document.write(""+navigator.appName+"")
//document.write("("+navigator.appVersion+")");
//document.write(navigator.platform+ " "+ navigator.cpuClass)
//window.document.write(navigator.appCodeName+"&nbsp;&nbsp;")
document.write(yourBR()+"");
//var ip = '<!--#echo var="REMOTE_ADDR"-->';
//document.write("Your IP="+ip);
</script>
&nbsp;&nbsp;<br />
<strong><?php if ($language=='tr') echo 'IP adresiniz: '; else echo 'Your IP: '; ?></strong>&nbsp;<?php  echo $user_ip." (".$user_country_name.")"; ?>&nbsp;&nbsp;
<br />
<?php if($language== 'en') echo '<strong>'; ?><a class="language" href="<?php echo $url.'&amp;language=en'; ?>">en</a><?php if($language== 'en') echo '</strong>'; ?>&nbsp;
<?php if($language== 'tr') echo '<strong>'; ?><a class="language" href="<?php echo $url.'&amp;language=tr'; ?>">tr</a><?php if($language== 'tr') echo '</strong>'; ?>&nbsp;&nbsp;&nbsp;
</div>
 
<div id="style_header_main_bottom">
<div id="style_header_main_menu">
<script type="text/javascript"> new menu (MENU_ITEMS, MENU_TPL); </script>
</div>
</div>
 
</div>
</div>

<div id="div_content">
<div id="div_content_center">
<?php
include_once($rootDir."/".$menu.".php");
?>
<p>
</p>
</div> 
</div> 

<div id="style_footer">
© 2003 - 2010 <img id="db_" src="images/SisIYA_xsmall.png" alt="SisIYA" /> 
</div> 
</div> <!-- end of div_container -->
</body>
</html>

