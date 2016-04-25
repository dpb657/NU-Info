#!/bin/ksh

#server1=chnuinfow2.it.northwestern.edu

# parameter 1 is the target server's fqdn
#
# parameter 2 is user:group for chmod
# parameter 3 is a mode for files
# parameter 4 is a mode for directories
# parameter 5 is a base directory
# parameter 6 onwards are colon-delimited list of files

export PATH="/sbin:/bin:/usr/bin:/usr/local/bin";

echo args={"$@"}
echo

server=$1;
shift
#echo "# server={$server}"
#echo "# user:group=$1 file mode=$2 dir mode=$3 base dir=$4"

if [ "$server" == "" ]; then
	echo "missing server, exiting........";
	exit -1;
fi

# "$@" is the sh idiom for all parameters quoted
# This will still get passed to sh -c command on the remote end
# so parameter quoting may be odd
if [ "$server" != "local" ]; then
   echo "executing remotely...."
   /usr/bin/ssh -i /root/.ssh/id_rsa root@$server /etc/httpd/conf/set-file-perms.pl "$@"
   status=$?
else
   echo "executing locally...."
   /etc/httpd/conf/set-file-perms.pl "$@"
   status=$?
fi

exit $status

# end with a comment
