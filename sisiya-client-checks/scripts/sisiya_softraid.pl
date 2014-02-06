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
our $mdadm_prog = '/sbin/mdadm';
#### end of the default values
#######################################################################################
my $service_name = 'softraid';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
sub get_array_list
{
	my @a;
	my $i = 0;
	foreach (@_) {
		$a[$i] = (split(/\s+/, $_))[1];
		#print STDERR "$a[$i]\n";
		$i++;
	}
	return @a;
}
#######################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $error_str = '';
my $ok_str = '';
my $warning_str = '';
my @raid_arrays;
my @a;

@a = `$mdadm_prog --detail --scan`;
my $retcode = $? >>=8;
if ($retcode != 0) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: Error executing the $mdadm_prog command! retcode=$retcode";
	print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}
my $i = 0;
foreach (@a) {
	$raid_arrays[$i++] = (split(/\s+/, $_))[1];
}
my $state;
my $raid_level;
my $total_devs;
my $raid_devs;
my $working_devs;
my $active_devs;
my $failed_devs;
my $spare_devs;
my $rebuild_status;
for $i (0..$#raid_arrays) {
	@a = `$mdadm_prog --detail $raid_arrays[$i]`;
	$retcode = $? >>=8;
	if ($retcode != 0) {
		$error_str .= " ERROR: Could not get info about $raid_arrays[$i]!";
	}
	else {
		chomp(@a = @a);
		$state = trim(( split(/:/, ( grep(/State :/, @a) )[0]) )[1]);
		$raid_level = trim(( split(/:/, ( grep(/Raid Level :/, @a) )[0]) )[1]);
		$raid_devs = trim(( split(/:/, ( grep(/Raid Devices :/, @a) )[0]) )[1]);
		$total_devs = trim(( split(/:/, ( grep(/Total Devices :/, @a) )[0]) )[1]);
		$active_devs = trim(( split(/:/, ( grep(/Active Devices :/, @a) )[0]) )[1]);
		$working_devs = trim(( split(/:/, ( grep(/Working Devices :/, @a) )[0]) )[1]);
		$failed_devs = trim(( split(/:/, ( grep(/Failed Devices :/, @a) )[0]) )[1]);
		$spare_devs = trim(( split(/:/, ( grep(/Spare Devices :/, @a) )[0]) )[1]);
		#print STDERR "$state\n";

		if ( ($state eq 'active') || ($state eq 'clean') ) {
			$ok_str .= " OK: $raid_arrays[$i] RAID level $raid_level is $state (RAID devices=$raid_devs, total=$total_devs, active=$active_devs, working=$working_devs, failed=$failed_devs, spare=$spare_devs).";
		} elsif (($state eq 'active, checking') || ($state eq 'clean, resyncing (DELAYED)') || ($state eq 'clean, checking') || ( $state eq 'clean, degraded, resyncing (DELAYED)')
			|| ($state eq 'active, resyncing (DELAYED)')) {
			$warning_str .= " WARNING: $raid_arrays[$i] RAID level $raid_level is $state (RAID devices=$raid_devs, total=$total_devs, active=$active_devs, working=$working_devs, failed=$failed_devs, spare=$spare_devs)!";
		} elsif ( ($state eq 'active, resyncing') || ($state eq 'clean,resyncing') || ($state eq 'active, degraded, recovering')) {
			$rebuild_status = (split(/:/, (grep(/Rebuild status :/i, @a))[0]))[1];
			#Rebuild Status : 7% complete
			$warning_str .= " WARNING: $raid_arrays[$i] RAID level $raid_level is $state (RAID devices=$raid_devs, total=$total_devs, active=$active_devs, working=$working_devs, failed=$failed_devs, spare=$spare_devs) Rebuild status $rebuild_status.";
		} else {
			$error_str .= " ERROR: $raid_arrays[$i] RAID level $raid_level is $state (RAID devices=$raid_devs, total=$total_devs, active=$active_devs, working=$working_devs, failed=$failed_devs, spare=$spare_devs)!";
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
	$message_str .= "$ok_str";
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
## mdadm --detail --scan
#ARRAY /dev/md1 metadata=1.0 name=appsrv20.elan-prj.com:1 UUID=531144cd:d44f532e:8a100058:bc5d4ccc
#ARRAY /dev/md0 metadata=1.1 name=appsrv20.elan-prj.com:0 UUID=b31e8f9a:e77953a1:19016817:5050b4fa
#ARRAY /dev/md2 metadata=1.1 name=appsrv20.elan-prj.com:2 UUID=01ef243f:a3fc3fe6:554b09e6:a4587361
#
#
# mdadm --detail /dev/md2
#/dev/md2:
#        Version : 1.1
#  Creation Time : Fri Aug 19 14:25:39 2011
#     Raid Level : raid5
#     Array Size : 4395406848 (4191.79 GiB 4500.90 GB)
#  Used Dev Size : 1465135616 (1397.26 GiB 1500.30 GB)
#   Raid Devices : 4
#  Total Devices : 4
#    Persistence : Superblock is persistent
#
#  Intent Bitmap : Internal
#
#    Update Time : Mon Oct 21 17:00:02 2013
#          State : active 
# Active Devices : 4
#Working Devices : 4
# Failed Devices : 0
#  Spare Devices : 0
#
#         Layout : left-symmetric
#     Chunk Size : 512K
#
#           Name : appsrv20.elan-prj.com:2
#           UUID : 01ef243f:a3fc3fe6:554b09e6:a4587361
#         Events : 338810
#
#    Number   Major   Minor   RaidDevice State
#       0       8       33        0      active sync   /dev/sdc1
#       1       8       49        1      active sync   /dev/sdd1
#       5       8       65        2      active sync   /dev/sde1
#       4       8       81        3      active sync   /dev/sdf1
########################################################################33
#Personalities : [raid1] 
#md2 : active raid1 sdb3[2] sda3[1]
#      465726272 blocks super 1.1 [2/1] [_U]
#      	resync=DELAYED
#      bitmap: 4/4 pages [16KB], 65536KB chunk
#
#md1 : active raid1 sdb2[2] sda2[1]
#      2046912 blocks super 1.1 [2/1] [_U]
#      	resync=DELAYED
#      
#md0 : active raid1 sdb1[2] sda1[1]
#      20479872 blocks super 1.0 [2/1] [_U]
#      [===================>.]  recovery = 97.3% (19931456/20479872) finish=0.3min speed=30214K/sec
#      bitmap: 1/1 pages [4KB], 65536KB chunk
#
#unused devices: <none>
