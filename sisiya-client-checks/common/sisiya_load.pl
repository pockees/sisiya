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
# load avarage is specified by A * 100, where A is the normal load avarage. Example: In 
# order to specify load avarage limit of 1.2 => 1.2 * 100 = 120
our %load_avarages = ( 'warning' => 2, 'error' => 5);
our $uptime_prog = 'uptime';
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
my $message_str = "INFO: Unsupported system for uptodate checking.";
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'info'};
my $service_name = 'load';
################################################################################
sub get_load_avarage
{
	my $n = 0;
	if ($SisIYA_Config::osname eq 'Linux') {
		#cat /proc/loadavg 
		#0.04 0.09 0.13 1/410 11983
		my $x;
		my $file;
		open($file, '<', '/proc/loadavg') || die "$0: Could not open file /proc/loadavg! $!";
		$x = <$file>;
		close $file;
		#chomp($x);
		$n = (split(/ /, $x))[0];
	}
	elsif ($SisIYA_Config::osname eq 'SunOS') {
		# uptime
		# 10:16am  up  3 users,  load average: 0.01, 0.02, 0.01
		my @a = `$uptime_prog`;
		my $retcode = $? >>=8;
		if ($retcode != 0) {
			$statusid = $SisIYA_Config::statusids{'error'};
			$message_str = "ERROR: Error executing the uptime command $uptime_prog! retcode=$retcode";
			print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
		}
		else {
			$n = (split(/,/,(split(/:/, $a[0]))[2]))[0];
		}

	}
	return $n;
}

sub get_cpu_usage
{
	my $s = '';

	if ($SisIYA_Config::osname eq 'Linux') {
		my @a = `top -b -n 1`;
		# starts with Cpu(s): or %Cpu(s):
		$s = (grep(/^.*[C,c]pu[0-9,(]/, @a))[0];
	}
	# the grep above undefines the $s
	if ((defined $s) && ($s ne '')) {
		$s = " Usage: $s";
	}
	else {
		$s = '';
	}
	return $s;
}

sub get_cpu_info
{
	my $s = '';
	if ($SisIYA_Config::osname eq 'Linux') {
		chomp(my @a =`cat /proc/cpuinfo`);
		my @b = grep(/^processor/, @a);
		my $cpu_count = @b;
		### I assume that all CPUs are of the same model. Actually this may not be the case.
		$s = $cpu_count.' x'.(split(/:/, (grep(/^model name/, @a))[0]))[1];
		$s .= ( split(/:/, (grep(/^vendor_id/, @a))[0]) )[1];
		$s .= " Cache size =".(split(/:/, (grep(/^cache size/, @a))[0]))[1];
	}
	if ($s ne '') {
		$s = " CPU: $s";
	}
	return $s;
}
################################################################################
my $n = get_load_avarage();
my $str = "Load average for the past 5 minutes is $n";

if ($n >= $load_avarages{'error'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: $str >= $load_avarages{'error'}!";
}
elsif ($n >= $load_avarages{'warning'}) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = "WARNING: $str >= $load_avarages{'warning'}!";
}
else {
	$statusid = $SisIYA_Config::statusids{'ok'};
	$message_str = "OK: $str.";
}
### add cpu info
$message_str .= get_cpu_info();
### add cpu usage info
$message_str .= get_cpu_usage();
$data_str = '<entries><entry name="load_average" type="numeric">'.$n.'</entry></entries>';
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
#
#cat /proc/cpuinfo 
#processor       : 0
#vendor_id       : GenuineIntel
#cpu family      : 6
#model           : 58
#model name      : Intel(R) Core(TM) i5-3210M CPU @ 2.50GHz
#stepping        : 9
#microcode       : 0x15
#cpu MHz         : 2900.000
#cache size      : 3072 KB
#physical id     : 0
#siblings        : 4
#core id         : 0
#cpu cores       : 2
#apicid          : 0
#initial apicid  : 0
#fpu             : yes
#fpu_exception   : yes
#cpuid level     : 13
#wp              : yes
#flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm ida arat epb xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep erms
#bogomips        : 4985.34
#clflush size    : 64
#cache_alignment : 64
#address sizes   : 36 bits physical, 48 bits virtual
#power management:
#
#processor       : 1
#vendor_id       : GenuineIntel
#cpu family      : 6
#model           : 58
#model name      : Intel(R) Core(TM) i5-3210M CPU @ 2.50GHz
#stepping        : 9
#microcode       : 0x15
#cpu MHz         : 3075.000
#cache size      : 3072 KB
#physical id     : 0
#siblings        : 4
#core id         : 1
#cpu cores       : 2
#apicid          : 2
#initial apicid  : 2
#fpu             : yes
#fpu_exception   : yes
#cpuid level     : 13
#wp              : yes
#flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm ida arat epb xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep erms
#bogomips        : 4985.34
#clflush size    : 64
#cache_alignment : 64
#address sizes   : 36 bits physical, 48 bits virtual
#power management:
