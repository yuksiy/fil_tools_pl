#!/usr/bin/perl

# ==============================================================================
#   機能
#     インストールファイルリストに記載されているファイル名を変更する
#     システムにインストール済みのファイル名も変更する
#   構文
#     USAGE 参照
#
#   Copyright (c) 2012-2017 Yukio Shiiya
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
my $root = "";
my $INST_FILE_LIST = "";
my $SRC_FILE = "";
my $DEST_FILE = "";

my $DEBUG = 0;
my $TMP_DIR = File::Spec->tmpdir();
my $SCRIPT_TMP_DIR = File::Spec->catdir($TMP_DIR, "$SCRIPT_NAME.$PID");
my $INST_FILE_LIST_TMP = File::Spec->catfile($SCRIPT_TMP_DIR, "inst_file_list.tmp");

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
    fil_rename.pl [OPTIONS ...] INST_FILE_LIST SRC_FILE DEST_FILE

    INST_FILE_LIST : Specify a install file list.
    SRC_FILE       : Specify a source file.
    DEST_FILE      : Specify a destination file.

OPTIONS:
    -r ROOT
       Specify a target root directory.
    --help
       Display this help and exit.
EOF
}

use Common_pl::Cmd_v;

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
	"help" => sub {
		USAGE();exit 0;
	},
) } ) {
	print STDERR "-E $s_err\n";
	USAGE();exit 1;
}

# 第1引数のチェック
if ( not defined($ARGV[0]) ) {
	print STDERR "-E Missing INST_FILE_LIST argument\n";
	USAGE();exit 1;
} else {
	$INST_FILE_LIST = "$ARGV[0]";
	$INST_FILE_LIST = File::Spec->catfile("$INST_FILE_LIST");
	# 削除ファイルリストのチェック
	if ( not -f "$INST_FILE_LIST" ) {
		print STDERR "-E INST_FILE_LIST not a file -- \"$INST_FILE_LIST\"\n";
		USAGE();exit 1;
	}
}

# 第2引数のチェック
if ( not defined($ARGV[1]) ) {
	print STDERR "-E Missing SRC_FILE argument\n";
	USAGE();exit 1;
} else {
	$SRC_FILE = "$ARGV[1]";
	$SRC_FILE = File::Spec->catfile("$SRC_FILE");
	# 名前変更元ファイルのチェック
	if ( ( not -f "$root$SRC_FILE" ) and ( not -l "$root$SRC_FILE" ) ) {
		print STDERR "-E SRC_FILE not a file -- \"$root$SRC_FILE\"\n";
		USAGE();exit 1;
	}
}

# 第3引数のチェック
if ( not defined($ARGV[2]) ) {
	print STDERR "-E Missing DEST_FILE argument\n";
	USAGE();exit 1;
} else {
	$DEST_FILE = "$ARGV[2]";
	$DEST_FILE = File::Spec->catfile("$DEST_FILE");
	# 名前変更先ファイルのチェック
	if ( -e "$root$DEST_FILE" ) {
		print STDERR "-E DEST_FILE already exists -- \"$root$DEST_FILE\"\n";
		USAGE();exit 1;
	}
}

# 作業開始前処理
PRE_PROCESS();

# 処理開始メッセージの表示
print "\n";
print "-I File rename has started.\n";

#####################
# メインループ 開始 #
#####################
if ( not defined(open(INST_FILE_LIST, '<', "$INST_FILE_LIST")) ) {
	print STDERR "-E INST_FILE_LIST cannot open -- \"$INST_FILE_LIST\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(INST_FILE_LIST);
if ( not defined(open(INST_FILE_LIST_TMP, '>', "$INST_FILE_LIST_TMP")) ) {
	print STDERR "-E INST_FILE_LIST_TMP cannot open -- \"$INST_FILE_LIST_TMP\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(INST_FILE_LIST_TMP);
@lines = ();
foreach $line (<INST_FILE_LIST>) {
	chomp $line;
	# コメントと空行は無視
	if ( ( $line !~ m/^#/ ) and ( $line !~ m/^$/ ) ) {
		$line = File::Spec->catdir("$line");
		# インストールファイルリストに記載されているファイルの場合
		if ( "$line" eq "$SRC_FILE" ) {
			# インストールファイルリストに記載されているファイル名の変更
			$line = "$DEST_FILE";
			# システムにインストール済みのファイル名の変更
			$rc = CMD_V "rename('$root$SRC_FILE', '$root$DEST_FILE');";
			if ( $rc != 1 ) {
				print STDERR "-E Command has ended unsuccessfully.\n";
				POST_PROCESS();exit 1;
			}
			$rc = CMD_V "use Common_pl::Ls; LS(qw(-ald), '$root$DEST_FILE');";
			if ( $rc != 0 ) {
				print STDERR "-E Command has ended unsuccessfully.\n";
				POST_PROCESS();exit 1;
			}
		}
		push @lines, $line;
	}
}
foreach $line (sort(@lines)) {
	print INST_FILE_LIST_TMP "$line\n";
}
close(INST_FILE_LIST_TMP);
close(INST_FILE_LIST);
#####################
# メインループ 終了 #
#####################

# インストールファイルリストの比較
$rc = CMD_V "use Text::Diff; diff('$INST_FILE_LIST', '$INST_FILE_LIST_TMP', {qw(STYLE Unified)});";
print $rc;

# インストールファイルリストのコピー
$rc = CMD_V "use Common_pl::Cp; CP('$INST_FILE_LIST_TMP', '$INST_FILE_LIST');";
if ( $rc != 0 ) {
	print STDERR "-E Command has ended unsuccessfully.\n";
	POST_PROCESS();exit 1;
}

# 処理終了メッセージの表示
print "\n";
print "-I File rename has ended successfully.\n";
# 作業終了後処理
POST_PROCESS();exit 0;

