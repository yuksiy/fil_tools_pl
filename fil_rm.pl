#!/usr/bin/perl

# ==============================================================================
#   機能
#     削除ファイルリストに従ってファイルを削除する
#     ディレクトリが空である場合はディレクトリも削除する
#   構文
#     USAGE 参照
#
#   Copyright (c) 2010-2017 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename;
use File::Find;
use File::Path;
use File::Spec;
use Getopt::Long qw(GetOptionsFromArray :config gnu_getopt no_ignore_case);
use IO::Handle;

autoflush STDOUT;flush STDOUT;
autoflush STDERR;flush STDERR;

my $s_err = "";
$SIG{__DIE__} = $SIG{__WARN__} = sub { $s_err = $_[0]; };

$SIG{WINCH} = "IGNORE";
$SIG{HUP} = $SIG{INT} = $SIG{TERM} = sub { POST_PROCESS();exit 1; };

my $SCRIPT_FULL_NAME = abs_path($0);
$SCRIPT_FULL_NAME = File::Spec->catfile("$SCRIPT_FULL_NAME");
my ($SCRIPT_NAME, $SCRIPT_ROOT) = fileparse($SCRIPT_FULL_NAME);
my $PID = $$;

######################################################################
# 変数定義
######################################################################
#my @RMDIR_OPTIONS = qw();
#my @RM_OPTIONS = qw();

my $root = "";
#my $FLAG_OPT_FORCE = 0;
my $DEL_FILE_LIST = "";

my ($src_file_count, $exist_remove_dir_count, $exist_skip_dir_count, $exist_file_count, $not_exist_file_count);

my $DEBUG = 0;
my $TMP_DIR = File::Spec->tmpdir();
my $SCRIPT_TMP_DIR = File::Spec->catdir($TMP_DIR, "$SCRIPT_NAME.$PID");
my $FIND_LIST = File::Spec->catfile($SCRIPT_TMP_DIR, "find_list.tmp");

my @lines;
my $line;
my $rc = 0;

######################################################################
# サブルーチン定義
######################################################################
sub PRE_PROCESS {
	# 一時ディレクトリの作成
	mkpath("$SCRIPT_TMP_DIR");
}

sub POST_PROCESS {
	# 一時ディレクトリの削除
	if ( ( not $DEBUG ) and ( not defined($ENV{DEBUG}) ) ) {
		rmtree("$SCRIPT_TMP_DIR");
	}
}

sub USAGE {
	print STDOUT <<EOF;
Usage:
    fil_rm.pl [OPTIONS ...] DEL_FILE_LIST

    DEL_FILE_LIST : Specify a delete file list.

OPTIONS:
    -r ROOT
       Specify a target root directory.
    --help
       Display this help and exit.
EOF
}
#    -f (force)
#       execute 'rm' command with '-f' option.

use Common_pl::Cmd_v;
use Common_pl::Is_dir_empty;

######################################################################
# メインルーチン
######################################################################

# オプションのチェック
if ( not eval { GetOptionsFromArray( \@ARGV,
	"r=s" => sub {
		$root = "$_[1]";
		$root = File::Spec->catdir("$root");
		# ROOTディレクトリのチェック
		if ( not -d "$root" ) {
			print STDERR "-E ROOT not a directory -- \"$root\"\n";
			USAGE();exit 1;
		}
	},
	#"f" => sub {
	#	$FLAG_OPT_FORCE = 1;
	#	push @RM_OPTIONS, "-f";
	#},
	"help" => sub {
		USAGE();exit 0;
	},
) } ) {
	print STDERR "-E $s_err\n";
	USAGE();exit 1;
}

# 第1引数のチェック
if ( not defined($ARGV[0]) ) {
	print STDERR "-E Missing DEL_FILE_LIST argument\n";
	USAGE();exit 1;
} else {
	$DEL_FILE_LIST = "$ARGV[0]";
	$DEL_FILE_LIST = File::Spec->catfile("$DEL_FILE_LIST");
	# 削除ファイルリストのチェック
	if ( not -f "$DEL_FILE_LIST" ) {
		print STDERR "-E DEL_FILE_LIST not a file -- \"$DEL_FILE_LIST\"\n";
		USAGE();exit 1;
	}
}

# 作業開始前処理
PRE_PROCESS();

# 削除対象ファイルのFINDリストの取得
if ( not defined(open(DEL_FILE_LIST, '<', "$DEL_FILE_LIST")) ) {
	print STDERR "-E DEL_FILE_LIST cannot open -- \"$DEL_FILE_LIST\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(DEL_FILE_LIST);
if ( not defined(open(FIND_LIST, '>', "$FIND_LIST")) ) {
	print STDERR "-E FIND_LIST cannot open -- \"$FIND_LIST\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(FIND_LIST);
@lines = ();
foreach $line (<DEL_FILE_LIST>) {
	# コメントと空行は無視
	if ( ( $line !~ m/^#/ ) and ( $line !~ m/^$/ ) ) {
		$line = File::Spec->catdir("$line");
		push @lines, $line;
	}
}
foreach $line (sort {$b cmp $a} @lines) {
	print FIND_LIST "$line";
}
close(FIND_LIST);
close(DEL_FILE_LIST);

# 処理開始メッセージの表示
print "\n";
print "-I File deletion has started.\n";

#####################
# メインループ 開始 #
#####################
$src_file_count = 0;
if ( not defined(open(FIND_LIST, '<', "$FIND_LIST")) ) {
	print STDERR "-E FIND_LIST cannot open -- \"$FIND_LIST\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(FIND_LIST);
foreach (<FIND_LIST>) {
	$src_file_count = $src_file_count + 1;
}
close(FIND_LIST);

$exist_remove_dir_count = 0;
$exist_skip_dir_count = 0;

$exist_file_count = 0;

$not_exist_file_count = 0;

if ( not defined(open(FIND_LIST, '<', "$FIND_LIST")) ) {
	print STDERR "-E FIND_LIST cannot open -- \"$FIND_LIST\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(FIND_LIST);
while ($line = <FIND_LIST>) {
	chomp $line;
	# 既存ディレクトリの場合
	if ( ( -d "$root$line" ) and ( not -l "$root$line" ) ) {
		# 削除対象ディレクトリが空ディレクトリであることのチェック
		$rc = IS_DIR_EMPTY("$root$line");
		# 空ディレクトリの場合
		if ( $rc == 0 ) {
			$exist_remove_dir_count = $exist_remove_dir_count + 1;
			# ディレクトリの削除
			$rc = CMD_V "use File::Path; rmtree('$root$line');";
			if ( $rc != 1 ) {
				print STDERR "-E Command has ended unsuccessfully.\n";
				POST_PROCESS();exit 1;
			}
		# 空ディレクトリでない場合
		} else {
			$exist_skip_dir_count = $exist_skip_dir_count + 1;
			print STDERR "-W \"$root$line\" directory not empty, skipped\n";
		}
	# 既存ファイルの場合
	} elsif ( ( -f "$root$line" ) or ( -l "$root$line" ) ) {
		$exist_file_count = $exist_file_count + 1;
		# ファイルの削除
		$rc = CMD_V "unlink('$root$line');";
		if ( $rc != 1 ) {
			print STDERR "-E Command has ended unsuccessfully.\n";
			POST_PROCESS();exit 1;
		}
	# 既存ディレクトリでない場合、かつ既存ファイルでない場合
	} else {
		$not_exist_file_count = $not_exist_file_count + 1;
		print STDERR "-W \"$root$line\" file not exists, skipped\n";
	}
}
close(FIND_LIST);
#####################
# メインループ 終了 #
#####################

# 統計の表示
print "\n";
print "Total of files in \"$DEL_FILE_LIST\" : $src_file_count\n";
print "----------------------------------------\n";
print "Total of deleted directories   : $exist_remove_dir_count\n";
print "Total of skipped directories   : $exist_skip_dir_count\n";
print "----------------------------------------\n";
print "Total of deleted files   : $exist_file_count\n";
print "Total of not exist files : $not_exist_file_count\n";

# 処理終了メッセージの表示
if ( ( $exist_remove_dir_count + $exist_skip_dir_count + $exist_file_count + $not_exist_file_count ) != $src_file_count ) {
	print "\n";
	print STDERR "-E Total of deleted files did not match.\n";
	print STDERR "-E File deletion has ended unsuccessfully.\n";
	POST_PROCESS();exit 1;
} else {
	print "\n";
	print "-I File deletion has ended successfully.\n";
	# 作業終了後処理
	POST_PROCESS();exit 0;
}

