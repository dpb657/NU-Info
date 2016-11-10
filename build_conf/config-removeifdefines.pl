#!/bin/perl
use strict;
use warn;

my $remove_list = { "DENYFORTEST", "BLAH" };

my $depth_true = 0;
my $depth_not_true = 0;
my $current_delete_list[];
my $current_pass_list[];

while(<>) {
# compare line for an <!ifdefine BLAH> and BLAH is to be removed
# if it matches set depth_true to 1 set current_delete_list[depth] = BLAH
#
# read next line
# if line matches <ifdefine BLAH> and BLAH is to be removed add 1 to depth_true - 
# while depth > 0
#	if line contains </ifdefine> and $depth_not_true > 0 print line
# 	if line match </ifdefine> subtract 1 from depth - next
# 	wileskip lines until depth_true = 0
# else if line matches <!ifdefine BLAH> and BLAH is to be removed add 1 to depth_false - next
# else if line contains <ifdefine BLAH>  or <!ifdefine BLAH> and BLAH is NOT to be removed add 1 to depth,print line next.
# else if line match </ifdefine> subtract 1 from depth - next
# else if line contains </ifdefine> and $depth_not_true > 0 print line
# set $depth_not_true +1
# if line contains </ifdefine> and $depth_not_true > 0 print line
# else next
}
# end inner while
