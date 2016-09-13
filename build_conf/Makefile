# NU Info Build, Test and Deploy Makefile
#
BUILD_DIR		= /etc/httpd/build_conf/
CONFIG_TARGET_DIR	= /etc/httpd/conf.d/

AMAgent_CONF_DIR	= /opt/websso/web_agents/apache24_agent/Agent_001/config/
AMAgent_CONF		= OpenSSOAgentConfiguration.properties

FILES			= $(CONFIG_TARGET_DIR)httpd.conf \
			  $(CONFIG_TARGET_DIR)apache-load-modules.conf \
			  $(CONFIG_TARGET_DIR)apache-options.conf \
			  $(CONFIG_TARGET_DIR)main-head.conf \
			  $(CONFIG_TARGET_DIR)main-only.conf \
			  $(CONFIG_TARGET_DIR)mime.types \
			  $(CONFIG_TARGET_DIR)virtual.conf \
			  $(CONFIG_TARGET_DIR)virtual-redirect.conf

#
# We are using rsync instead of cp locally because of error the checking
#
RSYNC			= /bin/rsync
# Locally we want the current timestamp
RSYNC_OPTS_LOCAL	= --archive --update --checksum
# On the remotes we want the timestamps to be the same
RSYNC_OPTS_REMOTE	= --archive --update --checksum

PERL			= /bin/perl
PERL_OPTS		= -f

SED			= /bin/sed
RM			= /bin/rm -f

SSH			= /bin/ssh
SSH_OPTS		= 

CP			= /bin/cp

SCP			= /bin/scp
SCP_OPTS		= -qp

# Directly manage httpd ignoring systemd
#HTTPD_RESTART		= "/usr/sbin/httpd -k stop && /bin/sleep 10 && /usr/sbin/httpd -k start || exit -1"
# In keeping with RHEL7 using the systemd commands
HTTPD_RESTART		= "/bin/systemctl stop httpd && /bin/sleep 10 && /bin/systemctl start httpd || exit -1"

include /etc/httpd/localhost_configs/local_makefile_include

DEFAULT:
	@tput bold
	@echo "You must supply a make target!"
	@echo "Vaild targets are: test deployChicago deployEvanston"
	@tput sgr0
	@exit 1

# ALL is not intended to be used directly in production.
ALL: $(FILES) $(BUILD_DIR)$(AMAgent_CONF)
	@echo -e "\nBuild of ALL Complete\n"

$(CONFIG_TARGET_DIR)httpd.conf: $(BUILD_DIR)httpd.conf
	@echo "Updating $@"
	@$(CP) $(BUILD_DIR)httpd.conf $@

$(CONFIG_TARGET_DIR)apache-load-modules.conf:  $(BUILD_DIR)apache-load-modules.conf 
	@echo "Updating $@"
	@$(CP) $(BUILD_DIR)apache-load-modules.conf $@

$(CONFIG_TARGET_DIR)apache-options.conf: $(BUILD_DIR)apache-options.conf
	@echo "Updating $@"
	@$(CP) $(BUILD_DIR)apache-options.conf $@

$(CONFIG_TARGET_DIR)main-head.conf: $(BUILD_DIR)main-head.conf
	@echo "Updating $@"
	@$(CP) $(BUILD_DIR)main-head.conf $@

$(CONFIG_TARGET_DIR)main-only.conf: $(BUILD_DIR)main-only.conf
	@echo "Updating $@"
	@$(CP) $(BUILD_DIR)main-only.conf $@

$(CONFIG_TARGET_DIR)mime.types: $(BUILD_DIR)mime.types
	@echo "Updating $@"
	@$(CP) $(BUILD_DIR)mime.types $@

$(CONFIG_TARGET_DIR)virtual.conf: $(BUILD_DIR)virtual.conf
	@echo "Updating $@"
	@$(CP) $(BUILD_DIR)virtual.conf $@

$(CONFIG_TARGET_DIR)virtual-redirect.conf: $(BUILD_DIR)virtual-redirect.conf
	@echo "Updating $@"
	@$(CP) $(BUILD_DIR)virtual-redirect.conf $@

$(BUILD_DIR)$(AMAgent_CONF): $(BUILD_DIR)policy-url-file.txt $(BUILD_DIR)$(AMAgent_CONF).template $(BUILD_DIR)policy-transform.pl
	@sh -c "cd $(BUILD_DIR) && $(PERL) $(PERL_OPTS) $(BUILD_DIR)policy-transform.pl -t " 

#
# TEST_DIR has the effect of switching all the includes to come from the build directory
#
test: 
	@/usr/sbin/httpd -t -f $(BUILD_DIR)httpd.conf -DTEST_DIR
	@echo ""

#
# Check the status of all of the servers. Best viewed through pagenation program
#
status:
	@$(foreach REMOTE_HOST, $(EV_HOSTS) $(CH_HOSTS), \
	echo -e "\n\n$(REMOTE_HOST)\n" && \
	$(SSH) $(SSH_OPTS) $(REMOTE_HOST) /bin/systemctl status httpd.service; \
	)

#
# deployChicago and deployEvanston are using GNU make specific syntax - foreach
#

deployChicago: ALL test
	@$(foreach REMOTE_HOST, $(CH_HOSTS), \
	echo -e "Deploying to $(REMOTE_HOST)" && \
	$(RSYNC) $(RSYNC_OPTS_REMOTE) $(BUILD_DIR) $(REMOTE_HOST):$(BUILD_DIR) && \
	echo -e "\tBuild directory synchronized" && \
	$(RSYNC) $(RSYNC_OPTS_REMOTE) $(CONFIG_TARGET_DIR) $(REMOTE_HOST):$(CONFIG_TARGET_DIR) && \
	echo -e "\tConfiguration directory synchronized" && \
	$(SED) -e "s/\%LOCALHOSTNAME\%/$(REMOTE_HOST)/" < $(BUILD_DIR)$(AMAgent_CONF) > $(BUILD_DIR)$(AMAgent_CONF).$(REMOTE_HOST) && \
	echo -e "\tCustom AMAgent configuration built for this system" && \
	$(SCP) $(SCP_OPTS) $(BUILD_DIR)$(AMAgent_CONF).$(REMOTE_HOST) $(REMOTE_HOST):/opt/websso/web_agents/apache24_agent/Agent_001/config/$(AMAgent_CONF) && \
	$(RM) $(BUILD_DIR)$(AMAgent_CONF).$(REMOTE_HOST) && \
	echo -e "\tCustom AMAgent configuration copied and removed" && \
	echo -e "\tBegin Apache Restart" && \
	$(SSH) $(SSH_OPTS) $(REMOTE_HOST) $(HTTPD_RESTART) && \
	echo -e "\tApache restarted successfully\n" || exit -1;)

deployEvanston: ALL test
	@$(foreach REMOTE_HOST, $(EV_HOSTS), \
	echo -e "Deploying to $(REMOTE_HOST)" && \
	$(RSYNC) $(RSYNC_OPTS_REMOTE) $(BUILD_DIR) $(REMOTE_HOST):$(BUILD_DIR) && \
	echo -e "\tBuild directory synchronized" && \
	$(RSYNC) $(RSYNC_OPTS_REMOTE) $(CONFIG_TARGET_DIR) $(REMOTE_HOST):$(CONFIG_TARGET_DIR) && \
	echo -e "\tConfiguration directory synchronized" && \
	$(SED) s/\%LOCALHOSTNAME\%/$(REMOTE_HOST)/ < $(BUILD_DIR)$(AMAgent_CONF) > $(BUILD_DIR)$(AMAgent_CONF).$(REMOTE_HOST) && \
	echo -e "\tCustom AMAgent configuration built for this system" && \
	$(SCP) $(SCP_OPTS) $(BUILD_DIR)$(AMAgent_CONF).$(REMOTE_HOST) $(REMOTE_HOST):/opt/websso/web_agents/apache24_agent/Agent_001/config/$(AMAgent_CONF) && \
	$(RM) $(BUILD_DIR)$(AMAgent_CONF).$(REMOTE_HOST) && \
	echo -e "\tCustom AMAgent configuration copied and removed" && \
	echo -e "\tBegin Apache Restart" && \
	$(SSH) $(SSH_OPTS) $(REMOTE_HOST) $(HTTPD_RESTART) && \
	echo -e "\tApache restarted successfully\n" || exit -1;)

