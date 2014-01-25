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
$rootDir='/var/www/html/sisiya';

include_once($rootDir."/conf/sisiya_common_conf.php");
include_once($rootDir."/conf/sisiya_gui_conf.php");

$prog_name=$_SERVER['PHP_SELF'];

select a.hostname,b.serviceid,b.statusid,b.updatetime,b.expires from systems as a left join systemservicestatus as b on a.id=b.systemid where a.active='t'

