#! /bin/perl
use strict;
use warnings;
#
# Declare and initialize variables
#
my $prevdeny = "";
my $prevallow = "";
my $whitespace = "";
my $restofline = "";
#
# Read from STDIN
#
while ( <> ) {
	chomp $_;
	if (/^$/) {					# Skip empty lines
		print  $_ , "\n";
		next;
	}
	if (/^(\s*)(#.*)$/) {				# Skip Comment only lines
		$whitespace = $1;
		$restofline = $2;
		printf "%s%s\n", $whitespace, $restofline;
		next;
	}
	if (/:8002/) {next;}				# Remove references to old test port except in comments
	if (/nwu.edu/) {next;}				# Remove references to old domain name except in comments
	s/northwestern.edu/\$\{local_Domain_Name\}/g;	# Turn current domain name into macro except in comments
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
			printf "%s%s\t%s%s\n", $whitespace, "Require all denied", $restofline, "# Updated for 2.4 Syntax";
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
			printf "%s%s%s\t%s\n", $whitespace, "Require all granted", $restofline, "# Updated for 2.4 Syntax";
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
	} elsif (/(\s*)allow\s*from(.*)$/i) {
		$whitespace = $1;
		$restofline = $2;
		printf "%s%s %s\t%s\n", $whitespace, "Require from", $restofline, "# Updated for 2.4 Syntax";
		$whitespace = $restofline = "";				# Reset all the variables
		next;
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
	print $_, "\n";
}
