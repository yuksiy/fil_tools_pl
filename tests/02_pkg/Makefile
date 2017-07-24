# make macros
SHELL = /bin/bash
#LANG = C

# System Configuration
srcdir = ../..

ifeq "$(ENVTYPE)" "win"
	PERL ?= $(SYSTEMDRIVE)/strawberry/perl/bin/perl.exe
else
	PERL ?= /usr/bin/perl
endif

localstatedir ?= /var/local


# Inference Rules

# Macro Defines
PROJ = fil_tools

info_dir_suffix = $(localstatedir)/lib/$(PROJ)/info

#通常のテストを行う場合
#test_root = tmp/$(PROJ).test
#diff_dir = diff_dir
#bkup_dir = bkup_dir
#cut_dir = cut_dir
#dest_dir = dest_dir
#dot_dest_dir = .dest_dir
#test_file_1 = test_file_1.txt
#test_file_2 = test_file_2.txt
#test_link_1 = test_link_1.txt
#test_link_2 = test_link_2.txt
#pkg_name = pkg_name
#pkg_file = $(pkg_name).tar.gz

#特殊文字(スペース,$,%)を含むディレクトリをテストする場合
test_root = tmp/$(PROJ).te $$s%t%
diff_dir = diff $$d%i%r
bkup_dir = bkup $$d%i%r
cut_dir = cut $$d%i%r
dest_dir = dest $$d%i%r
dot_dest_dir = .dest $$d%i%r
test_file_1 = test $$f%i%le 1.txt
test_file_2 = test $$f%i%le 2.txt
test_link_1 = test $$l%i%nk 1.txt
test_link_2 = test $$l%i%nk 2.txt
pkg_name = pkg $$n%a%me
pkg_file = $(pkg_name).tar.gz

fil_pkg_install_options-1 = --bsdtar-options='-v -p' -d '/$(test_root)/$(diff_dir)' -l both -b '/$(test_root)/$(bkup_dir)'
fil_pkg_install_options-2 = $(fil_pkg_install_options-1) -r '/$(test_root)'
fil_pkg_install_options-3 = $(fil_pkg_install_options-1) -C 1
fil_pkg_install_options-4 = $(fil_pkg_install_options-1) -C 1 -r '/$(test_root)'

fil_pkg_purge_options-1 =
fil_pkg_purge_options-2 = $(fil_pkg_purge_options-1) -r '/$(test_root)'
fil_pkg_purge_options-3 = $(fil_pkg_purge_options-1)
fil_pkg_purge_options-4 = $(fil_pkg_purge_options-1) -r '/$(test_root)'

fil_pkg_contents_options-1 = --bsdtar-options='-v'
fil_pkg_contents_options-2 = $(fil_pkg_contents_options-1)
fil_pkg_contents_options-3 = $(fil_pkg_contents_options-1)
fil_pkg_contents_options-4 = $(fil_pkg_contents_options-1)

fil_pkg_list_options-1 =
fil_pkg_list_options-2 = $(fil_pkg_list_options-1) -r '/$(test_root)'
fil_pkg_list_options-3 = $(fil_pkg_list_options-1)
fil_pkg_list_options-4 = $(fil_pkg_list_options-1) -r '/$(test_root)'

fil_pkg_listfiles_options-1 =
fil_pkg_listfiles_options-2 = $(fil_pkg_listfiles_options-1) -r '/$(test_root)'
fil_pkg_listfiles_options-3 = $(fil_pkg_listfiles_options-1)
fil_pkg_listfiles_options-4 = $(fil_pkg_listfiles_options-1) -r '/$(test_root)'

fil_pkg_renamefile_options-1 =
fil_pkg_renamefile_options-2 = $(fil_pkg_renamefile_options-1) -r '/$(test_root)'
fil_pkg_renamefile_options-3 = $(fil_pkg_renamefile_options-1)
fil_pkg_renamefile_options-4 = $(fil_pkg_renamefile_options-1) -r '/$(test_root)'


# Target List
all: \
				test \


# Test
ifneq "$(ENVTYPE)" "win"
test: test1 test2 test3 test4
else
test:       test2       test4
endif

ifneq "$(ENVTYPE)" "win"
test1: \
	test-CLEAN-ALL-FIRST-1 test-PREPARE-1 \
	test-PKG_LIST-1-1 test-PKG_CONTENTS-1 test-PKG_INSTALL-1 test-PKG_LISTFILES-1 test-PKG_LIST-1-2 \
	test-SHOW_DIFF_RESULT-1 test-SHOW_COPY_RESULT-1 \
	test-PKG_RENAMEFILE-1 \
	test-PKG_PURGE-1 test-PKG_LIST-1-3 \
	\
	test-CLEAN-ALL-LAST-1
endif

test2: \
	test-CLEAN-ALL-FIRST-2 test-PREPARE-2 \
	test-PKG_LIST-2-1 test-PKG_CONTENTS-2 test-PKG_INSTALL-2 test-PKG_LISTFILES-2 test-PKG_LIST-2-2 \
	test-SHOW_DIFF_RESULT-2 test-SHOW_COPY_RESULT-2 \
	test-PKG_RENAMEFILE-2 \
	test-PKG_PURGE-2 test-PKG_LIST-2-3 \
	\
	test-CLEAN-ALL-LAST-2

ifneq "$(ENVTYPE)" "win"
test3: \
	test-CLEAN-ALL-FIRST-3 test-PREPARE-3 \
	test-PKG_LIST-3-1 test-PKG_CONTENTS-3 test-PKG_INSTALL-3 test-PKG_LISTFILES-3 test-PKG_LIST-3-2 \
	test-SHOW_DIFF_RESULT-3 test-SHOW_COPY_RESULT-3 \
	test-PKG_RENAMEFILE-3 \
	test-PKG_PURGE-3 test-PKG_LIST-3-3 \
	\
	test-CLEAN-ALL-LAST-3
endif

test4: \
	test-CLEAN-ALL-FIRST-4 test-PREPARE-4 \
	test-PKG_LIST-4-1 test-PKG_CONTENTS-4 test-PKG_INSTALL-4 test-PKG_LISTFILES-4 test-PKG_LIST-4-2 \
	test-SHOW_DIFF_RESULT-4 test-SHOW_COPY_RESULT-4 \
	test-PKG_RENAMEFILE-4 \
	test-PKG_PURGE-4 test-PKG_LIST-4-3 \
	\
	test-CLEAN-ALL-LAST-4

testclean \
test-CLEAN-ALL-FIRST-1 test-CLEAN-ALL-LAST-1 \
test-CLEAN-ALL-FIRST-3 test-CLEAN-ALL-LAST-3:
ifeq "$(ENVTYPE)" "cygwin"
	@rm -fr '/$(test_root)'
else
	@sudo rm -fr '/$(test_root)'
endif

test-CLEAN-ALL-FIRST-2 test-CLEAN-ALL-LAST-2 \
test-CLEAN-ALL-FIRST-4 test-CLEAN-ALL-LAST-4:
	@rm -fr '/$(test_root)'

test-PREPARE-1:
	@mkdir -p '/$(test_root)/$(pkg_name)/$(test_root)/$(dest_dir)'; \
	mkdir -p '/$(test_root)/$(pkg_name)/$(test_root)/$(dot_dest_dir)'; \
	sleep 2; \
	date >    '/$(test_root)/$(pkg_name)/$(test_root)/$(dest_dir)/$(test_file_1)'; \
	chmod 444 '/$(test_root)/$(pkg_name)/$(test_root)/$(dest_dir)/$(test_file_1)'; \
	ln -s '$(test_file_1)' '/$(test_root)/$(pkg_name)/$(test_root)/$(dest_dir)/$(test_link_1)'; \
	bsdtar -cf '/$(test_root)/$(pkg_name).tar' -C '/$(test_root)/$(pkg_name)' .; \
	gzip       '/$(test_root)/$(pkg_name).tar'; \
	rm -fr    '/$(test_root)/$(pkg_name)'; \
	mkdir -p '/$(test_root)/$(diff_dir)'; \
	mkdir -p '/$(test_root)/$(bkup_dir)'

test-PREPARE-2:
	@mkdir -p '/$(test_root)/$(pkg_name)/$(dest_dir)'; \
	mkdir -p '/$(test_root)/$(pkg_name)/$(dot_dest_dir)'; \
	sleep 2; \
	date >    '/$(test_root)/$(pkg_name)/$(dest_dir)/$(test_file_1)'; \
	chmod 444 '/$(test_root)/$(pkg_name)/$(dest_dir)/$(test_file_1)'; \
	ln -s '$(test_file_1)' '/$(test_root)/$(pkg_name)/$(dest_dir)/$(test_link_1)'; \
	bsdtar -cf '/$(test_root)/$(pkg_name).tar' -C '/$(test_root)/$(pkg_name)' .; \
	gzip       '/$(test_root)/$(pkg_name).tar'; \
	rm -fr    '/$(test_root)/$(pkg_name)'; \
	mkdir -p '/$(test_root)/$(diff_dir)'; \
	mkdir -p '/$(test_root)/$(bkup_dir)'; \
	if [ ! -d '/$(test_root)$(info_dir_suffix)' ]; then \
		(set -x; mkdir -p '/$(test_root)$(info_dir_suffix)/'); \
	fi

test-PREPARE-3:
	@mkdir -p '/$(test_root)/$(pkg_name)/$(cut_dir)/$(test_root)/$(dest_dir)'; \
	mkdir -p '/$(test_root)/$(pkg_name)/$(cut_dir)/$(test_root)/$(dot_dest_dir)'; \
	sleep 2; \
	date >    '/$(test_root)/$(pkg_name)/$(cut_dir)/$(test_root)/$(dest_dir)/$(test_file_1)'; \
	chmod 444 '/$(test_root)/$(pkg_name)/$(cut_dir)/$(test_root)/$(dest_dir)/$(test_file_1)'; \
	ln -s '$(test_file_1)' '/$(test_root)/$(pkg_name)/$(cut_dir)/$(test_root)/$(dest_dir)/$(test_link_1)'; \
	bsdtar -cf '/$(test_root)/$(pkg_name).tar' -C '/$(test_root)/$(pkg_name)' .; \
	gzip       '/$(test_root)/$(pkg_name).tar'; \
	rm -fr    '/$(test_root)/$(pkg_name)'; \
	mkdir -p '/$(test_root)/$(diff_dir)'; \
	mkdir -p '/$(test_root)/$(bkup_dir)'

test-PREPARE-4:
	@mkdir -p '/$(test_root)/$(pkg_name)/$(cut_dir)/$(dest_dir)'; \
	mkdir -p '/$(test_root)/$(pkg_name)/$(cut_dir)/$(dot_dest_dir)'; \
	sleep 2; \
	date >    '/$(test_root)/$(pkg_name)/$(cut_dir)/$(dest_dir)/$(test_file_1)'; \
	chmod 444 '/$(test_root)/$(pkg_name)/$(cut_dir)/$(dest_dir)/$(test_file_1)'; \
	ln -s '$(test_file_1)' '/$(test_root)/$(pkg_name)/$(cut_dir)/$(dest_dir)/$(test_link_1)'; \
	bsdtar -cf '/$(test_root)/$(pkg_name).tar' -C '/$(test_root)/$(pkg_name)' .; \
	gzip       '/$(test_root)/$(pkg_name).tar'; \
	rm -fr    '/$(test_root)/$(pkg_name)'; \
	mkdir -p '/$(test_root)/$(diff_dir)'; \
	mkdir -p '/$(test_root)/$(bkup_dir)'; \
	if [ ! -d '/$(test_root)$(info_dir_suffix)' ]; then \
		(set -x; mkdir -p '/$(test_root)$(info_dir_suffix)/'); \
	fi

test-PKG_INSTALL-1:
ifeq "$(ENVTYPE)" "cygwin"
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl install $(fil_pkg_install_options-1) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	sudo PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl install $(fil_pkg_install_options-1) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-PKG_INSTALL-2:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl install $(fil_pkg_install_options-2) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_INSTALL-3:
ifeq "$(ENVTYPE)" "cygwin"
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl install $(fil_pkg_install_options-3) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	sudo PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl install $(fil_pkg_install_options-3) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-PKG_INSTALL-4:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl install $(fil_pkg_install_options-4) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_PURGE-1:
ifeq "$(ENVTYPE)" "cygwin"
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl purge $(fil_pkg_purge_options-1) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	sudo PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl purge $(fil_pkg_purge_options-1) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-PKG_PURGE-2:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl purge $(fil_pkg_purge_options-2) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_PURGE-3:
ifeq "$(ENVTYPE)" "cygwin"
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl purge $(fil_pkg_purge_options-3) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	sudo PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl purge $(fil_pkg_purge_options-3) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-PKG_PURGE-4:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl purge $(fil_pkg_purge_options-4) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_CONTENTS-1:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl contents $(fil_pkg_contents_options-1) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_CONTENTS-2:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl contents $(fil_pkg_contents_options-2) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_CONTENTS-3:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl contents $(fil_pkg_contents_options-3) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_CONTENTS-4:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl contents $(fil_pkg_contents_options-4) '/$(test_root)/$(pkg_file)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_LIST-1-1 test-PKG_LIST-1-2 test-PKG_LIST-1-3:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl list $(fil_pkg_list_options-1)
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_LIST-2-1 test-PKG_LIST-2-2 test-PKG_LIST-2-3:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl list $(fil_pkg_list_options-2)
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_LIST-3-1 test-PKG_LIST-3-2 test-PKG_LIST-3-3:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl list $(fil_pkg_list_options-3)
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_LIST-4-1 test-PKG_LIST-4-2 test-PKG_LIST-4-3:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl list $(fil_pkg_list_options-4)
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_LISTFILES-1:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl listfiles $(fil_pkg_listfiles_options-1) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_LISTFILES-2:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl listfiles $(fil_pkg_listfiles_options-2) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_LISTFILES-3:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl listfiles $(fil_pkg_listfiles_options-3) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_LISTFILES-4:
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl listfiles $(fil_pkg_listfiles_options-4) '$(pkg_name)'
	@echo '-I "$@" has ended successfully.' ; echo

test-PKG_RENAMEFILE-1:
ifeq "$(ENVTYPE)" "cygwin"
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-1) '$(pkg_name)' '/$(test_root)/$(dest_dir)/$(test_file_1)' '/$(test_root)/$(dest_dir)/$(test_file_2)'; \
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-1) '$(pkg_name)' '/$(test_root)/$(dest_dir)/$(test_link_1)' '/$(test_root)/$(dest_dir)/$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	sudo PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-1) '$(pkg_name)' '/$(test_root)/$(dest_dir)/$(test_file_1)' '/$(test_root)/$(dest_dir)/$(test_file_2)'; \
	sudo PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-1) '$(pkg_name)' '/$(test_root)/$(dest_dir)/$(test_link_1)' '/$(test_root)/$(dest_dir)/$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-PKG_RENAMEFILE-2:
ifeq "$(ENVTYPE)" "win"
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-2) '$(pkg_name)' '\$(dest_dir)\$(test_file_1)' '\$(dest_dir)\$(test_file_2)'; \
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-2) '$(pkg_name)' '\$(dest_dir)\$(test_link_1)' '\$(dest_dir)\$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-2) '$(pkg_name)' '/$(dest_dir)/$(test_file_1)' '/$(dest_dir)/$(test_file_2)'; \
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-2) '$(pkg_name)' '/$(dest_dir)/$(test_link_1)' '/$(dest_dir)/$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-PKG_RENAMEFILE-3:
ifeq "$(ENVTYPE)" "cygwin"
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-3) '$(pkg_name)' '/$(test_root)/$(dest_dir)/$(test_file_1)' '/$(test_root)/$(dest_dir)/$(test_file_2)'; \
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-3) '$(pkg_name)' '/$(test_root)/$(dest_dir)/$(test_link_1)' '/$(test_root)/$(dest_dir)/$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	sudo PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-3) '$(pkg_name)' '/$(test_root)/$(dest_dir)/$(test_file_1)' '/$(test_root)/$(dest_dir)/$(test_file_2)'; \
	sudo PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-3) '$(pkg_name)' '/$(test_root)/$(dest_dir)/$(test_link_1)' '/$(test_root)/$(dest_dir)/$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-PKG_RENAMEFILE-4:
ifeq "$(ENVTYPE)" "win"
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-4) '$(pkg_name)' '\$(dest_dir)\$(test_file_1)' '\$(dest_dir)\$(test_file_2)'; \
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-4) '$(pkg_name)' '\$(dest_dir)\$(test_link_1)' '\$(dest_dir)\$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-4) '$(pkg_name)' '/$(dest_dir)/$(test_file_1)' '/$(dest_dir)/$(test_file_2)'; \
	PATH="$(srcdir):${PATH}" PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_pkg.pl renamefile $(fil_pkg_renamefile_options-4) '$(pkg_name)' '/$(dest_dir)/$(test_link_1)' '/$(dest_dir)/$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-SHOW_DIFF_RESULT-1 \
test-SHOW_DIFF_RESULT-2 \
test-SHOW_DIFF_RESULT-3 \
test-SHOW_DIFF_RESULT-4:
	@IFS=$$'\n'; \
	for i in `find '/$(test_root)/$(diff_dir)' -type f | sort`; \
	do \
		echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
		(set -x; cat "$${i}"); \
		echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
	done

test-SHOW_COPY_RESULT-1 \
test-SHOW_COPY_RESULT-2 \
test-SHOW_COPY_RESULT-3 \
test-SHOW_COPY_RESULT-4:
	@IFS=$$'\n'; \
	for i in `find '/$(test_root)/$(dest_dir)' -type f | sort`; \
	do \
		echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
		(set -x; cat "$${i}"); \
		echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
	done

