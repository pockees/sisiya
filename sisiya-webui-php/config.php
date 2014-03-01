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
#error_reporting(E_ALL & ~E_DEPRECATED);

# DIRs
define('BASE_DIR' ,'/usr/share/sisiya-webui-php', false);
define('CONF_DIR' ,'/etc/sisiya/sisiya-webui-php', false);
define('JAVASCRIPT_DIR' ,BASE_DIR.'/javascrıpt', false);
define('VAR_DIR' ,'/var/lib/sisiya-webui-php', false);
define('LIB_DIR' ,BASE_DIR.'/lib', false);
define('LINKS_IMG_DIR' ,VAR_DIR.'/links', false);
define('PACKAGES_DIR' ,VAR_DIR.'/packages', false);
define('SYSTEMS_IMG_DIR' ,'/var/lib/sisiya-webui-images', false);
define('TMP_IMG_DIR' ,'/var/tmp/sisiya-webui-php', false);
# URLs
define('BASE_URL' ,'.', false);
define('CSS_URL' ,BASE_URL.'/style', false);
define('JAVASCRIPT_URL' ,BASE_URL.'/javascript', false);
define('IMG_URL' ,BASE_URL.'/images', false);
define('LIB_URL' ,BASE_URL.'/lib', false);
define('LINKS_IMG_URL' ,IMG_URL.'/links', false);
define('SISIYA_IMG_URL' ,IMG_URL.'/sisiya', false);
define('SYSTEMS_IMG_URL' ,IMG_URL.'/systems', false);
define('TMP_IMG_URL' ,IMG_URL.'/tmp', false);

?>
