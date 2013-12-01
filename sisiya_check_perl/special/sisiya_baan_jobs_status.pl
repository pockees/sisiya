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
our $baan_jobs_status_db_prog = '';
##our $baan_jobs_status_db_prog="$SisIYA_Config::sisiya_utils_dir/sisiya_baan_jobs_status_oracle.pl"
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
my $service_name = 'baan_jobs_status';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

if($baan_jobs_status_db_prog eq '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: There is no defined Baan Jobs status db script!";
	sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}

my @a = `$baan_jobs_status_db_prog`;
my $retcode = $? >>=8;
if($retcode != 0) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: Error executing the $baan_jobs_status_db_prog command! retcode=$retcode";
	sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}

#print STDERR @a;

my @jobs;
my ($job_code, $job_status, $job_description, $last_time, $next_time);
chomp(@a = @a);
foreach(@a) {
	$job_code = trim((split(/\|/, $_))[0]);
	$job_status = trim((split(/\|/, $_))[1]);
	$job_description = (split(/\|/, $_))[2];
	$next_time = (split(/\|/, $_))[3];
	$last_time = (split(/\|/, $_))[4];
	push @jobs, {'code' => $job_code, 'status' => $job_status, 'description' => $job_description, 'next_time' => $next_time, 'last_time' => $last_time};
}
my $info_str;
for my $i (0..$#jobs) {
	#print STDERR "code=[$jobs[$i]{'code'}] status=[$jobs[$i]{'status'}] description=[$jobs[$i]{'description'}] last=[$jobs[$i]{'last_time'}] next=[$jobs[$i]{'next_time'}]\n";
	$info_str = "$jobs[$i]{'description'} last execution time $jobs[$i]{'last_time'}, next execution time $jobs[$i]{'next_time'}";
	if($jobs[$i]{'status'} == 1) {
		$ok_str .= " OK: $jobs[$i]{'code'} ($info_str) is free.";
	}
	elsif($jobs[$i]{'status'} == 2) {
		$ok_str .= " OK: $jobs[$i]{'code'} ($info_str) is waiting.";
	}
	elsif($jobs[$i]{'status'} == 3) {
		$ok_str .= " OK: $jobs[$i]{'code'} ($info_str) is running.";
	}
	elsif($jobs[$i]{'status'} == 4) {
		$warning_str .= " WARNING: $jobs[$i]{'code'} ($info_str) is canceled!";
	}
	elsif($jobs[$i]{'status'} == 5) {
		$error_str .= " ERROR: $jobs[$i]{'code'} ($info_str) has got runtime error!";
	}
	elsif($jobs[$i]{'status'} == 6) {
		$ok_str .= " OK: $jobs[$i]{'code'} ($info_str) is in queue.";
	}
	elsif($jobs[$i]{'status'} == 7) {
		$error_str .= " ERROR: $jobs[$i]{'code'} ($info_str) is blocked!";
	}
	else {
		$error_str .= " ERROR: $jobs[$i]{'code'} ($info_str) status is unknown ($jobs[$i]{'status'})!";
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
	$message_str .= " $warning_str";
}
if($ok_str ne '') {
	$message_str .= " $ok_str";
}
if($info_str ne '') {
	$message_str .= " $info_str";
}
###################################################################################
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
