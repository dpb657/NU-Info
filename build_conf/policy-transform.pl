#! /bin/perl
use strict;
use warnings;


my $build_directory		= "/etc/httpd/build_conf";
#
# The policy file lists the URL to be protected
#
my $policy_url_file		= sprintf "%s/%s", $build_directory, "policy-url-file.txt";
my $policy_url_open_fail	= sprintf "Can't open for input %s: \$!", $policy_url_file;
my $policy_url_close_fail	= sprintf "Close of input file %s failed: \$!", $policy_url_file;
#
# This is a skeleton of what is need for the AMAgent configuration
# Any changes in behavior besides the URL list is made here
#
my $template_input_file		= sprintf "%s/%s", $build_directory, "OpenSSOAgentConfiguration.properties.template";
my $template_input_open_fail	= sprintf "Can't open for input %s: \$!", $template_input_file;
my $template_input_close_fail	= sprintf "Close of input file %s failed: \$!", $template_input_file;
my $fh_template_input;
#
# This should be the completed AMAgent configuration file
#
my $output_file			= sprintf "%s/%s", $build_directory, "OpenSSOAgentConfiguration.properties";
my $output_open_fail		= sprintf "Can't open for output %s: \$!", $output_file;
my $output_close_fail		= sprintf "Close of output file %s failed: \$!", $output_file;
my $fh_output;
#
# Make and needed table based on those configured
#
my $virtual_conf_file		= sprintf "%s/%s", $build_directory, "virtual.conf";
my $virtual_conf_open_fail	= sprintf "Can't open for input %s: \$!", $virtual_conf_file;
my $virtual_conf_close_fail	= sprintf "Close of input file %s failed: \$!", $virtual_conf_file;
#
# Patterns to search for and build tables in the AMAgent configuration file
#
my $AMAgent_notenforced		= "com.sun.identity.agents.config.notenforced.url";
my $AMAgent_fqdn		= "com.sun.identity.agents.config.fqdn.mapping";
#
# Make the table of URLs where WebSSO rules are to be enforced
# The table is named strangely but there is a flag in the configuration to reverse it's meaning
#
sub process_policy_file {
	my $index = 0;

	open(my $fh_policy_url,  "<", $policy_url_file)  or die $policy_url_open_fail;
	while ( my $row = <$fh_policy_url> ) {
		chomp $row;
		if ($row =~ /^#/ || $row =~ /^$/)			# Skip Comments and blank lines
		{
			next;
		}
		printf $fh_output "%s[%d] = %s\n", $AMAgent_notenforced, $index++, $row;
	}
	close($fh_policy_url)  || warn $policy_url_close_fail;
}
#
# Any processing for virtual hosts
#
sub process_virtual_conf {

	my $vhost = "";
	my $salias = "";
	my @row;

	open(my $fh_virtual_conf,  "<", $virtual_conf_file)  or die $virtual_conf_open_fail;
	while (@row = <$fh_virtual_conf> ) {
		chop(@row);
		chomp(@row);
		if ($row[0] =~ /^#/ || $row[0] =~ /^$/) {		# Skip Comments and blank lines
			next;
		}
		if ($row[1] =~ /\sServerName/i) {
			print "Row: ", @row, " ", __LINE__, "\n";
			$vhost =~ $row[1];				# Second token on line is the $vhost
			next;
		}
		if ($row[1] =~ /\sServerAlias/i) {
			print "Row: ", @row, " ", __LINE__, "\n";
			$salias =~ $row[1];				# Second token on line is the $salias
		} else {
			$salias =~ "";
		}
		if ($salias ne "" && $vhost ne "") {
			$vhost =~ s/\${local_Domain_Name}/northwestern.edu/i;
			$salias =~ s/\${local_Domain_Name}/northwestern.edu/i;
			printf $fh_output "%s[%s] = %s\n", $AMAgent_fqdn, $salias, $vhost;
			$salias =~ "";
		}
	}
	close($fh_virtual_conf)  || warn $virtual_conf_close_fail;
}
#
# Just skip past line in the template to get to where we need to insert our configuration.
# I could have just put the tables at the end of the file but to make the result more comprehensible
# I have put them in the place they are expected in the file.
#
sub skip_to {
	my $stop_string = $_[0];
	my $current_line;

	while ($current_line = <$fh_template_input> ) {
		chop($current_line);
		if ($current_line =~ /^#/ || $current_line =~ /^$/) {	# Skip Comments and blank lines
			printf $fh_output "%s\n", $current_line;
			next;
		}
		if ($current_line =~ m/$stop_string/) {
			last;
		}
		printf $fh_output "%s\n", $current_line;
	}
}
# 
# Open the main input and output files
#
open($fh_template_input,  "<", $template_input_file)  or die $template_input_open_fail;
open($fh_output, ">", $output_file) or die $output_open_fail;
#
# Here is the real work is done
#
skip_to($AMAgent_fqdn);
process_virtual_conf ();
skip_to($AMAgent_notenforced);
process_policy_file ();
skip_to("END_OF_FILE");
#
# Close the files and we are done
#
close($fh_output) || warn $output_close_fail;
close($fh_template_input)  || warn $template_input_close_fail;
exit(0);
