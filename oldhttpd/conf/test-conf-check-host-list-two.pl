#!/usr/bin/perl -wT
# Albert lunde
# 11-1-06 add explict failure exit code for unexpected results, for use in Makefile
#         add command-line option to set timeout

use strict;

#use lib '/sw/lib/perl5'; # for Mac tests

use HTTP::Request::Common;
use HTTP::Response;
use LWP::UserAgent;
use Getopt::Long;
use Net::DNS;
use Net::IP;
use Socket;

my($HTTP_TIMEOUT)=20;
my %LOCAL_IP = ("129.105.16.72","165.124.65.30","165.124.65.31","165.124.65.32","129.105.215.152","129.105.215.153","129.105.215.154");

my(@TEST_CASES)=();
my($OPTIONS)={
		'repeat' => 1,
	};

my($force_host_tocheck) = "";

sub http_request_wrapper {
	# do HTTP request, and interpret error conditions, follow redirects
	
	# return not-ok, HTTP-Status,message,$redirect_url,output-array-reference
	
	# reimplemented with LWP::UserAgent
	
	my($url,$limit_count,$redirect_url)=@_;

	my($ok,$http_status,$http_message,$output_ref);
	
	$HTTP_TIMEOUT=$OPTIONS->{'timeout'} if(defined($OPTIONS->{'timeout'}));

        my($ua) = LWP::UserAgent->new(
				        agent => "nuinfo-file-grabber/1.0",
				        timeout => $HTTP_TIMEOUT,
				        protocols_allowed => ["http","https"],
				  );
# added by vivek
	
	print ("url is ".$url."\n");
	my $urlvar= URI->new($url);
	my $domain = $urlvar->host;
	print ("domain is ".$domain."\n");

	my($status,$mess,$scheme,$host,$port,$path)=parse_url($url);
	print("host is ".$host."\n");
  
	my($ip_status, $host_ip) = lookup_ip($host);
	print "host ip is ".$host_ip."\n" ;

        my $req = HTTP::Request->new(GET => $url);

# 	print "Found '$host_ip'\n" if (exists $LOCAL_IP{$host_ip})
#  	print "Not Found - '$host_ip' not found\n" unless (exists $LOCAL_IP{$host_ip});

 	if (exists $LOCAL_IP{$host_ip})
	 {
	   if($force_host_tocheck ne "") {
		    print "Local Host '$host_ip' , forging host header \n";	   	    	
		    $url = $scheme . '://' .$force_host_tocheck. $path;
		    print "updated url : ".$url."\n" ;
		    $req->header( 'Host' => $host );
	    }
 	   else {			 
		    print " Local host but not forging header, the host ip is - '$host_ip' \n" ;
	   }
	
	 }	
	else
	 {
	   print "Remote host. The ip is - '$host_ip' \n" ;
	 }

	print "\n";
	
#	my($updated_url)=$scheme . '://' ."chnuinfow2.it.northwestern.edu" . $path;
#	print "updated url : ".$updated_url;
	
 
  #my $req = HTTP::Request->new(GET => $url);
 #my $req = HTTP::Request->new(GET => $updated_url);

  #added by vivek
  #   if(defined($force_host_name)){	
  #      print " force host: ".$force_host_name ;
  #  	$req->header( 'Host' => $force_host_name );
  #  };
  #
  #   	$req->header( 'Host' => $host );

 ####


    my($response) = $ua->simple_request($req);
   
  #  print "# response headers {".$response->headers->as_string."}\n"; # added by vivek
 
    $ok=$response->is_success;
    $ok=($ok?1:0);
    my($not_ok)=($ok?0:1);
    
    $http_status=$response->is_success;
    my($headers)=$response->headers;
    
    my($stat_line)=$response->status_line;
    
    $output_ref=$response->content_ref();
    
	if($stat_line =~ m|^(\d+)\s+(.+)$|){
		$http_status=$1;
		$http_message=$2;
	}else{
		$http_status=$req->code;
		$http_message="";
	}
	
	print "# (ok=$ok,status_line=\"$stat_line\",status=$http_status,mess=$http_message)\n" if($main::verbose);
	
	# manually follow redirects so I can get my hands on the Location: headers
	
	if(($http_status == 301) or ($http_status == 302)){
	
		$redirect_url=$headers->header('Location');
		print "# (Location=\"$redirect_url\")\n" if($main::verbose);
		
		$main::last_redirect_url=$redirect_url;
		$main::first_redirect_url=$redirect_url if(not defined($main::first_redirect_url));
		
		# HTTP redirect
		# follow redirects up to a limit
		$limit_count++;
		return(1,500,"Too many Redirects",$redirect_url,[""]) if ($limit_count>10);		
		if($redirect_url ne ""){
			return(http_request_wrapper($redirect_url,$limit_count,$redirect_url));
		}else{
			return(1,$http_status,$http_message,$redirect_url,$output_ref);
		}
	};

	return($not_ok,$http_status,$http_message,$redirect_url,$output_ref);
}


sub read_lines_to_array {
	my($path)=@_;
	my(@out)=();
	my($fh);
	open($fh,"<",$path) or fatal_error("Error opening \"$path\": $!");
	while(<$fh>){
		chomp;
		# trim white space
		s|^\s+||;
		s|\s+$||;
		# skip blank lines and comments
		next if($_ eq "");
		next if(m|^\#|);
		push @out,$_;
	};

	return(\@out);
}


sub read_lines_to_hash {
	my($path)=@_;
	my($out)=+{};
	my($fh);
	open($fh,"<",$path) or fatal_error("Error opening \"$path\": $!");
	while(<$fh>){
		chomp;
		# trim white space
		s|^\s+||;
		s|\s+$||;
		# skip blank lines and comments
		next if($_ eq "");
		next if(m|^\#|);
		$out->{$_}=1;
	};

	return($out);
}



sub parse_quoted_tokens
{
    my($line)=@_;

    # parse a line into a list of tokens
    # allow quoting of characters
    # aaaa  (non-space characters)
    # 'aaaa'
    # "aaaa"
    # are all acceptable
    #
    # This doesn't deal with C-style quoting or doubled quotes
    #
    
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;

    my(@tok)=();
    my($nn)=0;

#	print "START\n";
    while($line ne ""){
	$nn++;
#	    print "\n<$line>\n";
#	    print "*",(join ",",@tok),"*\n";
	if(($line =~ /^\s*\"([^\"]*)\"\s*(.*)$/)||
	   ($line =~ /^\s*\'([^\']*)\'\s*(.*)$/)||
	   ($line=~ /^\s*(\S+)\s*(.*)$/)
	   ){
	    push @tok,$1;
	    $line=$2;	
	}else{
	    last;
#		    print "ERROR\n";
	}

	$line =~ s/^\s+//;
	$line =~ s/\s+$//;
    }
#	print "END\n";

    return(@tok);
}


sub parse_url{
    my($url)=@_;
    # parse a full URL
    # scheme://host:port/path
    # scheme://host/path
    # scheme://host

    my($scheme)="";
    my($host)="";
    my($port)="";
    my($path)="";
    my($hostport);

    if($url =~ m|^([a-z][a-z0-9]+)\://(.+)$|){
        $scheme=$1;
        my($work)=$2;
        if($work =~ m|([^\/]+)/(.*)|){
            $hostport=$1;
            $path="/".$2;
        }else{
            $hostport=$work;
            $path="/";
        }
        $hostport=lc($hostport);
        if($hostport =~ m|^([a-z0-9\.\-]+)\:([0-9]+)$|){
            $host=$1;
            $port=$2;
            return(0,"",$scheme,$host,$port,$path);
        }elsif($hostport =~ m|^([a-z0-9\.\-]+)$|){
            $host=$1;
            $port="";
            $port=80 if($scheme eq "http");
            return(0,"",$scheme,$host,$port,$path);
        }else{
            return(1,"error parsing URL");
        }
    };

    return(1,"error parsing URL");
}


sub read_test_cases {
	my($path)=@_;
	
	
	my($fh);
	open($fh,"<",$path) or die("Error opening file: \"$path\": $!");
	$main::input_line_count=0;
	while(<$fh>){
		$main::input_line_count++;
		chomp;
		print "# in: $_\n" if($main::verbose);
		# trim lines
		s|^\s+||;	
		s|\s+$||;
		# skip blank lines and comments
		next if($_ eq "");
		next if(m|^\#|);
		$main::input_line=$_;
		my(@tok)=parse_quoted_tokens($_);
		#my(@tok)=split(/\s+/,$_);
		my $key =shift @tok;
		next if(not defined($key));
		$key=lc($key);
		
		# command syntax
		# sleep <nn>
		# set <name> <string>
		# url <url> <options>
		# options:
		# 	ok					Good if normal status
		# 	fail				Good if abnormal status
		# 	redirect <url>		Good if redirect to URL
		#	match <string>		Good if response body contains string 
		#	status <nnn>		Good if status is nnn 
		
		if($key eq "sleep"){
			my $nn =shift @tok;
			option_error("Error in sleep parameter") if(not defined($nn) and ($nn =~ m|^\d+$|));
			push @TEST_CASES,["sleep",$nn];
			
		}elsif($key eq "set"){
			my $name =shift @tok;
			my $val =shift @tok;
			option_error("Error in set option name") if(not defined($name) and ($name =~ m|^\w+$|));
			option_error("Error in set option value") if(not defined($val));
			$val = "" if($val eq "EMPTY");
			$name=lc($name);
			$OPTIONS->{$name}=$val;
			
		}elsif($key eq "url"){
			my $url =shift @tok;
			option_error("Error in url parameter") if(not defined($url) and ($url ne ""));
			
			
			
			my($url_options)=+{};
			
			for(;;){
				my($option) = shift @tok;
				last if(not defined($option));
				$option=lc($option);
				
				if($option eq "ok"){
					$url_options->{'ok'}=1;
				
				}elsif($option eq "fail"){
					$url_options->{'fail'}=1;
				
				}elsif($option eq "redirect"){
					my $url =shift @tok;
					option_error("Error in redirect option url parameter") if(not defined($url) and ($url ne ""));
					$url_options->{'redirect'}=$url;
					
				}elsif($option eq "match"){
					my $string =shift @tok;
					option_error("Error in match option string parameter") if(not defined($string) and ($string ne ""));
					$url_options->{'match'}=$string;
					
				}elsif($option eq "status"){
					my $nnn =shift @tok;
					option_error("Error in status option nnn parameter") 
							if(not defined($nnn) and ($nnn =~ m|^\d\d\d$|));
					$url_options->{'status'}=$nnn;
				
				}else{
					option_error("Unrecognized option: \"$option\" to url directive");
				};
			};
			
			my($iret,$mess,$scheme,$host,$port,$path)=parse_url($url);
			option_error("invalid url: $mess") if($iret);
			
			$port=$OPTIONS->{'port'} if(defined($OPTIONS->{'port'}));

			my($portadd);
			if($scheme eq "http" and ($port eq 80)){
				$portadd="";
			}elsif($scheme eq "https" and ($port eq 443)){
				$portadd="";
			}else{
				$portadd=':' . $port;
			}
			
			my($new_url)=$scheme . '://' . $host . $portadd  . $path;


			my($line_no)=$main::input_line_count;
			
			push @TEST_CASES,['url',$new_url,$url_options,$url,$line_no];
			
		}else{
			option_error("Unrecognized directive");
		};
		
	}
	
	return;
}

sub option_error {
	my($message)=@_;
	print "# {$main::input_line}\n";
	print "# Error in config line $main::input_line_count\,\:$message\n";
	exit 0;	
}

sub run_test_cases {
	
	my($item);
	
	foreach $item (@TEST_CASES){
		my(@stuff)=@$item;	
		my $key =shift @stuff;
		if($key eq 'sleep'){
			my $nn =shift @stuff;
			print "# sleep $nn\n" if($main::verbose);
			sleep($nn);
		}elsif($key eq 'url'){
			my $url =shift @stuff;
			my $url_options =shift @stuff;
			my $old_url =shift @stuff;
			my $line_no =shift @stuff;
			
			my($ok_option)=defined($url_options->{'ok'});		
			my($fail_option)=defined($url_options->{'fail'});		
			my($redirect_option)=defined($url_options->{'redirect'});		
			my($match_option)=defined($url_options->{'match'});	
			my($status_option)=defined($url_options->{'status'});
			
			$main::original_url=$old_url;
			$main::config_line=$line_no;
			
			print "\n# url $url\n" if($main::verbose);
			
			$main::last_redirect_url=undef;
			$main::first_redirect_url=undef;
			
			my($not_ok,$http_status,$http_message,$redirect_url,$output_ref)=
				http_request_wrapper($url,0,"");
			
			my($GOOD_STATUS)={
				'200' => 1,
				'208' => 1,
				'304' => 1,
			};
			
			my($ok)=((not $not_ok) and (defined($GOOD_STATUS->{$http_status})));
    		$ok=($ok?1:0);
			
			if($ok_option){
				if($ok){
					note_good();
				}else{
					note_bad("url \"$url\" did not succeed as expected");
				};
			}elsif($fail_option){
				if($ok){
					note_bad("url \"$url\" did not fail as expected");
				}else{
					note_good();
				};
			};
			if($redirect_option){
				my($target)=$url_options->{'redirect'};
				my($last)=$main::last_redirect_url;
				$last="" if(not defined($last));
				if(not(defined($last) and redirects_match($last,$target))){
					note_bad("url \"$url\" was not redirected to \"$target\" but to \"$last\"");
				};
			};
			if($status_option){
				my($nnn)=$url_options->{'status'};
				if($http_status != $nnn){
					note_bad("url \"$url\" had $http_status not $nnn as expected");		
				}
				
			}
			
			if($match_option){
				my($string)=$url_options->{'match'};
				my($q)=quotemeta($string);
				# normalize white space
				${$output_ref} =~ s|\s+| |sg;
				if(not ${$output_ref} =~ m|$q|i){
					note_bad("url \"$url\" did not match \"$string\"");		
				};
			}
			
		};

	# per-command sleep
	my($sleep)=$OPTIONS->{'sleep'};
	sleep($sleep) if(defined($sleep) and ($sleep != 0));

	}; # end foreach
	
}

sub transform_url {
	# canonize URLs for comparing redirects
	my($url)=@_;
	
	# ignore case
	$url=lc($url);

	# drop trailing slash	
	$url =~ s|\/+$||;
	
	# drop port number
	$url =~ s|\:\d+$||;
	
	return($url);
}

sub redirects_match {
	my($url1,$url2)=@_;	
	
	return(transform_url($url1) eq transform_url($url2));
}

sub note_good {
	$main::good_count++;
}

sub note_bad {
	my($mess)=@_;
	$main::bad_count++;
	push @$main::bad_messages,[$mess,$main::original_url,$main::config_line],
}

sub summary {
	print "# expected results: 	$main::good_count\n";
	print "# unexpected results: 	$main::bad_count\n";
	
	foreach (@$main::bad_messages){
		my($mess,$url,$nn)=@$_;
		print "\n# line $nn URL \"$url\"\n#: $mess\n";	
	};
	
	# fail so make will notice
	if($main::bad_count!=0){
		exit(-1);	
	};
	
}

sub usage {
	my($note)=@_;
	print STDERR "$note\n" if(defined($note) and ($note ne ""));
	print STDERR "test HTTP server\n";
	print STDERR "Usage:\n\t$0\t [options] config-file host\n";
	print STDERR "Options:\n";
	print STDERR "\t--port=nn\tuse port nn for tests\n";
	print STDERR "\t--repeat=nn\trepeat nn times\n";
	print STDERR "\t--timeout=nn\tconnect timeout in seconds\n";
	print STDERR "\t--echo\t\n";
	print STDERR "\t--verbose\t\n";
	print STDERR "\t--help\t\n";

	exit(1);
}

sub process_options{

	my($help)=0;
	my($port_option);
	my($repeat_option);
	my($sleep_option);
	my($run_sleep_option);
	my($timeout_option);

	my($ok)=GetOptions(
					"port=i" => \$port_option,
					"repeat=i" => \$repeat_option,
					"sleep=i" => \$sleep_option,
					"run-sleep=i" => \$run_sleep_option,
					"timeout=i" => \$timeout_option,
					"verbose" => \$main::verbose,
					"help" => \$help);

	usage("Error in Options") if(!$ok);
    
    usage() if ($help);
    
    if($port_option){
    	$OPTIONS->{'port'}=$port_option;
    };
   
   	if($repeat_option){
    	$OPTIONS->{'repeat'}=$repeat_option;
    };
    
   	if($sleep_option){
    	$OPTIONS->{'sleep'}=$sleep_option;
    };
    
   	if($run_sleep_option){
    	$OPTIONS->{'run_sleep'}=$run_sleep_option;
    };
    
   	if($timeout_option){
    	$OPTIONS->{'timeout'}=$timeout_option;
    };
    my $path =shift @ARGV;
    my $host_tocheck =shift @ARGV; #vivek

     if(defined($host_tocheck) and ($host_tocheck ne "")){
		$force_host_tocheck=$host_tocheck;
	}   

 
    usage("missing config file name") if(not(defined($path) and ($path ne "")));
		
	return($path);
}

sub lookup_ip{
           my($domain)=@_;

	   my $res = Net::DNS::Resolver->new();
	   my $a_query = $res->search($domain);

	   if ($a_query) {
      		foreach my $rr ($a_query->answer) {
		next unless $rr->type eq "A";
          	return(1, $rr->address);
      		}
  	    } else {
          	return(0, "");
	    }
}


sub init_globals{
	$|=1;
	$main::good_count=0;
	$main::bad_count=0;
	$main::bad_messages=[];
	$main::verbose=0;
}

# main
{

	init_globals();
	
	my($path)=process_options();
	
	read_test_cases($path);
	
	#exit;
	
	my($n)=$OPTIONS->{'repeat'};
	my($i);
	for($i=0;$i<$n;$i++){
		run_test_cases();
		
		# per-run sleep
		my($sleep)=$OPTIONS->{'run_sleep'};
		sleep($sleep) if(defined($sleep) and ($sleep != 0));
	};
	
	summary();
	
}
