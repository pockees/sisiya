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
use IO::Socket;
use SisIYA_Config;
#use diagnostics;

if( $#ARGV != 0 ) {
	#print "Usage : $0 SisIYA_client_conf.pm expire\n";
	print "Usage : $0 expire\n";
	print "The expire parameter must be given in minutes.\n";
	exit 1;
}

#my $conf_file = $ARGV[0];
#my $expire = $ARGV[1];
my $expire = $ARGV[0];

if(-f $SisIYA_Config::sisiya_local_conf) {
	require $SisIYA_Config::sisiya_local_conf;
}

#foreach ($SisIYA_Config::sisiya_base_dir, $SisIYA_Config::sisiya_common_dir, $SisIYA_Config::sisiya_special_dir) {
#	if (! -d $_) {
#		print "$0: No such directory : $_\n";
#		exit 1;
#	}
#}

sub get_serviceid
{
	my $sid;

	my @a = split(/$SisIYA_Config::FS/, $_[0]);
	$sid = $SisIYA_Config::serviceids{$a[0]};
	return $sid;
}

sub get_sisiya_date
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	
	$year = 1900 + $year;
	#	print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n";
	my $str = $year.sprintf("%.2d%.2d%.2d%.2d%.2d", $mon, $mday, $hour, $min, $sec);
	return $str;

}

sub send_message_data
{
	my $sock = new IO::Socket::INET (PeerAddr => $SisIYA_Config::sisiya_server, PeerPort => $SisIYA_Config::sisiya_port, Proto => 'tcp',);
	die "$0 :Could not create TCP socket to ".$SisIYA_Config::sisiya_server.":".$SisIYA_Config::sisiya_port." with the following error : $!\n" unless $sock;

	print $sock $_[0];

	close($sock);
}

opendir(my $dh, $SisIYA_Config::sisiya_common_dir) || die "$0 : Cannot open directory: $SisIYA_Config::sisiya_common_dir! $!";
my @scripts = grep { /^sisiya_*/ && -x "$SisIYA_Config::sisiya_common_dir/$_" } readdir($dh);
closedir($dh);

my $s;
my $statusid;
my $serviceid;

my $date_str = get_sisiya_date;

my $xml_str = '<?xml version="1.0" encoding="utf-8"?>';
$xml_str .= '<sisiya_messages><timestamp>'.$date_str.'</timestamp>';
$xml_str .= '<system><name>'.$SisIYA_Config::sisiya_hostname.'</name>';

foreach my $f (@scripts) {
	print STDERR "[$f] ...\n";
	#chomp($s = `/usr/bin/perl -I./ $SisIYA_Config::sisiya_common_dir/$f`);
	chomp($s = `/usr/bin/perl -I$SisIYA_Config::sisiya_base_dir $SisIYA_Config::sisiya_common_dir/$f`);
	$statusid = $? >> 8;
	$serviceid = get_serviceid($s);	
	print STDERR "statusid = $statusid serviceid = $serviceid message=$s\n";
	$xml_str .= "<message><serviceid>".$serviceid."</serviceid><statusid>".$statusid."</statusid><expire>".$expire."</expire><data>".$s."</data></message>";
}

print STDERR "systems dir: $SisIYA_Config::sisiya_systems_dir\n";

opendir($dh, $SisIYA_Config::sisiya_systems_dir) || die "$0 : Cannot open directory: $SisIYA_Config::sisiya_systems_dir! $!";
@scripts = grep { /^sisiya_*/ && -x "$SisIYA_Config::sisiya_systems_dir/$_" } readdir($dh);
closedir($dh);
foreach my $f (@scripts) {
	print STDERR "[$f] ...\n";
	chomp($s = `/usr/bin/perl -I$SisIYA_Config::sisiya_base_dir $SisIYA_Config::sisiya_systems_dir/$f`);
	$statusid = $? >> 8;
	$serviceid = get_serviceid($s);	
	print STDERR "statusid = $statusid serviceid = $serviceid message=$s\n";
	$xml_str .= "<message><serviceid>".$serviceid."</serviceid><statusid>".$statusid."</statusid><expire>".$expire."</expire><data>".$s."</data></message>";
}

$xml_str .= '</system></sisiya_messages>';

#print $xml_str;
send_message_data $xml_str;
exit 0;

# <?xml version="1.0" encoding="utf-8"?>
# <sisiya_messages>
# <timestamp>20130917193522</timestamp>
# <system><name>erdalmutlu-du</name>
# <message><serviceid>73</serviceid><statusid>8</statusid><expire>10</expire><data><msg>ERROR: [[ 1.379614] acpi PNP0A08:00: ACPI _OSC support notification failed, disabling PCIe ASPM] contains the string [fail]! ERROR: [[ 3.552141] ata5: SATA link down (SStatus 0 SControl 300)] contains the string [down]! ERROR: [[ 0.000000] MTRR default type: uncachable] contains the string [fault]! WARNING: [[ 2.391176] i8042: Warning: Keylock active] contains the string [warn]! OK: dmesg does not contain any of [error] [crit] [promiscuous] [timed out] [notice] [not responding] [NIC Link is Up] strings.</msg><datamsg></datamsg></data></message>
# <message><serviceid>1</serviceid><statusid>8</statusid><expire>10</expire><data><msg>ERROR: /data (ext4) 95% \(>= 90%\) of 436.67GB is full! OK: / (ext4) 50% of 18.25GB is used. </msg><datamsg></datamsg></data></message>
# <message><serviceid>100</serviceid><statusid>4</statusid><expire>10</expire><data><msg>WARNING: The system is out of date! There are 5 available updates.</msg><datamsg></datamsg></data></message>
# <message><serviceid>4</serviceid><statusid>2</statusid><expire>10</expire><data><msg>OK: Load average for the past 5 minutes is 23. ( 19:35:21 up 10 min, 6 users, load average: 0,23, 0,26, 0,21). CPU: 4 x Intel(R) Core(TM) i5-3210M CPU @ 2.50GHz GenuineIntel Cache size = 3072 KB Usage =%Cpu(s): 3,3 us, 1,2 sy, 0,0 ni, 91,2 id, 4,3 wa, 0,0 hi, 0,0 si, 0,0 st </msg><datamsg></datamsg></data></message>
# <message><serviceid>106</serviceid><statusid>2</statusid><expire>10</expire><data><msg>OK: There are 161 running process.</msg><datamsg></datamsg></data></message>
# <message><serviceid>3</serviceid><statusid>2</statusid><expire>10</expire><data><msg>OK: Swap usage is 0%. SWAP: total=0 used=0 free=0 RAM: total=7.67GB used=1.62GB free=6.05GB usage=21%</msg><datamsg></datamsg></data></message>
# <message><serviceid>0</serviceid><statusid>4</statusid><expire>10</expire><data><msg>WARNING: The system was restarted 10 minutes (&lt; 15 minutes) ago! Info: Linux 3.10.10-1-ARCH x86_64 unknown SisIYA: 0.5.31-1</msg><datamsg></datamsg></data></message>
# <message><serviceid>45</serviceid><statusid>1</statusid><expire>10</expire><data><msg> User list: erdalmutlu erdalmutlu erdalmutlu erdalmutlu erdalmutlu erdalmutlu </msg><datamsg></datamsg></data></message>
# <message><serviceid>76</serviceid><statusid>4</statusid><expire>10</expire><data><msg>WARNING: The system clock is not yet synchronized!</msg><datamsg></datamsg></data></message>
# </system>
# </sisiya_messages>

# erdalmutlu-du 73 8 10 <msg>ERROR: [[ 8.059751] ACPI Error: [DCK9] Namespace lookup failure, AE_ALREADY_EXISTS (20130328/dswload2-330)] contains the string [error]! ERROR: [[ 1.386936] acpi PNP0A08:00: ACPI _OSC support notification failed, disabling PCIe ASPM] contains the string [fail]! ERROR: [[ 3.475223] ata5: SATA link down (SStatus 0 SControl 300)] contains the string [down]! ERROR: [[ 0.000000] MTRR default type: uncachable] contains the string [fault]! WARNING: [[ 2.321273] i8042: Warning: Keylock active] contains the string [warn]! WARNING: [[ 7845.688658] usb 3-3: Device not responding to set address.] contains the string [not responding]! OK: dmesg does not contain any of [crit] [promiscuous] [timed out] [notice] [NIC Link is Up] strings.</msg><datamsg></datamsg>
# erdalmutlu-du 1 8 10 <msg>ERROR: /data (ext4) 95% \(>= 90%\) of 436.67GB is full!  OK: / (ext4) 51% of 18.25GB is used.  </msg><datamsg></datamsg>
# erdalmutlu-du 100 4 10 <msg>WARNING: The system is out of date! There are 5 available updates.</msg><datamsg></datamsg>
# erdalmutlu-du 4 2 10 <msg>OK: Load average for the past 5 minutes is 15. ( 16:08:29 up  2:31,  7 users,  load average: 0,15, 0,19, 0,16). CPU: 4 x Intel(R) Core(TM) i5-3210M CPU @ 2.50GHz  GenuineIntel Cache size = 3072 KB Usage =%Cpu(s): 2,1 us, 0,7 sy, 0,0 ni, 96,3 id, 0,9 wa, 0,0 hi, 0,0 si, 0,0 st </msg><datamsg></datamsg>
# erdalmutlu-du 106 2 10 <msg>OK: There are 163 running process.</msg><datamsg></datamsg>
# erdalmutlu-du 3 2 10 <msg>OK: Swap usage is 0%. SWAP: total=0 used=0 free=0 RAM: total=7.67GB used=2.91GB free=4.76GB usage=37%</msg><datamsg></datamsg>
# erdalmutlu-du 0 2 10 <msg>OK: The system is up since 2 hours 31 minutes. Info: Linux 3.10.10-1-ARCH x86_64 unknown SisIYA: 0.5.31-1</msg><datamsg></datamsg>
# erdalmutlu-du 45 1 10 <msg> User list:  erdalmutlu   erdalmutlu   erdalmutlu   erdalmutlu   erdalmutlu   erdalmutlu   erdalmutlu  </msg><datamsg></datamsg>
# erdalmutlu-du 76 2 10 <msg>OK: This system clock is synchronized to 10.13.1.1 .</msg><datamsg></datamsg>
