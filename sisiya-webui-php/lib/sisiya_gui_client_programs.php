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
###########################################################
### begin of functions
###########################################################
function getPackages($dir,$ext)
{
	$html='';
	if($files = getFilesByExtension($dir,$ext)) {
		for($i=0;$i<count($files);$i++)
			$html.='<tr><td><a href="'.$dir.'/'.$files[$i].'">'.$files[$i].'</a></td></tr>'."\n";
	}
	return($html);
}

###########################################################
### end of functions
###########################################################
$systems=array(
	'Linux'		=> 'rpm',
	'Windows'	=> 'exe'
);


$navigation_panel_str=getLinkIcon('dashboard',$mainProg.'?menu=dashboard');
$navigation_panel_str.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>'; 
$navigation_panel_str.='<a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_detailed_view.png" alt="'.$lrb['sisiya_gui.label.detailed_view'].'" title="'.$lrb['sisiya_gui.label.detailed_view'].'" /></a>';
$navigation_panel_str.='<a href="'.$mainProg.'?menu=system_services'.$debug_str.'"><img src="'.SISIYA_IMG_URL.'/icon_system_services.png" alt="'.$lrb['sisiya_gui.system_services.header'].'" title="'.$lrb['sisiya_gui.label.system_services'].'" /></a>';

$h=$_SESSION['h'];
$h->addContent('<div>');
foreach($systems as $s => $ext) {
	$h->addContent('<table class="packages">');
	$h->addContent('<caption><img src="'.SYSTEMS_IMG_URL.'/'.$s.'.png" alt="'.$s.'" />'.$s.'</caption>');
	#h->addContent('<td>'.$lrb['sisiya_gui.label.client_packages'].'</td>');
	$h->addContent(getPackages(PACKAGES_DIR.'/'.$s, $ext));
	$h->addContent('</table>');
}
$h->addContent('</div>');
?>
