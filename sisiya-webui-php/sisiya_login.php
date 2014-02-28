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

global $rootDir;
$rootDir=".";

include_once("config.php");
include_once(CONF_DIR."/sisiya_common_conf.php");
include_once(CONF_DIR."/sisiya_admin_conf.php");

startSession($sessionName);

$menu=getHTTPValue('menu');
if($menu == '')
	$menu='gui';

$destroy_session=getHTTPValue('destroy_session');
if($destroy_session == 1) {
	$menu=getHTTPValue('menu');
	destroySession();
	header('Location: '.$loginProg.'?menu='.$menu);
	exit();
}

if(!initialize()) {
	echo $loginProg.": Could not initialize!";
	exit;
}

$login_ok=false;

$username=getHTTPValue('username');
$password=getHTTPValue('password');
$button=getHTTPValue('button');


#$login_info='<div class="div_login_info">&nbsp;</div>'."\n";	
$login_info='';	
if($button == $lrb['sisiya_admin.button.login']) {
	if($username != '') { 
		$login_ok=checkLogin($username,$password);
		if($login_ok) {
			### write session data to file or db
			session_write_close();
			### redirect
			if($menu == 'admin')
				header('Location: '.$progNameSisIYA_Admin);
			else
				header('Location: '.$progNameSisIYA_GUI);
			exit();
		}
		else {
			$login_info=$lrb['sisiya_admin.login.invalid_login'];
		}
	}
}
if($button == $lrb['sisiya_admin.button.forgot_password']) {
	$login_info=$lrb['sisiya_admin.login.invalid_username'];
	if($username != '' && checkUsername($username)) {
		# send new password
		$login_info=$lrb['sisiya_admin.login.sent_new_password'];
	}
}

$h=new HTMLDocument();

$language_params='menu='.$menu;
$title=$lrb['sisiya_admin.login.title'];
include_once($rootDir."/lib/sisiya_login_docheader.php");
$header=$lrb['sisiya_admin.login.header'];
$header_type='login';

$h->addContent('<div class="div_container">');
$h->addContent('<div class="div_header">');

include_once($rootDir.'/lib/sisiya_gui_logo.php');
$h->addContent($lrb['sisiya_admin.login.header']);
$h->addContent('<div class="div_float_right small_font">');
include_once($rootDir.'/lib/sisiya_gui_language.php');
$h->addContent('</div>');

$h->addContent('</div> <!-- end of div_header -->');
$h->addContent('<div class="div_login_content">');
$h->addContent('	<form id="loginForm" action="'.$loginProg.'?menu='.$menu.'" method="post">');
$h->addContent('		<div class="div_center">');
$h->addContent('		<table class="login">');
$h->addContent('			<caption class="login">'.$lrb['sisiya_admin.login.label.login'].'</caption>');
$h->addContent('			<tr>');
$h->addContent('				<td class="label">'.$lrb['sisiya_admin.login.label.username'].'</td>');
$h->addContent('				<td><input type="text" size="20" name="username" value="'.$username.'" /></td>');
$h->addContent('			</tr>');
$h->addContent('			<tr>');
$h->addContent('				<td class="label">'.$lrb['sisiya_admin.login.label.password'].'</td>');
$h->addContent('				<td><input type="password" size="20" name="password" value="" /></td>');
$h->addContent('			</tr>');
$h->addContent('		</table>');
$h->addContent('		</div> <!-- end of div_center -->');
$h->addContent('		<div class="div_center">');
$h->addContent('			<p><input type="submit" name="button" value="'.$lrb['sisiya_admin.button.login'].'" /></p>');
$h->addContent('		</div> <!-- end of div_center -->');
$h->addContent('	</form>');
if($login_info != '') 
	$h->addContent('<div class="div_login_info">'.$login_info.'</div>');
$h->addContent('</div> <!-- end of div_login_content -->');
include_once($rootDir."/lib/sisiya_login_footer.php");
$h->addContent('</div> <!-- end of div_container -->');
$h->display();
?>
