#!/bin/sh
# Check Apache syntax and return a non-zero exit status if it fails

apachebinary="/usr/sbin/httpd"
apacheconfig='/etc/httpd/test-conf/httpd.conf'

OPTIONS=`grep -v '^#' /etc/httpd/test-conf/apache-options | grep -v '^$'`
echo "checking apache options and config. Options : "$OPTIONS

$apachebinary $OPTIONS -t -f $apacheconfig

status=$?
if [ $status -ne 0 ]; then
	echo "Check Test Apache Config Failed"
fi

exit $status

# end with a comment

