#!/bin/ksh -xv
# install /etc/init.d scripts for apache test and production
# so they will run at system start-up
prod_scripts_source_dir="/etc/httpd/conf"
test_scripts_source_dir="/etc/httpd/test-conf"
#
prod_pid_file=/var/run/httpd.pid
test_pid_file=/var/run/test-httpd.pid
#
scripts_dest_dir="/etc/init.d"
scripts_usergroup="root:wheel"
scripts_mode="754"
#
export PATH="/sbin:/bin:/usr/bin:/use/local/bin"
#
# set up the new script and then do an atomic rename
#
cp -p ${prod_scripts_source_dir}/web ${scripts_dest_dir}/web.new.$$
chown ${scripts_usergroup} ${scripts_dest_dir}/web.new.$$
chmod ${scripts_mode} ${scripts_dest_dir}/web.new.$$
mv ${scripts_dest_dir}/web.new.$$ ${scripts_dest_dir}/web
#
#
sleep 5
#
#
cp -p ${test_scripts_source_dir}/testweb ${scripts_dest_dir}/testweb.new.$$
chown ${scripts_usergroup} ${scripts_dest_dir}/testweb.new.$$
chmod ${scripts_mode} ${scripts_dest_dir}/testweb.new.$$
mv ${scripts_dest_dir}/testweb.new.$$ ${scripts_dest_dir}/testweb
#
#
sleep 5
#
# turn off the Red Hat "httpd" service, to prevent conflicts
chkconfig httpd off
# 
# do a quick-and-dirty kill of running httpd processes, if any
# The restart later will do a better job
if [ -f $prod_pid_file ]; then
kill `cat $prod_pid_file `
fi
#
if [ -f $test_pid_file ]; then
kill `cat $test_pid_file `
fi
#
sleep 15
#
# enable our services
#
# our port 80 production HTTP service
chkconfig --level 35 --add web
chkconfig --list web
#
sleep 5
#
# our port 8002 test HTTP service
chkconfig --level 35 --add testweb
chkconfig --list testweb
#
sleep 5
#
/etc/init.d/web restart
#
sleep 5
#
/etc/init.d/testweb restart
#
sleep 5
#
ps -fu webserv | wc -l
#
ps -fu webtest | wc -l
#
exit 0
#
