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
# load avarage is specified by A * 100, where A is the normal load avarage. Example: In 
# order to specify load avarage limit of 1.2 => 1.2 * 100 = 120
our %load_avarages = ( 'warning' => 2, 'error' => 5);
our $uptime_prog = 'uptime';
our $mpstat_prog = '/usr/bin/mpstat';
#### end of the default values
#######################################################################################
my $service_name = 'load';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
my $message_str = "INFO: Unsupported system for uptodate checking.";
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'info'};
#######################################################################################
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

sub get_cpu_utilization
{
	my $s = '';
	my @a = `$mpstat_prog`;
	my $retcode = $? >>=8;
	if ($retcode == 0) {
		#04:14:37 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
		#04:14:37 PM  all    5.55    0.00    1.88    1.55    0.00    0.06    0.00    0.00   90.96
		my @b = split(/\s+/, (grep(/all/, @a))[0]);
		my $i = 3;
		if ($#b == 10) {
			$i = 2;
		}
		$s = '<entry name="cpu_user" type="numeric">'.$b[$i++].'</entry>';
		$s .= '<entry name="cpu_nice" type="numeric">'.$b[$i++].'</entry>';
		$s .= '<entry name="cpu_sys" type="numeric">'.$b[$i++].'</entry>';
		$s .= '<entry name="cpu_iowait" type="numeric">'.$b[$i++].'</entry>';
		$s .= '<entry name="cpu_irq" type="numeric">'.$b[$i++].'</entry>';
		$s .= '<entry name="cpu_soft" type="numeric">'.$b[$i++].'</entry>';
		$s .= '<entry name="cpu_steal" type="numeric">'.$b[$i++].'</entry>';
		$s .= '<entry name="cpu_guest" type="numeric">'.$b[$i++].'</entry>';
		$s .= '<entry name="cpu_idle" type="numeric">'.$b[$i++].'</entry>';
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
$data_str = '<entries><entry name="load_average" type="numeric">'.$n.'</entry>'.get_cpu_utilization().'</entries>';
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
#mpstat 
#Linux 2.6.32-358.23.2.el6.x86_64 (dbsrv01.altiniplik.com.tr)    02/03/2014      _x86_64_        (16 CPU)
#
#04:14:37 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
#04:14:37 PM  all    5.55    0.00    1.88    1.55    0.00    0.06    0.00    0.00   90.96
########################################################################################
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
