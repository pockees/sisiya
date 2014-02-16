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
#### end of the default values
################################################################################
################################################################################
my $service_name = 'isuptodate';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################

sub use_pacman
{
	`$SisIYA_Config::external_progs{'pacman'} --sync --refresh >/dev/null`;
	chomp(my @a = `$SisIYA_Config::external_progs{'pacman'} --query --upgrades`);
	return @a;
}

sub use_apt_check
{
	chomp(my $s =`$SisIYA_Config::external_progs{'apt_check'} 2>&1`);
	return (split(/;/, $s))[0] + (split(/;/, $s))[1];
}

sub use_yum
{
	chomp(my @a = `$SisIYA_Config::external_progs{'yum'} -q list updates`);
	@a = grep(!/^Updated Packages/, grep(!/^Updated Packages/, @a));
	return @a;
}

sub use_zypper
{
	my $n;
	chomp($n = `$SisIYA_Config::external_progs{'zypper'} --non-interactive list-updates | grep "^v |" |  wc -l`);
	return $n;
}

################################################################################
my $message_str = "INFO: Unsupported system for uptodate checking.";
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'info'};
my $n = -1;

if (-x $SisIYA_Config::external_progs{'yum'}) {
	$n = use_yum();
}
elsif (-x $SisIYA_Config::external_progs{'apt_check'}) {
	$n = use_apt_check();
}
elsif (-x $SisIYA_Config::external_progs{'pacman'}) {
	$n = use_pacman();
}
elsif (-x $SisIYA_Config::external_progs{'zypper'}) {
	$n = use_zypper();
}

if ($n > 0) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = "WARNING: The system is out of date! There are $n available updates.";
}
elsif ($n == 0) {
	$statusid = $SisIYA_Config::statusids{'ok'};
	$message_str = "OK: The system is uptodate.";
}#	
$data_str = '<entries>';
if ($n == 0) {
	$data_str .= '<entry name="is_uptodate" type="boolean">1</entry>';
} else {
	$data_str .= '<entry name="is_uptodate" type="boolean">0</entry>';
}
$data_str .= '<entry name="number_of_packages" type="numeric">'.$n.'</entry>';
$data_str .= '</entries>';

###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
