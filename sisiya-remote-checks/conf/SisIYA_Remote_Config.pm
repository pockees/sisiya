##!/usr/bin/perl -w
#
#
## This file is the config for SisIYA remote check programs.
##
##    Copyright (C) Erdal Mutlu
##
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program; if not, write to the Free Software
##    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##
##
##################################################################################
#use strict;
#use warnings;

package SisIYA_Remote_Config;

our $client_conf 		= '/opt/sisiya-client-checks/SisIYA_Config.pm';
our $client_local_conf	 	= '/opt/sisiya-client-checks/SisIYA_Config_local.pm';
our $base_dir		 	= '/opt/sisiya-remote-checks';
our $local_conf			= "$base_dir/SisIYA_Remote_Config_local.pm";
our $conf_dir 			= "$base_dir/conf";
our $misc_dir 			= "$base_dir/misc";
our $scripts_dir	 	= "$base_dir/scripts";
our $utils_dir	 		= "$base_dir/utils";
1;
