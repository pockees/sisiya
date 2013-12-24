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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
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

sub get_serviceid
{
	return $SisIYA_Config::serviceids{ (split(/$SisIYA_Config::FS/, $_[0]))[0] };
}


sub get_timestamp
{
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	
	$year = 1900 + $year;
	#	print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n";
	my $str = $year.sprintf("%.2d%.2d%.2d%.2d%.2d", $mon, $mday, $hour, $min, $sec);
	return $str;

}
sub get_size
{
	my $x;
	if ($_[0] == 0) {
		return '0';
	}
	elsif ($_[0] < 1024) {
		$x = $_[0].'B';
		return $x;
	}
	elsif ($_[0] < 1048576) {
		return get_formated_size($_[0], 1024, 'KB');
	}
	elsif ($_[0] < 1073741824) {
		return get_formated_size($_[0], 1048576, 'MB');
	}
	elsif ($_[0] < 1099511627776) {
		return get_formated_size($_[0], 1073741824, 'GB');
	}
	elsif ($_[0] < 1125899906842624) {
		return get_formated_size($_[0], 1099511627776, 'TB');
	}
	elsif ($_[0] < 1152921504606846976) {
		return get_formated_size($_[0], 1125899906842624, 'EB');
	}
	return get_formated_size($_[0], 1125899906842624, 'EB');
}


sub get_size_k
{
	my $x;
	if ($_[0] == 0) {
		return '0';
	}
	elsif ($_[0] < 1024) {
		$x = $_[0].'KB';
		return $x;
	}
	elsif ($_[0] < 1048576) {
		return get_formated_size($_[0], 1024, 'MB');
	}
	elsif ($_[0] < 1073741824) {
		return get_formated_size($_[0], 1048576, 'GB');
	}
	elsif ($_[0] < 1099511627776) {
		return get_formated_size($_[0], 1073741824, 'TB');
	}
	elsif ($_[0] < 1125899906842624) {
		return get_formated_size($_[0], 1099511627776, 'PB');
	}
	elsif ($_[0] < 1152921504606846976) {
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

1;
