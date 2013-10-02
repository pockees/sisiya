<?php
/*
    Copyright (C) 2008  Erdal Mutlu

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
# Database classes
include_once("dbclass.php");

# Database configuration
include_once("dbconf.php");

# Common functions
include_once("sisiya_functions.php");

global $progNameSisIYA;
$progNameSisIYA='sisiya.php';
global $sendMessageProg;
$sendMessageProg='/opt/sisiya_client_checks/bin/sisiya_send_message.sh /opt/sisiya_client_checks/sisiya_client.conf';

global $sessionName;
$sessionName='sisiya_admSID';
global $min_password_length;
$min_password_length=8;
global $salt_length;
$salt_length=12; ### Use MD5 with 12 character salt


# default language
global $defaultLanguage;
$defaultLanguage='en';
global $defaultCharset;
$defaultCharset='iso-8859-1';

# available languages
global $langs;
$langs=array(0=>'tr',1=>'en',2=>'de',3=>'ru');

# Language resource bundle, used to store language (key,strings) pairs
global $lrb;
$lrb=array();

### Jabber settings
$jabber_server='message.example.org'; 
$jabber_port=5222;
$jabber_user='sisiya';
$jabber_password='sisiya';
###
?>
