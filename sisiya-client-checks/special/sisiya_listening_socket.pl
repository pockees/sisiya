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
###############################################################################
#### the default values
our $netstat_prog = 'netstat';
our @sockets;
#our @sockets = ( 
#		{
#			'progname' 	=> 'myserver', 
#			'description' 	=> 'My special server1',
#			'onerror'	=> 'warn',
#			'port'		=> 45566,
#			'protocol'	=> 'tcp',
#			'interface'	=> '0.0.0.0'
#		},
#		{
#			'progname' 	=> 'myserver', 
#			'description' 	=> 'My special server1',
#			'onerror'	=> 'warn',
#			'port'		=> 45566,
#			'protocol'	=> 'udp',
#			'interface'	=> '0.0.0.0'
#		},
#	);
#
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if (-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'listening_socket';
my $error_str = '';
my $ok_str = '';
my $warning_str = '';
#push @sockets , { 'progname' => 'myserver1', 'description' => 'My special server1', 'onerror' => 'warn', 'port' => 45566, 'protocol' => 'tcp', 'interface' => '0.0.0.0' };
#push @sockets , { 'progname' => 'myserver2', 'description' => 'My special server2', 'onerror' => '', 'port' => 45566, 'protocol' => 'tcp', 'interface' => '0.0.0.0' };
#print STDERR "array size      = @sockets\n";
#print STDERR "max array index = $#sockets\n";
my @a;
my @netstat_list;

sub is_listening_socket
{
	my $j = $_[0];
	my $found = 0;
	my $interface_port_str;
	for my $i (0..$#netstat_list) {
		$interface_port_str = "$sockets[$j]{'interface'}:$sockets[$j]{'port'}";
		#print STDERR "$netstat_list[$i][0] [$netstat_list[$i][5]] [$netstat_list[$i][6]] $netstat_list[$i][3] $interface_port_str\n";
		if ($sockets[$j]{'protocol'} eq 'tcp') {
			if (
				($netstat_list[$i][0] eq $sockets[$j]{'protocol'})
			&& 	($netstat_list[$i][3] eq $interface_port_str)
			&& 	($netstat_list[$i][5] eq 'LISTEN')
			&& 	($netstat_list[$i][6] eq $sockets[$j]{'progname'})
			) {
					$found = 1;
					last;
			}
		} elsif ($sockets[$j]{'protocol'} eq 'udp') {
			if (
				($netstat_list[$i][0] eq $sockets[$j]{'protocol'})
			&& 	($netstat_list[$i][3] eq $interface_port_str)
			&& 	($netstat_list[$i][5] eq $sockets[$j]{'progname'})
			) {
					$found = 1;
					last;
			}
		} elsif ($sockets[$j]{'protocol'} eq 'unix') {
			if (
				(
						($netstat_list[$i][0] eq $sockets[$j]{'protocol'})
					&& 	($netstat_list[$i][9] eq $sockets[$j]{'progname'})
				) || (
					($netstat_list[$i][0] eq $sockets[$j]{'protocol'})
					&&	(defined $netstat_list[$i][10])
					&& 	($netstat_list[$i][10] eq $sockets[$j]{'progname'})
				)
			) {
					$found = 1;
					last;
			}
		}

	}
	return $found;
}

my ($i, $j);
if ($#sockets > -1) {
	@a = `$netstat_prog -nlp`;
	my $retcode = $? >>=8;
	if ($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Error executing the netstat command! retcode=$retcode";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
	my @b;
        my @c;
	for $i (0..$#a) {
		@b = split(/\s+/, $a[$i]);
		print STDERR @b."\n";
		$j = 0;
		foreach my $k (@b) {
			print STDERR "$k ";
			if (($j == 6) && ($netstat_list[$i][0] eq 'tcp')) {
				# extract the progname part of "PID/progname" string
				# and only add the line if it has a valid progname
				@c = split(/\//, $k);
				if ($#c == 1) {
					push @{$netstat_list[$i]}, $c[1];
				} else {
					push @{$netstat_list[$i]}, $k;
				}
			} elsif (($j == 5) && ($netstat_list[$i][0] eq 'udp')) {
				# extract the progname part of "PID/progname" string
				# and only add the line if it has a valid progname
				@c = split(/\//, $k);
				if ($#c == 1) {
					push @{$netstat_list[$i]}, $c[1];
				} else {
					push @{$netstat_list[$i]}, $k;
				}
			} else {
				push @{$netstat_list[$i]}, $k;
			}
			$j++;
		}
		print STDERR "\n";
	}

	my $s;
	for $i (0..$#sockets) {
		#print STDERR "$sockets[$i]{'progname'}...\n";
		$s = '';
		if ($i > 0) {
			$s =',';
		}
		if (is_listening_socket($i)) {
			#print STDERR "$sockets[$i]{'progname'} is OK\n";
			$ok_str .= "$s $sockets[$i]{'description'} ($sockets[$i]{'interface'}:$sockets[$i]{'port'})";
		}
		else {
			#print STDERR "$sockets[$i]{'progname'} is NOT OK\n";
			if ($sockets[$i]{'onerror'} eq 'warn') {
				$warning_str .= "$s $sockets[$i]{'description'} ($sockets[$i]{'interface'}:$sockets[$i]{'port'})";
			}
			else {
				$error_str .= "$s $sockets[$i]{'description'} ($sockets[$i]{'interface'}:$sockets[$i]{'port'})";
			}
		}
	}

}
#for $i (0..$#sockets) {
#	print STDERR "progname=$sockets[$i]{'progname'}\n";
#}
#for $i (0..$#netstat_list) {
#	print STDERR "--- i=$i : ";
#	for $j (0..(@{$netstat_list[$i]} -1)) {
#		print STDERR "$j : $netstat_list[$i][$j]";
#	}
#	print STDERR "\n";
#}
if ($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR:$error_str";
}
if ($warning_str ne '') {
	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= " WARNING:$warning_str";
}
if ($ok_str ne '') {
	$message_str .= " OK:$ok_str";
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
################################################################################
#Active Internet connections (only servers)
#Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
#tcp        0      0 0.0.0.0:58667           0.0.0.0:*               LISTEN      -                   
#tcp        0      0 0.0.0.0:5900            0.0.0.0:*               LISTEN      14852/ssh           
#tcp        0      0 127.0.0.1:5939          0.0.0.0:*               LISTEN      400/teamviewerd     
#tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      382/sshd            
#tcp        0      0 127.0.0.1:631           0.0.0.0:*               LISTEN      345/cupsd           
#tcp6       0      0 :::50758                :::*                    LISTEN      -                   
#tcp6       0      0 :::5900                 :::*                    LISTEN      14852/ssh           
#tcp6       0      0 :::22                   :::*                    LISTEN      382/sshd            
#tcp6       0      0 ::1:631                 :::*                    LISTEN      345/cupsd           
#udp        0      0 10.13.1.99:123          0.0.0.0:*                           390/ntpd            
#udp        0      0 10.13.1.98:123          0.0.0.0:*                           390/ntpd            
#udp        0      0 127.0.0.1:123           0.0.0.0:*                           390/ntpd            
#udp        0      0 0.0.0.0:123             0.0.0.0:*                           390/ntpd            
#udp6       0      0 fe80::863a:4bff:fe6:123 :::*                                390/ntpd            
#udp6       0      0 fe80::baca:3aff:fed:123 :::*                                390/ntpd            
#udp6       0      0 ::1:123                 :::*                                390/ntpd            
#udp6       0      0 :::123                  :::*                                390/ntpd            
#raw6       0      0 :::58                   :::*                    7           927/dhcpcd          
#raw6       0      0 :::58                   :::*                    7           405/dhcpcd          
#Active UNIX domain sockets (only servers)
#Proto RefCnt Flags       Type       State         I-Node   PID/Program name     Path
#unix  2      [ ACC ]     STREAM     LISTENING     13823    516/pulseaudio       /run/user/2000/pulse/native
#unix  2      [ ACC ]     STREAM     LISTENING     12294    1/init               /run/cups/cups.sock
#unix  2      [ ACC ]     STREAM     LISTENING     8969     350/kdm              /var/run/xdmctl/dmctl-:0/socket
#unix  2      [ ACC ]     STREAM     LISTENING     12297    1/init               /run/dbus/system_bus_socket
#unix  2      [ ACC ]     STREAM     LISTENING     18450    1094/ssh-agent       /tmp/ssh-jEvWzsCPjlHn/agent.1092
#unix  2      [ ACC ]     STREAM     LISTENING     16406    885/mysqld           /ev/erdalmutlu/.local/share/akonadi/socket-erdalmutlu-du/mysql.socket
#unix  2      [ ACC ]     STREAM     LISTENING     16415    878/akonadiserver    /ev/erdalmutlu/.local/share/akonadi/socket-erdalmutlu-du/akonadiserver.socket
#unix  2      [ ACC ]     STREAM     LISTENING     13690    508/dbus-daemon      @/tmp/dbus-rxp2XDVYcR
#unix  2      [ ACC ]     STREAM     LISTENING     13860    575/gpg-agent        /tmp/gpg-x0cQyC/S.gpg-agent
#unix  2      [ ACC ]     STREAM     LISTENING     10865    771/kdeinit4: ksmse  @/tmp/.ICE-unix/771
#unix  2      [ ACC ]     STREAM     LISTENING     14398    534/wineserver       socket
#unix  2      [ ACC ]     STREAM     LISTENING     13887    597/kdeinit4: kdein  /tmp/ksocket-erdalmutlu/kdeinit4__0
#unix  2      [ ACC ]     STREAM     LISTENING     7497     1/init               /run/systemd/private
#unix  2      [ ACC ]     STREAM     LISTENING     7511     1/init               /run/lvm/lvmetad.socket
#unix  2      [ ACC ]     STREAM     LISTENING     7519     1/init               /run/systemd/journal/stdout
#unix  2      [ ACC ]     STREAM     LISTENING     12539    352/X                @/tmp/.X11-unix/X0
#unix  2      [ ACC ]     STREAM     LISTENING     10866    771/kdeinit4: ksmse  /tmp/.ICE-unix/771
#unix  2      [ ACC ]     STREAM     LISTENING     14466    578/ssh-agent        /tmp/ssh-JslTJ7HLcNGI/agent.577
#unix  2      [ ACC ]     STREAM     LISTENING     14494    601/kdeinit4: klaun  /tmp/ksocket-erdalmutlu/klauncherXMT601.slave-socket
#unix  2      [ ACC ]     STREAM     LISTENING     10659    516/pulseaudio       /tmp/.esd-2000/socket
#unix  2      [ ACC ]     STREAM     LISTENING     10662    516/pulseaudio       /run/user/2000/pulse/dbus-socket
#unix  2      [ ACC ]     STREAM     LISTENING     10435    350/kdm              /var/run/xdmctl/dmctl/socket
#unix  2      [ ACC ]     SEQPACKET  LISTENING     7623     1/init               /run/udev/control
#unix  2      [ ACC ]     STREAM     LISTENING     12540    352/X                /tmp/.X11-unix/X0
#
