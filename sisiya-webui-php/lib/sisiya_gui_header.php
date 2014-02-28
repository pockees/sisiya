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


$h->addContent('<!-- header : start -->');
$h->addContent('<div class="div_gui_header">');
include_once($libDir.'/sisiya_gui_logo.php');
$h->addContent('		<div class="div_header_center">'.$header);
#$h->addContent('<br />__NAVIGATION_PANEL__');
$h->addContent('</div>');
$h->addContent('		<div class="div_float_right small_font div_right_text_align">');
if(isset($_SESSION['valid_user'])) {
	$h->addContent($_SESSION['user_name'].' '.$_SESSION['user_surname'].' ('.$_SESSION['valid_user'].') ');
	$h->addContent(getLinkIcon('logout',$loginProg.'?menu=gui&amp;destroy_session=1')); 
}
else {
	$h->addContent(getLinkIcon('login',$loginProg.'?menu=gui'));
}
$h->addContent(getLinkIcon('settings',$adminProg));
$h->addContent(getLinkIcon('download',$mainProg.'?menu=client_programs'));
$h->addContent(getLinkIcon('rss',$rssFile));
include_once($libDir.'/sisiya_gui_language.php');
$h->addContent('		<br />');
$h->addContent(getLastUpdated().'<br />');


$h->addContent('		</div> <!-- end of div_float_right -->');
$h->addContent('<div class="div_gui_menu">');
$h->addContent('	<div class="div_gui_menu_inner">');
include_once($libDir."/sisiya_gui_menu.php");
$h->addContent('	</div>');
$h->addContent('</div>');
$h->addContent('</div> <!-- end of div_gui_header -->');
$h->addContent('<!-- header :finish --> ');
?>
