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
### end of functions
###########################################################
$html='';
$table_name='users';
if($_SESSION['is_admin'] == 't')
	$users=getSQL2SelectArray("select id,concat(name,' ',surname,' (',username,')') from users order by username");
if(getHTTPValue('button') == $lrb['sisiya_admin.button.change'] ) {
	if($_SESSION['is_admin'] == 't') {
		$user_id=getHTTPValue('user_id');
		$old_password='';
	}
	else {
		$user_id=$_SESSION['user_id'];
		$old_password=getHTTPValue('old_password');
	}
	change_password($user_id,$old_password,getHTTPValue('new_password'),getHTTPValue('renew_password'));
}
$html.='<form action="'.$progName.'" method="post">'."\n";
$html.='<table class="general">'."\n";
if($_SESSION['is_admin'] == 't') { 
	$html.='<tr class="row">'."\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.users.label.username']."</td>\n";
	$html.='	<td>'.getSelect('user_id',getHTTPValue('user_id'),$users)."</td>\n";
	$html.="</tr>\n";
}
else {
	$html.='<tr class="row">'."\n";
	$html.='	<td class="label">'.$lrb['sisiya_admin.'.$menu.'.label.old_password']."</td>\n";
	$html.='	<td><input class="password" type="password" name="old_password" value="" /></td>'."\n";
	$html.="</tr>\n";
}
$html.='<tr class="row">'."\n";
$html.='	<td class="label">'.$lrb['sisiya_admin.'.$menu.'.label.new_password']."</td>\n";
$html.='	<td><input class="password" type="password" name="new_password" value="" /></td>'."\n";
$html.="</tr>\n";
$html.='<tr class="row">'."\n";
$html.='	<td class="label">'.$lrb['sisiya_admin.'.$menu.'.label.renew_password']."</td>\n";
$html.='	<td><input class="password" type="password" name="renew_password" value="" /></td>'."\n";
$html.="</tr>\n";
$html.="</table>\n";
$html.='<div><input type="submit" name="button" value="'.$lrb['sisiya_admin.button.change'].'" /></div>'."\n";
$html.="</form>\n";
$h->addContent($html);
?>
