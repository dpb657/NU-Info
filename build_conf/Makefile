# NU Info Build, Test and Deploy Makefile
# We are using rsync instead of cp because of error checking and timestamp maintanence

FILES = /etc/httpd/conf/httpd.conf /etc/httpd/conf/apache-load-modules.conf /etc/httpd/conf/apache-options.conf /etc/httpd/conf/main-head.conf /etc/httpd/conf/main-only.conf /etc/httpd/conf/mime.types /etc/httpd/conf/policy-url-file.txt /etc/httpd/conf/virtual.conf /etc/httpd/conf/virtual-host-map.txt /etc/httpd/conf/virtual-redirect.conf

RSYNC = /bin/rsync
RSYNC_OPTS = --archive --update --checksum

Default:
	@echo "You must supply a TARGET"
	@echo "Vaild Targets are Test deployChicago deployEvanston"
	@exit 1

# ALL is not to be used directly in production.
ALL: $(FILES) Test
	@echo "Build of all Complete"

/etc/httpd/conf/httpd.conf: /etc/httpd/build_conf/httpd.conf
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/httpd.conf /etc/httpd/conf/httpd.conf

/etc/httpd/conf/apache-load-modules.conf:  /etc/httpd/build_conf/apache-load-modules.conf 
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/apache-load-modules.conf  /etc/httpd/conf/apache-load-modules.conf 

/etc/httpd/conf/apache-options.conf: /etc/httpd/build_conf/apache-options.conf
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/apache-options.conf /etc/httpd/conf/apache-options.conf 

/etc/httpd/conf/main-head.conf: /etc/httpd/build_conf/main-head.conf
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/main-head.conf /etc/httpd/conf/main-head.conf

/etc/httpd/conf/main-only.conf: /etc/httpd/build_conf/main-only.conf
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/main-only.conf /etc/httpd/conf/main-only.conf

/etc/httpd/conf/mime.types: /etc/httpd/build_conf/mime.types
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/mime.types /etc/httpd/conf/mime.types

/etc/httpd/conf/policy-url-file.txt: /etc/httpd/build_conf/policy-url-file.txt
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/policy-url-file.txt /etc/httpd/conf/policy-url-file.txt

/etc/httpd/conf/virtual.conf: /etc/httpd/build_conf/virtual.conf
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/virtual.conf /etc/httpd/conf/virtual.conf

/etc/httpd/conf/virtual-host-map.txt: /etc/httpd/build_conf/virtual-host-map.txt
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/virtual-host-map.txt /etc/httpd/conf/virtual-host-map.txt

/etc/httpd/conf/virtual-redirect.conf: /etc/httpd/build_conf/virtual-redirect.conf
	@echo "Updating $@"
	@$(RSYNC) $(RSYNC_OPTS) /etc/httpd/build_conf/virtual-redirect.conf /etc/httpd/conf/virtual-redirect.conf

 
Test:
 
