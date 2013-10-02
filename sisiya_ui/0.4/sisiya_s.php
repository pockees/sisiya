<?php
/*
    Copyright (C) 2004  Erdal Mutlu
    Copyright (C) 2005  Martin Scherbaum

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

#error_reporting(E_ALL);
include_once("dbclass.php");
include_once("dbconf.php");

# get a session to store debug status and db timing in
session_start();
foreach (array('debug', 'sdebug', 'stime') as $index) {
	if (isset($_GET[$index]))  { $_SESSION[$index]  = $_GET[$index]; }
}
$_SESSION['dbtime'] = 0;

$today = date("Ymd", time());
$date = (isset($_GET['date'])) ? $_GET['date'] : $today;

#echo "today:$today\n";
#echo "date: $date\n";

function print_a($arr)
{
  if (!isset($arr)) {
        echo "not set!<br>";
        return;
  }
  if (!is_array($arr)) {
        echo "not array!<br>";
        return;
  }
  // Note: the function is recursive
  echon('<table border="1">');
  foreach($arr as $key => $value) {
      echon(' <tr>');
      echon('  <td bgcolor="lightgray"><b>'.$key.'</b></td>');
      echo('  <td bgcolor="gray">');
      if (is_array($value))
          print_a($value);
      else
          echo('<font color="white">'.$value.'</font>');
      echon('</td>');
      echon(' </tr>');
  }
  echon('</table>');
}

function echon($str) {
    echo $str."\n";
}

$patharr = array('/var/www/html/sisiya/stat',$date);
if (!file_exists(join('/',$patharr))) mkdir(join('/',$patharr));

switch($dbType) {
  case "MySQL" :
                $db=new MySQL_DBClass($db_server,$db_name,$db_user,$db_password);
                break;
  case "PostgreSQL" :
                $db=new PostgreSQL_DBClass($db_server,$db_name,$db_user,$db_password);
                break;
        default :
                echo "Unsupported DB Type!";
                exit;
                break;
}
$db->connect();

$offset = 3;

$maxsum = 0;
$statarr = array();
$time = strtotime($date);
for($min=5;$min<1440;$min += 5) {
	$ustart = $time + (($min + $offset - 10) * 60);
	$start = strftime("%Y%m%d%H%M%S", $ustart);
	$end   = strftime("%Y%m%d%H%M%S", $time + (($min + 5 + $offset) * 60));

	$query  = "select shs.systemid, max(shs.statusid) as statusid, s.effectsglobal as criticali, max(recievetime) ";
	$query .= " from systemhistorystatus".(($date != $today) ? "all" : "")." shs, systems s ";
	$query .= " where shs.recievetime >= '".$start."' ";
	$query .= " and   shs.recievetime < '".$end."' ";
	$query .= " and   shs.systemid = s.id ";
	$query .= " and   s.active = 't' ";
	$query .= " group by shs.systemid ";
	$query .= " order by shs.systemid, shs.statusid, shs.serviceid";
 	$result=$db->query($query);
 	$row_count=$db->getRowCount($result);
	$sum = 0;
	$prevsys = '';
	for ($i=0;$i<$row_count;$i++) {
		$row=$db->fetchRow($result,$i);
		if ($prevsys == $row[0]) {continue;}
		$prevsys = $row[0];
		$statarr[$ustart][(($row[2] == 't') ? $row[1] : (0 - $row[1]))]++;
		#$statarr[$ustart][$row[1]]++;
		$sum++;
	}
	if ($sum > $maxsum) $maxsum = $sum;
}
$stretch = 7;
$maxh = ($maxsum + 10) * $stretch;
$w = $stretch;
$img = imagecreate (288*($w+5), $maxh + 200) or die ("Kann keinen neuen GD-Bild-Stream erzeugen");
$background_color = ImageColorAllocate ($img, 255, 255, 255);

$colors = array (
	-1 => ImageColorAllocate ($img, 30,255,30),   // gruen
	-2 => ImageColorAllocate ($img, 255,255,30), // gelb
	-3 => ImageColorAllocate ($img, 255,30,30),   // rot
	0 => ImageColorAllocate ($img, 30,30,255),   // blau
	1 => ImageColorAllocate ($img, 30,255,30),   // gruen
	2 => ImageColorAllocate ($img, 255,255,30), // gelb
	3 => ImageColorAllocate ($img, 255,30,30),   // rot
	4 => ImageColorAllocate ($img, 0,0,0)     // schwarz
);

function smallrect($img,$x1,$y1,$x2,$y2,$col,$fillcol,$outline=0) {
	$x1s = $x1 + 1;
	$x2s = $x2 - 1;
	$y1s = $y1 + 1;
	$y2s = $y2 - 1;
	imagerectangle ($img, $x1, $y1, $x2, $y2, (($outline) ? $fillcol : $col));
	if (!$outline) imagefilledrectangle ($img, $x1s, $y1s, $x2s, $y2s, $fillcol);
}

function makegrid($img,$y0,$num,$slots,$step,$offset,$col) {
	$slots += 3 ;
	for ($i=0;$i<$num;$i++) {
		if ($i && ($i % 5) == 0) imagestring($img,2,5,($y0 - ($step*$i)),$i,$col);
		imageline($img,25,($y0 - ($step*$i)),$slots * ($step + $offset) + 5,($y0 - ($step*$i)),$col);
	}
}

$fname = '';
for($slot=count($statarr)-1;$slot < count($statarr); $slot++) {
	$cnt = 0;
	$x = 35;
	foreach ($statarr as $sdate => $arr) {
	        $start = strftime("%Y/%m/%d %H:%M:%S", $sdate);
		makegrid($img,$maxh,$maxsum,$slot,$stretch,$w,$colors[4]);
		$cy = 0;
		for ($stat=-3;$stat < 4;$stat++) {
			$y  = 0;
			$num = (isset($arr[$stat])) ? $arr[$stat] : 0;
			for ($i = 0;$i < $num;$i++) {
				$y = $i * $stretch;
				smallrect ($img, $x, ($maxh - ($cy + $y + $stretch)), ($x + $w), ($maxh - ($cy + $y)), $colors[4], $colors[$stat], (($stat <  0) ? 1 : 0));
			}
			$cy += $y;	
		}
		if (ereg('.*:0'.$offset.':00$', $start)) {
			imageline($img, $x + 5, $maxh + 10, $x + 5, $maxh + 20, $colors[4]);
			imagestringup ($img, 5, $x, $maxh + 200, $start, $colors[4]);
		}
		$x += $w + $stretch;
		if ($cnt > $slot) break;
		$cnt++;
	}
	$fname = join('/',$patharr)."/slot".sprintf("%03d",$slot).".png";
	ImagePNG ($img, $fname);
}
if ($fname != '') {
	# create current link for this date
	chdir(join('/',$patharr));
	if (file_exists('current.png')) {unlink('current.png');}
	symlink($fname,'current.png');
	# create current link for all dates
	if ($date == $today) {
		chdir($patharr[0]);
		unlink('current.png'); 
		symlink($fname,'current.png');
	}
	if (!isset($_GET['cron'])) {
		header ("Content-type: image/png");
		ImagePNG ($img);
	}
}

exit;

?>
