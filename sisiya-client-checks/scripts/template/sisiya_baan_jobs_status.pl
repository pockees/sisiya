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
my $service_name = 'baan_jobs_status';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
chomp($module_conf_file);
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

if (! -f $SisIYA_Config::external_progs{'baan_jobs_status_db'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: External program $SisIYA_Config::external_progs{'baan_jobs_status_db'} does not exist!";
	print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}

my @a = `$SisIYA_Config::external_progs{'baan_jobs_status_db'}`;
my $retcode = $? >>=8;
if ($retcode != 0) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: Error executing the $SisIYA_Config::external_progs{'baan_jobs_status_db'} command! retcode=$retcode";
	print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}

#print STDERR @a;

my @jobs;
my ($job_code, $job_status, $job_description, $last_time, $next_time);
chomp(@a = @a);
foreach (@a) {
	$job_code = trim((split(/\|/, $_))[0]);
	$job_status = trim((split(/\|/, $_))[1]);
	$job_description = (split(/\|/, $_))[2];
	$next_time = (split(/\|/, $_))[3];
	$last_time = (split(/\|/, $_))[4];
	push @jobs, {'code' => $job_code, 'status' => $job_status, 'description' => $job_description, 'next_time' => $next_time, 'last_time' => $last_time};
}
$data_str = '<entries>';
my $flag = 1; # true
for my $i (0..$#jobs) {
	#print STDERR "code=[$jobs[$i]{'code'}] status=[$jobs[$i]{'status'}] description=[$jobs[$i]{'description'}] last=[$jobs[$i]{'last_time'}] next=[$jobs[$i]{'next_time'}]\n";
	$info_str = "$jobs[$i]{'description'} last execution time $jobs[$i]{'last_time'}, next execution time $jobs[$i]{'next_time'}";
	if ($jobs[$i]{'status'} == 1) {
		$ok_str .= " OK: $jobs[$i]{'code'} ($info_str) is free.";
	}
	elsif ($jobs[$i]{'status'} == 2) {
		$ok_str .= " OK: $jobs[$i]{'code'} ($info_str) is waiting.";
	}
	elsif ($jobs[$i]{'status'} == 3) {
		$ok_str .= " OK: $jobs[$i]{'code'} ($info_str) is running.";
	}
	elsif ($jobs[$i]{'status'} == 4) {
		$warning_str .= " WARNING: $jobs[$i]{'code'} ($info_str) is canceled!";
		$flag = 0; # false
	}
	elsif ($jobs[$i]{'status'} == 5) {
		$error_str .= " ERROR: $jobs[$i]{'code'} ($info_str) has got runtime error!";
		$flag = 0; # false
	}
	elsif ($jobs[$i]{'status'} == 6) {
		$ok_str .= " OK: $jobs[$i]{'code'} ($info_str) is in queue.";
	}
	elsif ($jobs[$i]{'status'} == 7) {
		$error_str .= " ERROR: $jobs[$i]{'code'} ($info_str) is blocked!";
		$flag = 0; # false
	}
	else {
		$error_str .= " ERROR: $jobs[$i]{'code'} ($info_str) status is unknown ($jobs[$i]{'status'})!";
		$flag = 0; # false
	}
	$data_str .= '<entry name="'.$jobs[$i]{'code'}.'" type="boolean">'.$flag.'</entry>';
}
$data_str .= '</entries>';

if ($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
if ($warning_str ne '') {
	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= " $warning_str";
}
if ($ok_str ne '') {
	$message_str .= " $ok_str";
}
if ($info_str ne '') {
	$message_str .= " $info_str";
}
######################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
######################################################################################
