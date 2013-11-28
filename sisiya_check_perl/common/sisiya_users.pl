#!/usr/bin/perl -w
#
#    Copyright (C) Erdal Mutlu
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
#######################################################################################
#BEGIN {push @INC, '..'}
## or run : perl -I..
use strict;
use warnings;
use SisIYA_Config;

if(-f $SisIYA_Config::sisiya_local_conf) {
	require $SisIYA_Config::sisiya_local_conf;
}
if(-f $SisIYA_Config::sisiya_functions) {
	require $SisIYA_Config::sisiya_functions;
}
#######################################################################################
###############################################################################
#### the default values
our @exception_users;
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::sisiya_systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str = '';
my $statusid = $SisIYA_Config::statusids{'info'};
my $service_name = 'users';
my @a;

if($SisIYA_Config::sisiya_osname eq 'HP-UX') {
	@a = `who -R`;
}
else {
	@a = `who`;
}
my $user_list = "@a";
my @root_users = grep(/root/, @a);
if($#root_users > -1) {
	my @b = @a;
	foreach my $exception_str(@exception_users) {
		# remove from the array
		foreach(@b) {
			if(index($_, $exception_str) != -1) {
				#print STDERR "Removing $exception_str from the logged in users list...\n";
				@b = grep ! /$exception_str/, @b;
			}
		}
	}
	if($#b > -1) {
		$statusid = $SisIYA_Config::statusids{'warning'};
		$message_str = "WARNING: User root is logged in!"
	}
}
if($#a == -1) {
	$message_str = "No user is logged in.";
}
else {
	$message_str .= " INFO: $user_list";
	$message_str =~ s/\s+/ /g;
}
################################################################################
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
################################################################################
