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

if (-f $SisIYA_Config::local_conf) {
	require $SisIYA_Config::local_conf;
}
if (-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
###############################################################################
#### the default values
our %update_progs = (
	'apt_cache'	=> '/usr/bin/apt-cache', 
	'apt_check' 	=> '/usr/lib/update-notifier/apt-check', 
	'pacman' 	=> '/usr/bin/pacman', 
	'yum' 		=> '/usr/bin/yum', 
	'zypper' 	=> '/usr/bin/zypper'
);
#### end of the default values
################################################################################

#######################################################################################
sub use_pacman
{
	`$update_progs{'pacman'} --sync --refresh >/dev/null`;
	chomp(my @a = `$update_progs{'pacman'} --query --upgrades`);
	return @a;
}

sub use_apt_check
{
	chomp(my $s =`$update_progs{'apt_check'} 2>&1`);
	return (split(/;/, $s))[0] + (split(/;/, $s))[1];
}

sub use_yum
{
	chomp(my @a = `$update_progs{'yum'} -q list updates`);
	@a = grep(!/^Updated Packages/, grep(!/^Updated Packages/, @a));
	return @a;
}

sub use_zypper
{
	my $n;
	chomp($n = `$update_progs{'zypper'} --non-interactive list-updates | grep "^v |" |  wc -l`);
	return $n;
}
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if (-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str = "INFO: Unsupported system for uptodate checking.";
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'info'};
my $service_name = 'isuptodate';
my $n = -1;

if (-x $update_progs{'yum'}) {
	$n = use_yum();
}
elsif (-x $update_progs{'apt_check'}) {
	$n = use_apt_check();
}
elsif (-x $update_progs{'pacman'}) {
	$n = use_pacman();
}
elsif (-x $update_progs{'zypper'}) {
	$n = use_zypper();
}

if ($n > 0) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = "WARNING: The system is out of date! There are $n available updates.";
}
elsif ($n == 0) {
	$statusid = $SisIYA_Config::statusids{'ok'};
	$message_str = "OK: The system is uptodate.";
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################