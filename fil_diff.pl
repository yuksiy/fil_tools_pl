#!/usr/bin/perl

# ==============================================================================
#   機能
#     ディレクトリ構造に従ってファイルを比較する
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
use Text::Diff;

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
#my %DIFF_OPTIONS = ();
my @DIFF_OPTIONS = ();
my $DIFF_FILE_SUFFIX = "diff";

my $root = "";
my $FLAG_OPT_CONTEXT = 0;
my $ARG_OPT_CONTEXT = 3;
my $FLAG_OPT_UNIFIED = 0;
my $ARG_OPT_UNIFIED = 3;
my $src_dir = "";
my $dest_dir = "";

my ($src_file_count, $exist_file_count, $not_exist_file_count);

my $DEBUG = 0;
my $TMP_DIR = File::Spec->tmpdir();
my $SCRIPT_TMP_DIR = File::Spec->catdir($TMP_DIR, "$SCRIPT_NAME.$PID");
my $FIND_LIST = File::Spec->catfile($SCRIPT_TMP_DIR, "find_list.tmp");
my @files;
my $file;

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
    fil_diff.pl [OPTIONS ...] SRC_DIR DEST_DIR

    SRC_DIR  : Specify a directory storing files for comparing.
    DEST_DIR : Specify an EMPTY directory for storing comparison result files.

OPTIONS:
    -r ROOT
       Specify a target root directory.
    -c (context)
       execute 'diff' command with '-c' option.
    -C NUM (context)
       execute 'diff' command with '-C NUM' option.
    -u (unified)
       execute 'diff' command with '-u' option.
    -U NUM (unified)
       execute 'diff' command with '-U NUM' option.
    --help
       Display this help and exit.
EOF
}

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
	"c" => sub {
		$FLAG_OPT_CONTEXT = 1;
		#$DIFF_OPTIONS{STYLE} = "Context";
		push @DIFF_OPTIONS, "STYLE", "Context";
	},
	"C=s" => sub {
		$ARG_OPT_CONTEXT = $_[1];
		#$DIFF_OPTIONS{CONTEXT} = $ARG_OPT_CONTEXT;
		push @DIFF_OPTIONS, "CONTEXT", $ARG_OPT_CONTEXT;
	},
	"u" => sub {
		$FLAG_OPT_UNIFIED = 1;
		#$DIFF_OPTIONS{STYLE} = "Unified";
		push @DIFF_OPTIONS, "STYLE", "Unified";
	},
	"U=s" => sub {
		$ARG_OPT_UNIFIED = $_[1];
		#$DIFF_OPTIONS{CONTEXT} = $ARG_OPT_CONTEXT;
		push @DIFF_OPTIONS, "CONTEXT", $ARG_OPT_CONTEXT;
	},
	"help" => sub {
		USAGE();exit 0;
	},
) } ) {
	print STDERR "-E $s_err\n";
	USAGE();exit 1;
}

# 第1引数のチェック
if ( not defined($ARGV[0]) ) {
	print STDERR "-E Missing SRC_DIR argument\n";
	USAGE();exit 1;
} else {
	$src_dir = $ARGV[0];
	$src_dir = File::Spec->catdir("$src_dir");
	# diff対象ファイル格納ディレクトリのチェック
	if ( not -d "$src_dir" ) {
		print STDERR "-E SRC_DIR not a directory -- \"$src_dir\"\n";
		USAGE();exit 1;
	}
}

# 第2引数のチェック
if ( not defined($ARGV[1]) ) {
	print STDERR "-E Missing DEST_DIR argument\n";
	USAGE();exit 1;
} else {
	$dest_dir = $ARGV[1];
	$dest_dir = File::Spec->catdir("$dest_dir");
	# diff結果ファイル格納ディレクトリのチェック
	if ( not -d "$dest_dir" ) {
		print STDERR "-E DEST_DIR not a directory -- \"$dest_dir\"\n";
		USAGE();exit 1;
	}
}

# diff結果ファイル格納ディレクトリが空ディレクトリであることのチェック
$rc = IS_DIR_EMPTY("$dest_dir");
if ( $rc != 0 ) {
	print STDERR "-E DEST_DIR directory not empty -- \"$dest_dir\"\n";
	USAGE();exit 1;
}

# 作業開始前処理
PRE_PROCESS();

# diff対象ファイル格納ディレクトリ内のFINDリストの取得
if ( not defined(open(FIND_LIST, '>', "$FIND_LIST")) ) {
	print STDERR "-E FIND_LIST cannot open -- \"$FIND_LIST\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(FIND_LIST);
@files = ();
find(sub {
	push @files, File::Spec->catfile($File::Find::name);
}, "$src_dir");
foreach $file (sort(@files)) {
	$file =~ s?^\Q$src_dir\E??;
	if ( $file !~ m/^$/ ) {
		print FIND_LIST "$file\n";
	}
}
close(FIND_LIST);

# 処理開始メッセージの表示
print "\n";
print "-I File comparing has started.\n";

#####################
# メインループ 開始 #
#####################
$src_file_count = 0;
find(sub {
	if ( (-f) or (-l) ) {
		$File::Find::name =~ s?^\Q$src_dir\E??;
		if ( $File::Find::name !~ m/^$/ ) {
			$src_file_count = $src_file_count + 1;
		}
	}
}, "$src_dir");
$exist_file_count = 0;
$not_exist_file_count = 0;

if ( not defined(open(FIND_LIST, '<', "$FIND_LIST")) ) {
	print STDERR "-E FIND_LIST cannot open -- \"$FIND_LIST\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(FIND_LIST);
while ($line = <FIND_LIST>) {
	chomp $line;
	# ディレクトリの処理
	if ( ( -d "$src_dir$line" ) and ( not -l "$src_dir$line" ) ) {
		# 既存ディレクトリの場合
		if ( ( -d "$root$line" ) and ( not -l "$root$line" ) ) {
			# diff結果ファイル格納ディレクトリの作成
			$rc = CMD_V "use File::Path; mkpath('$dest_dir$line');";
			if ( $rc < 1 ) {
				print STDERR "-E Command has ended unsuccessfully.\n";
				POST_PROCESS();exit 1;
			}
			next;
		# 既存ディレクトリでない場合
		} else {
			# 何もしない
			next;
		}
	}
	# ファイルの処理
	if ( ( -f "$src_dir$line" ) or ( -l "$src_dir$line" ) ) {
		# 既存ファイルの場合
		if ( ( -f "$root$line" ) or ( -l "$root$line" ) ) {
			$exist_file_count = $exist_file_count + 1;
			# ファイルの比較
			if ( not defined(open(DIFF_FILE, '>', "$dest_dir$line.$DIFF_FILE_SUFFIX")) ) {
				print STDERR "-E DIFF_FILE cannot open -- \"$dest_dir$line.$DIFF_FILE_SUFFIX\": $!\n";
				POST_PROCESS();exit 1;
			}
			#binmode(DIFF_FILE);
			$rc = CMD_V "use Text::Diff; diff('$root$line', '$src_dir$line', {qw(@DIFF_OPTIONS)});";
			print DIFF_FILE $rc;
			close(DIFF_FILE);
		# 既存ファイルでない場合
		} else {
			$not_exist_file_count = $not_exist_file_count + 1;
			print STDERR "-W \"$root$line\" file not exists, skipped\n";
		}
	}
}
close(FIND_LIST);
#####################
# メインループ 終了 #
#####################

# 統計の表示
print "\n";
print "Total of files in \"$src_dir\" : $src_file_count\n";
print "----------------------------------------\n";
print "Total of compared files  : $exist_file_count\n";
print "Total of not exist files : $not_exist_file_count\n";

# 処理終了メッセージの表示
if ( ( $exist_file_count + $not_exist_file_count ) != $src_file_count ) {
	print "\n";
	print STDERR "-E Total of compared files did not match.\n";
	print STDERR "-E File comparing has ended unsuccessfully.\n";
	POST_PROCESS();exit 1;
} else {
	print "\n";
	print "-I File comparing has ended successfully.\n";
	# 作業終了後処理
	POST_PROCESS();exit 0;
}

