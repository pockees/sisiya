#!/usr/bin/perl
#
#    Copyright (C)   Erdal Mutlu
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
#
#######################################################################################
use strict;
use warnings;

use IO::Socket;

if (($#ARGV+1) != 3) {
	printf("Usage: %s server port message\n",$0);
	printf("---------------------- or ----------------------------------\n");
	printf("Usage: %s server port message_file\n",$0);
	printf("	server         : The name or IP address of the SisIYA server to connect.\n");
	printf("	port           : The port on which the SisIYA server is listening.\n");
	printf("	message : The SisIYA message string that is going to be transfered to the SisIYA server.\n");
	printf("	file contents  : Every line is a SisIYA message string.\n");
	printf("	For more information please refer to the project's website : http://sisiya.sourceforge.net\n");
	exit(1);
}
my $server_ip = $ARGV[0];
my $port = $ARGV[1];
my $message = $ARGV[2];

#print "server_ip=$server_ip $port $message\n";

my $sock = new IO::Socket::INET (PeerAddr => $server_ip,PeerPort => $port,Proto => 'tcp',);
die "$0 :Could not create TCP socket to $server_ip:$port with the following error : $!\n" unless $sock;

if (-e $message) {
	open FILE, "< $message" or die "$0 : Could not open file $message for reading! Error: $!";
	while(<FILE>) { 	# reads a line and stores it in '$_'
		chomp; 		# remove new-line chars, same as 'chomp $_;'
		#print $sock $_."\n";
		print $sock $_;
	}
	close FILE;
}
else {
	print $sock "$message";
}
close($sock);
