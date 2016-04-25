#!/usr/bin/perl -w
# set user group mode on a list of files/directories within a base directory
# replacement for tricky GNU make rule
# revised to set a different mode on directories
use strict;

# main
{
    # parameter 1: user:group for chmod
    my($usergroup)=shift @ARGV;
    # parameter 2: mode for files
    my($mode)=shift @ARGV;
    # parameter 3: mode for directories
    my($dir_mode)=shift @ARGV;
    # parameter 4: base directory to form file paths
    my($base_dir)=shift @ARGV;

    # parameters 5 and onwards are one or more
    # colon-delimited lists of file or directory paths,
    # relative to base_dir

    my(@filelist)=@ARGV;
    
    # print "# raw file list: {\"".join("\", \"",@filelist)."\"}\n";
 
    # parse file lists looking for colon delimiters
    my(@files)=();
    my($arg);
    foreach $arg (@filelist){

        # Discard missing or empty arguments.

        # These may be artifacts of quoting in the calling script
        # and are potentially dangerous.
        next if(not defined($arg));
        next if($arg eq "");

        # remove leading or trailing colons from the arg to be split
        $arg =~ s|^\:||;
        $arg =~ s|\:$||;

        # split each arg on colons
        my(@terms)=split(/:/,$arg);

        # process non-empty terms
        my($term);
        foreach $term (@terms)
        {
            # trim whitespace
            $term =~ s|^\s+||;
            $term =~ s|\s+$||;

            # discard empty values
            next if($term eq "");

            push @files,$term;
        };
    };
    # print "# cleaned file list: {\"".join("\", \"",@files)."\"}\n";

    die("missing user:group") if(not(defined($usergroup) and ($usergroup ne "")));

    die("missing mode") if(not(defined($mode) and ($mode ne "")));

    die("missing dir mode") if(not(defined($dir_mode) and ($dir_mode ne "")));

    die("missing base directory") if(not(defined($base_dir) and ($base_dir ne "")));

    die("no files specified") if(scalar(@files)==0);

    my($user,$group);

    if($usergroup=~ m|^([^\:]+)\:(.*)$|){
        $user=$1;
        $group=$2;
    }else{
        die("invalid user:group: \"$usergroup\"");
    };

    die("invalid username: \"$user\"") if(not($user =~ m|^[a-z][a-z0-9]{1,7}$|));

    die("invalid groupname: \"$group\"") if(not($group =~ m|^[a-z][a-z0-9]{1,7}$|));

    die("mode must be 3 or 4 digit octal: \"$mode\"") if(not($mode =~ m|^[0-7]{3,4}$|));

    die("dir_mode must be 3 or 4 digit octal: \"$dir_mode\"") if(not($dir_mode =~ m|^[0-7]{3,4}$|));

    # fix base directory not to have trailing slashes
    $base_dir =~ s|\/+$||;

    # sanity check on directory
    die("base directory cannot be / or empty")
        if(($base_dir eq "") or ($base_dir eq "/"));

    die("base directory not found: \"$base_dir\" ") if(not( -d $base_dir ));

    my($omode)=oct("0".$mode);
    my($odir_mode)=oct("0".$dir_mode);

    my($uid)=scalar(getpwnam($user));
    die("no such user: \"$user\"") if(not defined($uid));

    my($gid)=scalar(getgrnam($group));
    die("no such group: \"$group\"") if(not defined($gid));

    # chdir to base_dir for sanity in edge cases
    chdir $base_dir or die("chdir to base directory failed: $!");

    my($name);
    foreach $name (@files)
    {
        my($path)=$base_dir."/".$name;
#       my($path)=$base_dir.$name;

        if( -e $path ){
            eval {
                # use a different mode for files and directories
                if( -d $path ){
                    chown($uid, $gid, $path);
                    chmod($odir_mode, $path);
                }else{
                    chown($uid, $gid, $path);
                    chmod($omode, $path);
                };
            };
            if($@){
                print "Error processing \"$path\":".$@."\n";
                exit -1;
            }
        }else{
            print "Not found: \"$path\"\n";
            exit -1;
        }
    }

    exit 0;
}

