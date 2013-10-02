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

global $rootDir,$progName;
$rootDir=".";

include_once($rootDir."/conf/sisiya_common_conf.php");
include_once($rootDir."/conf/sisiya_gui_conf.php");

startSession($sessionName);

###
if($force_login == true && !isset($_SESSION['valid_user'])) {
	### redirect
	header('Location: '.$loginProg);
	exit();
}

if(!initialize()) {
	echo $progName.": Could not initialize!<br>";
	exit;
}

$menu=getHTTPValue('menu');
if($menu == '')
	$menu="overview";

$header=$lrb['sisiya_gui.'.$menu.'.header'];
$title=$lrb['sisiya_gui.'.$menu.'.title'];

$h=new HTMLDocument();

$menu_file=getLanguageFileName($rootDir.'/javascript/gui_menu_items_','.js');

include_once($libDir."/sisiya_gui_docheader.php");

$h->addContent('<div class="div_container">');

$language_params='menu='.$menu;
include_once($libDir."/sisiya_gui_header.php");
$h->addContent('<div class="div_content">');
$h->addContent('	<div class="div_content_center">');	
$debug_str='';
if(getHTTPValue('debug') != '')
	$debug_str='&amp;debug=1';
$progName=$mainProg.'?menu='.$menu.$debug_str;

$navigation_panel_str='';
$_SESSION['h']=$h;
$h->addContent(getStatusMessage());
### save session
session_write_close();

include_once($libDir.'/sisiya_gui_'.$menu.'.php');

$h->addContent('	</div> <!-- end of div_content_center -->');
$h->addContent('</div> <!-- end of div_content -->');

include_once($rootDir."/lib/sisiya_gui_footer.php");
$h->addContent('</div> <!-- end of div_container -->');

$html=$h->get();
#####$html=preg_replace('/__NAVIGATION_PANEL__/',$navigation_panel_str,$html,1);
echo $html;
?>
