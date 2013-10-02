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
function getSystemImages()
{
	global $systemsImageDir,$allowed_types;

	$html='';
/*
	$files=array();
	for($i=0;$i<count($allowed_types);$i++) {
		$a=explode('/',$allowed_types[$i]);
		$ext=$a[1];
		if($images = getFilesByExtension($systemsImageDir,$ext)) {
			$files=array_merge($files,$images);	
		}
	}
*/
	if($files = getFilesByExtension($systemsImageDir,'gif')) {
#	if(count($files) > 0) {
		sort($files,SORT_STRING);
		$nrows=count($files);
		$_SESSION['nrows_change_system_image']=$nrows;
		for($i=0;$i<$nrows;$i++) {
			$html.='<tr><td>'.$files[$i].'</td><td><img src="'.$systemsImageDir.'/'.$files[$i].'" alt="'.$files[$i].'" /></td>';
			$html.='<td>'.getButtonIcon('update',$i).'<input type="hidden" name="file_name['.$i.']" value="'.$files[$i].'" /></td>';
			$html.='<td>'.getButtonIcon('delete',$i).'</td></tr>'."\n";
		}
	}
	return $html;
}


function updateImageLink($system_str,$img_file)
{
	global $systemsImageDir,$imgSystemsDirName,$linksImageDir,$lrb;

	$link_file=$linksImageDir.'/'.$system_str.'.gif';
	$image_file=$systemsImageDir.'/'.$img_file;
#echo "<br />link_file=".$link_file;
#echo "<br />iis_file=".is_file($link_file);
#echo "<br />is_link=".is_link($link_file);
	#if(file_exists($link_file)) {
	if(is_link($link_file)) {
#echo "<br />link exists : link_file=".$link_file;
		if(!unlink($link_file)) {
			$_SESSION['status_type']=STATUS_ERROR;
			$_SESSION['status_message']=$lrb['sisiya.msg.error.delete'].' ('.$link_file.')';
			return(false);
		}
	}
	$link_file=$system_str.'.gif';
	$image_file='../'.$imgSystemsDirName.'/'.$img_file;
	#if(!symlink($image_file,$link_file)) {
	exec('cd '.$linksImageDir.'; ln -s '.$image_file.' '.$link_file,$results);
	if(count($results) != 0) {
		$_SESSION['status_type']=STATUS_ERROR;
		$_SESSION['status_message']=$lrb['sisiya.msg.error.symlink'].' ('.$image_file.' -> '.$link_file.')';
		return(false);
	}
	#$_SESSION['status_type']=STATUS_OK;
	#$_SESSION['status_message']=$lrb['sisiya.msg.ok.symlink'].' ('.$image_file.' -> '.$link_file.')';
	return(true);
}

### we use readlink to display the system's image, because browsers do not refresh with the same name automatically.
function getSystemImage($system_name)
{
	global $systemsImageDir,$linksImageDir;

	$link_file=$linksImageDir.'/'.$system_name.'.gif';
	#if(($image_str=readlink($link_file)) == false)
	if((file_exists($link_file)) == false)
		return '';
	else {
		$image_str=readlink($link_file);
		return $systemsImageDir.'/'.$image_str;
	}
}
### end of functions
###########################################################
$html='';
if($_SESSION['is_admin'] == 'f')
	return;
#$systems=getSQL2SelectArray("select id,hostname from systems where active='t' order by hostname");
$systems=getSQL2SelectArray("select id,hostname from systems order by hostname");
$systemID=getHTTPValue('systemID');
$systemName=getSystemName($systemID,$systems);
if(isset($_POST['upload'])) {
	if(checkUploadFileError($_FILES['upload_file']['error']) && checkUploadFileSize($_FILES['upload_file']['size']) && checkUploadFileType($_FILES['upload_file']['type'],$allowed_types)) {
			if(file_exists($systemsImageDir.'/'.$_FILES['upload_file']['name'])) {
				$_SESSION['status_type']=STATUS_ERROR;
				$_SESSION['status_message']=$lrb['sisiya_admin.msg.file_exists'].' ('.$systemsImageDir.'/'.$_FILES['upload_file']['name'].')';
			}
			else {
				if(!move_uploaded_file($_FILES['upload_file']['tmp_name'],$systemsImageDir.'/'.$_FILES['upload_file']['name'])) {
					$_SESSION['status_type']=STATUS_ERROR;
					$_SESSION['status_message']=$lrb['sisiya_admin.msg.couldnot_be_stored'].' ('.$systemsImageDir.')';
				}
				else {
					$_SESSION['status_type']=STATUS_OK;
					$_SESSION['status_message']=$lrb['sisiya.msg.ok.upload'].' ('.$systemsImageDir.'/'.$_FILES['upload_file']['name'].')';
					if($systemName != '')
						updateImageLink($systemName,$_FILES['upload_file']['name']);
				}
			}
	}
}
else {
	if(isset($_SESSION['nrows_change_system_image'])) {
		for($i=0;$i<$_SESSION['nrows_change_system_image'];$i++) {
			if(isset($_POST['update'][$i])) {
				updateImageLink($systemName,$_POST['file_name'][$i]);
			}
			else if(isset($_POST['delete'][$i])) {
				removeImageFile($_POST['file_name'][$i]);
			}
		}
	}
}
$html.='<form id="change_system_imageForm" action="'.$progName.'" method="post" enctype="multipart/form-data">'."\n";
$html.='<table class="general">'."\n";
if($_SESSION['is_admin'] == 't') {
	$html.='<tr class="row">'."\n";
	$html.='	<td>'.getSelect('systemID',getHTTPValue('systemID'),$systems,"document.forms['change_system_imageForm'].submit();")."</td>\n";
	$html.='	<td colspan="3">'."\n";
	$img_file=getSystemImage($systemName);
	if($img_file != '')
		$html.='		<img src="'.$img_file.'" alt="'.$systemName.'" />';
	$html.="	</td>\n";
	$html.="</tr>\n";
	$html.='<tr class="row">'."\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.label.add_image_file']."</td>\n";
	$html.='	<td><input type="file" name="upload_file" /></td>'."\n";
	$html.='	<td colspan="2" class="center">'.getButtonIcon('upload')."</td>\n";
	$html.="</tr>\n";
	$html.=getSystemImages()."\n";
}
$html.="</table>\n";
$html.="</form>\n";
$h->addContent($html);
?>
