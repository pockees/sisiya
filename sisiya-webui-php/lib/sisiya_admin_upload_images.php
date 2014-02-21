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
function getSystemImages()
{
	global $systemsImageDir,$allowed_types;

	$html='';
	$files=array();
	for($i=0;$i<count($allowed_types);$i++) {
		$a=explode('/',$allowed_types[$i]);
		$ext=$a[1];
		if($images = getFilesByExtension($systemsImageDir,$ext)) {
			$files=array_merge($files,$images);	
		}
	}
	#if($files = getFilesByExtension($systemsImageDir,'gif')) {
	if(count($files) > 0) {
		sort($files,SORT_STRING);
		$nrows=count($files);
		$_SESSION['nrows_upload_images']=$nrows;
		for($i=0;$i<$nrows;$i++) {
			$html.='<tr><td>'.$files[$i].'</td><td><img src="'.$systemsImageDir.'/'.$files[$i].'" alt="'.$files[$i].'" /></td>';
			$html.='<td>'.getButtonIcon('delete',$i).'<input type="hidden" name="file_name['.$i.']" value="'.$files[$i].'" /></td>'."</tr>\n";
		}
	}
	return $html;
}
### end of functions
###########################################################
$html='';
if($_SESSION['is_admin'] == 'f')
	return;
if(isset($_POST['upload'])) {
	if(checkUploadFileError($_FILES['file']['error']) && checkUploadFileSize($_FILES['file']['size']) && checkUploadFileType($_FILES['file']['type'],$allowed_types)) {
			if(file_exists($systemsImageDir.'/'.$_FILES['file']['name'])) {
				$_SESSION['status_type']=STATUS_ERROR;
				$_SESSION['status_message']=$lrb['sisiya_admin.msg.file_exists'].' ('.$systemsImageDir.'/'.$_FILES['file']['name'].')';
			}
			else {
				if(!move_uploaded_file($_FILES['file']['tmp_name'],$systemsImageDir.'/'.$_FILES['file']['name'])) {
					$_SESSION['status_type']=STATUS_ERROR;
					$_SESSION['status_message']=$lrb['sisiya_admin.msg.couldnot_be_stored'].' ('.$systemsImageDir.')';
				}
				else {
					$_SESSION['status_type']=STATUS_OK;
					$_SESSION['status_message']=$lrb['sisiya.msg.ok.upload'].' ('.$systemsImageDir.'/'.$_FILES['file']['name'].')';
				}
			}
	}
}
else {
	if(isset($_SESSION['nrows_upload_images'])) {
		for($i=0;$i<$_SESSION['nrows_upload_images'];$i++) {
			if(isset($_POST['delete'][$i])) {
				removeImageFile($_POST['file_name'][$i]);
			}
		}
	}
}
$html.='<form action="'.$progName.'" method="post" enctype="multipart/form-data">'."\n";
$html.='<table class="general">'."\n";
if($_SESSION['is_admin'] == 't') { 
	$html.='<tr class="row">'."\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.label.image_file'].'</td>'."\n";
	$html.='	<td><input type="file" name="file" /></td>'."\n";
	$html.='	<td>'.getButtonIcon('upload')."</td>\n";
	$html.="</tr>\n";
	$html.=getSystemImages()."\n";
}
$html.="</table>\n";
$html.='</form>'."\n";
$h->addContent($html);
?>
