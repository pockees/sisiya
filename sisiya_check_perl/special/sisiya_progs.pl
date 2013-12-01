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
our $ps_prog = 'ps';
our @progs;
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
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'progs';
my $error_str = '';
my $ok_str = '';
#my $warning_str = '';
my @ps_list;

sub is_running
{
	my $prog = $_[0];
	my $found = 0;

	for my $i (0..$#ps_list) {
		if($prog eq $ps_list[$i]) {
			$found = 1;
			last;
		}
	}
	return $found;
}

my $ps_params = '-eo comm';
if($SisIYA_Config::sisiya_osname eq 'OpenBSD') {
	$ps_params = '-xeo comm';
}
#elsif($SisIYA_Config::sisiya_osname eq 'HP-UX') {
#	# see if I need to UNIX95="" ; export UNIX95
#	$ps_params = '-eo comm';
#}
#elsif($SisIYA_Config::sisiya_osname eq 'SunOS') {
#	$ps_params = '-eo comm';
#}
elsif($SisIYA_Config::sisiya_osname eq 'Linux') {
	$ps_params = '-eo command';
}

chomp(@ps_list = `$ps_prog $ps_params`);
for my $i (0..$#progs) {
	if(is_running($progs[$i])) {
		$ok_str .= " $progs[$i]";
	}
	else {
		$error_str .= " $progs[$i]";
	}
}

if($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR:$error_str";
}
#if($warning_str ne '') {
#	if($statusid < $SisIYA_Config::statusids{'warning'}) {
#		$statusid = $SisIYA_Config::statusids{'warning'};
#	}	
#	$message_str .= " WARNING:$warning_str";
#}
if($ok_str ne '') {
	$message_str .= " OK:$ok_str";
}
###################################################################################
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
