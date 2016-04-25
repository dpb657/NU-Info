#!/usr/bin/perl -w
{
    my($script_dir)="/etc/httpd/conf/";
    my($config)=@ARGV;
    $host = `cat /local-adm-pub/config/this-node-fqdn.txt`; 	
    print "hostname is ".$host;	
    $config=$script_dir."all-names.conf" if(not defined($config));

    my(@cmd)=($script_dir."test-conf-check-host-list-two.pl","--port=80","--timeout=2","$config",$host );

    exec(@cmd) or die("exec failed: $!");
}
#
