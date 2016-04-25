HOST=evnuinfoprodweb1
HOSTFQDN=$(HOST).ci.northwestern.edu
TARGETDIR=/etc/httpd/conf
SOURCEDIR=/etc/httpd/build_conf

ALL:	httpd.conf mime.types policy-url-file.txt main-only.conf virtual.conf \
	virtual-redirect.conf am_template_$(HOST)_prod.properties \
	AMAgent_$(HOST)_prod.properties apache.options main-head.conf \
	virtual-host-map.txt


httpd.conf:	$(SOURCEDIR)/httpd.conf

mime.types:		$(SOURCEDIR)/mime.types
	cp $(SOURCEDIR)/$@ $(TARGETDIR)/$@

policy-url-file.txt:	$(SOURCEDIR)/policy-url-file.txt
	cp $(SOURCEDIR)/$@ $(TARGETDIR)/$@

main-only.conf:		$(SOURCEDIR)/main-only.conf
	cp $(SOURCEDIR)/$@ $(TARGETDIR)/$@

virtual.conf:		$(SOURCEDIR)/virtual.conf
	cp $(SOURCEDIR)/$@ $(TARGETDIR)/$@

virtual-redirect.conf:	$(SOURCEDIR)/virtual-redirect.conf
	cp $(SOURCEDIR)/$@ $(TARGETDIR)/$@

apache.options:		$(SOURCEDIR)/apache.options
	cp $(SOURCEDIR)/$@ $(TARGETDIR)/$@

main-head.conf:		$(SOURCEDIR)/main-head.conf
	cp $(SOURCEDIR)/$@ $(TARGETDIR)/$@

virtual-host-map.txt:	$(SOURCEDIR)/virtual-host-map.txt
	cp $(SOURCEDIR)/$@ $(TARGETDIR)/$@

am_template_$(HOST)_prod.properties:	$(SOURCEDIR)/am_template_$(HOST)_prod.properties

AMAgent_$(HOST)_prod.properties:	$(SOURCEDIR)/AMAgent_$(HOST)_prod.properties


