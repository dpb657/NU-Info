#!/bin/csh
# run operations on the test http stop/start scripts
# parameter 1 is the server name
# parameter 2 is opcode

echo 'This server is "'`/bin/hostname --fqdn`'"'

echo 'The target server is "'"$1"'"; the action is "'"$2"'"'

set server="$1"
set action="$2"

if ( "$server" == "" ) then
    echo "Missing server, exiting........";
    exit -1;
endif

if ( "$action" == "" ) then
    echo "Missing action, exiting........";
    exit -1;
endif

if ( "$server" != "local" ) then

   echo "executing remotely on $server"
    /usr/bin/ssh -i /root/.ssh/id_rsa root@$server '/etc/init.d/testweb '$action

else

   echo "executing locally...."
   /etc/init.d/testweb $action

endif

exit $status

