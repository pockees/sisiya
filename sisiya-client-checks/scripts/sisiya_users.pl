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
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
#######################################################################################
#BEGIN {push @INC, '..'}
## or run : perl -I..
use strict;
use warnings;
use SisIYA_Config;

if (-f $SisIYA_Config::local_conf) {
	require $SisIYA_Config::local_conf;
}
if (-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
#######################################################################################
#######################################################################################
#### the default values
our @exception_users;
#### end of the default values
#######################################################################################
my $service_name = 'users';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'info'};
my @a;

if ($SisIYA_Config::osname eq 'HP-UX') {
	@a = `$SisIYA_Config::external_progs{'who'} -R`;
}
else {
	@a = `$SisIYA_Config::external_progs{'who'}`;
}
my $user_list = "@a";
my @root_users = grep(/root/, @a);
if ($#root_users > -1) {
	my @b = @a;
	foreach my $exception_str(@exception_users) {
		# remove from the array
		foreach (@b) {
			if (index($_, $exception_str) != -1) {
				#print STDERR "Removing $exception_str from the logged in users list...\n";
				@b = grep ! /$exception_str/, @b;
			}
		}
	}
	if ($#b > -1) {
		$statusid = $SisIYA_Config::statusids{'warning'};
		$message_str = "WARNING: User root is logged in!"
	}
}
if ($#a == -1) {
	$message_str = "No user is logged in.";
}
else {
	$message_str .= " INFO: $user_list";
	$message_str =~ s/\s+/ /g;
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
