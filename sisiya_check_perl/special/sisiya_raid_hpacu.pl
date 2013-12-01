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
our $hpacucli_prog = '/usr/sbin/hpacucli';
our %default_temperatures = ( 'warning' => 70, 'error' => 80 );
our %temperatures;
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
my $service_name = 'raid';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

################################################################################
my (@a, @b, @c, @d, $s, $retcode);
@a = `$hpacucli_prog ctrl all show status`;
$retcode = $? >>=8;
if($retcode == 0) {
	#chomp(@a = @a);
	#print STDERR @a;
	my @ctrls = grep(/Slot/, @a);
	#print STDERR @ctrls;
	my ($ctrlid, $total_logical_drives, $i);
	foreach(@ctrls) {
		$ctrlid = trim((split(/Slot/, $_))[1]);
		#print STDERR "ctrl id = [$ctrlid]\n";
		@a = `$hpacucli_prog ctrl slot=$ctrlid show detail`;
			#$ctrlid = 1;
			#@a = (
			#'Smart Array P400 in Slot 1',
			#'   Bus Interface: PCI',
			#'   Slot: 1',
			#'   Cache Status: OK',
			#'   Controller Status: OK',
			#'   Battery/Capacitor Status: OK'
			#);

		$retcode = $? >>=8;
		if($retcode == 0) {
			chomp(@b = @a);
			$s = "@b";
			$info_str .= " INFO: $s";
			#print STDERR @a;
			my ($ctrl_status, $cache_status, $battery_status);
			my ($raid_level, $logicaldrive_size, $logicaldrive_strip_size, $mount_points, $logicaldrive_status, $multidomain_status);
			$ctrl_status = trim((split(/:/, (grep(/Controller Status/, @a))[0]))[1]);
			if($ctrl_status eq 'OK') {
				$ok_str .= " OK: Controller status for the controller in slot $ctrlid is OK.";
			}
			else {
				$error_str .= " ERROR: Controller status for the controller in slot $ctrlid is $ctrl_status (!=OK)!";
			}
			$cache_status = trim((split(/:/, (grep(/Cache Status/, @a))[0]))[1]);
			if($cache_status eq 'OK') {
				$ok_str .= " OK: Cache status for the controller in slot $ctrlid is OK.";
			}
			else {
				$error_str .= " ERROR: Cache status for the controller in slot $ctrlid is $cache_status (!=OK)!";
			}
			#$ctrl_status = trim((split(/:/, (grep(/Battery\/Capacitor Status/, @a))[0]))[1]);
			@b = grep(/Battery\/Capacitor Status/, @a);
			if($#b != -1) {
				$battery_status = trim((split(/:/, $b[0]))[1]);
				#print STDERR " battery status=[$battery_status]\n";
				if($battery_status eq 'OK') {
					$ok_str .= " OK: Battery/Capacitor status for the controller in slot $ctrlid is OK.";
				}
				elsif($battery_status eq 'Recharging') {
					$warning_str .= " WARNING: Battery/Capacitor status for the controller in slot $ctrlid is $battery_status!";
				}
				else {
					$error_str .= " ERROR: Battery/Capacitor status for the controller in slot $ctrlid is $battery_status (!=OK)!";
				}
			}
			@b = `$hpacucli_prog ctrl slot=$ctrlid logicaldrive all show`;
			$retcode = $? >>=8;
			if($retcode == 0) {
				@b = grep(/logicaldrive/, @b);
				$total_logical_drives = $#b + 1;
				#print STDERR @b;
				#print STDERR "Total logical drives = [$total_logical_drives]\n";
				for $i (1..$total_logical_drives) {
					#print STDERR "Processing logical drive $i...\n";
					@c = `$hpacucli_prog ctrl slot=$ctrlid logicaldrive $i show`;
					$retcode = $? >>=8;
					if($retcode == 0) {
						#print STDERR @c;
						chomp(@c = @c);
						$raid_level = (split(/:/, (grep(/Fault Tolerance/, @c))[0]))[1];
						$logicaldrive_size = (split(/:/, (grep(/  Size/, @c))[0]))[1];
						$logicaldrive_strip_size = (split(/:/, (grep(/Strip Size/, @c))[0]))[1];
						$logicaldrive_status = trim((split(/:/, (grep(/  Status/, @c))[0]))[1]);
						$mount_points = trim((split(/:/, (grep(/Mount Points/, @c))[0]))[1]);
						@d = grep(/MultiDomain Status/, @c);
						$multidomain_status = '';
						if($#d != -1) {
							$multidomain_status = trim((split(/:/, $d[0]))[1]);
						}
						#print STDERR "raid level=[$raid_level] logicaldrive_size=[$logicaldrive_size] logicaldrive_strip_size=[$logicaldrive_strip_size] logicaldrive_status=[$logicaldrive_status] multidomain_status=[$multidomain_status]\n";
						if($logicaldrive_status eq 'OK') {
							$ok_str .= " OK: Logical drive $i (with RAID level=$raid_level, size=$logicaldrive_size, strip size=$logicaldrive_strip_size, mount points=$mount_points, multi domain status=$multidomain_status) in controller slot $ctrlid is OK.";
						}
						else {
							@d = grep(/Recovering/, $logicaldrive_status);
							if($#d == -1) {
								$error_str .= " ERROR: Logical drive $i (with RAID level=$raid_level, size=$logicaldrive_size, strip size=$logicaldrive_strip_size, mount points=$mount_points, multi domain status=$multidomain_status) in controller slot $ctrlid has status $logicaldrive_status!";
							}
							else {
								$warning_str .= " WARNING: Logical drive $i (with RAID level=$raid_level, size=$logicaldrive_size, strip size=$logicaldrive_strip_size, mount points=$mount_points, multi domain status=$multidomain_status) in controller slot $ctrlid has status $logicaldrive_status!";
							}
						}
						@d = grep(/physical drive/, @c);
						if($#d != -1) {
							print STDERR "Checking physical drives for this ctrl slot=$ctrlid logicaldrive=$i ...\n";
						}
					}
				}
			}
		}
	}
}

# check individual logical and physical drives
my ($total_logical_drives, $total_physical_drives, $faulty_logical_drive_count, $faulty_physical_drive_count);
@a = `$hpacucli_prog ctrl all show config`;
$retcode = $? >>=8;
if($retcode == 0) {
	#chomp(@a = @a);
	#print STDERR @a;
	# logical drives
	@b = grep(/logicaldrive/, @a);
	$total_logical_drives = $#b + 1;
	@b = grep(!/OK/, @b);
	$faulty_logical_drive_count = $#b + 1;

	if($faulty_logical_drive_count != 0) {
		$error_str .= " ERROR: $faulty_logical_drive_count out of $total_logical_drives are not OK!";
	}
	else {
		$ok_str .= " OK: All $total_logical_drives logical drives are OK.";
	}

	# physical drives
	@b = grep(/physicaldrive/, @a);
	$total_physical_drives = $#b + 1;
	@b = grep(!/OK/, @b);
	$faulty_physical_drive_count = $#b + 1;

	if($faulty_physical_drive_count != 0) {
		$error_str .= " ERROR: $faulty_physical_drive_count out of $total_physical_drives are not OK!";
		# find out which physical drives have problems and their location (bay number)
		my ($drive_bay, $drive_status);
		foreach(@b) {
			print STDERR "faulty physical drive ...\n";
			$drive_bay = (split(/\s+/, (split(/:/, (split(/,/, $_))[0]))[4]))[1];
			$drive_status = trim((split(/:/, (split(/,/, $_))[3]))[0]);
			if($drive_status eq 'Rebuilding') {
				$warning_str .= "WARNING: The hard disk in the $drive_bay bay has status $drive_status!";
			}
			else {
				$error_str .= "ERROR: The hard disk in the $drive_bay bay has status $drive_status!";
			}
		}
	}
	else {
		$ok_str .= " OK: All $total_physical_drives physical drives are OK.";
	}
}

if($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
if($warning_str ne '') {
	if($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= "$warning_str";
}
if($ok_str ne '') {
	$message_str .= "$ok_str";
}
if($info_str ne '') {
	$message_str .= "$info_str";
}
###################################################################################
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
#hpacucli ctrl slot=1 logicaldrive all show
#
#Smart Array P400 in Slot 1
#
#   array A
#
#         logicaldrive 1 (546.8 GB, RAID 1+0, OK)
########################################################
## hpacucli ctrl slot=4 logicaldrive all show
#
#Smart Array P800 in Slot 4
#
# array A
#
#        logicaldrive 1 (1.2 TB, RAID 5, OK)
#
# array B
#
#        logicaldrive 2 (2.5 TB, RAID 5, OK)
#
# array C
#
#        logicaldrive 3 (1.2 TB, RAID 5, OK)
########################################################
# hpacucli ctrl all show status
#
#Smart Array P400 in Slot 1
#   Controller Status: OK
#   Cache Status: OK
#
#Smart Array P800 in Slot 4
#   Controller Status: OK
#   Cache Status: OK
#   Battery/Capacitor Status: OK
################################################################################
#
#hpacucli ctrl slot=1 show detail
#Smart Array P400 in Slot 1
#   Bus Interface: PCI
#   Slot: 1
#   Serial Number: P61620D9SUG472
#   Cache Serial Number: PA82C0H9SUP79K
#   RAID 6 (ADG) Status: Disabled
#   Controller Status: OK
#   Chassis Slot: 
#   Hardware Revision: Rev D
#   Firmware Version: 7.22
#   Rebuild Priority: Medium
#   Expand Priority: Medium
#   Surface Scan Delay: 15 secs
#   Surface Scan Mode: Idle
#   Wait for Cache Room: Disabled
#   Surface Analysis Inconsistency Notification: Disabled
#   Post Prompt Timeout: 0 secs
#   Cache Board Present: True
#   Cache Status: OK
#   Accelerator Ratio: 100% Read / 0% Write
#   Drive Write Cache: Disabled
#   Total Cache Size: 256 MB
#   No-Battery Write Cache: Disabled
#   Battery/Capacitor Count: 0
#   SATA NCQ Supported: True

###############
#
#hpacucli ctrl slot=4 show detail
#Smart Array P800 in Slot 4
#   Bus Interface: PCI
#   Slot: 4
#   Serial Number: PAFGF0N9SX40OJ
#   Cache Serial Number: PA82B0A9SX50IF
#   RAID 6 (ADG) Status: Enabled
#   Controller Status: OK
#   Chassis Slot: 
#   Hardware Revision: Rev E
#   Firmware Version: 7.22
#   Rebuild Priority: Medium
#   Expand Priority: Medium
#   Surface Scan Delay: 15 secs
#   Surface Scan Mode: Idle
#   Queue Depth: Automatic
#   Monitor and Performance Delay: 60 min
#   Elevator Sort: Enabled
#   Degraded Performance Optimization: Disabled
#   Inconsistency Repair Policy: Disabled
#   Wait for Cache Room: Disabled
#   Surface Analysis Inconsistency Notification: Disabled
#   Post Prompt Timeout: 0 secs
#   Cache Board Present: True
#   Cache Status: OK
#   Accelerator Ratio: 25% Read / 75% Write
#   Drive Write Cache: Disabled
#   Total Cache Size: 512 MB
#   No-Battery Write Cache: Disabled
#   Cache Backup Power Source: Batteries
#   Battery/Capacitor Count: 2
#   Battery/Capacitor Status: OK
#   SATA NCQ Supported: True
##############################################################################################
