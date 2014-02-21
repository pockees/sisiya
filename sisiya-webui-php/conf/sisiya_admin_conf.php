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
global $debug;
$debug=false;

global $sendMessageProg;
$sendMessageProg='/opt/sisiya_client_checks/bin/sisiya_send_message.sh /opt/sisiya_client_checks/sisiya_client.conf';

### number of records per page
global $nrecords_per_page;
$nrecords_per_page=20;

### max number of pages to be shown
global $max_pages;
$max_pages=5;

global $mainProg;
$mainProg=$progNameSisIYA_Admin;

global $max_upload_files_size;
$max_upload_files_size=200000;

global $allowed_types;
$allowed_types=array(
		0	=> 'image/gif',
		1	=> 'image/jpeg',
		2	=> 'image/png',
		3	=> 'image/ico'
	);

# functions
#include_once($libDir.'/sisiya_common_functions.php');
include_once($libDir.'/sisiya_admin_functions.php');

?>
