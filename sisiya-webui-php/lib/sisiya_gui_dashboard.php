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
function getSystemServiceStatusHistoryPanel($effectsglobal='')
{
	global $lrb,$sisiyaImageDir,$tmpImageDir,$statusNames;

	$title_str=$lrb['sisiya.label.HistoryOfServices'];
	if ($effectsglobal == '') {
		$effectsglobal_str='';
		$image_file=$tmpImageDir.'/system_service_status_history_all.png';
	}
	else {
		$effectsglobal_str=" and b.effectsglobal='".$effectsglobal."'";
		$image_file=$tmpImageDir.'/system_service_status_history_'.$effectsglobal.'.png';
	}


	$sql_str="select substr(a.recievetime,1,11),a.statusid,count(a.statusid) from systemhistorystatus a,systems b where a.systemid=b.id and b.active='t' ".$effectsglobal_str." group by substr(a.recievetime,1,11),a.statusid order by substr(a.recievetime,1,11),a.statusid;";
	getSystemServiceStatusHistory($image_file,$sql_str); 
	$html='';
	$html.='<table class="dashboard">'."\n";
	#$html.='<caption class="dashboard">'.$lrb['sisiya_admin.label.system_status'].'</caption>'."\n";
	$html.='<caption class="dashboard">'.$title_str.'</caption>'."\n";
	$html.="<tr>\n";
	$html.='<td colspan="2"><img src="'.$image_file.'" alt="System status pie" /></td>';
	$html.="</tr>\n";
	$html.="</table>\n";

	return $html;
}


function getSystemServiceStatusHistory(&$image_file,$sql_str)
{
	global $db,$tmpImageDir;

	debug('sql_str='.$sql_str);
	$result=$db->query($sql_str);
	if (!$result)
		errorRecord('select');
	else {
		$w=400;
		$h=150;
		createHistoryLineGraph($result,$image_file,$h,$w);
		$db->freeResult($result);
	}
}

function createHistoryLineGraph($result,$image_file,$H,$W)
{
	global $db,$statusNames;

	#row[0]=timestamp;
	#row[1]=statusid
	#row[2]=count

	$font_h=20;
	$font_w=22;

	$dh=5;
	$dw=5;
	
	$x_title_h=12;
	$x_axis_h=10;

	$y_title_w=16;
	$y_axis_w=12;


	$h=$H-$font_h;
	$w=$W;

	$x_origin=$font_w;
	$y_origin=0;

	$font_size=1;
	$x_line_count=24*2;
	$dx=($w-2*$font_w)/$x_line_count; # x axis is 24 hours	timeline
	$dy=$h/10;
	$m=720/(24*60);
	$x_max=$W;
	$y_max=$H;
	$im = @ImageCreate ($x_max, $y_max) 
			or die ("Cannot Initialize new GD image stream");
	### the first call to ImageColorAllocate sets the background color
	#$background_color = ImageColorAllocate ($im, 0, 255, 255);
	$background_color = ImageColorAllocate ($im, 255, 255, 255);

	$text_color 		= ImageColorAllocate ($im, 0, 0, 0);
	$line_color 		= ImageColorAllocate ($im, 0, 0, 0);
	$graph_color_gray	= ImageColorAllocate ($im,60,60,60);
	$graph_color_magenta= ImageColorAllocate ($im,144,53,160);
	$graph_color_blue	= ImageColorAllocate ($im,30,30,250);
	$graph_color_green 	= ImageColorAllocate ($im,70,220,70); //($im,70,190,70);
	$graph_color_red 	= ImageColorAllocate ($im,240,10,80); //($im,240,15,90);
	$graph_color_yellow	= ImageColorAllocate ($im,230,230,10);
	$graph_color_blue1	= ImageColorAllocate ($im,30,30,250);
	$graph_color_green1 = ImageColorAllocate ($im,107,189,91);
	$graph_color_red1 	= ImageColorAllocate ($im,240,57,62);
	$graph_color_yellow1= ImageColorAllocate ($im,221,216,48);
	$graph_color_black	= ImageColorAllocate ($im,0,0,0);
	$graph_color_white	= ImageColorAllocate ($im,255,255,255);	
	$axis_color			= ImageColorAllocate ($im,210,90,205);	
	$axis_font_color	= ImageColorAllocate ($im,14,55,55);	
	
	//end of graph
	$nrows=$db->getRowCount($result);

	$x_axis_color	= ImageColorAllocate ($im,200,200,200);	
	$y_axis_color=$x_axis_color;
	#imagerectangle($im,0,0,$w,$h,$graph_color_blue);
	### x axis lines
	for($i=0;$i<$x_line_count+1;$i++) {
		$x1=$x_origin+$i*$dx;
		$y1=$y_origin;
		$x2=$x1;
		$y2=$h;
		imageline($im,$x1,$y1,$x2,$y2,$x_axis_color);
		# baseline tick
		if ($i % 2 == 0) {
			imageline($im,$x1,$h-3,$x2,$h+3,$graph_color_black);
		}
		# x axis labels
		if ($i % 12 == 0) {
			$str=$i/2;
			imagestring($im,$font_size,$x1-3,$h+5,$str,$text_color);
		}
		
	}
	# y axis lines
	for($i=0;$i<11;$i++) {
		$x1=$x_origin;
		$y1=$i*$dy;
		$x2=$w-$font_w;
		$y2=$y1;
		imageline($im,$x1,$y1,$x2,$y2,$y_axis_color);

		# y axis labels
		$str=(10-$i)*10;
		$str=$str.'%';
		$x1=0;
		$y1=$i*$dy;
		if ($i<10)
			imagestring($im,$font_size,$x1,$y1,$str,$text_color);
	}
	
	$nrows=$db->getRowCount($result);
	if ($nrows == 0)
		return;
	$system_status_history_count=array(array());
	$system_status_history_total=0;
	$system_status_history_total_max=0;

	for ($j=0;$j<count($statusNames);$j++) {
		for($i=0;$i<144;$i++) {
			$jj=pow(2,$j);
			$system_status_history_count[$i*10][$jj]=-1;
		}
	}
	$time_stamp=0;
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$time_stamp=60*intval(substr($row[0],8,2))+10*intval(substr($row[0],10,1));
		$status_stamp=$row[1];
#		echo $status_stamp.'|';
		$system_status_history_count[$time_stamp][$status_stamp]=$row[2];
		$system_status_history_total=array_sum($system_status_history_count[$time_stamp]);
		if ($system_status_history_total > $system_status_history_total_max)
			$system_status_history_total_max=$system_status_history_total;
	}
	//echo $system_status_history_count[610][3]."-";
	//echo $system_status_history_total.":";
	//echo $system_status_history_total_max;
		$dx=($w-$font_w-$x_origin)/144;
		$dy=($y_origin-$h)/$system_status_history_total_max;
		$x1=$x_origin;
		$y1=$h;
		$x2=$w-$font_w;
		$y2=$y_origin;
	//echo $dx."-".$dy;	
	for ($j=0;$j<count($statusNames);$j++) {
		$zz=0;
		$xx1=0;
		$yy1=0;
		$xx2=0;
		$yy2=0;
		for($i=0;$i<$time_stamp/10;$i++) {
		$jj=pow(2,$j);
			if ($system_status_history_count[$i*10][$jj]>0) {
			$xx1=$x1+$dx*$i;
####			$xx2=$x1+$dx*($i+1);
			$yy1=$y1+$dy*$system_status_history_count[$i*10][$jj];
####				$yy2=$y1+$dy*$system_status_history_count[$i*10+10][$jj];

				switch($jj) {
					case STATUS_INFO:
						$color_g=$graph_color_blue;
						break;
					case STATUS_OK:
						$color_g=$graph_color_green;
						break;
					case STATUS_WARNING:
					case STATUS_MWARNING:
						$color_g=$graph_color_yellow;
						break;
					case STATUS_ERROR:
					case STATUS_MERROR:
						$color_g=$graph_color_red;
						break;
					case STATUS_NOREPORT:
					case STATUS_MNOREPORT:
						$color_g=$graph_color_gray;
						break;
					case STATUS_UNAVAILABLE:
					case STATUS_MUNAVAILABLE:
						$color_g=$graph_color_magenta;
						break;
				}
				if ($zz==1) {
				#				imagefilledrectangle($im,$xx1-1,$yy2-1,$xx1+1,$yy2+1,$color_g);
				imageline($im,$xx1,$yy1,$xx2,$yy2,$color_g);
				imageline($im,$xx1,$yy1+1,$xx2,$yy2+1,$color_g);
#				imageline($im,$xx1,$yy1-1,$xx2,$yy2-1,$color_g);
				}
			$xx2=$xx1;
			$yy2=$yy1;				
			$zz=1;
			}
		}
	}
	if (imagepng($im,$image_file) == false)
		debug("ERROR: Yaratamadim");
	else
		debug("OK: Yarattim.");
	# clean up 
	ImageDestroy($im);
}

function createSystemStatusPie($info_count, $ok_count, $warning_count, $error_count, $other_count, $result, $image_file, $h, $w)
{
	global $db;

	$image = imagecreatetruecolor($w, $h);

	# allocate some solors
	$white = imagecolorallocate($image, 0xFF, 0xFF, 0xFF);
	$gray = imagecolorallocate($image, 0xC0, 0xC0, 0xC0);
	$darkgray = imagecolorallocate($image, 0x90, 0x90, 0x90);
	$navy = imagecolorallocate($image, 0x00, 0x00, 0xC0);
	$darknavy = imagecolorallocate($image, 0x00, 0x00, 0x90);
	$red = imagecolorallocate($image, 0xFF, 0x00, 0x00);
	$darkred = imagecolorallocate($image, 0x90, 0x00, 0x00);
	$yellow = imagecolorallocate($image, 0xFF, 0xFF, 0x00);
	$darkyellow = imagecolorallocate($image, 0x90, 0x90, 0x00);
	$green = imagecolorallocate($image, 0x00, 0xC0, 0x00);
	$darkgreen = imagecolorallocate($image, 0x00, 0x90, 0x00);

	imagefilledrectangle($image, 0, 0 ,$w, $h,$white);

	# box parameters
	$font_size = 2;
	$dh = 4;
	$dw = 4;
	$font_h = imagefontheight($font_size);
	$box_h = $font_h + $dh;
	$box_w = $w - 2 * $dw;
	$box_x_gap = $box_w / 5;
	$box_dw = 2;

	# small square
	$sq = $font_h;

	$box_y = $h - $sq - 2 * $dh;

	$box_x0 = $dw;
	$box_x1 = $box_x0 + $box_dw;
	$box_y0 = $h-$sq - 2 * $dh;
	$box_y1 = $box_y0 + ($box_h - $sq) / 2;
	$box_y2 = $box_y0 + ($box_h + $sq) / 2;

	$x1 = $box_x0;
	$x2 = $box_w + $dw;
	$y1 = $box_y0;
	$y2 = $box_y + $box_h;
	imagerectangle($image, $x1, $y1, $x2, $y2, $gray);
	$total = $info_count + $ok_count + $warning_count + $error_count + $other_count;
	if ($total > 0) {
		$x1 = $box_x1;
		$x2 = $x1 + $sq;
		$y1 = $box_y1;
		$y2 = $box_y2;
		imagefilledrectangle($image, $x1, $y1, $x2, $y2, $navy);
		imagestring($image, $font_size, $x2 + $box_dw, $y1, round(100 * $info_count / $total)."%",$darkgray);

		$x1 = $x1 + $box_x_gap;
		$x2 = $x1 + $sq;
		imagefilledrectangle($image, $x1, $y1, $x2, $y2, $green);
		imagestring($image, $font_size, $x2 + $box_dw, $y1, round(100 * $ok_count / $total)."%", $darkgray);
	
		$x1 = $x1 + $box_x_gap;
		$x2 = $x1 + $sq;
		imagefilledrectangle($image, $x1, $y1, $x2, $y2, $yellow);
		imagestring($image, $font_size, $x2 + $box_dw, $y1, round(100 * $warning_count / $total)."%", $darkgray);
	
		$x1 = $x1 + $box_x_gap;
		$x2 = $x1 + $sq;
		imagefilledrectangle($image, $x1, $y1, $x2, $y2, $red);
		imagestring($image, $font_size, $x2 + $box_dw, $y1, round(100 * $error_count / $total)."%", $darkgray);
	
		$x1 = $x1 + $box_x_gap;
		$x2 = $x1 + $sq;
		imagefilledrectangle($image, $x1, $y1, $x2, $y2, $gray);
		imagestring($image, $font_size, $x2 + $box_dw, $y1, round(100 * $other_count / $total)."%", $darkgray);

		# make the 3D effect
		#$z1 = 90;
		#$z2 = 90 + 360 * $info_count / $total;
		#$z3 = 90 + 360 * ($info_count + $ok_count) / $total;
		#$z4 = 90 + 360 * ($info_count + $ok_count + $warning_count) / $total;
		#$z5 = 90 + 360 * ($info_count + $ok_count + $warning_count + $error_count) / $total;
		#$z6 = 90 + 360 * ($info_count + $ok_count + $warning_count + $error_count + $other_count) / $total;
		#$z6 = 90 + 360;
	
		$z1 = 90;
		$z2 = $z1 + round(360 * $info_count / $total);
		$z3 = $z2 + round(360 * $ok_count / $total);
		$z4 = $z3 + round(360 * $warning_count / $total);
		$z5 = $z4 + round(360 * $error_count / $total);
		$z6 = $z5 + round(360 * $other_count / $total);
		#$z6 = 90 + 360;

		$rx = $w / 2 - 2 * $dw;
		$ry = $rx / 2;
		$cx = $dw + $rx;
		$cy = $dh + $ry;
		for ($i = $cy + 15; $i > $cy; $i--) {
			if ($z1 <> $z2)
				imagefilledarc($image, $cx, $i, 2 * $rx, 2*$ry, $z1, $z2, $darknavy, IMG_ARC_PIE);
			if ($z2 <> $z3)
				imagefilledarc($image, $cx, $i, 2 * $rx, 2*$ry, $z2, $z3, $darkgreen, IMG_ARC_PIE);
			if ($z3 <> $z4)
				imagefilledarc($image, $cx, $i, 2 * $rx, 2*$ry, $z3, $z4, $darkyellow, IMG_ARC_PIE);
			if ($z4 <> $z5)
				imagefilledarc($image, $cx, $i, 2 * $rx, 2*$ry, $z4, $z5, $darkred, IMG_ARC_PIE);
			if ($z5 <> $z6)
				imagefilledarc($image, $cx, $i, 2 * $rx, 2*$ry, $z5, $z6, $darkgray, IMG_ARC_PIE);
		}
		if ($z1 <> $z2)
			imagefilledarc($image, $cx, $cy, 2 * $rx, 2 * $ry, $z1, $z2, $navy, IMG_ARC_PIE);
		if ($z2 <> $z3)
			imagefilledarc($image, $cx, $cy, 2 * $rx, 2 * $ry, $z2, $z3, $green, IMG_ARC_PIE);
		if ($z3 <> $z4)
			imagefilledarc($image, $cx, $cy, 2 * $rx, 2 * $ry, $z3, $z4, $yellow, IMG_ARC_PIE);
		if ($z4 <> $z5)
			imagefilledarc($image, $cx, $cy, 2 * $rx, 2 * $ry, $z4, $z5, $red, IMG_ARC_PIE);
		if ($z5 <> $z6)
			imagefilledarc($image, $cx, $cy, 2 * $rx, 2 * $ry, $z5, $z6, $gray, IMG_ARC_PIE);
	}
	imagepng($image, $image_file);
	imagedestroy($image);
}


function getNavigationPan()
{
	global $lrb,$mainProg,$debug_str,$sisiyaImageDir;
/*
	$html='';
	$html.='<table class="navigation">'."\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="left"><a href="'.$mainProg.'?menu=overview'.$debug_str.'">'.$lrb['sisiya_gui.label.overview'].'</a></td>';
	$html.='<td><a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'">'.$lrb['sisiya_gui.label.detailed_view'].'</a></td>';
	$html.='<td class="right"><a href="'.$mainProg.'?menu=system_services'.$debug_str.'">'.$lrb['sisiya_gui.label.system_services'].'</a></td>';
	$html.="</tr>\n";
	$html.="</table>\n";
*/

	$html='';
#	$html.='<table class="navigation">'."\n";
#	$html.='<tr class="row">'."\n";
#	$html.='<td>';
	$html.='<a href="'.$mainProg.'?menu=switch_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_switch_view.png" alt="'.$lrb['sisiya_gui.label.switch_view'].'" title="'.$lrb['sisiya_gui.label.switch_view'].'" /></a>';
	$html.='<a href="'.$mainProg.'?menu=overview'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_overview.png" alt="'.$lrb['sisiya_gui.label.overview'].'" title="'.$lrb['sisiya_gui.label.overview'].'" /></a>';
	$html.='<a href="'.$mainProg.'?menu=detailed_view'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_detailed_view.png" alt="'.$lrb['sisiya_gui.label.detailed_view'].'" title="'.$lrb['sisiya_gui.label.detailed_view'].'" /></a>';
	$html.='<a href="'.$mainProg.'?menu=system_services'.$debug_str.'"><img src="'.$sisiyaImageDir.'/icon_system_services.png" alt="'.$lrb['sisiya_gui.system_services.header'].'" title="'.$lrb['sisiya_gui.label.system_services'].'" /></a>';
#	$html.="</td></tr>\n";
#	$html.="</table>\n";

	return $html;
}

function getSystemStatusCount(&$info_count,&$ok_count,&$warning_count,&$error_count,&$other_count,&$image_file,$sql_str)
{
	global $db,$tmpImageDir;

	$info_count=0;
	$ok_count=0;
	$warning_count=0;
	$error_count=0;
	$other_count=0;

	debug('sql_str='.$sql_str);
	$result=$db->query($sql_str);
	if (!$result)
		errorRecord('select');
	else {
		$nrows = $db->getRowCount($result);
		for($i = 0; $i < $nrows; $i++) {
			$row = $db->fetchRow($result, $i);
			#$base_statusid = getBaseStatusID2($row[0]);
			#echo "statusid=".$row[0]." base statusid=".$base_statusid."<br />";
			switch(getBaseStatusID2($row[0])) {
				case STATUS_INFO:
					$info_count+=$row[1];
					break;
				case STATUS_OK:
					$ok_count+=$row[1];
					break;
				case STATUS_WARNING:
					$warning_count+=$row[1];
					break;
				case STATUS_ERROR:
					$error_count+=$row[1];
					break;
				default:
					$other_count+=$row[1];
					break;
			}	
		}
		$w = 200;
		$h = 150;
		createSystemStatusPie($info_count, $ok_count, $warning_count, $error_count, $other_count, $result, $image_file, $h, $w);
		$db->freeResult($result);
	}
}

function getSystemStatusPanel($effectsglobal='')
{
	global $lrb, $force_login, $mainProg, $sisiyaImageDir, $tmpImageDir, $statusNames;

	$info_percent=0;
	$ok_percent=0;
	$warning_percent=0;
	$error_percent=0;
	$other_percent=0;

	$title_str=$lrb['sisiya.label.Systems'];
	if ($effectsglobal == '') {
		$effectsglobal_str='';
		$effectsglobal_link_str='';
		$image_file=$tmpImageDir.'/system_status_pie_all.png';
	}
	else {
		$effectsglobal_str=" and b.effectsglobal='".$effectsglobal."'";
		$effectsglobal_link_str='&amp;effectsglobal='.$effectsglobal;
		$image_file=$tmpImageDir.'/system_status_pie_'.$effectsglobal.'.png';
	}

	$link_str=$mainProg.'?menu=detailed_view2'.$effectsglobal_link_str;

	$securitygroups_sql='';
	if ($force_login && !$_SESSION['hasAllSystems']) 
		$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	####################################################################################################################################################
	$sql_str="select a.statusid,count(a.statusid) from systemstatus a,systems b where a.systemid=b.id ".$securitygroups_sql." and b.active='t' ".$effectsglobal_str." group by a.statusid order by a.statusid;";
	getSystemStatusCount($info_count,$ok_count,$warning_count,$error_count,$other_count,$image_file,$sql_str); 
	$total=$info_count+$ok_count+$warning_count+$error_count+$other_count;
	if ($total > 0) {
		$info_percent = round(100*$info_count/$total,2);
		$ok_percent = round(100*$ok_count/$total,2);
		$warning_percent = round(100*$warning_count/$total,2);
		$error_percent = round(100*$error_count/$total,2);
		$other_percent = round(100*$other_count/$total,2);
	}


	$html='';
	$html.='<table class="dashboard">'."\n";
	#$html.='<caption class="dashboard">'.$lrb['sisiya_admin.label.system_status'].'</caption>'."\n";
	$html.='<caption class="dashboard">'.$title_str.'</caption>'."\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center">'.$lrb['sisiya_gui.label.total'].'</td>';
	$html.='<td class="right">'.$total.'</td>';
	$html.='<td rowspan="6"><a href="'.$link_str.'"><img src="'.$image_file.'" alt="System status pie" /></a></td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_ERROR].'.png" alt="'.$statusNames[STATUS_ERROR].'" /></td>';
#	$html.='<td class="right">'.$error_percent.'%</td>';
	$html.='<td class="right">'.$error_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_WARNING].'.png" alt="'.$statusNames[STATUS_WARNING].'" /></td>';
#	$html.='<td class="right">'.$warning_percent.'%</td>';
	$html.='<td class="right">'.$warning_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_OK].'.png" alt="'.$statusNames[STATUS_OK].'" /></td>';
#	$html.='<td class="right">'.$ok_percent.'%</td>';
	$html.='<td class="right">'.$ok_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_INFO].'.png" alt="'.$statusNames[STATUS_INFO].'" /></td>';
#	$html.='<td class="right">'.$info_percent.'%</td>';
	$html.='<td class="right">'.$info_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_NOREPORT].'.png" alt="'.$statusNames[STATUS_NOREPORT].'" /></td>';
#	$html.='<td class="right">'.$other_percent.'%</td>';
	$html.='<td class="right">'.$other_count.'</td>';
	$html.="</tr>\n";

	$html.="</table>\n";

	return $html;

}


function getSystemStatusPanel2()
{
	global $lrb, $force_login, $tmpImageDir, $statusNames;

	$info_percent=0;
	$ok_percent=0;
	$warning_percent=0;
	$error_percent=0;

	$securitygroups_sql='';
	if ($force_login && !$_SESSION['hasAllSystems']) 
		$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	####################################################################################################################################################
	$sql_str="select a.statusid,count(a.statusid) from systemstatus a,systems b where a.systemid=b.id ".$securitygroups_sql." and b.active='t' and b.effectsglobal='f' group by a.statusid order by a.statusid;";
	$image_file=$tmpImageDir.'/system_status_pie2.png';
	getSystemStatusCount($info_count,$ok_count,$warning_count,$error_count,$image_file,$sql_str); 
	$total=$info_count+$ok_count+$warning_count+$error_count;
	if ($total > 0) {
		$info_percent=round(100*$info_count/$total,2);
		$ok_percent=round(100*$ok_count/$total,2);
		$warning_percent=round(100*$warning_count/$total,2);
		$error_percent=round(100*$error_count/$total,2);
	}


	$html='';
	$html.='<table class="dashboard">'."\n";
	#$html.='<caption class="dashboard">'.$lrb['sisiya_admin.label.system_status'].'</caption>'."\n";
	$html.='<caption class="dashboard">System Status</caption>'."\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center">'.$lrb['sisiya_gui.label.total'].'</td>';
	$html.='<td class="right">'.$total.'</td>';
	$html.='<td rowspan="5"><img src="'.$image_file.'" alt="System status pie" /></td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$tmpImageDir.'/'.$statusNames[STATUS_ERROR].'.png" alt="'.$statusNames[STATUS_ERROR].'" /></td>';
#	$html.='<td class="right">'.$error_percent.'%</td>';
	$html.='<td class="right">'.$error_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$tmpImageDir.'/'.$statusNames[STATUS_WARNING].'.png" alt="'.$statusNames[STATUS_WARNING].'" /></td>';
#	$html.='<td class="right">'.$warning_percent.'%</td>';
	$html.='<td class="right">'.$warning_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$tmpImageDir.'/'.$statusNames[STATUS_OK].'.png" alt="'.$statusNames[STATUS_OK].'" /></td>';
#	$html.='<td class="right">'.$ok_percent.'%</td>';
	$html.='<td class="right">'.$ok_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$tmpImageDir.'/'.$statusNames[STATUS_INFO].'.png" alt="'.$statusNames[STATUS_INFO].'" /></td>';
#	$html.='<td class="right">'.$info_percent.'%</td>';
	$html.='<td class="right">'.$info_count.'</td>';
	$html.="</tr>\n";
	$html.="</table>\n";

	return $html;

}

function getServiceStatusPanel($serviceID, $label, $effectsglobal = '')
{
	global $lrb, $force_login, $sisiyaImageDir, $tmpImageDir, $statusNames, $mainProg;

	$info_percent = 0;
	$ok_percent = 0;
	$warning_percent = 0;
	$error_percent = 0;
	$other_percent = 0;
	
	if ($effectsglobal == '') {
		$effectsglobal_str = '';
		$effectsglobal_link_str = '';
		$image_file = $tmpImageDir.'/system_'.$serviceID.'_all_service_status_pie.png';
	}
	else {
		$effectsglobal_str = " and b.effectsglobal='".$effectsglobal."'";
		$effectsglobal_link_str = '&amp;effectsglobal='.$effectsglobal;
		$image_file = $tmpImageDir.'/system_'.$serviceID.'_'.$effectsglobal.'_service_status_pie.png';
	}
	$securitygroups_sql = '';
	if ($force_login && !$_SESSION['hasAllSystems']) 
		$securitygroups_sql = ' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	####################################################################################################################################################
	$sql_str="select a.statusid,count(a.statusid) from systemservicestatus a,systems b where a.systemid=b.id ".$securitygroups_sql." and b.active='t' ".$effectsglobal_str." and a.serviceid=".$serviceID." group by a.statusid order by a.statusid;";
	#echo "sql=".$sql_str."<br>";
	getSystemStatusCount($info_count,$ok_count,$warning_count,$error_count,$other_count,$image_file,$sql_str); 
	$total=$info_count+$ok_count+$warning_count+$error_count+$other_count;
	#echo  "total=$total info_count=$info_count ok_count=$ok_count warning_count=$warning_count error_count=$error_count other_count=$other_count<br>";
	if ($total > 0) {
		$info_percent=round(100*$info_count/$total,2);
		$ok_percent=round(100*$ok_count/$total,2);
		$warning_percent=round(100*$warning_count/$total,2);
		$error_percent=round(100*$error_count/$total,2);
		$other_percent=round(100*$other_count/$total,2);
		#echo "info_percent=$info_percent ok_percent=$ok_percent warning_percent=$warning_percent error_percent=$error_percent= error_percent=$error_percent= other_percent=$other_percent<br>";
	}

	$link_str=$mainProg.'?menu=service_view&amp;serviceID='.$serviceID.$effectsglobal_link_str.'&amp;imageFile='.$image_file;

	$html='';
	$html.='<table class="dashboard">'."\n";
	#$html.='<caption class="dashboard">'.$lrb['sisiya_admin.label.system_status'].'</caption>'."\n";
	$html.='<caption class="dashboard">'.$label.'</caption>'."\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center">'.$lrb['sisiya_gui.label.total'].'</td>';
	$html.='<td class="right">'.$total.'</td>';
	$html.='<td rowspan="6"><a href="'.$link_str.'"><img src="'.$image_file.'" alt="System status pie" /></a></td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_ERROR].'.png" alt="'.$statusNames[STATUS_ERROR].'" /></td>';
#	$html.='<td class="right">'.$error_percent.'%</td>';
	$html.='<td class="right">'.$error_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_WARNING].'.png" alt="'.$statusNames[STATUS_WARNING].'" /></td>';
#	$html.='<td class="right">'.$warning_percent.'%</td>';
	$html.='<td class="right">'.$warning_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_OK].'.png" alt="'.$statusNames[STATUS_OK].'" /></td>';
#	$html.='<td class="right">'.$ok_percent.'%</td>';
	$html.='<td class="right">'.$ok_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_INFO].'.png" alt="'.$statusNames[STATUS_INFO].'" /></td>';
#	$html.='<td class="right">'.$info_percent.'%</td>';
	$html.='<td class="right">'.$info_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_NOREPORT].'.png" alt="'.$statusNames[STATUS_NOREPORT].'" /></td>';
#	$html.='<td class="right">'.$other_percent.'%</td>';
	$html.='<td class="right">'.$other_count.'</td>';
	$html.="</tr>\n";
/*
	$html.='<tr class="row">'."\n";
	$html.='<td colspan="2" class="left">';
	$html.='<img src="'.$tmpImageDir.'/'.$statusNames[STATUS_INFO].'.png" alt="'.$statusNames[STATUS_INFO].'" />&nbsp;'.$info_count.'&nbsp;&nbsp;&nbsp;';
	$html.='<img src="'.$tmpImageDir.'/'.$statusNames[STATUS_OK].'.png" alt="'.$statusNames[STATUS_OK].'" />&nbsp;'.$ok_count.'&nbsp;&nbsp;&nbsp;';
	$html.='<img src="'.$tmpImageDir.'/'.$statusNames[STATUS_WARNING].'.png" alt="'.$statusNames[STATUS_WARNING].'" />&nbsp;'.$warning_count.'&nbsp;&nbsp;&nbsp;';
	$html.='<img src="'.$tmpImageDir.'/'.$statusNames[STATUS_ERROR].'.png" alt="'.$statusNames[STATUS_ERROR].'" />&nbsp;'.$error_count;
	$html.='</td>';
	$html.="</tr>\n";
*/
	$html.="</table>\n";

	return $html;

}

function getSystemServiceStatusPanel($effectsglobal='')
{
	global $lrb, $force_login, $sisiyaImageDir, $tmpImageDir, $statusNames;

	$info_percent=0;
	$ok_percent=0;
	$warning_percent=0;
	$error_percent=0;
	$other_percent=0;

	$title_str=$lrb['sisiya.label.Services'];
	if ($effectsglobal == '') {
		$effectsglobal_str='';
		$image_file=$tmpImageDir.'/system_services_status_pie_all.png';
	}
	else {
		$effectsglobal_str=" and b.effectsglobal='".$effectsglobal."'";
		$image_file=$tmpImageDir.'/system_services_status_pie_'.$effectsglobal.'.png';
	}

	$securitygroups_sql='';
	if ($force_login && !$_SESSION['hasAllSystems']) 
		$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	####################################################################################################################################################
	$sql_str="select a.statusid,count(a.statusid) from systemservicestatus a,systems b where a.systemid=b.id ".$securitygroups_sql." and b.active='t' ".$effectsglobal_str." group by a.statusid order by a.statusid;";
	getSystemStatusCount($info_count,$ok_count,$warning_count,$error_count,$other_count,$image_file,$sql_str); 
	$total=$info_count+$ok_count+$warning_count+$error_count+$other_count;
	if ($total > 0) {
		$info_percent=round(100*$info_count/$total,2);
		$ok_percent=round(100*$ok_count/$total,2);
		$warning_percent=round(100*$warning_count/$total,2);
		$error_percent=round(100*$error_count/$total,2);
		$other_percent=round(100*$other_count/$total,2);
	}


	$html='';
	$html.='<table class="dashboard">'."\n";
	#$html.='<caption class="dashboard">'.$lrb['sisiya_admin.label.system_status'].'</caption>'."\n";
	$html.='<caption class="dashboard">'.$title_str.'</caption>'."\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center">'.$lrb['sisiya_gui.label.total'].'</td>';
	$html.='<td class="right">'.$total.'</td>';
	$html.='<td rowspan="6"><img src="'.$image_file.'" alt="System status pie" /></td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_ERROR].'.png" alt="'.$statusNames[STATUS_ERROR].'" /></td>';
#	$html.='<td class="right">'.$error_percent.'%</td>';
	$html.='<td class="right">'.$error_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_WARNING].'.png" alt="'.$statusNames[STATUS_WARNING].'" /></td>';
#	$html.='<td class="right">'.$warning_percent.'%</td>';
	$html.='<td class="right">'.$warning_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_OK].'.png" alt="'.$statusNames[STATUS_OK].'" /></td>';
#	$html.='<td class="right">'.$ok_percent.'%</td>';
	$html.='<td class="right">'.$ok_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_INFO].'.png" alt="'.$statusNames[STATUS_INFO].'" /></td>';
#	$html.='<td class="right">'.$info_percent.'%</td>';
	$html.='<td class="right">'.$info_count.'</td>';
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='<td class="center"><img src="'.$sisiyaImageDir.'/'.$statusNames[STATUS_NOREPORT].'.png" alt="'.$statusNames[STATUS_NOREPORT].'" /></td>';
#	$html.='<td class="right">'.$other_percent.'%</td>';
	$html.='<td class="right">'.$other_count.'</td>';
	$html.="</tr>\n";


/*
	$html.='<tr class="row">'."\n";
	$html.='<td colspan="2" class="left">';
	$html.='<img src="'.$tmpImageDir.'/'.$statusNames[STATUS_INFO].'.png" alt="'.$statusNames[STATUS_INFO].'" />&nbsp;'.$info_count.'&nbsp;&nbsp;&nbsp;';
	$html.='<img src="'.$tmpImageDir.'/'.$statusNames[STATUS_OK].'.png" alt="'.$statusNames[STATUS_OK].'" />&nbsp;'.$ok_count.'&nbsp;&nbsp;&nbsp;';
	$html.='<img src="'.$tmpImageDir.'/'.$statusNames[STATUS_WARNING].'.png" alt="'.$statusNames[STATUS_WARNING].'" />&nbsp;'.$warning_count.'&nbsp;&nbsp;&nbsp;';
	$html.='<img src="'.$tmpImageDir.'/'.$statusNames[STATUS_ERROR].'.png" alt="'.$statusNames[STATUS_ERROR].'" />&nbsp;'.$error_count;
	$html.='</td>';
	$html.="</tr>\n";
*/
	$html.="</table>\n";

	return $html;

}

function getSystemServiceStatusDailyAveragePanel($effectsglobal='')
{
	global $lrb, $force_login, $sisiyaImageDir, $tmpImageDir, $statusNames;

	$info_percent=0;
	$ok_percent=0;
	$warning_percent=0;
	$error_percent=0;
	$other_count=0;

	$title_str=$lrb['sisiya.label.DailyAverageOfServices'];
	if ($effectsglobal == '') {
		$effectsglobal_str='';
		$image_file=$tmpImageDir.'/system_service_status_daily_average_pie_all.png';
	}
	else {
		$effectsglobal_str=" and b.effectsglobal='".$effectsglobal."'";
		$image_file=$tmpImageDir.'/system_service_status_daily_average_pie_'.$effectsglobal.'.png';
	}


	$securitygroups_sql='';
	if ($force_login && !$_SESSION['hasAllSystems']) 
		$securitygroups_sql=' and a.systemid in (select sgs.systemid from securitygroupsystem sgs,securitygroupuser sgu where sgs.securitygroupid=sgu.securitygroupid and sgu.userid='.$_SESSION['user_id'].')';
	####################################################################################################################################################
	$sql_str="select a.statusid,count(a.statusid) from systemhistorystatus a,systems b where a.systemid=b.id ".$securitygroups_sql." and b.active='t' ".$effectsglobal_str."  group by a.statusid order by a.statusid";
	getSystemStatusCount($info_count,$ok_count,$warning_count,$error_count,$other_count,$image_file,$sql_str); 
	$total=$info_count+$ok_count+$warning_count+$error_count+$other_count;
	if ($total > 0) {
		$info_percent=round(100*$info_count/$total,2);
		$ok_percent=round(100*$ok_count/$total,2);
		$warning_percent=round(100*$warning_count/$total,2);
		$error_percent=round(100*$error_count/$total,2);
		$other_percent=round(100*$other_count/$total,2);
	}


	$html='';
	$html.='<table class="dashboard">'."\n";
	#$html.='<caption class="dashboard">'.$lrb['sisiya_admin.label.system_status'].'</caption>'."\n";
	$html.='<caption class="dashboard">'.$title_str.'</caption>'."\n";
	$html.="<tr>\n";
	$html.='<td colspan="2"><img src="'.$image_file.'" alt="System status pie" /></td>';
	$html.="</tr>\n";
	$html.="</table>\n";

	return $html;

}

function getSystemsPanel($effectsglobal='t')
{
	global $lrb;

	$critical_str='Critical';
	if ($effectsglobal == 'f')
		$critical_str='NonCritical';
	$html='';
	$html.='<table class="dashboard_layout">'."\n";
	$html.='<caption class="dashboard">'.$lrb['sisiya.label.'.$critical_str.'Systems'].'</caption>'."\n";
	$html.='	<tr class="row">';
	$html.='	<td>';
	$html.=getSystemStatusPanel($effectsglobal);
	$html.='	</td>';
	$html.='	<td>';
	$html.=getSystemServiceStatusPanel($effectsglobal);
	$html.='	</td>';
	$html.='	<td>';
	$html.=getSystemServiceStatusHistoryPanel($effectsglobal);
	$html.='	</td>';
	$html.='	<td>';
	$html.=getSystemServiceStatusDailyAveragePanel($effectsglobal);
	$html.='	</td>';
	$html.='	</tr>';
	$html.='</table>'."\n";
	return $html;
}

function getSystemsDashboard($effectsglobal='')
{
	global $lrb;


	$html='';
	$html.='<p />';
	if ($effectsglobal != '')
		$html.=getSystemsPanel($effectsglobal);
	else {
		$html.=getSystemsPanel('t');
		$html.='<p />';
		$html.=getSystemsPanel('f');
	}
	return $html;
}

function getServicesDashboard($effectsglobal)
{

	$html='';
$html.='<table class="dashboard_layout">'."\n";
$html.='<caption class="dashboard">Some Interesting Services</caption>'."\n";
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(101,'Antivirus Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(101,'Antivirus Status for Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(101,'Antivirus Status for Non-Critical','f');
	$html.='</td>';
$html.='</tr>';
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(100,'Uptodate Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(100,'Uptodate Status for Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(100,'Uptodate Status for Non-Critical','f');
	$html.='</td>';
$html.='</tr>';
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(1,'Filesystem Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(1,'Filesystem Status for Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(1,'Filesystem Status for Non-Critical','f');
	$html.='</td>';
$html.='</tr>';
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(10,'Oracle Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(81,'RAID Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(61,'Temperature for All');
	$html.='</td>';
$html.='</tr>';
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(76,'Time Synchronization Status Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(3,'SWAP Status for Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(4,'CPU for Critical','t');
	$html.='</td>';
$html.='</tr>';


$html.='</table>'."\n";
	return $html;
}


###########################################################
### end of functions
###########################################################
#$global_status_id=getSystemGlobalStatusID();
#$status_str=$statusNames[getBaseStatusID($global_status_id)];

$effectsglobal=getHTTPValue('effectsglobal');
$type=getHTTPValue('type');


$html='';
$h->addHeadContent('<meta http-equiv="cache-control" content="no-cache" />');
$h->addHeadContent('<meta http-equiv="refresh" content="180" />');

$effectsglobal_hidden_str='';
if ($effectsglobal != '') {
	$effectsglobal_hidden_str='<input type="hidden" name="effectsglobal" value="'.$effectsglobal.'" />';
}
$type_hidden_str='';
if ($type != '') {
	$type_hidden_str='<input type="hidden" name="type" value="'.$type.'" />';
}


$html_type_str='';
if ($type == 'systems') {
	$html_type_str=getSystemsDashboard($effectsglobal);
}
else if ($type == 'services') {
	$html_type_str=getServicesDashboard($effectsglobal);
}
else {
	$html_type_str=getSystemsDashboard();
}



#$html.='<div>'."\n";
#$html.=getNavigationPan();
#$html.='</div>'."\n";
$navigation_panel_str=getNavigationPan();

if ($effectsglobal != '' && $type != '') {
	$html.='<form id="dashbowardForm"  method="post" action="'.$progName.'">';
	$html.=$effectsglobal_hidden_str;
	$html.=$type_hidden_str;
	$html.='</form>';
}
$html.=$html_type_str;
$h->addContent($html);
return;




$html.='<p />';
/*
$html.='<div>'."\n";
$html.=$lrb['sisiya_gui.label.OverallSystemStatus'].' : ';
$html.='<img src="'.getStatusImage($global_status_id).'" alt="'.$status_str.'" />';
$html.=$lrb['sisiya.label.status.'.$status_str]."\n";
$html.='</div>'."\n";
*/

#$html.='<div class="div_ralative div_h500">'."\n";
#$html.='<div class="div_float_left">'."\n";

$html.='<table class="dashboard_layout">'."\n";
$html.='<caption class="dashboard">'.$lrb['sisiya.label.CriticalSystems'].'</caption>'."\n";
$html.='<tr class="row">';
	$effectsglobal='t';
	$html.='<td>';
		$html.=getSystemStatusPanel($effectsglobal);
	$html.='</td>';
	$html.='<td>';
		$html.=getSystemServiceStatusPanel($effectsglobal);
	$html.='</td>';
	$html.='<td>';
		$html.=getSystemServiceStatusHistoryPanel($effectsglobal);
	$html.='</td>';
	$html.='<td>';
		$html.=getSystemServiceStatusDailyAveragePanel($effectsglobal);
	$html.='</td>';
$html.='</tr>';
$html.='</table>'."\n";

$html.='<p />'."\n";
$html.='<table class="dashboard_layout">'."\n";
$html.='<caption class="dashboard">'.$lrb['sisiya.label.NonCriticalSystems'].'</caption>'."\n";
$html.='<tr class="row">';
	$effectsglobal='f';
	$html.='<td>';
		$html.=getSystemStatusPanel($effectsglobal);
	$html.='</td>';
	$html.='<td>';
		$html.=getSystemServiceStatusPanel($effectsglobal);
	$html.='</td>';
	$html.='<td>';
		$html.=getSystemServiceStatusHistoryPanel($effectsglobal);
	$html.='</td>';
	$html.='<td>';
		$html.=getSystemServiceStatusDailyAveragePanel($effectsglobal);
	$html.='</td>';
$html.='</tr>';
$html.='</table>'."\n";

$html.='<p />'."\n";
$html.='<table class="dashboard_layout">'."\n";
$html.='<caption class="dashboard">Some Interesting Services</caption>'."\n";
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(101,'Antivirus Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(101,'Antivirus Status for Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(101,'Antivirus Status for Non-Critical','f');
	$html.='</td>';
$html.='</tr>';
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(100,'Uptodate Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(100,'Uptodate Status for Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(100,'Uptodate Status for Non-Critical','f');
	$html.='</td>';
$html.='</tr>';
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(1,'Filesystem Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(1,'Filesystem Status for Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(1,'Filesystem Status for Non-Critical','f');
	$html.='</td>';
$html.='</tr>';
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(10,'Oracle Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(81,'RAID Status for All');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(61,'Temperature for All');
	$html.='</td>';
$html.='</tr>';
$html.='<tr class="row">';
	$html.='<td>';
		$html.=getServiceStatusPanel(76,'Time Synchronization Status Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(3,'SWAP Status for Critical','t');
	$html.='</td>';
	$html.='<td>';
		$html.=getServiceStatusPanel(4,'CPU for Critical','t');
	$html.='</td>';
$html.='</tr>';


$html.='</table>'."\n";

#$html.='</div>'."\n";

/*
$html.='<div class="div_ralative div_h500">'."\n";

$html.='<div class="div_1a">'."\n";
$html.=getSystemStatusPanel();
$html.='</div>'."\n";


$html.='<div class="div_1a">'."\n";
$html.=getSystemServiceStatusPanel();
$html.=getSystemServiceStatusHistoryPanel();
$html.='</div>'."\n";

$html.='<div class="div_1a">';
$html.=getSystemStatusPanel2();
$html.='</div>'."\n";

$html.='<div class="div_1a">'."\n";
$html.=getSystemServiceStatusPanel2();
$html.='</div>'."\n";

$html.='<div class="div_1a">'."\n";
$html.=getSystemServiceStatusDailyAveragePanel();
$html.='</div>'."\n";

$html.='<div class="div_1a">'."\n";
$html.=getServiceStatusPanel(101,'Antivirus Status');

$html.=getServiceStatusPanel(100,'Uptodate Status');

$html.=getServiceStatusPanel(1,'Filesystem Status');
$html.='</div>'."\n";

$html.='<div class="div_float_right">'."\n";
$html.=getNavigationPan();
$html.='</div>'."\n";

$html.='</div>'."\n";

$html.='<div class="div_ralative div_h500">'."\n";

$html.='</div>'."\n";
*/
$h->addContent($html);
?>
