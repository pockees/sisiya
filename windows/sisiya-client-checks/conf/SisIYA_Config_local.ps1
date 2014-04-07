#
# This file is the local config for SisIYA check programs. 
# Edit this file for your local changes. This is file is not
# going to be overwritten by updates.
#
#    Copyright (C) 2003 - 2014  Erdal Mutlu
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#################################################################################
#################################################################################
### SisIYA Server's name or IP address
$SISIYA_SERVER = "127.0.0.1"
### SisIYA server port on which the SisIYA daemon is listenening 
$SISIYA_PORT = 8888
#################################################################################
### SisIYA update server configuration
#################################################################################
$SISIYA_UPDATE_SERVER	= "www.sisiya.org"
### SisIYA packages directory
$SISIYA_PACKAGES_DIR	= "/packages"
### Package name
$SISIYA_PACKAGE_NAME	= "SisIYA_client_checks_MSWindows"
### Versions XML file
$SISIYA_VERSIONS_XML_FILE = "versions.xml"
#################################################################################
# uncomment to enable the corresponding client check
#$checks.Item('battery').Item('auto) = 1
#$checks.Item('brightstore_devices').Item('auto) = 1
#$checks.Item('brightstore_jobs').Item('auto) = 1
#$checks.Item('brightstore_scratch').Item('auto) = 1
#$checks.Item('msexchange_mailqueue').Item('auto) = 1
#$checks.Item('msexchange_mapiconnectivity').Item('auto) = 1
#$checks.Item('mssexchange_mailflow').Item('auto) = 1
#$checks.Item('msexchange_servicehealth').Item('auto) = 1
#$checks.Item('progs').Item('auto) = 1
#$checks.Item('raid_hpacu').Item('auto) = 1
#$checks.Item('temperature').Item('auto) = 1
#################################################################################
