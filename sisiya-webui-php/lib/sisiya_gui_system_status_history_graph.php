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
function getPacketLostPercent($str)
{
	# ERROR: The system is unreachable! 3 packets transmitted, 0 received, +2 errors, 100% packet loss, time 2006ms
	# WARNING: The system has network problems! 3 packets transmitted, 2 received, 33% packet loss, time 2001ms
	# OK: 3 packets transmitted, 3 received, 0% packet loss, time 2000ms
	$a1=explode('%',$str);
	$a2=explode(' ',$a1[0]);
	$p=$a2[count($a2)-1];
	#if($p == '')
	#	$p=0;
	return($p);
}

function getResponseTime($str)
{
	# ERROR: The system is unreachable! 3 packets transmitted, 0 received, +2 errors, 100% packet loss, time 2006ms
	# WARNING: The system has network problems! 3 packets transmitted, 2 received, 33% packet loss, time 2001ms
	# OK: 3 packets transmitted, 3 received, 0% packet loss, time 2000ms
	$a1=explode('%',$str);
	$a2=explode(' ',$a1[1]);
	### does ping always return in ms?
	$p=preg_replace("/[^0-9]/",'',$a2[count($a2)-1]);
	#if($p == '')
	#	$p=0;
	return($p);
}

### begin of functions
function createGraphPingResponseTimes($result,$image_file,$system_id,$service_id,$H,$W)
{
	global $db;

	#row[0]=timestamp;
	#row[1]=statusid
	#row[2]=message

	$font_h=20;
	$font_w=22;


	$h=$H-$font_h;
	$w=$W-$font_w;

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
		if($i % 2 == 0) {
			imageline($im,$x1,$h-3,$x2,$h+3,$graph_color_black);
		}
		# x axis labels
		if($i % 12 == 0) {
			$str=$i/2;
			imagestring($im,$font_size,$x1-3,$h+5,$str,$text_color);
		}
		
	}
	$response_times=array();
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$x=getResponseTime($row[2]);
		$response_times[$i]=$x;
	}
	$max_response_time=max($response_times);
	# y axis lines
	$max_rp_y=round($max_response_time,-2);
	for($i=0;$i<11;$i++) {
		$x1=$x_origin;
		$y1=$i*$dy;
		$x2=$w-$font_w;
		$y2=$y1;
		imageline($im,$x1,$y1,$x2,$y2,$y_axis_color);

		# y axis labels
		$str=$max_rp_y*(1-$i/10);

		$x1=0;
		$y1=$i*$dy;
		if($i<10)
			imagestring($im,$font_size,$x1,$y1,$str,$text_color);
	}

	# xp : the previous x1
	$xp=-1;
	$yp=-1;
	$m=$h/$max_rp_y;
	for($i=0;$i<count($response_times);$i++) {
		$y1=$h*(1-($max_rp_y-$response_time[$i])/$max_rp_y)*$m;
		if($i!=0) {
				//if($i==6)imagestring($im,$font_size,1,4,$x1."-".$x2,$text_color);
		}
		switch($row[1]) {
			case 0:
				$color_g=$graph_color_blue;
				break;
			case 1:
				$color_g=$graph_color_green;
				break;
			case 2:
				$color_g=$graph_color_yellow;
				break;
			case 3:
				$color_g=$graph_color_red;
				break;
		}
		$x2=$x1;
		# get packet lost percent

		if($xp != -1) {
			imageline($im,$xp,$yp,$x1,$y1,$graph_color_black);
		}
		
		### save the previous (x1,x2)
		$xp=$x1;
		$yp=$y1;

	}
	if(imagepng($im,$image_file) == false)
		debug("ERROR: Yaratamadim");
	else
		debug("OK: Yarattim.");
	# clean up 
	ImageDestroy($im);
}


function createGraphPingPacketsLost($result,$image_file,$system_id,$service_id,$H,$W)
{
	global $db;

	#row[0]=timestamp;
	#row[1]=statusid
	#row[2]=message

	$font_h=20;
	$font_w=22;

	$dh=5;
	$dw=5;
	
	$x_title_h=12;
	$x_axis_h=10;

	$y_title_w=16;
	$y_axis_w=12;


	$h=$H-$font_h;
	$w=$W-$font_w;

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
		if($i % 2 == 0) {
			imageline($im,$x1,$h-3,$x2,$h+3,$graph_color_black);
		}
		# x axis labels
		if($i % 12 == 0) {
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
		if($i<10)
			imagestring($im,$font_size,$x1,$y1,$str,$text_color);
	}
	# xp : the previous x1
	$xp=-1;
	$yp=-1;
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$hour=floatval(substr($row[0],8,2));
		$min=floatval(substr($row[0],10,2));
		$x1=$x_origin+$m*($hour*60+$min);
		$lost_percent=getPacketLostPercent($row[2]);
		$y1=$h*(1-$lost_percent/100);
		if($i!=0) {
				//if($i==6)imagestring($im,$font_size,1,4,$x1."-".$x2,$text_color);
		}
		switch($row[1]) {
			case 0:
				$color_g=$graph_color_blue;
				break;
			case 1:
				$color_g=$graph_color_green;
				break;
			case 2:
				$color_g=$graph_color_yellow;
				break;
			case 3:
				$color_g=$graph_color_red;
				break;
		}
		$x2=$x1;
		# get packet lost percent

		if($xp != -1) {
			imageline($im,$xp,$yp,$x1,$y1,$graph_color_black);
		}
		
		### save the previous (x1,x2)
		$xp=$x1;
		$yp=$y1;

	}
	if(imagepng($im,$image_file) == false)
		debug("ERROR: Yaratamadim");
	else
		debug("OK: Yarattim.");
	# clean up 
	ImageDestroy($im);
}


function createGraph2($result,$image_file,$system_id,$service_id,$h,$w)
{
	global $db;

	$font_size=1;
	$dx=0.25; # x axis is 24 hours	timeline
	$dy=$h;
	$m=720/(24*60);
	$x_max=$w;
	$y_max=$h;
	$im = @ImageCreate ($x_max+1, $y_max+1) //canvas
			or die ("Cannot Initialize new GD image stream");
	### the first call to ImageColorAllocate sets the background color
	#$background_color = ImageColorAllocate ($im, 0, 255, 255);
	$background_color = ImageColorAllocate ($im, 255, 255, 255);
#	imagefilledrectangle($im,0,0,$w,$h,$background_color);

	$text_color 		= ImageColorAllocate ($im, 0, 0, 0);
	$line_color 		= ImageColorAllocate ($im, 0, 0, 0);
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

	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$hour=floatval(substr($row[0],8,2));
		$min=floatval(substr($row[0],10,2));
		$x1=$m*($hour*60+$min)-90;
		if($i!=0) {
				//if($i==6)imagestring($im,$font_size,1,4,$x1."-".$x2,$text_color);
		switch($row[1]) {
			case 0:
				$color_g=$graph_color_blue;
				break;
			case 1:
				$color_g=$graph_color_green;
				break;
			case 2:
				$color_g=$graph_color_yellow;
				break;
			case 3:
				$color_g=$graph_color_red;
				break;
		}
		//imagefilledrectangle($im,$x1,$y1,$x2,$y2,$color_g);
		if ($hour < 12) {
			//imagefilledarc($im,$x_max/2,$y_max/2,$x_max*2/3,$y_max*2/3,$x1,$x2,$color_g,IMG_ARC_PIE);
		}
			else {
			imagefilledarc($im,$x_max/2,$y_max/2,$x_max,$y_max,$x1,$x2,$color_g,IMG_ARC_PIE);
			}
		}
		$x2=$x1;
	}
		imagefilledarc($im,$x_max/2,$y_max/2,$x_max*2/3,$y_max*2/3,0,360,$graph_color_white,IMG_ARC_PIE);
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$hour=floatval(substr($row[0],8,2));
		$min=floatval(substr($row[0],10,2));
		$x1=$m*($hour*60+$min)-90;
		if($i!=0) {
				//if($i==6)imagestring($im,$font_size,1,4,$x1."-".$x2,$text_color);
		switch($row[1]) {
			case 0:
				$color_g=$graph_color_blue;
				break;
			case 1:
				$color_g=$graph_color_green;
				break;
			case 2:
				$color_g=$graph_color_yellow;
				break;
			case 3:
				$color_g=$graph_color_red;
				break;
		}
		//imagefilledrectangle($im,$x1,$y1,$x2,$y2,$color_g);
		if ($hour < 12) {
			imagefilledarc($im,$x_max/2,$y_max/2,$x_max*2/3,$y_max*2/3,$x1,$x2,$color_g,IMG_ARC_PIE);
		}
			else {
			//imagefilledarc($im,$x_max/2,$y_max/2,$x_max,$y_max,$x1,$x2,$color_g,IMG_ARC_PIE);
			}
		}
		$x2=$x1;
	}
		imagearc($im,$x_max/2,$y_max/2,$x_max-1,$y_max-1,0,360,$axis_color);
		imagearc($im,$x_max/2,$y_max/2,$x_max*2/3-1,$y_max*2/3-1,0,360,$axis_color);
		imagearc($im,$x_max/2,$y_max/2,$x_max*2/3,$y_max*2/3,0,360,$axis_color);
		imagearc($im,$x_max/2,$y_max/2,$x_max*2/3+1,$y_max*2/3+1,0,360,$axis_color);
		imagearc($im,$x_max/2,$y_max/2,$x_max/3-2,$y_max/3-2,0,360,$axis_color);		
	//imageline($im,0,$dy/2,$w,$dy/2,$line_color);
	for($i=0;$i<12;$i++) {
		$y=$i*30;
			imagefilledarc($im,$x_max/2,$y_max/2,$x_max-1,$y_max-1,$y,$y+1,$axis_color,IMG_ARC_PIE);
			imagestring($im,5,$x_max/2+$x_max/4*cos(3.1416*($y-90)/180),$y_max/2+$y_max/4*sin(3.1416*($y-90)/180),$i,$axis_font_color);
			imagestring($im,5,$x_max/2+$x_max/2.4*cos(3.1416*($y-90)/180),$y_max/2+$y_max/2.4*sin(3.1416*($y-90)/180),$i+12,$axis_font_color);
	}
		imagefilledarc($im,$x_max/2,$y_max/2,$x_max/3,$y_max/3,0,360,$graph_color_white,IMG_ARC_PIE);
		imagearc($im,$x_max/2,$y_max/2,$x_max/3-1,$y_max/3-1,0,360,$axis_color);
		# output image
	# Header('Content-type: image/png');
	if(imagepng($im,$image_file) == false)
		debug("ERROR: Yaratamadim");
	else
		debug("OK: Yarattim.");
	# clean up 
	ImageDestroy($im);
	
	$dest = imagecreatefrompng($image_file);
	$src =  imagecreatefrompng('sisiya_merge.png');
	// Copy and merge
//	imagecopymerge($dest, $src, $x_max/3+4, $y_max/3+4, 0, 0, 100, 100, 30);
	imagecopy($dest, $src, $x_max/3*1.16, $y_max/3*1.16, 20, 20, 90, 90);

	// Output and free from memory
	imagepng($dest,$image_file);
	imagedestroy($dest);
	imagedestroy($src);

}


function createGraph($result,$image_file,$system_id,$service_id,$h,$w)
{
	global $db;

	$font_size=1;
	$dx=$w/(24*60); # x axis is 24 hours	timeline
	$dy=$h;
	#### y=m * x + n
	#### (0,23*60) -> (0,w)  => y=[w/23*60]*x  => m=w/23*60 n=0
	$m=$w/(24*60);
	$x_max=$w;
	$y_max=$h;
	$im = @ImageCreate ($x_max, $y_max) //canvas
			or die ("Cannot Initialize new GD image stream");
	### the first call to ImageColorAllocate sets the background color
	#$background_color = ImageColorAllocate ($im, 0, 255, 255);
	$background_color = ImageColorAllocate ($im, 255, 255, 255);
#	imagefilledrectangle($im,0,0,$w,$h,$background_color);

	$text_color 		= ImageColorAllocate ($im, 0, 0,0);
	$line_color 		= ImageColorAllocate ($im, 0, 0,0);
	$graph_color_blue	= ImageColorAllocate ($im,30,30,250);
	$graph_color_green 	= ImageColorAllocate ($im,70,190,70);
	$graph_color_red 	= ImageColorAllocate ($im,240,15,90);
	$graph_color_yellow	= ImageColorAllocate ($im,230,230,10);
	$x1=0;
	$y1=0;
	//end of graph
	$nrows=$db->getRowCount($result);
	$y1=0;
	$y2=$dy;
	$xp=-1;
	for($i=0;$i<$nrows;$i++) {
		$row=$db->fetchRow($result,$i);
		$hour=intval(substr($row[0],8,2));
		$min=intval(substr($row[0],10,2));
		$x1=$m*($hour*60+$min);
		$x2=$x1+$dx;
		switch($row[1]) {
			case 0:
				$color_g=$graph_color_blue;
				break;
			case 1:
				$color_g=$graph_color_green;
				break;
			case 2:
				$color_g=$graph_color_yellow;
				break;
			case 3:
				$color_g=$graph_color_red;
				break;
		}
		imagefilledrectangle($im,$x1,$y1,$x2,$y2,$color_g);
		if($xp != -1) {
			imagefilledrectangle($im,$xp,$y1,$x1,$y2,$color_g);
		}
		
		### save the previous x1
		$xp=$x1;
		debug($x1."-".$y1);
	}

	imageline($im,0,$dy/2,$w,$dy/2,$line_color);
	for($i=0;$i<25;$i++) {
		$x1=$m*$i*60;	
		if($i == 24)
			$x1=$x1-1;
		imageline($im,$x1,$dy/3,$x1,2*$dy/3,$line_color);
		$str=$i;
		if($i == 24)
			$x1=$x1-9;
		imagestring($im,$font_size,$x1,2*$dy/3,$str,$text_color);
	}

	# output image
	# Header('Content-type: image/png');
	if(imagepng($im,$image_file) == false)
		debug("ERROR: Yaratamadim");
	else
		debug("OK: Yarattim.");
	# clean up 
	ImageDestroy($im);
}

function getServiceName($service_id)
{
	global $db;

	$service_name='';
	$sql_str="select c.str from services a,strkeys b,interface c,languages d where a.keystr=b.keystr and b.id=c.strkeyid and d.code='".$_SESSION['language']."' and d.id=c.languageid and a.id=".$service_id;
	$result=$db->query($sql_str);
	if(!$result)
	        errorRecord('select');
	else {
		$row=$db->fetchRow($result,0);
		$service_name=$row[0];
	}
	return($service_name);
}

function getSystemNameX($system_id)
{
	global $db;

	$system_name='';
	$sql_str="select hostname from systems where id=".$system_id;
	$result=$db->query($sql_str);
	if(!$result)
	        errorRecord('select');
	else {
		$row=$db->fetchRow($result,0);
		$system_name=$row[0];
	}
	return($system_name);
}

### end of functions
###########################################################
$system_id=getHTTPValue('systemID');
$service_id=getHTTPValue('serviceID');
$image_file=$imgDir.'/graph_s.png';
$image2_file=$imgDir.'/graph_s2.png';
$h=800;
$w=800;

$sql_str="select a.recievetime, a.statusid from systemhistorystatus a where a.systemid=".$system_id." and a.serviceid=".$service_id." order by a.recievetime desc";
#echo $sql_str;
$result=$db->query($sql_str);

createGraph($result,$image_file,$system_id,$service_id,30,800);
createGraph2($result,$image2_file,$system_id,$service_id,$h,$w);

$db->freeResult($result);

##################################################################
#### for ping
$h=200;
$w=800;
$ping_packets_lost_image_file=$imgDir.'/graph_ping_packets_lost.png';
$ping_response_times_image_file=$imgDir.'/graph_ping_response_times.png';
$sql_str="select a.recievetime,a.statusid,a.str from systemhistorystatus a where a.systemid=".$system_id." and a.serviceid=22 order by a.recievetime desc";
#echo $sql_str;
$result=$db->query($sql_str);
createGraphPingPacketsLost($result,$ping_packets_lost_image_file,$system_id,$service_id,$h,$w);
createGraphPingResponseTimes($result,$ping_response_times_image_file,$system_id,$service_id,$h,$w);
$db->freeResult($result);
#### end of for ping
##################################################################
$system_name=getSystemNameX($system_id);
$service_name=getServiceName($service_id);
echo "System: ".$system_name." service:".$service_name;
?>
<p><img alt="Graph" width="<?php echo $w/1;?>" hight="<?php echo $h/1;?>" src="<?php echo $ping_packets_lost_image_file;?>" /></p>
<p><img alt="Graph" width="<?php echo $w/1;?>" hight="<?php echo $h/1;?>" src="<?php echo $ping_response_times_image_file;?>" /></p>

<?php
	return;
?>

<p><img alt="Graph" src="<?php echo $image_file;?>" /></p>
<p><img alt="Graph" width="<?php echo $w/1;?>" hight="<?php echo $h/1;?>" src="<?php echo $image2_file;?>" /></p>
