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
###############################################################################
#### the default values
our @progs;
# our @progs = (
#		{
#			'command' 	=> '/usr/sbin/sisiyad /etc/sisiyad.conf', 
#			'description'	=> 'SisIYA server'
#		},
#		{
#			'command' 	=> '/usr/sbin/httpd', 
#			'description'	=> 'Web server'
#		},
#	);
#
#push @progs , { 'command' => '/usr/sbin/sisiyad /etc/sisiyad.conf', 'description' => 'SisIYA server'};
#push @progs , { 'command' => '/usr/sbin/httpd', 'description' => 'Web server'};
#### end of the default values
#######################################################################################
my $service_name = 'progs';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $error_str = '';
my $ok_str = '';
#my $warning_str = '';
my @ps_list;

sub is_running
{
	my $prog = $_[0];
	my $found = 0;

	for my $i (0..$#ps_list) {
		if ($prog eq $ps_list[$i]) {
			$found = 1;
			last;
		}
	}
	return $found;
}

if (! -f $SisIYA_Config::external_progs{'ps'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: External program $SisIYA_Config::external_progs{'ps'} does not exist!";
	print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}
my $ps_params = '-eo comm';
if ($SisIYA_Config::osname eq 'OpenBSD') {
	$ps_params = '-xeo comm';
}
#elsif ($SisIYA_Config::osname eq 'HP-UX') {
#	# see if I need to UNIX95="" ; export UNIX95
#	$ps_params = '-eo comm';
#}
#elsif ($SisIYA_Config::osname eq 'SunOS') {
#	$ps_params = '-eo comm';
#}
elsif ($SisIYA_Config::osname eq 'Linux') {
	$ps_params = '-eo command';
}

chomp(@ps_list = `$SisIYA_Config::external_progs{'ps'} $ps_params`);
my ($s, $flag);
$data_str = '<entries>';
for my $i (0..$#progs) {
	$s = '';
	$flag = 0; # false
	if ($i > 0) {
		$s =',';
	}
	if (is_running($progs[$i]{'command'})) {
		$ok_str .= "$s $progs[$i]{'description'}";
		$flag = 1; # true
	}
	else {
		$error_str .= "$s $progs[$i]{'description'}";
	}
	$data_str .= '<entry name="'.$progs[$i]{'description'}.'" type="boolean">'.$flag.'</entry>';
}
$data_str .= '</entries>';

if ($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR:$error_str";
}
#if ($warning_str ne '') {
#	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
#		$statusid = $SisIYA_Config::statusids{'warning'};
#	}	
#	$message_str .= " WARNING:$warning_str";
#}
if ($ok_str ne '') {
	$message_str .= " OK:$ok_str";
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
