# Run sudo, refer targets to our ant build
# Put copies in both the test and production conf
# So we can control them from either place
# -Dquiet=true will turn off some output
xxx:
		@(cd /etc/httpd/conf ; /usr/bin/sudo /usr/local/bin/ant -logger org.apache.tools.ant.NoBannerLogger )
#
.DEFAULT:	
		@echo "$@" 
		@(cd /etc/httpd/conf ; /usr/bin/sudo /usr/local/bin/ant -logger org.apache.tools.ant.NoBannerLogger "$@" )
#

