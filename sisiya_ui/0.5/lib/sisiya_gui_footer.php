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


$h->addContent('<div class="div_footer small_font" >'); 
#$h->addContent('	<div>');
$h->addContent('		'.$lrb['sisiya.label.symbol_info'].' : ');
/*
	for($i=0;$i<count($statusNames);$i++) {
		$s=$statusNames[$i];
		if($i != 0)
			echo "&nbsp;\n";
		echo '		<img class="center" src="'.$sisiyaImageDir.'/'.$s.'.png'.'" alt="'.$s.'" />';
		echo $lrb['sisiya.label.status.'.$s];
	}
*/
		$s='info';
		$h->addContent('		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_INFO].'.png'.'" alt="'.$s.'" />');
		$h->addContent($lrb['sisiya.label.status.Status1']);
		$h->addContent('		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_OK].'.png'.'" alt="'.$s.'" />');
		$h->addContent($lrb['sisiya.label.status.Status2']);
		$h->addContent('		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_WARNING].'.png'.'" alt="'.$s.'" />');
		$h->addContent($lrb['sisiya.label.status.Status4']);
		$h->addContent('		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_ERROR].'.png'.'" alt="'.$s.'" />');
		$h->addContent($lrb['sisiya.label.status.Status8']);
		$h->addContent('		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_NOREPORT].'.png'.'" alt="'.$s.'" />');
		$h->addContent($lrb['sisiya.label.status.Status16']);
		$h->addContent('		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_UNAVAILABLE].'.png'.'" alt="'.$s.'" />');
		$h->addContent($lrb['sisiya.label.status.Status32']);
		$h->addContent('		<img class="center" src="'.$sisiyaImageDir.'/icon_maintenance.png'.'" alt="'.$s.'" />');
		$h->addContent($lrb['sisiya.label.maintenance']);
/*
		echo '		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_MWARNING].'.png'.'" alt="'.$s.'" />');
		echo $lrb['sisiya.label.status.Status64']);
		echo '		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_MERROR].'.png'.'" alt="'.$s.'" />');
		echo $lrb['sisiya.label.status.Status128']);
		echo '		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_MNOREPORT].'.png'.'" alt="'.$s.'" />');
		echo $lrb['sisiya.label.status.Status256']);
		echo '		<img class="center" src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_MUNAVAILABLE].'.png'.'" alt="'.$s.'" />');
		echo $lrb['sisiya.label.status.Status512']');
*/
#$h->addContent('<br />');
$h->addContent('© 2003 - '.YEAR.' SisIYA '.$lrb['sisiya.label.version'].': '.VERSION);
#$h->addContent('	</div> <!-- end of version info -->');
$h->addContent('</div> <!-- end of div_footer -->');
?>
