#!/usr/bin/perl -w
#
# Common functions
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
sub get_formated_size
{
	my $x1 = int($_[0] / $_[1]);
	my $x2 = int(100 * ($_[0] % $_[1]) / $_[1]);
		#print STDERR "get_formated_size: $_[0] $_[1] : x1=$x1 x2=$x2 \n";
	if ($x2 != 0) {
		return $x1.','.$x2."$_[2]";
	}
	return "$x1$_[2]";
}

sub get_serviceid
{
	return $SisIYA_Config::serviceids{$_[0]};
}

sub minutes2string
{
	my ($days, $hours, $minutes);
	my $total_minutes = $_[0];

	$days = int($total_minutes / 1440);
	$total_minutes = $total_minutes - $days * 1440;

	$hours = int($total_minutes / 60);
	$minutes = $total_minutes - $hours * 60;

	#print "days = $days hours = $hours minutes = $minutes\n";

	my $str = '';
	if ($days > 0) {
		$str = "$days day";
		if ($days > 1) {
			$str .= 's';
		}
	}
	if ($hours > 0) {
		if ($str ne '') {
			$str .= ' ';
		}
		$str .= "$hours hour";
		if ($hours > 1) {
			$str .= 's';
		}
	}
	if ($minutes > 0) {
		if ($str ne '') {
			$str .= ' ';
		}
		$str .= "$minutes minute";
		if ($minutes > 1) {
			$str .= 's';
		}
	}
	return "$str";
}

sub get_timestamp
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	
	$year = 1900 + $year;
	$mon += 1;
	#	print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n";
	my $str = $year.sprintf("%.2d%.2d%.2d%.2d%.2d", $mon, $mday, $hour, $min, $sec);
	return $str;

}
sub get_size
{
	my $x;

	if ($_[0] == 0) {
		return '0';
	} elsif ($_[0] < 1024) {
		$x = $_[0].'B';
		return $x;
	} elsif ($_[0] < 1048576) {
		return get_formated_size($_[0], 1024, 'KB');
	} elsif ($_[0] < 1073741824) {
		return get_formated_size($_[0], 1048576, 'MB');
	} elsif ($_[0] < 1099511627776) {
		return get_formated_size($_[0], 1073741824, 'GB');
	} elsif ($_[0] < 1125899906842624) {
		return get_formated_size($_[0], 1099511627776, 'TB');
	} elsif ($_[0] < 1152921504606846976) {
		return get_formated_size($_[0], 1125899906842624, 'PB');
	}
       	return get_formated_size($_[0], 1125899906842624, 'EB');
}


sub get_size_k
{
	my $x;

	if ($_[0] == 0) {
		return '0';
	} elsif ($_[0] < 1024) {
		$x = $_[0].'KB';
		return $x;
	} elsif ($_[0] < 1048576) {
		return get_formated_size($_[0], 1024, 'MB');
	} elsif ($_[0] < 1073741824) {
		return get_formated_size($_[0], 1048576, 'GB');
	} elsif ($_[0] < 1099511627776) {
		return get_formated_size($_[0], 1073741824, 'TB');
	} elsif ($_[0] < 1125899906842624) {
		return get_formated_size($_[0], 1099511627776, 'PB');
	} elsif ($_[0] < 1152921504606846976) {
		return get_formated_size($_[0], 1125899906842624, 'EB');
	}
	return get_formated_size($_[0], 1125899906842624, 'EB');
}

sub ltrim 
{ 
	my $s = shift; 
	$s =~ s/^\s+//; 
	return $s;
}

sub rtrim 
{ 
	my $s = shift; 
	$s =~ s/\s+$//; 
	return $s; 
}

sub send_message_data
{
	my $sock = new IO::Socket::INET (PeerAddr => $SisIYA_Config::server, PeerPort => $SisIYA_Config::port, Proto => 'tcp',);
	die "$0 :Could not create TCP socket to ".$SisIYA_Config::server.":".$SisIYA_Config::port." with the following error : $!\n" unless $sock;

	print $sock $_[0];

	close($sock);
}

# Parameters:
# 1: field seperator
# 2: service name
# 3: statusid
# 4: message string
# 5: data string
sub print_and_exit
{
	print "$_[1]$_[0]<msg>$_[3]</msg><datamsg>$_[4]</datamsg>\n";
	exit $_[2];
}

sub trim 
{ 
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s 
}

# Return codes: -1 = error, 1 = ok
sub get_pid_from_file
{
	my ($pid_file) = @_;
	my $pid = -1;
	if (-f $pid_file) {
		#print STDERR "PID file $pid_file exists! Checking with ps command...\n";
		if (open(my $file, '<', $pid_file)) {
			$pid = <$file>;
			chomp($pid);
			close($file);
		}
	}
	return $pid;
}

# Return codes: 0 = error, 1 = ok
sub put_pid_in_file
{
	my ($pid, $pid_file) = @_;
	if (open(my $file, '>', $pid_file)) {
		print { $file } $pid;
		close($file);
		return 1;
	}
	return $0;
}

#
# This function checks whether the specified program is running or
# not according to the PID, which is recorded in the PID file.
# If the programm is running or something is wrong returns 0 (false).
# If the programm is not running writes the PID of the running program
# in the PID file and returns 1 (true).
sub lock_using_pid_file
{
	my ($prog_name, $pid_file, $ps_prog) = @_;

	# get the PID from the file
	my $pid = get_pid_from_file($pid_file);
	if (($pid > -1)) {
		my @a = `$ps_prog -eo pid,command`;
	 	if (grep(/$prog_name/, grep(/$pid/, @a))) {
			#print STDERR "$prog_name IS RUNNING WITH PID=$pid!\n";
			return 0;
		}
	}
	return put_pid_in_file($$, $pid_file);
}

sub unlock_using_pid_file
{
	my ($pid_file) = @_;
	return unlink $pid_file;
}
1;
