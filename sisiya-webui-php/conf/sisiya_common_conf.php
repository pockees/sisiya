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
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

define("VERSION","__VERSION__",false);
define("YEAR","__YEAR__",false);
define("SISIYA_URL","http://sisiya.example.com",false);

# Setup wizard
#include_once($rootDir.'/lib/sisiya_setup_wizard.php');

global $progNameSisIYA_GUI;
$progNameSisIYA_GUI=$rootDir.'/sisiya_gui.php';

global $progNameSisIYA_Admin;
$progNameSisIYA_Admin=$rootDir.'/sisiya_admin.php';

global $defaultTimezone;
$defaultTimezone = 'Europe/Istanbul';

# default language
global $defaultLanguage;
$defaultLanguage='tr';
global $defaultCharset;
$defaultCharset='utf-8';
                                                                                                                                                                                                          
### password related stuff                                                                                                                                                                                
global $min_password_length;                                                                                                                                                                              
$min_password_length=8;                                                                                                                                                                                   
global $salt_length;                                                                                                                                                                                      
$salt_length=12; ### Use MD5 with 12 character salt                                                                                                                                                       

global $resourceDir;
$resourceDir=$rootDir;

global $confDir;
$confDir=$rootDir."/conf";

global $libDir;
$libDir=$rootDir.'/lib';

global $cssDir;
$cssDir=$rootDir."/style";

global $imgDir;
#$imgDir=$rootDir."/images";
$imgDir="images";

global $linksImageDir;
$linksImageDir=$imgDir.'/links';

global $sisiyaImageDir;
$sisiyaImageDir=$imgDir.'/sisiya';

global $imgSystemsDirName;
$imgSystemsDirName='systems';

global $systemsImageDir;
$systemsImageDir=$imgDir.'/'.$imgSystemsDirName;

global $tmpImageDir;
$tmpImageDir=$imgDir.'/tmp';

global $sessionName;
$sessionName='sisiya_SID';

global $loginProg;
$loginProg=$rootDir.'/sisiya_login.php';

global $rssFile;
$rssFile=$rootDir.'/sisiya_rss.xml';

# Database classes
include_once($rootDir.'/lib/dbclass.php');

# HTML Document class
include_once($libDir.'/documentClass.php');

# Database configuration
include_once($rootDir.'/conf/dbconf.php');

# Common functions
include_once($libDir.'/sisiya_common_functions.php');

#########################################################################################################
### start of :do not change

### message status type definitions
define('STATUS_INFO'		,'1',false);
define('STATUS_OK'		,'2',false);
define('STATUS_WARNING'		,'4',false);
define('STATUS_ERROR'		,'8',false);
define('STATUS_NOREPORT'	,'16',false);
define('STATUS_UNAVAILABLE'	,'32',false);
define('STATUS_MWARNING'	,'64',false);
define('STATUS_MERROR'		,'128',false);
define('STATUS_MNOREPORT'	,'256',false);
define('STATUS_MUNAVAILABLE'	,'512',false);

# available languages
global $langs;
$langs=array();

# Language resource bundle, used to store language (key,strings) pairs
global $lrb;
$lrb=array();

### used for translating id's to str.
global $statusNames;
$statusNames=array( 
	STATUS_INFO 		=> 'Info', 
	STATUS_OK 		=> 'Ok', 
	STATUS_WARNING 		=> 'Warning', 
	STATUS_ERROR 		=> 'Error',
	STATUS_NOREPORT 	=> 'Noreport',
	STATUS_UNAVAILABLE	=> 'Unavailable',
	STATUS_MWARNING 	=> 'MWarning', 
	STATUS_MERROR 		=> 'MError',
	STATUS_MNOREPORT 	=> 'MNoreport',
	STATUS_MUNAVAILABLE	=> 'MUnavailable',
);

### used in tables for building HTML selects.
global $true_false;

### used in table headers for specifying search parameters
global $table_header_parameters;
### end of : do not change
#########################################################################################################

?>
