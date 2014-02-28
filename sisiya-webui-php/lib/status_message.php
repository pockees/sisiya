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

#debug("status_message.php: status_type=".$_SESSION['status_type']." status_message=".$_SESSION['status_message']);
if(isset($_SESSION['status_message']) && isset($_SESSION['status_type'])) {
	switch($_SESSION['status_type']) {
		case STATUS_INFO	:
			echo '<script type="text/javascript">window.status="'.$_SESSION['status_message'].'";</script>'."\n";
			break;
		case STATUS_OK		:
		case STATUS_WARNING	:
		case STATUS_ERROR	:
			echo '<script type="text/javascript">alert("'.$_SESSION['status_message'].'");</script>'."\n";
			break;
	}
	unset($_SESSION['status_type']);
	unset($_SESSION['status_message']);
}
#if(isset($_SESSION['refresh']))
#	echo '<script type="text/javascript">timedRefresh('.$_SESSION['refresh'].');</script>'."\n";
?>
