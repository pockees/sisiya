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
$h->addContent('<div class="div_header">');
include_once(LIB_DIR.'/sisiya_admin_logo.php');
$h->addContent('	<div class="div_header_center">'.$header.'</div>');
$h->addContent('	<div class="div_float_right small_font">');
$h->addContent('	'.$_SESSION['user_name'].' '.$_SESSION['user_surname'].' ('.$_SESSION['valid_user'].')');
$h->addContent(getLinkIcon('logout',$loginProg.'?menu=admin&amp;destroy_session=1')); 
$h->addContent(getLinkIcon('monitoring',$progNameSisIYA_GUI)); 
include_once(LIB_DIR.'/sisiya_admin_language.php');
$h->addContent('	</div> <!-- end of div_float_right -->');
$h->addContent('	<div class="div_admin_menu">');
$h->addContent('		<div class="div_admin_menu_inner">');
include(LIB_DIR.'/sisiya_admin_menu.php');
$h->addContent('		</div> <!-- end of div_admin_menu_inner -->');
$h->addContent('	</div> <!-- end of div_admin_menu -->');
$h->addContent('</div> <!-- end of div_header -->');
$h->addContent('<!-- header :finish -->');
?>
