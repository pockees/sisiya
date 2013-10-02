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


# build up corresponding connection to db

switch($dbType) {
	case 'MySQL' :
		$db=new MySQL_DBClass($db_server,$db_name,$db_user,$db_password);
		break;
	case 'Oracle' :
		$db=new Oracle_DBClass($db_server,$db_name,$db_user,$db_password);
		break;
	case 'PostgreSQL' :
		$db=new PostgreSQL_DBClass($db_server,$db_name,$db_user,$db_password);
		break;
	default :
		echo 'Unsupported DB Type!';
		exit;
		break;
}

#$db->debug();
$db->connect();
?>
