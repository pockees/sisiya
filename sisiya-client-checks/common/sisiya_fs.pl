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

if(-f $SisIYA_Config::local_conf) {
	require $SisIYA_Config::local_conf;
}
if(-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
###############################################################################
#### the default values
our $df_prog = 'df';
our $tune2fs_prog = '/sbin/tune2fs';
our %percents = ('warning' => 85, 'error' => 90); 
our @exclude_list = ( '/proc', '/dev/shm', '/var/media', 'devtmpfs', 'tmpfs');
our %exception_list;
# %exception_list = ( 
#			'/'	=> {'error' => 91, 'warning' => 88},
#			'/usr'	=> {'error' => 90, 'warning' => 87}
#		);
#### end of the default values
################################################################################
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
sub get_filesystem_state
{
	my $fs_device = $_[0];
	my $fs_type = $_[1];
	my $state = ''; # not defined
	### check the filesystem state
	#print STDERR "fs_type = $fs_type\n";
	if( ($fs_type eq 'reiserfs') || ($fs_type eq 'vfat') || ($fs_type eq 'tmpfs') || ($fs_type eq 'fuseblk')) {
		#print STDERR "fs_type = $fs_type is not appicable.\n";
		return $state;
	}
	my @a =   `$tune2fs_prog -l $fs_device 2>/dev/null`;
	my $retcode = $? >>=8;
	if($retcode == 0) {
		@a = grep(/^Filesystem state/, @a);
		chomp($a[0] = $a[0]);
		#my @b = split(/:/, $a[0]);
		#$state = trim($b[1]);
		$state = trim( (split(/:/, $a[0]))[1] );
		#print STDERR "$fs_device state is $state\n";
	}
	return $state;
}
#######################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'filesystem';
my $error_str = '';
my $ok_str = '';
my $warning_str = '';
my %file_systems;
my $fs_state;
my $percent_error;
my $percent_warning;
if($SisIYA_Config::osname eq 'Linux') {
	#my @a = `$df_prog -TPk`;
	my @a = grep(/^\//, `$df_prog -TPkl`);
	my $found;
	foreach my $fs (@a) {
		chomp($fs);
		#print STDERR "fs=[$fs]\n";
		$found = 0;
		foreach(@exclude_list) {
			if(index($fs, $_) != -1) {
				$found = 1;
				last;
			}	
		}
		if($found == 0) {
			#printf STDERR "Adding fs=[$fs]\n";
			my @b = split(/ +/, $fs);
			#foreach(@b) {
			#	printf STDERR "$_\n";
			#}
			$file_systems{$b[0]}{'type'} = $b[1]; 
			$file_systems{$b[0]}{'total'} = $b[2]; 
			$file_systems{$b[0]}{'used'} = $b[3]; 
			$file_systems{$b[0]}{'available'} = $b[4];
			my @c = split('%', $b[5]);
			$file_systems{$b[0]}{'capacity'} = $c[0];
			$file_systems{$b[0]}{'mounted_on'} = $b[6];
		}
	}
}
elsif($SisIYA_Config::osname eq 'SunOS') {
	#my @a = `$df_prog -TPk`;
	my @a = grep(/^\//, `$df_prog -k`);
	my $found;
	foreach my $fs (@a) {
		chomp($fs);
		#print STDERR "fs=[$fs]\n";
		$found = 0;
		foreach(@exclude_list) {
			if(index($fs, $_) != -1) {
				$found = 1;
				last;
			}	
		}
		if($found == 0) {
			#printf STDERR "Adding fs=[$fs]\n";
			my @b = split(/ +/, $fs);
			#foreach(@b) {
			#	printf STDERR "$_\n";
			#}
			$file_systems{$b[0]}{'type'} = $b[1]; 
			$file_systems{$b[0]}{'total'} = $b[2]; 
			$file_systems{$b[0]}{'used'} = $b[3]; 
			$file_systems{$b[0]}{'available'} = $b[4];
			my @c = split('%', $b[5]);
			$file_systems{$b[0]}{'capacity'} = $c[0];
			$file_systems{$b[0]}{'mounted_on'} = $b[6];
		}
	}
}
for my $k (keys %file_systems) {
	#print STDERR "-----> : key=[$k] type=[$file_systems{$k}{'type'}] total=[$file_systems{$k}{'total'}] used=[$file_systems{$k}{'used'}] available=[$file_systems{$k}{'available'}] capacity=[$file_systems{$k}{'capacity'}] mountded on=[$file_systems{$k}{'mounted_on'}]\n";
	$percent_error = $percents{'error'};
	$percent_warning = $percents{'warning'};
	if(defined $exception_list{$file_systems{$k}{'mounted_on'}}) {
		$percent_error = $exception_list{$file_systems{$k}{'mounted_on'}}{'error'};
		$percent_warning = $exception_list{$file_systems{$k}{'mounted_on'}}{'warning'};
	}
	if($file_systems{$k}{'capacity'} >= $percent_error) {
		$error_str .= "ERROR: $file_systems{$k}{'mounted_on'} ($file_systems{$k}{'type'}) $file_systems{$k}{'capacity'}% (>= $percent_error) of ".get_size_k($file_systems{$k}{'total'})." is full!";
	}
	elsif($file_systems{$k}{'capacity'} >= $percent_warning) {
		$warning_str .= "WARNING: $file_systems{$k}{'mounted_on'} ($file_systems{$k}{'type'}) $file_systems{$k}{'capacity'}% (>= $percent_warning) of ".get_size_k($file_systems{$k}{'total'})." is full!";
	}
	else {
		$ok_str .= "OK: $file_systems{$k}{'mounted_on'} ($file_systems{$k}{'type'}) $file_systems{$k}{'capacity'}% of ".get_size_k($file_systems{$k}{'total'})." is used.";
	}
	$fs_state = get_filesystem_state($k, $file_systems{$k}{'type'});
	if( ($fs_state ne '') && ($fs_state ne 'clean') ) {
			$error_str .= " ERROR: The filesystem state for $file_systems{$k}{'mounted_on'} is $fs_state (<> clean)!";
	}
}

if($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = $error_str;
}
if($warning_str ne '') {
	if($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= $warning_str;
}
if($ok_str ne '') {
	$message_str .= $ok_str;
}
##################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
##################################################################################
#echo "df_command=[$df_command] grep_prog=[$grep_prog]"
#######################################################################
### OpenSolaris 5.11 (2009.06)
# df -TPk
#Filesystem    Type 1024-blocks      Used Available Capacity Mounted on
#rpool/ROOT/opensolaris zfs   3562422   2991983    570440      84% /
#swap         tmpfs      658504       372    658132       1% /etc/svc/volatile
#/usr/lib/libc/libc_hwcap1.so.1 lofs   3562422   2991983    570440      84% /lib/libc.so.1
#swap         tmpfs      658152        20    658132       1% /tmp
#swap         tmpfs      658216        84    658132       1% /var/run
#rpool/export   zfs      570461        21    570440       1% /export
#rpool/export/home zfs    570459        19    570440       1% /export/home
#rpool          zfs      570517        78    570440       1% /rpool
#######################################################################
### on OpenBSD
# df-Pk
#Filesystem  1024-blocks       Used   Available Capacity Mounted on
#/dev/sd0a        908184      39802      822974     5%   /
#/dev/sd0e        431490          2      409914     0%   /home
#/dev/sd0d       2523220     583064     1813996    24%   /usr
#######################################################################
### on NetBSD 
#df -Pk
#Filesystem 1024-blocks Used Available Capacity Mounted on
#/dev/sd0a 33030000 4870720 26507792 15% /
#kernfs 1 1 0 100% /kern
#ptyfs 1 1 0 100% /dev/pts
#procfs 4 4 0 100% /proc
#######################################################################
# on HP-UX
# Filesystem          1024-blocks  Used  Available Capacity Mounted on
# icserpln:/backup      1209713792 774085504 435628288    64%   /backup
# /dev/vg01/lvol2       12158948  8157614  4001334    68%   /apps
# /dev/vg03/lvol1       35430160 19787352 15642808    56%   /data
# /dev/vg04/lvol1       33263016 18000192 15262824    55%   /data2
# /dev/vg00/lvol9       500351   123155   377196    25%   /home
# /dev/vg05/lvol1       69212064 28835000 40377064    42%   /index
# /dev/vg02/lvol1       35034586 18950806 16083780    55%   /index2
# /dev/vg00/lvol4       1005272   351037   654235    35%   /opt
# /dev/vg00/lvol5       131072    62241    68831    48%   /tmp
# /dev/vg00/lvol6       1014661   505745   508916    50%   /usr
# /dev/vg01/lvol1       12118226  5112992  7005234    43%   /usr2
# /dev/vg00/lvol7       1038753   842327   196426    82%   /var
# /dev/vg00/lvol1       75359    39512    35847    53%   /stand
# /dev/vg00/lvol3       385866   273466   112400    71%   /
#######################################################################
### on Linux 
# df -TPk
#Filesystem    Type 1024-blocks      Used Available Capacity Mounted on
#/dev/sda2      ext4      19136764   9761152 8380472      54% /
#dev            devtmpfs   4023108         0 4023108       0% /dev
#run            tmpfs      4025944       892 4025052       1% /run
#tmpfs          tmpfs      4025944        76 4025868       1% /dev/shm
#tmpfs          tmpfs      4025944         0 4025944       0% /sys/fs/cgroup
#tmpfs          tmpfs      4025944        12 4025932       1% /tmp
#/dev/sda3      ext4     457882848 430496788 4103836     100% /data
#######################################################################

