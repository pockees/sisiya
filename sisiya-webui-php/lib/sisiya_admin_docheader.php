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
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

*/
error_reporting(E_ALL);

### resources array
#global $rs;
$rs=array();

$rs['meta-author']='www.sisiya.net';
$rs['meta-description']='SisIYA system and network monitoring';
$rs['meta-generator']='sisiya_admin';
$rs['meta-keywords']='sisiya,system monitoring,network monitoring,snmp traps,web based,free';

$h->setDoctype('html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"');
$h->setHTMLTag('xmlns="http://www.w3.org/1999/xhtml"');
$h->setTitle($title);
$h->addHeadContent('<meta http-equiv="Content-Type" content="text/html; charset='.getCharset().'" />');
$h->addHeadContent('<meta http-equiv="X-UA-Compatible" content="IE=edge" />');
$h->addHeadContent('<link rel="stylesheet" type="text/css" href="'.$cssDir.'/style_common.css" />');
$h->addHeadContent('<link rel="stylesheet" type="text/css" href="'.$cssDir.'/style_admin.css" />');
$h->addHeadContent('<link rel="stylesheet" type="text/css" href="'.$cssDir.'/menu.css" />');
$h->addHeadContent('<meta name="author" content="'.$rs['meta-author'].'" />');
$h->addHeadContent('<meta name="generator" content="'.$rs['meta-generator'].'" />');
$h->addHeadContent('<meta name="description" content="'.$rs['meta-description'].'" />');
$h->addHeadContent('<meta name="keywords" content="'.$rs['meta-keywords'].'" />');
$h->addHeadContent('<script type="text/javascript" src="'.$rootDir.'/javascript/sisiya_common_functions.js"></script>');
if(preg_match("/sisiya_admin.php/",$progName)) {
	$h->addHeadContent('<!-- including menu javascript files -->');
	$h->addHeadContent('<script type="text/javascript" src="javascript/menu.js"></script>');
	$h->addHeadContent('<script type="text/javascript" src="'.$menu_file.'"></script>');
	$h->addHeadContent('<script type="text/javascript" src="javascript/menu_tpl.js"></script>');
	$h->addHeadContent('<!-- included menu javascript files -->');
}
?>
