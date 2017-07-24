# System Configuration
srcdir = .

ifeq "$(ENVTYPE)" "win"
	PERL ?= $(SYSTEMDRIVE)/strawberry/perl/bin/perl.exe
	prefix ?= /strawberry/perl
	exec_prefix ?= $(prefix)
	scriptbindir ?= $(HOME)/script/bin
else
	PERL ?= /usr/bin/perl
	prefix ?= /usr/local
	exec_prefix ?= $(prefix)
	scriptbindir ?= $(prefix)/bin
endif
datadir ?= $(scriptbindir)

bindir ?= $(exec_prefix)/bin
libdir ?= $(exec_prefix)/lib
sbindir ?= $(exec_prefix)/sbin

sysconfdir ?= $(prefix)/etc
infodir ?= $(prefix)/info
mandir ?= $(prefix)/man
localstatedir ?= /var/local

CHECK_SCRIPT_SH = /bin/sh -n
CHECK_SCRIPT_PL = $(PERL) -c

INSTALL = /usr/bin/install -p
INSTALL_PROGRAM = $(INSTALL)
INSTALL_SCRIPT = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_DIR = /usr/bin/install -d -m 755


# Inference Rules

# Macro Defines
PROJ = fil_tools_pl
VER = 1.0.0

PKG_SORT_KEY ?= 6,6

SUBDIRS-TEST-SCRIPTS-SH = \
				tests/01_fil \
				tests/02_pkg \

SUBDIRS-TEST = \
				$(SUBDIRS-TEST-SCRIPTS-SH) \

SUBDIRS = \
				$(SUBDIRS-TEST) \

PROGRAMS = \

SCRIPTS-SH = \

SCRIPTS-PL = \
				fil_backup.pl \
				fil_copy.pl \
				fil_diff.pl \
				fil_ll.pl \
				fil_pkg.pl \
				fil_rename.pl \
				fil_rm.pl \

SCRIPTS-OTHER = \

SCRIPTS = \
				$(SCRIPTS-SH) \
				$(SCRIPTS-PL) \
				$(SCRIPTS-OTHER) \

DATA = \

DIRS = \
				$(localstatedir)/lib/fil_tools/info/ \

# Target List
test-recursive \
:
	@target=`echo $@ | sed s/-recursive//`; \
	list='$(SUBDIRS-TEST)'; \
	for subdir in $$list; do \
		echo "Making $$target in $$subdir"; \
		echo " (cd $$subdir && $(MAKE) $$target)"; \
		(cd $$subdir && $(MAKE) $$target); \
	done

all: \
				$(PROGRAMS) \
				$(SCRIPTS) \
				$(DATA) \
				$(DIRS) \

# Executables

# Source Objects

# Clean Up Everything
clean:
	rm -f *.$(o) $(PROGRAMS)

# Check
check: check-SCRIPTS-SH check-SCRIPTS-PL

check-SCRIPTS-SH:
	@list='$(SCRIPTS-SH)'; \
	for i in $$list; do \
		echo " $(CHECK_SCRIPT_SH) $$i"; \
		$(CHECK_SCRIPT_SH) $$i; \
	done

check-SCRIPTS-PL:
	@list='$(SCRIPTS-PL)'; \
	for i in $$list; do \
		echo " $(CHECK_SCRIPT_PL) $$i"; \
		$(CHECK_SCRIPT_PL) $$i; \
	done

# Test
test:
	$(MAKE) test-recursive

# Install
install: install-SCRIPTS install-DATA install-DIRS

install-SCRIPTS:
	@list='$(SCRIPTS)'; \
	if [ ! -d "$(DESTDIR)$(scriptbindir)/" ]; then \
		echo " mkdir -p $(DESTDIR)$(scriptbindir)/"; \
		mkdir -p $(DESTDIR)$(scriptbindir)/; \
	fi;\
	for i in $$list; do \
		echo " $(INSTALL_SCRIPT) $$i $(DESTDIR)$(scriptbindir)/"; \
		$(INSTALL_SCRIPT) $$i $(DESTDIR)$(scriptbindir)/; \
	done

install-DATA:
	@list='$(DATA)'; \
	if [ ! -d "$(DESTDIR)$(datadir)/" ]; then \
		echo " mkdir -p $(DESTDIR)$(datadir)/"; \
		mkdir -p $(DESTDIR)$(datadir)/; \
	fi;\
	for i in $$list; do \
		echo " $(INSTALL_DATA) $$i $(DESTDIR)$(datadir)/"; \
		$(INSTALL_DATA) $$i $(DESTDIR)$(datadir)/; \
	done

install-DIRS:
	@list='$(DIRS)'; \
	for i in $$list; do \
		echo " $(INSTALL_DIR) $(DESTDIR)$$i"; \
		$(INSTALL_DIR) $(DESTDIR)$$i; \
	done

# Pkg
pkg:
	@$(MAKE) DESTDIR=$(CURDIR)/$(PROJ)-$(VER).$(ENVTYPE) install; \
	tar cvf ./$(PROJ)-$(VER).$(ENVTYPE).tar ./$(PROJ)-$(VER).$(ENVTYPE) > /dev/null; \
	tar tvf ./$(PROJ)-$(VER).$(ENVTYPE).tar 2>&1 | sort -k $(PKG_SORT_KEY) | tee ./$(PROJ)-$(VER).$(ENVTYPE).tar.list.txt; \
	gzip -f ./$(PROJ)-$(VER).$(ENVTYPE).tar; \
	rm -fr ./$(PROJ)-$(VER).$(ENVTYPE)
