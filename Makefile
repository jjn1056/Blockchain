#
# makefile for common devops / automation tasks
#

LOCALDIR := $(PWD)/local/
CPANMURL := https://cpanmin.us/
LOCALPERL := perl 
RUNTESTS := --notest 
PERLJOBS := 9
help::
	@echo ""
	@echo "==> Setup and Dependency Management"
	@echo "setup		-- Install Perl to $(LOCALDIR) and bootstrap dependencies"
	@echo "installdeps	-- Install 'cpanfile' dependencys to $(LOCALDIR)"
	@echo "installdevelop 	-- Install 'cpanfile --with-develop' dependencys to $(LOCALDIR)"
	@echo "locallib	-- Bootstrap a local-lib to $(LOCALDIR)"
	@echo ""
	@echo "==> Server Control"
	@echo "client_server    -- Start the application in the foreground process"
	@echo "node_server	-- Start the application in the foreground process"
	@echo ""

locallib::
	@echo "Bootstrapping local::lib"
	curl -L $(CPANMURL) | perl - -l $(LOCALDIR) local::lib
	eval $$(perl -I$(LOCALDIR)lib/perl5 -Mlocal::lib=--deactivate-all); \
	 curl -L $(CPANMURL) | $(LOCALPERL) - -L $(LOCALDIR) $(RUNTESTS) --reinstall \
	  local::lib \
	  App::cpanminus \
	  App::local::lib::helper 

buildexec::
	@echo "Creating exec program"
	@echo '#!/usr/bin/env bash' > $(LOCALEXEC)
	@echo 'eval $$(perl -I$(LOCALDIR)lib/perl5 -Mlocal::lib=--deactivate-all)' >> $(LOCALEXEC)
	@echo 'source $(LOCALDIR)bin/localenv-bashrc' >> $(LOCALEXEC)
	@echo 'PATH=$(LOCALDIR)bin:$(PERLINSTALLTARGETDIR)/bin:$$PATH' >> $(LOCALEXEC)
	@echo 'export PATH' >> $(LOCALEXEC)
	@echo 'exec  "$$@"' >> $(LOCALEXEC)
	@chmod 755 $(LOCALEXEC)

installdeps::
	@echo "Installing application dependencies"
	$(LOCALEXEC) cpanm -v $(RUNTESTS) --installdeps .

installdevelop::
	@echo "Installing application dependencies"
	$(LOCALEXEC) cpanm -v $(RUNTESTS) --with-develop --installdeps .

setup:: locallib installdevelop

client_server::
	perl -I$(LOCALDIR)perl5 -Ilib lib/BlockchainClient/Server.pm --port 3000

node_server::
	$(LOCALEXEC) perl -I$(LOCALDIR)perl5 -Ilib lib/BlockchainNode/Server.pm --port 5000
