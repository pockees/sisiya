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

if( ($#ARGV < 0) || ($#ARGV > 1) ) {
	print "Usage : $0 expire\n";
	print "Usage : $0 check_script expire\n";
	print "The expire parameter must be given in minutes.\n";
	exit 1;
}

if(-f $SisIYA_Config::sisiya_local_conf) {
	require $SisIYA_Config::sisiya_local_conf;
}
if(-f $SisIYA_Config::sisiya_functions) {
	require $SisIYA_Config::sisiya_functions;
}

#foreach ($SisIYA_Config::sisiya_base_dir, $SisIYA_Config::sisiya_common_dir, $SisIYA_Config::sisiya_special_dir) {
#	if (! -d $_) {
#		print "$0: No such directory : $_\n";
#		exit 1;
#	}
#}

# Parameter	: script name
# Return	: xml message string
sub run_script
{
	my $expire = $_[1];
	my ($status_id, $service_id, $s);

	#print STDERR "[$_[0]] ...\n";
	chomp($s = `/usr/bin/perl -I$SisIYA_Config::sisiya_base_dir $_[0]`);
	$status_id = $? >> 8;
	$service_id = get_serviceid($s);	
	# replace ' with \', because it is a problem in the SQL statemnet
	$s =~ s/'/\\\'/g;
	$s = (split(/$SisIYA_Config::FS/, $s))[1];
	$s = '<message><serviceid>'.$service_id.'</serviceid><statusid>'.$status_id.'</statusid><expire>'.$expire.'</expire><data>'.$s.'</data></message>';
	#print STDERR "statusid = $status_id serviceid = $service_id message=$s\n";
	return $s;	

}

# Parameter	: Script directory
# Return	: XML string
sub process_checks
{
	my $dir_str = $_[0];
	my $expire  = $_[1];
	my ($status_id, $service_id);
	my $s = '';

	if(opendir(my $dh, $dir_str)) {
		my @scripts = grep { /^sisiya_*/ && -x "$dir_str/$_" } readdir($dh);
		closedir($dh);
		foreach my $f (@scripts) {
			$s .= run_script("$dir_str/$f", $expire); 
		}
	}
	return $s;
}

# record the start time
my $date_str = get_sisiya_date();
my $expire;
my $xml_s_str = '';

if($#ARGV == 1) {
	$expire = $ARGV[1];
	$xml_s_str = run_script($ARGV[0], $expire);
}
else {
	$expire = $ARGV[0];
	$xml_s_str  = process_checks($SisIYA_Config::sisiya_common_dir, $expire);
	$xml_s_str .= process_checks($SisIYA_Config::sisiya_systems_dir, $expire);
}

if($xml_s_str eq '') {
	print STDERR "There is no SisIYA message to be send!\n";
	exit 1;
}

my $xml_str = '<?xml version="1.0" encoding="utf-8"?>';
$xml_str .= '<sisiya_messages><timestamp>'.$date_str.'</timestamp>';
$xml_str .= '<system><name>'.$SisIYA_Config::sisiya_hostname.'</name>';
$xml_str .= $xml_s_str;
$xml_str .= '</system></sisiya_messages>';

#print STDERR $xml_str;
send_message_data($xml_str);
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
