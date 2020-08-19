SOURCES = $(filter-out src/redirector.c, $(wildcard src/*.c))
PACKAGES = lwan-git hitch uacme

.PHONY: deploy packages

$(BLDDIR):
	@$(MKDIR) $(BLDDIR)/.well-known/acme-challenge

bin: $(BLDDIR)
	@$(CC) $(CFLAGS) $(LDFLAGS) $(SOURCES) -DVERSION="\"$(VER)\n\"" -o $(BLDDIR)/$(PROGNM)
	@$(CC) $(CFLAGS) $(LDFLAGS) ./src/redirector.c -o $(BLDDIR)/redirector

clean:
	@rm -rf -- dist cov-int $(PROGNM).tgz ./src/*.plist
	@(pushd bld; rm -rf -- $(PACKAGES) src pkg packages $(PROGNM); popd)

install: all
	@$(MKDIR) -- $(BINDIR) $(SVCDIR)
	@cp -a --no-preserve=ownership $(BLDDIR)/* $(PKGDIR)/
	@cp -a --no-preserve=ownership svc/* $(SVCDIR)/
	@install -m755 -t $(BINDIR) bin/*

packages: clean
	@(pushd bld; \
		$(MKDIR) packages; \
		for i in $(PACKAGES); do \
			cower -df "$$i" --ignorerepo &> /dev/null; \
			pushd "$$i"; \
			PKGDEST=../packages makepkg -s; \
			popd; \
			echo "$$i: built"; \
		done; \
		PKGDEST=packages makepkg -s; \
	)

deploy: packages
	@(pushd bld; \
		ssh -p $(PORT) $(TARGET) 'rm -r -- ~/packages'; \
		scp -P $(PORT) -r packages $(TARGET):~; \
		ssh -p $(PORT) $(TARGET); \
	)

uninstall:
	@rm -rf -- $(PKGDIR)/.well-known
	@rm -f  -- $(SVCDIR)/{$(PROGNM),redirector}.service
	@rm -f  -- $(BINDIR)/website
