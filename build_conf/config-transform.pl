#! /bin/perl
use strict;
use warnings;
use Data::Dumper qw(Dumper);
#
# Declare and initialize variables
#
my $prevdeny = "";
my $prevallow = "";
my $whitespace = "";
my $restofline = "";
my $retainedname = "";
my $printalias = 0;

#
# Read from STDIN
#
print "# vim: syntax=apache\n#\n";
while ( <> ) {
	chomp $_;
	if (/^$/) {					# Skip processing empty lines
		print "\n";
		next;
	}
	if (/^(\s*)(#.*)$/) {				# Skip processing comment only lines but maintain the placement
		$whitespace = $1;
		$restofline = $2;
		printf "%s%s\n", $whitespace, $restofline;
		next;
	}
	if (/NameVirtualHost/i) {		# Comment out to eliminate warning message
		print  "#", $_ , "\n";
		next;
	}
	if (/VirtualHost/i) {
		print  $_ , "\n";
		next;
	}
	if (/:8002/) {next;}				# Remove references to old test port except in comments
	if (/nwu.edu/) {next;}				# Remove references to old domain name except in comments
	if (/(\s)*ServerName\s*(.*)$/i) {
		$whitespace = $1;			# Store leading whitespace to keep the indentation correct
		$retainedname = $restofline = $2;	# Modify the name to use the macro
		if ( ! defined ( $whitespace )) { $whitespace = ""; }
		if ( /northwestern.edu/i ) {
			$restofline =~ s/northwestern.edu/\$\{local_Domain_Name\}/g;
			$printalias = 1;
		};
		#printf "%sServerName  %s\n", $whitespace, $retainedname;
		printf "%sServerName  %s\n", $whitespace, $restofline;
		if ( $printalias ) {
			# printf "%sServerAlias %s\n", $whitespace, $restofline;
			printf "%sServerAlias %s\n", $whitespace, $retainedname;
			$printalias = 0;
		}
		next
	} else { 
		s/northwestern.edu/\$\{local_Domain_Name\}/g;
	}
	#
	# Change:
	# 	Order deny,allow
	# 	Deny from all
	# To:
	#	Require all denied
	# No matter what the case is
	#
	if (/(\s)*order\s*deny,allow(.*)$/i) {
		$whitespace = $1;
		$restofline = $2;
		$prevdeny = $_;
		next;
	} elsif (/(\s*)order\s*allow,deny(.*)$/i) {
		$whitespace = $1;
		$restofline = $2;
		$prevallow = $_;
		next;
	} elsif (/(\s*)deny\s+from\s+all(.*)$/i) {
		$whitespace = $1;
		$restofline = $2;
		if ($prevdeny ne "") {
			printf "%s%s%s\n", $whitespace, "Require all denied", $restofline;
			$whitespace = $restofline = $prevdeny = "";	# Reset all the variables
			next;
		} else {
			printf "%s\t%s\n", $_, "# Prior to 2.4 Syntax";
			$whitespace = $restofline = $prevdeny = "";	# Reset all the variables
			next;
		}
	#
	# Change:
	# 	Order allow,deny
	# 	Allow from all
	# To:
	#	Require all granted
	# No matter what the case is
	#
	} elsif (/(\s*)allow\s+from\s+all(.*)$/i) {
		$whitespace = $1;
		$restofline = $2;
		if ($prevallow ne "") {
			printf "%s%s%s\n", $whitespace, "Require all granted", $restofline;
			$whitespace = $restofline = $prevallow = "";	# Reset all the variables
			next;
		} else {
			printf "%s\t%s\n", $_, "# Prior to 2.4 Syntax";
			$whitespace = $restofline = $prevallow = "";	# Reset all the variables
			next;
		}
	#
	# Modify any remaining "allow from" lines
	#
	#} elsif (/(\s*)allow\s*from(.*)$/i) {
	#	$whitespace = $1;
	#	$restofline = $2;
	#	printf "%s%s%s\n", $whitespace, "Require from", $restofline;
	#	$whitespace = $restofline = "";				# Reset all the variables
	#	next;
	# 
	# Flush any stored content
	#
	} else {
		if ($prevallow ne "") {
			printf "%s\t%s\n", $prevallow, "# Prior to 2.4 Syntax";
			printf "%s\n", $_;
			$whitespace = $restofline = $prevallow = "";	# Reset all the variables
			next;
		} elsif ($prevdeny ne "") {
			printf "%s\t%s\n", $prevdeny, "# Prior to 2.4 Syntax";
			printf "%s\n", $_;
			$whitespace = $restofline = $prevdeny = "";	# Reset all the variables
			next;
		}
	}
	if (/^(\s*)Options/) {
		$whitespace = $1;

		my @options;
		my $elements;
		my $item;
		my $char;
		my $skip = 1;

		@options = split /\s/, $_;
		$elements = scalar(@options);

		foreach $item (@options) {
			if($item eq "Options") {
				printf "%s%s", $whitespace, $item;
				$skip = 0;
			} elsif ($skip != 1) {
				$char = substr($item, 0, 1);
				if($char ne "-" && $char ne "+") {
					printf " %s%s", "+", $item;
				} else {
					printf " %s", $item;
				}
			}
		}
		print "\n";
		next;
	}
	print $_, "\n";
}
# vim: syntax=perl
