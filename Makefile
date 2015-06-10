## Based on debian/rules from the original source

SHELL = /bin/bash

share = usr/share/squeezeboxserver
varlib = var/lib/squeezeboxserver
source = source/server
platform_source = source/platforms
vendor_source = source/vendor

PerlArch = $(shell perl -e 'use Config; print "$$Config{archname}\n";')

.PHONY: build
build:
	(git --git-dir=${source}/.git log -n 1 --pretty=format:%ct; echo; date -R >>revision.txt) >revision.txt
	if quilt unapplied; then quilt push -a; fi
	
	cd ${vendor_source}/CPAN && ./buildme.sh
	
.PHONY: install
install:
	# Create directories needed.
	install -d -m0755 $(DESTDIR)/etc/default/
	install -d -m0755 $(DESTDIR)/etc/squeezeboxserver/
	install -d -m0755 $(DESTDIR)/etc/init.d/
	install -d -m0755 $(DESTDIR)/usr/sbin
	install -d -m0755 $(DESTDIR)/usr/share/perl5/
	install -d -m0755 $(DESTDIR)/${share}
	#install -d -m0755 $(DESTDIR)/usr/share/lintian/overrides/
	install -d -m0755 $(DESTDIR)/usr/share/doc/squeezeboxserver/
	install -d -m0755 $(DESTDIR)/${varlib}/prefs
	install -d -m0755 $(DESTDIR)/${varlib}/cache
	
	# Copy our server files to the appropriate Debian locations.
	install -m0755 ${source}/slimserver.pl $(DESTDIR)/usr/sbin/squeezeboxserver
	install -m0755 ${source}/scanner.pl $(DESTDIR)/usr/sbin/squeezeboxserver-scanner
	install -m0755 ${source}/cleanup.pl $(DESTDIR)/usr/sbin/squeezeboxserver-cleanup
	
	cp -r ${source}/Slim $(DESTDIR)/usr/share/perl5/
	
	# Copy our CPAN directory and locally modified perl modules
	cp -r ${source}/CPAN $(DESTDIR)/${share}
	cp -r ${source}/lib $(DESTDIR)/${share}
	
	# Make sure we copy in the Bin directory
	cp -r ${source}/Bin $(DESTDIR)/${share}
	
	# Remove non-Linux binary modules and binaries
	#rm -rf $(DESTDIR)/${share}/CPAN/arch/*/darwin-thread-multi-2level
	#rm -rf $(DESTDIR)/${share}/CPAN/arch/*/i386-freebsd-64int
	#rm -rf $(DESTDIR)/${share}/CPAN/arch/*/sparc-linux
	#rm -rf $(DESTDIR)/${share}/CPAN/arch/*/MSWin32-x86-multi-thread
	#rm -rf $(DESTDIR)/${share}/Bin/darwin
	#rm -rf $(DESTDIR)/${share}/Bin/MSWin32-x86-multi-thread
	#rm -rf $(DESTDIR)/${share}/Bin/i386-freebsd-64int
	rm -rf $(DESTDIR)/${share}/CPAN/arch/*
	rm -rf $(DESTDIR)/${share}/Bin/*
	rm -rf $(DESTDIR)/usr/share/perl5/Slim/Plugin/PreventStandby
	
	
	# And aux files needed to run SlimServer
	cp -r ${source}/Firmware $(DESTDIR)/${share}
	cp -r ${source}/Graphics $(DESTDIR)/${share}
	cp -r ${source}/HTML $(DESTDIR)/${share}
	cp -r ${source}/IR $(DESTDIR)/${share}
	cp -r ${source}/SQL $(DESTDIR)/${share}
	cp -r ${source}/strings.txt $(DESTDIR)/${share}
	cp -r ${source}/MySQL $(DESTDIR)/${share}
	cp -r ${source}/icudt46*.dat $(DESTDIR)/${share}
	
	
	# We put the Plugins into /var/lib/ because they are modifiable, 
	# and shouldn't be put into /usr. 
	cp -r ${source}/Plugins $(DESTDIR)/${varlib} || mkdir -p $(DESTDIR)/${varlib}/Plugins
	
	# Remove errmsg.sys files from the MySQL dir, since they may not match
	# up with the installed version's
	rm $(DESTDIR)/${share}/MySQL/errmsg.*
	
	# Set up the pref's file locations...
	cp -r ${source}/*.conf $(DESTDIR)/etc/squeezeboxserver
	
	# Wrapper to keep the server alive.
	cp -r ${platform_source}/debian/squeezeboxserver_safe $(DESTDIR)/usr/sbin/squeezeboxserver_safe
	
	# Documentation
	cp ${source}/Change* $(DESTDIR)/usr/share/doc/squeezeboxserver/
	cp ${source}/Installation.txt $(DESTDIR)/usr/share/doc/squeezeboxserver/
	cp ${source}/License.txt $(CURDIR)/debian/copyright
	
	# Copy the revision file
	cp revision.txt $(DESTDIR)/${share}
	
	install -d -m0755 $(DESTDIR)/${share}/CPAN/arch/5.18
	cp -r ${vendor_source}/CPAN/build/5.18/lib/perl5/${PerlArch}/ $(DESTDIR)/${share}/CPAN/arch/5.18/
	#mv $(tar zxvf faad2/faad2-build-armv7l-.tgz --wildcards *bin/faad) /usr/share/squeezeboxserver/Bin/arm-linux/
	#mv $(tar zxvf flac/flac-build-armv7l-.tgz --wildcards *bin/flac) /usr/share/squeezeboxserver/Bin/arm-linux/
	#mv $(tar zxvf sox/sox-build-armv7l-.tgz --wildcards *bin/sox) /usr/share/squeezeboxserver/Bin/arm-linux/

.PHONY: clean
clean:
	rm -f revision.txt
	if quilt applied; then quilt pop -a; fi
	
clean-vendors:
	rm -rf ${vendor_source}/CPAN/*.stamp ${vendor_source}/CPAN/build
