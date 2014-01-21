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
our $sunos_swap_prog = '/usr/sbin/swap';
our $sunos_prtconf_prog = '/usr/sbin/prtconf';
our $sunos_vmstat_prog = '/usr/bin/vmstat';
our %swap_percents = ( 'warning' => 30, 'error' => 50);
#### end of the default values
################################################################################

#######################################################################################
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if (-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
# 1 parameter is the search string
# 2 parameter is an array to cat /proc/meminfo
#
#sub get_meminfo
#{
#	my ($str, @lines) = @_;
#
#	my @a = grep(/$str/, @lines); 
#		#print STDERR "1 - memtotal = $a[0]\n";
#	@a = split(/:/, $a[0]);
#		#print STDERR "2 - memtotal = $a[1]\n";
#	@a = split(/k/, $a[1]);
#		#print STDERR "3 - memtotal = $a[0]\n";
#	return $a[0];
#}

my $statusid;
my $message_str;
my $data_str = '';
my $service_name = 'swap';
my $retcode;
my ($ram_free, $ram_total, $ram_used, $ram_percent);
my ($swap_free, $swap_total, $swap_used, $swap_percent);
if ($SisIYA_Config::osname eq 'Linux') {
	my $file;
	open($file, '<', '/proc/meminfo') || die "$0: Could not open file /proc/meminfo! $!";
	my @lines = <$file>;
	close $file;
	chomp(@lines);
#	foreach (@lines) {
#		print STDERR "$_\n";
#	}

		#$ram_total = get_meminfo('MemTotal:', @lines);
		#$ram_free = get_meminfo('MemFree:', @lines);
	$ram_total = (split(/k/, (split(/:/, (grep(/MemTotal:/, @lines))[0]))[1]))[0];
	$ram_free = (split(/k/, (split(/:/, (grep(/MemFree:/, @lines))[0]))[1]))[0];
	$ram_used = $ram_total - $ram_free;
		#$swap_total = get_meminfo('SwapTotal:', @lines);
		#$swap_free = get_meminfo('SwapFree:', @lines);
	$swap_total = (split(/k/, (split(/:/, (grep(/SwapTotal:/, @lines))[0]))[1]))[0];
	$swap_free = (split(/k/, (split(/:/, (grep(/SwapFree:/, @lines))[0]))[1]))[0];
	$swap_used = $swap_total - $swap_free;
#	print STDERR "SWAP: total=$swap_total free=$swap_free used=$swap_total\n";
#	print STDERR "RAM: total=$ram_total free=$ram_free used=$ram_total\n";
#	print STDERR "formated RAM total=".get_size_k($ram_total)."\n";
}
elsif ($SisIYA_Config::osname eq 'SunOS') {
	my @a = `$sunos_swap_prog -s`;
	$retcode = $? >>=8;
	if ($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = " ERROR: Could not execute swap command $sunos_swap_prog!";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
	else {
		$swap_total = (split(/k/, (split(/,/, $a[0]))[1]))[0];
		$swap_used = (split(/k/, (split(/=/, $a[0]))[1]))[0];
		$swap_free = $swap_total - $swap_used;
	}
	@a = `$sunos_prtconf_prog`;
	$retcode = $? >>=8;
	if ($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = " ERROR: Could not execute prtconf command $sunos_prtconf_prog!";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
	else {
		my $s = (grep(/^Memory size:/, @a))[0];
		$ram_total = (split(/\s+/, (split(/:/, $s))[1]))[1];
		$ram_total = 1024 * $ram_total;
		$ram_free = 0;
		@a = `$sunos_vmstat_prog 1 2`;
		$retcode = $? >>=8;
		if ($retcode != 0) {
			$statusid = $SisIYA_Config::statusids{'error'};
			$message_str = " ERROR: Could not execute vmstat command $sunos_vmstat_prog!";
			print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
		}
		else {
			$s = $a[3];
			$ram_free = (split(/\s+/, $s))[5];
		}
		$ram_used = $ram_total - $ram_free;
	}
}
$swap_percent = 0;
if ($swap_total != 0) {
	$swap_percent = int(100 * $swap_used / $swap_total);
}
### only for info
$ram_percent = 0;
if ($ram_total != 0) {
	$ram_percent = int(100 * $ram_used / $ram_total);
}
my $s = "SWAP: total=".get_size_k($swap_total)." used=".get_size_k($swap_used)." free=".get_size_k($swap_free).". RAM: total=".get_size_k($ram_total)." used=".get_size_k($ram_used)." free=".get_size_k($ram_free)." usage=".int($ram_percent).'%.';
if ($swap_percent >= $swap_percents{'error'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: Swap usage is ".$swap_percent."% (>= ".$swap_percents{'error'}.")! $s";
	#	SWAP: total=".get_size_k($swap_total)." used=".get_size_k($swap_used)." free=".get_size_k($swap_free).". RAM: total=".get_size_k($ram_total)." used=".get_size_k($ram_used)." free=".get_size_k($ram_free)." usage=".int($ram_percent).'%.';
}
elsif ($swap_percent >= $swap_percents{'warning'}) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = "WARNING: Swap usage is ".$swap_percent."% (>= ".$swap_percents{'warning'}.")! $s";
	#	RAM: total=".get_size_k($ram_total)." used=".get_size_k($ram_used)." free=".get_size_k($ram_free)." usage=".int($ram_percent).'%.';
}
else {
	$statusid = $SisIYA_Config::statusids{'ok'};
	$message_str = "OK: Swap usage is ".$swap_percent."%. $s";
	#RAM: total=".get_size_k($ram_total)." used=".get_size_k($ram_used)." free=".get_size_k($ram_free)." usage=".int($ram_percent).'%.';
}
#	
$data_str = '<entry name="swap_total" type="numeric">'.trim($swap_total).'</entry>';
$data_str .= '<entry name="swap_free" type="numeric">'.trim($swap_free).'</entry>';
$data_str .= '<entry name="swap_used" type="numeric">'.trim($swap_used).'</entry>';
$data_str .= '<entry name="swap_used_percent" type="numeric">'.trim($swap_percent).'</entry>';
$data_str .= '<entry name="ram_total" type="numeric">'.trim($ram_total).'</entry>';
$data_str .= '<entry name="ram_free" type="numeric">'.trim($ram_free).'</entry>';
$data_str .= '<entry name="ram_used" type="numeric">'.trim($ram_used).'</entry>';
$data_str .= '<entry name="ram_used_percent" type="numeric">'.trim($ram_percent).'</entry>';

###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
# cat /proc/meminfo
# cat /proc/meminfo 
# MemTotal:        4019664 kB
# MemFree:         2802780 kB
# Buffers:          423664 kB
# Cached:           504420 kB
# SwapCached:          248 kB
# Active:           840476 kB
# Inactive:         248416 kB
# Active(anon):     160156 kB
# Inactive(anon):    35536 kB
# Active(file):     680320 kB
# Inactive(file):   212880 kB
# Unevictable:           0 kB
# Mlocked:    0 kB
# HighTotal:       3286984 kB
# HighFree:        2627932 kB
# LowTotal:         732680 kB
# LowFree:          174848 kB
# SwapTotal:       4095992 kB
# SwapFree:        4094600 kB
# Dirty:    260 kB
# Writeback: 12 kB
# AnonPages:        160724 kB
# Mapped: 37404 kB
# Shmem:  34884 kB
# Slab:  101232 kB
# SReclaimable:      90776 kB
# SUnreclaim:        10456 kB
# KernelStack:        1360 kB
# PageTables:         3776 kB
# NFS_Unstable:          0 kB
# Bounce:     0 kB
# WritebackTmp:          0 kB
# CommitLimit:     6105824 kB
# Committed_AS:     467648 kB
# VmallocTotal:     122880 kB
# VmallocUsed:        5360 kB
# VmallocChunk:     109400 kB
# HugePages_Total:       0
# HugePages_Free:        0
# HugePages_Rsvd:        0
# HugePages_Surp:        0
# Hugepagesize:       2048 kB
# DirectMap4k:       10232 kB
# DirectMap2M:      897024 kB
## #############################################################
# on a SunOS system
## #############################################################
#swap -s
#total: 276788k bytes allocated + 103884k reserved = 380672k used, 4552520k available
#####
# prtconf
# System Configuration:  Oracle Corporation  i86pc
# Memory size: 2048 Megabytes
# System Peripherals (Software Nodes):
#
# i86pc
#     scsi_vhci, instance #0
#         pci, instance #0
#      pci8086,1237 (driver not attached)
#   isa, instance #0
#        i8042, instance #0
#  keyboard, instance #0
#           mouse, instance #0
# lp, instance #0 (driver not attached)
#      pit_beep, instance #0
#   pci-ide, instance #0
#    ide, instance #0
#  cmdk, instance #0
#   ide (driver not attached)
#    display, instance #0
# pci8086,1e, instance #0
#         pci80ee,cafe, instance #0
#      pci8086,7113 (driver not attached)
#   fw, instance #0
#           cpu (driver not attached)
#        sb, instance #1
# used-resources (driver not attached)
#     fcoe, instance #0
#  iscsi, instance #0
#      agpgart, instance #0 (driver not attached)
#          options, instance #0
#   pseudo, instance #0
#        vga_arbiter, instance #0 (driver not attached)
#   xsvc, instance #0
#
