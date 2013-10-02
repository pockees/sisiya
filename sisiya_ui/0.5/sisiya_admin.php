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
include_once($rootDir."/conf/sisiya_admin_conf.php");

startSession($sessionName);

###
if(!isset($_SESSION['valid_user'])) {
	### redirect
	header('Location: '.$loginProg);
	exit();
}

if(!initialize()) {
	echo $progName.": Could not initialize!<br>";
	exit;
}

$h=new HTMLDocument();

$menu=getHTTPValue('menu');
if($menu == '')
	$menu="systems";
$table=getHTTPValue('table');
$table_str='';
if($table != '') {
	$table_str='&amp;table='.$table;
	$header=$lrb['sisiya_admin.'.$table.'.header'];
	$title=$lrb['sisiya_admin.'.$table.'.title'];
}
else {
	$header=$lrb['sisiya_admin.'.$menu.'.header'];
	$title=$lrb['sisiya_admin.'.$menu.'.title'];
}
$language_params='menu='.$menu.$table_str;

$button=getHTTPValue('button');
if($button == $lrb['sisiya_admin.button.logout']) {
	destroySession();
	### redirect
	header('Location: '.$loginProg);
	exit();
}

#$user_name=$_SESSION['user_name'];
#$user_surname=$_SESSION['user_surname'];
#$valid_user=$_SESSION['valid_user'];
#$user_id=$_SESSION['user_id'];
#$is_admin=$_SESSION['is_admin'];

$menu_file=getLanguageFileName($rootDir.'/javascript/menu_items_','.js');

include_once($libDir."/sisiya_admin_docheader.php");

$h->addContent('<div class="div_container">'."\n");

$header_type='main';
include_once($libDir."/sisiya_admin_header.php");
$h->addContent('<div class="div_content">');
		$debug_str='';
		if(getHTTPValue('debug') != '')
			$debug_str='&amp;debug=1';
		$progName='sisiya_admin.php?menu='.$menu.$table_str.$debug_str;

		include_once($libDir.'/sisiya_admin_'.$menu.'.php');
		include_once($libDir.'/status_message.php');
		### save session
		session_write_close();
$h->addContent("</div> <!-- end of div_content -->\n");
$h->addContent("<p>&nbsp;</p>\n");
include_once($libDir."/sisiya_admin_footer.php");
$h->addContent('</div> <!-- end of div_container -->');

$html=$h->get();
echo $html;
?>
