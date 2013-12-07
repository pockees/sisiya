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
#Put the following line in the conf/sisiya_system.pl file:
#$info_prog = '/usr/bin/perl -I/opt/sisiya-client-checks /opt/sisiya-client-checks/special/sisiya_system_info_hpasm.pl';
###############################################################################
#### the default values
#
our $hpasmcli_prog = '/sbin/hpasmcli';
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################

my @a = `$hpasmcli_prog -s "show server"`;
my $retcode = $? >>=8;
if($retcode != 0) {
	print '';
}
else {
	chomp(@a = @a);
	my $s = "@a";
	$s =~ s/\s+/ /g;
	print $s;
}
1;
################################################################################
################################################################################
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

# hpasmcli -s "show server"
#
#System        : ProLiant DL180 G6  
#Serial No.    : CZ31492TTA
#ROM version   : O20 06/15/2011
#iLo present   : No
#Embedded NICs : 2
#        NIC1 MAC: 44:1e:a1:53:09:ce
#        NIC2 MAC: 44:1e:a1:53:09:cf
#
#Processor: 0
#        Name         : Intel Xeon
#        Stepping     : 2
#        Speed        : 2400 MHz
#        Bus          : 532 MHz
#        Core         : 4
#        Thread       : 8
#        Socket       : 1
#        Level1 Cache : 256 KBytes
#        Level2 Cache : 1024 KBytes
#        Level3 Cache : 12288 KBytes
#        Status       : Ok
#
#Processor: 1
#        Name         : Intel Xeon
#        Stepping     : 2
#        Speed        : 2400 MHz
#        Bus          : 532 MHz
#        Core         : 4
#        Thread       : 8
#        Socket       : 2
#        Level1 Cache : 256 KBytes
#        Level2 Cache : 1024 KBytes
#        Level3 Cache : 12288 KBytes
#        Status       : Ok
#
#Processor total  : 2
#
#Memory installed : 65536 MBytes
#ECC supported    : Yes
