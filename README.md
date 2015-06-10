SYNOPSIS
========

"In an ideal world, CPAN/ can be blown away, and the OSes packages can be used." -- logitechmediaserver/lib/README

I attempted to achieve that, but it's like Perl developers haven't heard of "API compatibility". Quite a few modules changed behaviour between versions which resulted in very strange behaviour. In the end I just gave up and packed what the Logitech Media Server developers provided.

How to build
============

	git clone --recursive https://github.com/Uplink03/logitechmediaserver-deb.git
	cd logitechmediaserver-deb
	
	dpkg-buildpackage -rfakeroot -b -us -uc

Normally you'll just need to install the packages referenced in build-depends. If you need extras, that's a bug in build-depends. `dpkg-buildpackage` will tell you what packages you need to install to satisfy the build-depends.

Packages
========

Unlike the Logitech-provided software, you will get several packages instead of just one:
- logitechmediaserver : the main software
- logitechmediaserver-html : the web pages
- logitechmediaserver-cpan-bundle : the CPAN modules, including the architecture-dependent bits

Optional packages:
- logitechmediaserver-code2000-font : the CODE2000 font, which is shareware and requires a registration fee after a "reasonable" amount of time, but the author and official website appear to be in the wind now
- logitechmediaserver-firmware : the Squeezebox firmware, which nobody but Logitech can distribute

You don't need the optional packages to run a squeezelite/squeezeslave/softsqueeze-only setup.
