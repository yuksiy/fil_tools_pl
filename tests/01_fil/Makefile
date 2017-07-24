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


# Inference Rules

# Macro Defines
PROJ = fil_tools

file_list_suffix = list

#通常のテストを行う場合
#test_root = tmp/$(PROJ).test
#src_dir = src_dir
#diff_dir = diff_dir
#bkup_dir = bkup_dir
#dest_dir = dest_dir
#test_file_1 = test_file_1.txt
#test_file_2 = test_file_2.txt
#test_link_1 = test_link_1.txt
#test_link_2 = test_link_2.txt

#特殊文字(スペース,$,%)を含むディレクトリをテストする場合
test_root = tmp/$(PROJ).te $$s%t%
src_dir = src $$d%i%r
diff_dir = diff $$d%i%r
bkup_dir = bkup $$d%i%r
dest_dir = dest $$d%i%r
test_file_1 = test $$f%i%le 1.txt
test_file_2 = test $$f%i%le 2.txt
test_link_1 = test $$l%i%nk 1.txt
test_link_2 = test $$l%i%nk 2.txt

fil_diff_options-1 = -u
fil_diff_options-2 = $(fil_diff_options-1) -r '/$(test_root)'

fil_ll_options-1 =
fil_ll_options-2 = $(fil_ll_options-1) -r '/$(test_root)'

fil_backup_options-1 =
fil_backup_options-2 = $(fil_backup_options-1) -r '/$(test_root)'

fil_copy_options-1 = -f -l '/$(test_root)'
fil_copy_options-2 = $(fil_copy_options-1) -r '/$(test_root)'

fil_rename_options-1 =
fil_rename_options-2 = $(fil_rename_options-1) -r '/$(test_root)'

fil_rm_options-1 =
fil_rm_options-2 = $(fil_rm_options-1) -r '/$(test_root)'


# Target List
all: \
				test \

# Test
ifneq "$(ENVTYPE)" "win"
test: test1 test2
else
test:       test2
endif

ifneq "$(ENVTYPE)" "win"
test1: \
	test-CLEAN-ALL-FIRST-1-1 test-PREPARE-1-1 \
	test-FIL_DIFF-1-1 test-SHOW_DIFF_RESULT-1-1 \
	test-FIL_LL-BEFORE-1-1 test-FIL_BACKUP-1-1 test-FIL_COPY-1-1 test-FIL_LL-AFTER-1-1 test-SHOW_COPY_RESULT-1-1 test-SHOW_FILE_LIST-1-1 \
	\
	test-CLEAN-PARTIAL-1-2 test-PREPARE-1-2 \
	test-FIL_DIFF-1-2 test-SHOW_DIFF_RESULT-1-2 \
	test-FIL_LL-BEFORE-1-2 test-FIL_BACKUP-1-2 test-FIL_COPY-1-2 test-FIL_LL-AFTER-1-2 test-SHOW_COPY_RESULT-1-2 test-SHOW_FILE_LIST-1-2 \
	\
	test-FIL_RENAME-1-3 \
	\
	test-FIL_RM-1-3 \
	\
	test-CLEAN-ALL-LAST-1
endif

test2: \
	test-CLEAN-ALL-FIRST-2-1 test-PREPARE-2-1 \
	test-FIL_DIFF-2-1 test-SHOW_DIFF_RESULT-2-1 \
	test-FIL_LL-BEFORE-2-1 test-FIL_BACKUP-2-1 test-FIL_COPY-2-1 test-FIL_LL-AFTER-2-1 test-SHOW_COPY_RESULT-2-1 test-SHOW_FILE_LIST-2-1 \
	\
	test-CLEAN-PARTIAL-2-2 test-PREPARE-2-2 \
	test-FIL_DIFF-2-2 test-SHOW_DIFF_RESULT-2-2 \
	test-FIL_LL-BEFORE-2-2 test-FIL_BACKUP-2-2 test-FIL_COPY-2-2 test-FIL_LL-AFTER-2-2 test-SHOW_COPY_RESULT-2-2 test-SHOW_FILE_LIST-2-2 \
	\
	test-FIL_RENAME-2-3 \
	\
	test-FIL_RM-2-3 \
	\
	test-CLEAN-ALL-LAST-2

testclean \
test-CLEAN-ALL-FIRST-1-1 test-CLEAN-ALL-LAST-1 \
test-CLEAN-ALL-FIRST-2-1 test-CLEAN-ALL-LAST-2:
	@rm -fr '/$(test_root)'

test-CLEAN-PARTIAL-1-2 \
test-CLEAN-PARTIAL-2-2:
	@rm -fr '/$(test_root)/$(src_dir)' '/$(test_root)/$(diff_dir)' '/$(test_root)/$(bkup_dir)'

test-PREPARE-1-1 test-PREPARE-1-2:
	@mkdir -p '/$(test_root)/$(src_dir)/$(test_root)/$(dest_dir)'; \
	sleep 2; \
	date >    '/$(test_root)/$(src_dir)/$(test_root)/$(dest_dir)/$(test_file_1)'; \
	chmod 444 '/$(test_root)/$(src_dir)/$(test_root)/$(dest_dir)/$(test_file_1)'; \
	ln -s '$(test_file_1)' '/$(test_root)/$(src_dir)/$(test_root)/$(dest_dir)/$(test_link_1)'; \
	mkdir -p '/$(test_root)/$(diff_dir)'; \
	mkdir -p '/$(test_root)/$(bkup_dir)'

test-PREPARE-2-1 test-PREPARE-2-2:
	@mkdir -p '/$(test_root)/$(src_dir)/$(dest_dir)'; \
	sleep 2; \
	date >    '/$(test_root)/$(src_dir)/$(dest_dir)/$(test_file_1)'; \
	chmod 444 '/$(test_root)/$(src_dir)/$(dest_dir)/$(test_file_1)'; \
	ln -s '$(test_file_1)' '/$(test_root)/$(src_dir)/$(dest_dir)/$(test_link_1)'; \
	mkdir -p '/$(test_root)/$(diff_dir)'; \
	mkdir -p '/$(test_root)/$(bkup_dir)'

test-FIL_DIFF-1-1 test-FIL_DIFF-1-2:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_diff.pl $(fil_diff_options-1) '/$(test_root)/$(src_dir)' '/$(test_root)/$(diff_dir)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_DIFF-2-1 test-FIL_DIFF-2-2:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_diff.pl $(fil_diff_options-2) '/$(test_root)/$(src_dir)' '/$(test_root)/$(diff_dir)'
	@echo '-I "$@" has ended successfully.' ; echo

test-SHOW_DIFF_RESULT-1-1 test-SHOW_DIFF_RESULT-1-2 \
test-SHOW_DIFF_RESULT-2-1 test-SHOW_DIFF_RESULT-2-2:
	@IFS=$$'\n'; \
	for i in `find '/$(test_root)/$(diff_dir)' -type f | sort`; \
	do \
		echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
		(set -x; cat "$${i}"); \
		echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
	done

test-FIL_LL-BEFORE-1-1 test-FIL_LL-AFTER-1-1 test-FIL_LL-BEFORE-1-2 test-FIL_LL-AFTER-1-2:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_ll.pl $(fil_ll_options-1) '/$(test_root)/$(src_dir)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_LL-BEFORE-2-1 test-FIL_LL-AFTER-2-1 test-FIL_LL-BEFORE-2-2 test-FIL_LL-AFTER-2-2:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_ll.pl $(fil_ll_options-2) '/$(test_root)/$(src_dir)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_BACKUP-1-1 test-FIL_BACKUP-1-2:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_backup.pl $(fil_backup_options-1) '/$(test_root)/$(src_dir)' '/$(test_root)/$(bkup_dir)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_BACKUP-2-1 test-FIL_BACKUP-2-2:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_backup.pl $(fil_backup_options-2) '/$(test_root)/$(src_dir)' '/$(test_root)/$(bkup_dir)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_COPY-1-1 test-FIL_COPY-1-2:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_copy.pl $(fil_copy_options-1) '/$(test_root)/$(src_dir)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_COPY-2-1 test-FIL_COPY-2-2:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_copy.pl $(fil_copy_options-2) '/$(test_root)/$(src_dir)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_RENAME-1-3:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_rename.pl $(fil_rename_options-1) '/$(test_root)/$(src_dir).$(file_list_suffix)' '/$(test_root)/$(dest_dir)/$(test_file_1)' '/$(test_root)/$(dest_dir)/$(test_file_2)'; \
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_rename.pl $(fil_rename_options-1) '/$(test_root)/$(src_dir).$(file_list_suffix)' '/$(test_root)/$(dest_dir)/$(test_link_1)' '/$(test_root)/$(dest_dir)/$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_RENAME-2-3:
ifeq "$(ENVTYPE)" "win"
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_rename.pl $(fil_rename_options-2) '/$(test_root)/$(src_dir).$(file_list_suffix)' '\$(dest_dir)\$(test_file_1)' '\$(dest_dir)\$(test_file_2)'; \
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_rename.pl $(fil_rename_options-2) '/$(test_root)/$(src_dir).$(file_list_suffix)' '\$(dest_dir)\$(test_link_1)' '\$(dest_dir)\$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
else
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_rename.pl $(fil_rename_options-2) '/$(test_root)/$(src_dir).$(file_list_suffix)' '/$(dest_dir)/$(test_file_1)' '/$(dest_dir)/$(test_file_2)'; \
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_rename.pl $(fil_rename_options-2) '/$(test_root)/$(src_dir).$(file_list_suffix)' '/$(dest_dir)/$(test_link_1)' '/$(dest_dir)/$(test_link_2)'
	@echo '-I "$@" has ended successfully.' ; echo
endif

test-FIL_RM-1-3:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_rm.pl $(fil_rm_options-1) '/$(test_root)/$(src_dir).$(file_list_suffix)'
	@echo '-I "$@" has ended successfully.' ; echo

test-FIL_RM-2-3:
	PERL5LIB="${PERL5LIB}" $(PERL) $(srcdir)/fil_rm.pl $(fil_rm_options-2) '/$(test_root)/$(src_dir).$(file_list_suffix)'
	@echo '-I "$@" has ended successfully.' ; echo

test-SHOW_COPY_RESULT-1-1 test-SHOW_COPY_RESULT-1-2 \
test-SHOW_COPY_RESULT-2-1 test-SHOW_COPY_RESULT-2-2:
	@IFS=$$'\n'; \
	for i in `find '/$(test_root)/$(dest_dir)' -type f | sort`; \
	do \
		echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
		(set -x; cat "$${i}"); \
		echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
	done

test-SHOW_FILE_LIST-1-1 test-SHOW_FILE_LIST-1-2 \
test-SHOW_FILE_LIST-2-1 test-SHOW_FILE_LIST-2-2:
	@echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'; \
	(set -x; cat '/$(test_root)/$(src_dir).$(file_list_suffix)'); \
	echo '::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'

