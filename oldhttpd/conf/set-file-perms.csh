#!/bin/csh

#server1=chnuinfow2.it.northwestern.edu


echo 'argument 2 is '"$2"
echo 'argument 3 is '"$3"
echo 'param is 4 '"$4"
echo 'param is 5 '"$5"

set server="$1"
set param="$2"
#set file_list=("$5")


if ( "$server" == "" ) then
	echo "missing server, exiting........";
	exit -1;
endif


if ( "$server" != "local" ) then

   echo "executing remotely...."
   /usr/bin/ssh -i /root/.ssh/id_rsa root@$server '/etc/httpd/conf/set-file-perms.pl '"$2" "$3" "$4" "$5"
else
   echo "executing locally...."
   /etc/httpd/conf/set-file-perms.pl "$2" "$3" "$4" "$5"
endif
