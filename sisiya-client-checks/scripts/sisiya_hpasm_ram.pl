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
#######################################################################################
#######################################################################################
#### the default values
#### end of the default values
#######################################################################################
my $service_name = 'ram';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'info'};
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
my @a = `$SisIYA_Config::external_progs{'hpasmcli'} -s "show dimm"`;
my $retcode = $? >>=8;
if ($retcode == 0) {
	chomp(@a = @a);
	my $s = "@a";
	$s =~ s/\s+/ /g;
	my @b = grep(/Module/, split(/Cartridge/, $s));
	#print STDERR @b;
	my $status;
	for my $i (0..$#b) {
		#print STDERR "$i $b[$i]\n";
		$status = trim((split(/:/, (split(/Status/, $b[$i]))[1]))[1]);
		#print STDERR "status=[$status]\n";
		if ($status eq 'N/A') {
			$info_str .= " INFO: Cartridge $b[$i].";
		}
		elsif ($status eq 'Ok') {
			$ok_str .= " OK: Cartridge $b[$i].";
		}
		else {
			$error_str .= " ERROR: The status of RAM $i is $status (!= Ok)! Cartridge $b[$i].";
		}
	}

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
	if ($statusid < $SisIYA_Config::statusids{'ok'}) {
		$statusid = $SisIYA_Config::statusids{'ok'};
	}
	$message_str .= "$ok_str";
}
if ($info_str ne '') {
	$message_str .= "$info_str";
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
### Sample output of the hpasmcli -s "show dimm" command :
#DIMM Configuration
#------------------
#Cartridge #:                  0
#Module #:                     1
#Present:                      Yes
#Form Factor:                  fh
#Memory Type:                  14h
#Size:                         1024 MB
#Speed:                        667 MHz
#Supports Lock Step:           No
#Configured for Lock Step:     No
#Status:                       Ok
#
#Cartridge #:                  0
#Module #:                     2
#Present:                      Yes
#Form Factor:                  fh
#Memory Type:                  14h
#Size:                         1024 MB
#Speed:                        667 MHz
#Supports Lock Step:           No
#Configured for Lock Step:     No
#Status:                       Ok
#############################################################################
### Sample output of the hpasmcli -s "show dimm" command :
##
#Cartridge #:    0
#Processor #:    1
#Module #:       2
#Present:        Yes
#Form Factor:    fh
#Memory Type:    5h
#Size:           8192 MB
#Speed:          1333 MHz
#Status:         N/A
#
#Cartridge #:    0
#Processor #:    1
#Module #:       4
#Present:        Yes
#Form Factor:    fh
#Memory Type:    5h
#Size:           8192 MB
#Speed:          1333 MHz
#Status:         N/A
##############################################################################################
