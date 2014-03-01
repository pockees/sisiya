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
global $debug;
$debug=false;

global $force_login;
$force_login=false;

global $ncolumns;
$ncolumns=40;

global $mainProg;
$mainProg=$progNameSisIYA_GUI;

global $adminProg;
$adminProg=$progNameSisIYA_Admin;

global $rssFile;
$rssFile=BASE_URL.'/sisiya_rss.xml';


# functions
include_once(LIB_DIR.'/sisiya_common_functions.php');
include_once(LIB_DIR.'/sisiya_gui_functions.php');
?>
