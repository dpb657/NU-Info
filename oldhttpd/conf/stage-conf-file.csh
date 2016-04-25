#!/bin/csh
# filename
set file="$1"
set usergroup="root:webconf"
set mode="640"
set testconfdir="/etc/httpd/test-conf"
set prodconfdir="/etc/httpd/conf"
#
if ( "$file" == "") then
	echo "missing file parameter"
	exit;
endif
#
if ( ! -f "$testconfdir/$file") then
	echo "no such file: $file"
	exit;
endif
#
cmp -s "$testconfdir/$file" "$prodconfdir/$file"
#
if ( "$status" != "0" ) then
	echo "update $file"
	# use --reply=yes to superceed "ok to overwrite foo" prompts 
	cp -p -f --reply=yes "$testconfdir/$file" "$prodconfdir/$file"
	chmod $mode "$prodconfdir/$file"
	chown $usergroup "$prodconfdir/$file"

else
	echo "$file unchanged"
endif

exit 0;
