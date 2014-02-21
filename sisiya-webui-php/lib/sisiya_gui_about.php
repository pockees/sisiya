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
###########################################################
### begin of functions
###########################################################
###########################################################
### end of functions
###########################################################
$html='<a href="http://sisiya.sourceforge.net">SisIYA at Sourceforge</a>';
$html.='<br />';
$html.='<a href="http://www.sisiya.net">SisIYA Website</a>';
$html.='<p>'."\n";
$html.='<a href="http://sourceforge.net/projects/sisiya"><img src="http://sourceforge.net/sflogo.php?group_id=115771&amp;type=1" width="88" height="31" alt="SourceForge.net Logo" />SisIYA Development</a>';
$html.='</p>';

$h=$_SESSION['h'];
$h->addContent($html);
?>
