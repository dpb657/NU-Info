# NU Info Build, Test and Deploy Makefile
#
BUILD_DIR		= /etc/httpd/build_conf
CONFIG_TARGET_DIR	= /etc/httpd/conf.d/
AMAgent_CONF_DIR	= /opt/websso/web_agents/apache24_agent/Agent_001/config/

AMAgent_CONF		= OpenSSOAgentConfiguration.properties
FILES			= $(CONFIG_TARGET_DIR)httpd.conf \
			  $(CONFIG_TARGET_DIR)apache-load-modules.conf \
			  $(CONFIG_TARGET_DIR)apache-options.conf \
			  $(CONFIG_TARGET_DIR)main-head.conf \
			  $(CONFIG_TARGET_DIR)main-only.conf \
			  $(CONFIG_TARGET_DIR)mime.types \
			  $(CONFIG_TARGET_DIR)policy-url-file.txt \
			  $(CONFIG_TARGET_DIR)virtual.conf \
			  $(CONFIG_TARGET_DIR)virtual-host-map.txt \
			  $(CONFIG_TARGET_DIR)virtual-redirect.conf

#
# We are using rsync instead of cp locally because of error the checking
#
RSYNC			= /bin/rsync
# Locally we want the current timestamp
RSYNC_OPTS_LOCAL	= --archive --update --checksum --no-t
# On the remotes we want the timestamps to be the same
RSYNC_OPTS_REMOTE	= --archive --update --checksum

PERL			= /bin/perl
PERL_OPTS		= -f

SED			= /bin/sed
RM			= /bin/rm -f

SSH			= /bin/ssh
SSH_OPTS		= 

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
ALL: test $(FILES) $(AMAgent_CONF_DIR)$(AMAgent_CONF)
	@$(RSYNC) $(RSYNC_OPTS_LOCAL) $(BUILD_DIR)/ $(CONFIG_TARGET_DIR)/
	@echo -e "Build of all Complete\n"

# TEST_DIR has the effect of switching all the includes to come from the build directory
test: 
	@/usr/sbin/httpd -t -f $(BUILD_DIR)/httpd.conf -DTEST_DIR
	@echo ""

#
# deployChicago and deployEvanston are using GNU make specific syntax - foreach
#

deployChicago: ALL
	@$(foreach REMOTE_HOST, $(CH_HOSTS), \
	$(RSYNC) $(RSYNC_OPTS_REMOTE) $(BUILD_DIR)/ $(REMOTE_HOST):$(BUILD_DIR)/ && \
	echo -e "$(REMOTE_HOST) - Build directory synchronized" && \
	$(RSYNC) $(RSYNC_OPTS_REMOTE) $(CONFIG_TARGET_DIR) $(REMOTE_HOST):$(CONFIG_TARGET_DIR) && \
	echo -e "$(REMOTE_HOST) - Configuration directory synchronized" && \
	$(SED) s/@LOCALHOSTNAME@/$(REMOTE_HOST)/ < $(BUILD_DIR)/$(AMAgent_CONF) > $(BUILD_DIR)/$(AMAgent_CONF).$(REMOTE_HOST) && \
	echo -e "$(REMOTE_HOST) - AMAgent configuration rebuilt for this system" && \
	$(RSYNC) $(RSYNC_REMOTE_OPTS) $(BUILD_DIR)/$(AMAgent_CONF).$(REMOTE_HOST) $(REMOTE_HOST):/opt/websso/web_agents/apache24_agent/Agent_001/config/ && \
	echo -e "$(REMOTE_HOST) - AMAgent configuration synchronized" && \
	$(RM) $(BUILD_DIR)/$(AMAgent_CONF).$(REMOTE_HOST) && \
	echo -e "$(REMOTE_HOST) - Remove custom AMAgent configuration\n$(REMOTE_HOST) - Begin Apache Restart" && \
	$(SSH) $(SSH_OPTS) $(REMOTE_HOST) $(HTTPD_RESTART) && \
	echo -e "$(REMOTE_HOST) - Apache restarted successfully\n" || exit -1;)

deployEvanston: ALL
	@$(foreach REMOTE_HOST, $(EV_HOSTS), \
	$(RSYNC) $(RSYNC_OPTS_REMOTE) $(BUILD_DIR)/ $(REMOTE_HOST):$(BUILD_DIR)/ && \
	echo -e "$(REMOTE_HOST) - Build directory synchronized" && \
	$(RSYNC) $(RSYNC_OPTS_REMOTE) $(CONFIG_TARGET_DIR) $(REMOTE_HOST):$(CONFIG_TARGET_DIR) && \
	echo -e "$(REMOTE_HOST) - Configuration directory synchronized" && \
	$(SED) s/@LOCALHOSTNAME@/$(REMOTE_HOST)/ < $(BUILD_DIR)/$(AMAgent_CONF) > $(BUILD_DIR)/$(AMAgent_CONF).$(REMOTE_HOST) && \
	echo -e "$(REMOTE_HOST) - AMAgent configuration rebuilt for this system" && \
	$(RSYNC) $(RSYNC_REMOTE_OPTS) $(BUILD_DIR)/$(AMAgent_CONF).$(REMOTE_HOST) $(REMOTE_HOST):/opt/websso/web_agents/apache24_agent/Agent_001/config/ && \
	echo -e "$(REMOTE_HOST) - AMAgent configuration synchronized" && \
	$(RM) $(BUILD_DIR)/$(AMAgent_CONF).$(REMOTE_HOST) && \
	echo -e "$(REMOTE_HOST) - Remove custom AMAgent configuration\n$(REMOTE_HOST) - Begin Apache Restart" && \
	$(SSH) $(SSH_OPTS) $(REMOTE_HOST) $(HTTPD_RESTART) && \
	echo -e "$(REMOTE_HOST) - Apache restarted successfully\n" || exit -1;)

