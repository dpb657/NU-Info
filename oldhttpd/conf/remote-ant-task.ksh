#!/bin/ksh
# run "ant -f localConfig.xml" task on a remote server via OpenSSH
# simple arguments will be passed but don't depend on quoting

export PATH="/sbin:/bin:/usr/bin:/usr/local/bin";

echo
echo args={"$@"}
echo

server=$1;
shift
echo "# server={$server}"

if [ "$server" == "" ]; then
	echo "missing server, exiting........";
	exit -1;
fi

# "$@" is the sh idiom for all parameters quoted
# This will still get passed to sh -c command on the remote end
# so parameter quoting may be odd
if [ "$server" != "local" ]; then
   echo "executing remotely...."
   /usr/bin/ssh -i /root/.ssh/id_rsa root@$server /usr/local/bin/ant -f /etc/httpd/conf/localConfig.xml "$@"
   status=$?
else
   echo "executing locally...."
   /usr/local/bin/ant  -f /etc/httpd/conf/localConfig.xml "$@"
   status=$?
fi
echo status=$status
exit $status

# end with a comment
