#!/usr/bin/perl

# ==============================================================================
#   機能
#     ディレクトリ構造に従ってファイルをコピーする
#     ディレクトリが存在しない場合はディレクトリも作成する
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
#my @MKDIR_OPTIONS = qw();
my @CP_OPTIONS = qw(-p -d);

my $root = "";							#初期状態が「空文字」でなければならない変数
my $file_list_dir = "";					#初期状態が「空文字」でなければならない変数
my $file_list;
my $FILE_LIST_SUFFIX = "list";
my $FLAG_OPT_FORCE = 0;
my $FLAG_OPT_YES = 0;
my $src_dir = "";

my ($src_file_count, $exist_dir_count, $not_exist_dir_count, $exist_overwrite_file_count, $exist_skip_file_count, $not_exist_file_count);
my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);
my ($mod_num, $mod_str);
my ($uname, $gname);
my %uname = ();
my %gname = ();


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
    fil_copy.pl [OPTIONS ...] SRC_DIR

    SRC_DIR  : Specify a directory storing files for copy.

OPTIONS:
    -r ROOT
       Specify a target root directory.
    -l FILE_LIST_DIR
       Specify a directory where the file list of the copied files is stored.
    -f (force)
       execute 'cp' command with '-f' option.
    -y (yes)
       Suppresses prompting to confirm you want to overwrite an
       existing destination file.
    --help
       Display this help and exit.
EOF
}

use Common_pl::Cmd_v;
use Common_pl::Yesno;

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
	"l=s" => sub {
		$file_list_dir = "$_[1]";
		$file_list_dir = File::Spec->catdir("$file_list_dir");
		# FILEリスト格納ディレクトリのチェック
		if ( not -d "$file_list_dir" ) {
			print STDERR "-E FILE_LIST_DIR not a directory -- \"$file_list_dir\"\n";
			USAGE();exit 1;
		}
	},
	"f" => sub {
		$FLAG_OPT_FORCE = 1;
		push @CP_OPTIONS, "-f";
	},
	"y" => \$FLAG_OPT_YES,
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
	# コピー対象ファイル格納ディレクトリのチェック
	if ( not -d "$src_dir" ) {
		print STDERR "-E SRC_DIR not a directory -- \"$src_dir\"\n";
		USAGE();exit 1;
	}
}

# 変数定義(引数のチェック後)
if ( "$file_list_dir" eq "" ) {
	$file_list = "";
} else {
	$file_list = File::Spec->catfile("$file_list_dir", basename("$src_dir") . ".$FILE_LIST_SUFFIX");
	# ファイルリストのチェック
	if ( -f "$file_list" ) {
		print STDERR "-W \"$file_list\" file exists\n";
		# YES オプションが指定されていない場合
		if ( not $FLAG_OPT_YES ) {
			# 削除確認
			print STDERR "-Q Delete?\n";
			$rc = YESNO();
			# NO の場合
			if ( $rc != 0 ) {
				print "-I Interrupted.\n";
				exit 0;
			}
		}
		print STDERR "-W Deleting...\n";
		# ファイルの削除
		$rc = CMD_V "unlink('$file_list');";
		if ( $rc != 1 ) {
			print STDERR "-E Command has ended unsuccessfully.\n";
			POST_PROCESS();exit 1;
		}
	}
}

# 作業開始前処理
PRE_PROCESS();

# コピー対象ファイル格納ディレクトリ内のFINDリストの取得
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
print "-I File copy has started.\n";

#####################
# メインループ 開始 #
#####################
$src_file_count = 0;
find(sub {
	if ( ( (-d) and (not -l) ) or ( (-f) or (-l) ) ) {
		$File::Find::name =~ s?^\Q$src_dir\E??;
		if ( $File::Find::name !~ m/^$/ ) {
			$src_file_count = $src_file_count + 1;
		}
	}
}, "$src_dir");

$exist_dir_count = 0;
$not_exist_dir_count = 0;

$exist_overwrite_file_count = 0;
$exist_skip_file_count = 0;
$not_exist_file_count = 0;

if ( not defined(open(FIND_LIST, '<', "$FIND_LIST")) ) {
	print STDERR "-E FIND_LIST cannot open -- \"$FIND_LIST\": $!\n";
	POST_PROCESS();exit 1;
}
#binmode(FIND_LIST);
if ( not "$file_list" eq "" ) {
	if ( not defined(open(file_list, '>', "$file_list")) ) {
		print STDERR "-E file_list cannot open -- \"$file_list\": $!\n";
		POST_PROCESS();exit 1;
	}
}
#binmode(file_list);
while ($line = <FIND_LIST>) {
	chomp $line;
	# ディレクトリの処理
	if ( ( -d "$src_dir$line" ) and ( not -l "$src_dir$line" ) ) {
		# 既存ディレクトリの場合
		if ( ( -d "$root$line" ) and ( not -l "$root$line" ) ) {
			$exist_dir_count = $exist_dir_count + 1;
			if ( not "$file_list" eq "" ) { print file_list "$line\n"; }
			print STDERR "-W \"$root$line\" directory exists, skipped\n";
		# 既存ディレクトリでない場合
		} else {
			$not_exist_dir_count = $not_exist_dir_count + 1;
			if ( not "$file_list" eq "" ) { print file_list "$line\n"; }
			# 作成対象ディレクトリのモード・オーナ・グループ取得
			($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = lstat("$src_dir$line");
			$mod_num = $mode & 07777;
			$mod_str = sprintf("%4lo", $mod_num);
			if ( $^O !~ m#^(?:MSWin32)$# ) {
				# uname
				if ( defined($uname{$uid}) ) {
					$uname = $uname{$uid};
				} else {
					$uname = getpwuid($uid);
					if ( defined($uname) ) { $uname{$uid} = $uname; } else { $uname = $uid; }
				}
				# gname
				if ( defined($gname{$gid}) ) {
					$gname = $gname{$gid};
				} else {
					$gname = getgrgid($gid);
					if ( defined($gname) ) { $gname{$gid} = $gname; } else { $gname = $gid; }
				}
			}
			# ディレクトリの作成
			$rc = CMD_V "use File::Path; mkpath('$root$line');";
			if ( $rc != 1 ) {
				print STDERR "-E Command has ended unsuccessfully.\n";
				POST_PROCESS();exit 1;
			}
			if ( $^O !~ m#^(?:MSWin32)$# ) {
				# ディレクトリのオーナ・グループ設定
				$rc = CMD_V "chown($uid, $gid, '$root$line');  # OWNER = $uname:$gname";
				if ( $rc != 1 ) {
					print STDERR "-E Command has ended unsuccessfully.\n";
					POST_PROCESS();exit 1;
				}
				# ディレクトリのモード設定
				$rc = CMD_V "chmod($mod_num, '$root$line');  # MODE = $mod_str";
				if ( $rc != 1 ) {
					print STDERR "-E Command has ended unsuccessfully.\n";
					POST_PROCESS();exit 1;
				}
			}
		}
		next;
	}
	# ファイルの処理
	if ( ( -f "$src_dir$line" ) or ( -l "$src_dir$line" ) ) {
		# 既存ファイルの場合
		if ( ( -f "$root$line" ) or ( -l "$root$line" ) ) {
			print STDERR "-W \"$root$line\" file exists\n";
			# YES オプションが指定されていない場合
			if ( not $FLAG_OPT_YES ) {
				# 上書き確認
				print STDERR "-Q Overwrite?\n";
				$rc = YESNO();
				# YES の場合
				if ( $rc == 0 ) {
					$exist_overwrite_file_count = $exist_overwrite_file_count + 1;
					if ( not "$file_list" eq "" ) { print file_list "$line\n"; }
					print STDERR "-W Overwriting...\n";
				# NO の場合
				} else {
					$exist_skip_file_count = $exist_skip_file_count + 1;
					if ( not "$file_list" eq "" ) { print file_list "$line\n"; }
					print STDERR "-W Skipping...\n";
					next;
				}
			# YES オプションが指定されている場合
			} else {
				$exist_overwrite_file_count = $exist_overwrite_file_count + 1;
				if ( not "$file_list" eq "" ) { print file_list "$line\n"; }
				print STDERR "-W Overwriting...\n";
			}
		# 既存ファイルでない場合
		} else {
			$not_exist_file_count = $not_exist_file_count + 1;
			if ( not "$file_list" eq "" ) { print file_list "$line\n"; }
			print "-I New file -- \"$root$line\"\n";
		}
		# ファイルのコピー
		$rc = CMD_V "use Common_pl::Cp; CP(qw(@CP_OPTIONS), '$src_dir$line', '$root$line');";
		if ( $rc != 0 ) {
			print STDERR "-E Command has ended unsuccessfully.\n";
			POST_PROCESS();exit 1;
		}
	}
}
if ( not "$file_list" eq "" ) {
	close(file_list);
}
close(FIND_LIST);
#####################
# メインループ 終了 #
#####################

# 統計の表示
print "\n";
print "Total of files in \"$src_dir\" : $src_file_count\n";
print "----------------------------------------\n";
print "Total of existing directories  : $exist_dir_count\n";
print "Total of maked new directories : $not_exist_dir_count\n";
print "----------------------------------------\n";
print "Total of copied new files : $not_exist_file_count\n";
print "Total of overwrited files : $exist_overwrite_file_count\n";
print "Total of skipped files    : $exist_skip_file_count\n";

# 処理終了メッセージの表示
if ( ( $exist_dir_count + $not_exist_dir_count + $not_exist_file_count + $exist_overwrite_file_count + $exist_skip_file_count ) != $src_file_count ) {
	print "\n";
	print STDERR "-E Total of copied files did not match.\n";
	print STDERR "-E File copy has ended unsuccessfully.\n";
	POST_PROCESS();exit 1;
} else {
	print "\n";
	print "-I File copy has ended successfully.\n";
	# 作業終了後処理
	POST_PROCESS();exit 0;
}

