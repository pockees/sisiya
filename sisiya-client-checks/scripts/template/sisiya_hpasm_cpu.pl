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
#### the default values
#### end of the default values
#######################################################################################
my $service_name = 'cpu';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

################################################################################
if (! -f $SisIYA_Config::external_progs{'hpasmcli'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: External program $SisIYA_Config::external_progs{'hpasmcli'} does not exist!";
	print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}
my @a = `$SisIYA_Config::external_progs{'hpasmcli'} -s "show server"`;
my $retcode = $? >>=8;
if ($retcode == 0) {
	chomp(@a = @a);
	my $s = (grep(/Processor total/, @a))[0];
	chomp($s = $s);
	$info_str = "INFO: $s"; 

	$s = "@a";
	$s =~ s/\s+/ /g;
	my @b = grep(/Stepping/, split(/Processor/, $s));
	my $status;
	$data_str = '<entries>';
	for my $i (0..$#b) {
		#print STDERR "$i $b[$i]\n";
		$status = trim((split(/:/, (split(/Status/, $b[$i]))[1]))[1]);
		#print STDERR "status=[$status]\n";
		if ($status eq 'Ok') {
			$ok_str .= " OK: Processor $b[$i].";
			$data_str .= '<entry name="cpu_'.$i.'" type="booloean">1</entry>';
		}
		else {
			$error_str .= " ERROR: The status of processor $i is $status (!= Ok)! $b[$i].";
			$data_str .= '<entry name="cpu_'.$i.'" type="booloean">0</entry>';
		}
	}
	$data_str = '<entries>';
}

if ($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
if ($warning_str ne '') {
	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= "$warning_str";
}
if ($ok_str ne '') {
	$message_str .= "$ok_str";
}
if ($info_str ne '') {
	$message_str .= "$info_str";
}
###################################################################################
# The output of the following command : hpasmcli -s "show server"
########################################################################
#System        : ProLiant DL380 G5
#Serial No.    : CZC7321M4B      
#ROM version   : P56 05/18/2009
#iLo present   : Yes
#Embedded NICs : 2
#	NIC1 MAC: 00:1b:78:96:72:a8
#	NIC2 MAC: 00:1b:78:96:72:a6
#
#Processor: 0
#	Name         : Intel Xeon
#	Stepping     : 6
#	Speed        : 2333 MHz
#	Bus          : 1333 MHz
#	Core         : 2
#	Thread       : 2
#	Socket       : 1
#	Level2 Cache : 4096 KBytes
#	Status       : Ok
#
#Processor: 1
#	Name         : Intel Xeon
#	Stepping     : 6
#	Speed        : 2333 MHz
#	Bus          : 1333 MHz
#	Core         : 2
#	Thread       : 2
#	Socket       : 2
#	Level2 Cache : 4096 KBytes
#	Status       : Ok
#
#Processor total  : 2
#
#Memory installed : 20480 MBytes
#ECC supported    : Yes
##############################################################################################
######################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
######################################################################################
