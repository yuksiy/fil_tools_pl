#!/usr/bin/perl

# ==============================================================================
#   機能
#     Simple package manager for fil_tools
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
use Getopt::Long qw(GetOptionsFromArray GetOptionsFromString :config gnu_getopt no_ignore_case);
use IO::Handle;
use IPC::Cmd qw(QUOTE);

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
my $LOCALSTATEDIR = "/var/local";

my $BSDTAR = "bsdtar";
my $BSDTAR_OPTIONS_INT_LIST = "-t";
my $BSDTAR_OPTIONS_INT_EXTRACT = "-x";

my $BSDTAR_CHANGE_DIR_OPT = "-C";

my $PROJ = "fil_tools";

my $FIL_DIFF   = File::Spec->catfile($SCRIPT_ROOT, "fil_diff.pl");
my $FIL_LL     = File::Spec->catfile($SCRIPT_ROOT, "fil_ll.pl");
my $FIL_BACKUP = File::Spec->catfile($SCRIPT_ROOT, "fil_backup.pl");
my $FIL_COPY   = File::Spec->catfile($SCRIPT_ROOT, "fil_copy.pl");
my $FIL_RM     = File::Spec->catfile($SCRIPT_ROOT, "fil_rm.pl");
my $FIL_RENAME = File::Spec->catfile($SCRIPT_ROOT, "fil_rename.pl");

my $FIL_DIFF_OPTIONS = "";
my $FIL_LL_OPTIONS = "";
my $FIL_BACKUP_OPTIONS = "";
my $FIL_COPY_OPTIONS = "-f -y";
my $FIL_RM_OPTIONS = "";
my $FIL_RENAME_OPTIONS = "";

my $pkg_file = "";						#初期状態が「空文字」でなければならない変数
my $pkg_name = "";						#初期状態が「空文字」でなければならない変数
my $src_file = "";						#初期状態が「空文字」でなければならない変数
my $dest_file = "";						#初期状態が「空文字」でなければならない変数

my $PERL = "";
my $PERL_OPTIONS = "";
my $BSDTAR_OPTIONS_EXT = "";			#初期状態が「空文字」でなければならない変数
my $BSDTAR_OPTIONS_EXT_ORG = "";		#初期状態が「空文字」でなければならない変数
my $CUT_DIRS_NUM = "0";
my $root = "";							#初期状態が「空文字」でなければならない変数
my $INFO_DIR_SUFFIX = File::Spec->catdir("$LOCALSTATEDIR", "lib", "$PROJ", "info");
my $FILE_LIST_SUFFIX = "list";
my $diff_dir = "";						#初期状態が「空文字」でなければならない変数
my $LL_MODE = "";						#初期状態が「空文字」でなければならない変数
my $bkup_dir = "";						#初期状態が「空文字」でなければならない変数
my $FLAG_OPT_NOHEADER = 0;
my $FLAG_OPT_YES = 0;

my ($action, $info_dir);
my ($pkg_file_base, $pkg_file_dir, $ARC_TYPE, $pkg_dir, $pkg_dir_wk);
my ($ARC, $ARC_OPTIONS, $ARC_CHANGE_DIR_OPT);
my @cmd_line;
my $cmd_line;
my ($count, $cut_dir, $file, $file_dest);

my $DEBUG = 0;
my $TMP_DIR = File::Spec->tmpdir();
my $SCRIPT_TMP_DIR = File::Spec->catdir($TMP_DIR, "$SCRIPT_NAME.$PID");

my $rc = 0;

######################################################################
# 関数定義
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
    fil_pkg.pl ACTION [OPTIONS ...] [ARGUMENTS ...]

ACTIONS:
    i|install [OPTIONS ...] PKG_FILE
       Install a package.
    P|purge [OPTIONS ...] PKG_NAME
       Remove a package include its configuration files installed with it.
    c|contents [OPTIONS ...] PKG_FILE
       List contents of a package file.
    l|list [OPTIONS ...]
       List package names installed to the system.
    L|listfiles [OPTIONS ...] PKG_NAME
       List files installed to the system from a package file.
    renamefile [OPTIONS ...] PKG_NAME SRC_FILE DEST_FILE
       Rename file installed to the system from a package file.

ARGUMENTS:
    PKG_FILE : Specify a package file.
       Following package file types are supported now.
         *.tar
         *.tar.gz|*.tgz
         *.tar.bz2|*.tbz2
         *.tar.xz
         *.tar.lzma
         *.zip
    PKG_NAME  : Specify a package name installed to the system.
    SRC_FILE  : Specify a source file.
    DEST_FILE : Specify a destination file.

OPTIONS:
    --perl="PERL"
       Specify perl command to execute.
       (Available with: install, purge, renamefile)
    --perl-options="PERL_OPTIONS ..."
       Specify options which execute perl command with.
       (Available with: install, purge, renamefile)
    --bsdtar-options="BSDTAR_OPTIONS ..."
       Specify options which execute bsdtar command with.
       Following options are supported now.
         -o|--no-same-owner
         --no-same-permissions
         --numeric-owner
         -p|--same-permissions|--preserve-permissions
         --same-owner
         -v|--verbose
       Other options are used internally or not supported.
       See also bsdtar(1) or "bsdtar --help" for the further information on
       each option.
       (Available with: install, contents)
    -C CUT_DIRS_NUM (cut-dirs-number)
       Specify the number of package directory components you want to ignore.
       (Available with: install)
    -r ROOT
       Specify a target root directory.
       (Available with: install, purge, list, listfiles, renamefile)
    -d DIFF_DIR
       Run fil_diff.pl before fil_copy.pl.
       Specify an EMPTY directory for storing comparison result files.
       (Available with: install)
    -l LL_MODE
       LL_MODE : {before|after|both}
       Run fil_ll.pl before|after|both fil_copy.pl.
       (Available with: install)
    -b BKUP_DIR
       Run fil_backup.pl before fil_copy.pl.
       Specify an EMPTY directory for storing backed-up files.
       (Available with: install)
    --no-header
       Specifies that the column header should not be displayed in the output.
       (Available with: list)
    -y (yes)
       Suppresses prompting to confirm you want to continue to do the
       specified action.
       (Available with: install, purge)
    --help
       Display this help and exit.
EOF
}

use Common_pl::Cmd_v;
use Common_pl::Is_dir_empty;
use Common_pl::Is_numeric;
use Common_pl::Yesno;

# 処理継続確認
sub CALL_YESNO {
	print "-Q Continue?\n";
	#print "-Q 続行しますか？\n";
	$rc = YESNO;
	if ( $rc != 0 ) {
		# 作業終了後処理
		print "-I Interrupted.\n";
		#print "-I 中断します\n";
		POST_PROCESS();exit 0;
	}
}

######################################################################
# メインルーチン
######################################################################

# ACTIONのチェック
if ( not defined($ARGV[0]) ) {
	print STDERR "-E Missing ACTION\n";
	USAGE();exit 1;
} else {
	if ( "$ARGV[0]" =~ m#^(?:i|install|P|purge|c|contents|l|list|L|listfiles|renamefile)$# ) {
		$action = "$ARGV[0]";
	} else {
		print STDERR "-E Invalid ACTION -- \"$ARGV[0]\"\n";
		USAGE();exit 1;
	}
}

# ACTIONをシフト
shift @ARGV;

# オプションのチェック
if ( not eval { GetOptionsFromArray( \@ARGV,
	"perl=s" => sub {
		$PERL = "$_[1]";
		$PERL = File::Spec->catfile("$PERL");
	},
	"perl-options=s" => sub {
		$PERL_OPTIONS = "$_[1]";
	},
	"bsdtar-options=s" => sub {
		$BSDTAR_OPTIONS_EXT_ORG = "$_[1]";
	},
	"C=s" => sub {
		# 指定された文字列が数値か否かのチェック
		$rc = IS_NUMERIC("$_[1]");
		if ( $rc != 0 ) {
			print STDERR "-E Argument to \"-$_[0]\" not numeric -- \"$_[1]\"\n";
			USAGE();exit 1;
		}
		if ( "-$_[0]" eq "-C" ) {
			$CUT_DIRS_NUM = "$_[1]";
		}
	},
	"r=s" => sub {
		$root = "$_[1]";
		$root = File::Spec->catdir("$root");
	},
	"d=s" => sub {
		$diff_dir = "$_[1]";
		$diff_dir = File::Spec->catdir("$diff_dir");
		# diff結果ファイル格納ディレクトリのチェック
		if ( not -d "$diff_dir" ) {
			print STDERR "-E DIFF_DIR not a directory -- \"$diff_dir\"\n";
			USAGE();exit 1;
		}
		# diff結果ファイル格納ディレクトリが空ディレクトリであることのチェック
		$rc = IS_DIR_EMPTY("$diff_dir");
		if ( $rc != 0 ) {
			print STDERR "-E DIFF_DIR directory not empty -- \"$diff_dir\"\n";
			USAGE();exit 1;
		}
	},
	"l=s" => sub {
		if ( "$_[1]" =~ m#^(?:before|after|both)$# ) {
			$LL_MODE = "$_[1]";
		} else {
			print STDERR "-E Argument to \"-$_[0]\" is invalid -- \"$_[1]\"\n";
			USAGE();exit 1;
		}
	},
	"b=s" => sub {
		$bkup_dir = "$_[1]";
		$bkup_dir = File::Spec->catdir("$bkup_dir");
		# バックアップディレクトリのチェック
		if ( not -d "$bkup_dir" ) {
			print STDERR "-E BKUP_DIR not a directory -- \"$bkup_dir\"\n";
			USAGE();exit 1;
		}
		# バックアップディレクトリが空ディレクトリであることのチェック
		$rc = IS_DIR_EMPTY("$bkup_dir");
		if ( $rc != 0 ) {
			print STDERR "-E BKUP_DIR directory not empty -- \"$bkup_dir\"\n";
			USAGE();exit 1;
		}
	},
	"no-header" => \$FLAG_OPT_NOHEADER,
	"y" => \$FLAG_OPT_YES,
	"help" => sub {
		USAGE();exit 0;
	},
) } ) {
	print STDERR "-E $s_err\n";
	USAGE();exit 1;
}

# オプションのチェック (BSDTAR_OPTIONS_EXT)
if ( not "$BSDTAR_OPTIONS_EXT_ORG" eq "" ) {
	if ( not eval { GetOptionsFromString( $BSDTAR_OPTIONS_EXT_ORG,
		"o"                     => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT -$_[0]"; },
		"p"                     => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT -$_[0]"; },
		"v"                     => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT -$_[0]"; },
		"no-same-owner"         => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT --$_[0]"; },
		"no-same-permissions"   => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT --$_[0]"; },
		"numeric-owner"         => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT --$_[0]"; },
		"same-permissions"      => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT --$_[0]"; },
		"preserve-permissions"  => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT --$_[0]"; },
		"same-owner"            => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT --$_[0]"; },
		"verbose"               => sub { $BSDTAR_OPTIONS_EXT = "$BSDTAR_OPTIONS_EXT --$_[0]"; },
	) } ) {
		print STDERR "-E $s_err\n";
		USAGE();exit 1;
	}
}

# 引数のチェック
if ( $action =~ m#^(?:i|install|c|contents)$# ) {
	# 第1引数のチェック
	if ( not defined($ARGV[0]) ) {
		print STDERR "-E Missing PKG_FILE argument\n";
		USAGE();exit 1;
	} else {
		$pkg_file = "$ARGV[0]";
		$pkg_file = File::Spec->catfile("$pkg_file");
		# パッケージファイルのチェック
		if ( not -f "$pkg_file" ) {
			print STDERR "-E PKG_FILE not a file -- \"$pkg_file\"\n";
			USAGE();exit 1;
		}
	}
} elsif ( $action =~ m#^(?:P|purge|L|listfiles|renamefile)$# ) {
	# 第1引数のチェック
	if ( not defined($ARGV[0]) ) {
		print STDERR "-E Missing PKG_NAME argument\n";
		USAGE();exit 1;
	} else {
		$pkg_name = "$ARGV[0]";
		# パッケージ名のチェック
		#該当ACTIONの実行を以って本チェックとするため、該当作業なし
	}
	if ( $action =~ m#^(?:renamefile)$# ) {
		# 第2引数のチェック
		if ( not defined($ARGV[1]) ) {
			print STDERR "-E Missing SRC_FILE argument\n";
			USAGE();exit 1;
		} else {
			$src_file = "$ARGV[1]";
			$src_file = File::Spec->catfile("$src_file");
			# 元ファイルのチェック
			#該当ACTIONの実行を以って本チェックとするため、該当作業なし
		}
		# 第3引数のチェック
		if ( not defined($ARGV[2]) ) {
			print STDERR "-E Missing DEST_FILE argument\n";
			USAGE();exit 1;
		} else {
			$dest_file = "$ARGV[2]";
			$dest_file = File::Spec->catfile("$dest_file");
			# 先ファイルのチェック
			#該当ACTIONの実行を以って本チェックとするため、該当作業なし
		}
	}
}

# 変数定義(引数のチェック後)
$info_dir = "$root" . "$INFO_DIR_SUFFIX";
$FIL_DIFF_OPTIONS = ( ($FIL_DIFF_OPTIONS eq "") ? "" : "$FIL_DIFF_OPTIONS " ) . ( ($root eq "") ? "" : "-r " . QUOTE . "$root" . QUOTE );
$FIL_LL_OPTIONS = ( ($FIL_LL_OPTIONS eq "") ? "" : "$FIL_LL_OPTIONS " ) . ( ($root eq "") ? "" : "-r " . QUOTE . "$root" . QUOTE );
$FIL_BACKUP_OPTIONS = ( ($FIL_BACKUP_OPTIONS eq "") ? "" : "$FIL_BACKUP_OPTIONS " ) . ( ($root eq "") ? "" : "-r " . QUOTE . "$root" . QUOTE );
$FIL_COPY_OPTIONS = ( ($FIL_COPY_OPTIONS eq "") ? "" : "$FIL_COPY_OPTIONS " ) . ( ($root eq "") ? "" : "-r " . QUOTE . "$root" . QUOTE . " " ) . "-l " . QUOTE . "$info_dir" . QUOTE;
$FIL_RM_OPTIONS = ( ($FIL_RM_OPTIONS eq "") ? "" : "$FIL_RM_OPTIONS " ) . ( ($root eq "") ? "" : "-r " . QUOTE . "$root" . QUOTE );
$FIL_RENAME_OPTIONS = ( ($FIL_RENAME_OPTIONS eq "") ? "" : "$FIL_RENAME_OPTIONS " ) . ( ($root eq "") ? "" : "-r " . QUOTE . "$root" . QUOTE );

# FILEリスト格納ディレクトリのチェック
if ( "$ARGV[0]" =~ m#^(?:i|install|P|purge|l|list|L|listfiles|renamefile)$# ) {
	if ( not -d "$info_dir" ) {
		print STDERR "-E INFO_DIR not a directory -- \"$info_dir\"\n";
		USAGE();exit 1;
	}
} else {
	# 何もしない
}

# PKG_FILE 引数が指定されている場合
if ( not "$pkg_file" eq "" ) {
	($pkg_file_base, $pkg_file_dir) = fileparse($pkg_file);
	# パッケージファイル形式の判定
	if ( "$pkg_file_base" =~ m#(?:\.tar)$# ) {
		$ARC_TYPE = "BSDTAR";
		$pkg_name = $pkg_file_base;
		$pkg_name =~ s#(?:\.tar)$##;
	} elsif ( "$pkg_file_base" =~ m#(?:\.tar\.gz|\.tgz)$# ) {
		$ARC_TYPE = "BSDTAR";
		$pkg_name = $pkg_file_base;
		$pkg_name =~ s#(?:\.tar\.gz|\.tgz)$##;
	} elsif ( "$pkg_file_base" =~ m#(?:\.tar\.bz2|\.tbz2)$# ) {
		$ARC_TYPE = "BSDTAR";
		$pkg_name = $pkg_file_base;
		$pkg_name =~ s#(?:\.tar\.bz2|\.tbz2)$##;
	} elsif ( "$pkg_file_base" =~ m#(?:\.tar\.xz)$# ) {
		$ARC_TYPE = "BSDTAR";
		$pkg_name = $pkg_file_base;
		$pkg_name =~ s#(?:\.tar\.xz)$##;
	} elsif ( "$pkg_file_base" =~ m#(?:\.tar\.lzma)$# ) {
		$ARC_TYPE = "BSDTAR";
		$pkg_name = $pkg_file_base;
		$pkg_name =~ s#(?:\.tar\.lzma)$##;
	} elsif ( "$pkg_file_base" =~ m#(?:\.zip)$# ) {
		$ARC_TYPE = "BSDTAR";
		$pkg_name = $pkg_file_base;
		$pkg_name =~ s#(?:\.zip)$##;
	} else {
		print STDERR "-E Invalid package file type -- \"$pkg_file_base\"\n";
		USAGE();exit 1;
	}
	$pkg_dir = File::Spec->catdir($SCRIPT_TMP_DIR, "$pkg_name");
	$pkg_dir_wk = File::Spec->catdir($SCRIPT_TMP_DIR, "pkg_dir.wk");

	# ARC の初期化
	# ARC_OPTIONS,ARC_CHANGE_DIR_OPT の初期化
	if ( $ARC_TYPE =~ m#^BSDTAR$# ) {
		$ARC = "$BSDTAR";
		if ( $action =~ m#^(?:i|install)$# ) {
			$ARC_OPTIONS = "$BSDTAR_OPTIONS_INT_EXTRACT";
		} elsif ( $action =~ m#^(?:c|contents)$# ) {
			$ARC_OPTIONS = "$BSDTAR_OPTIONS_INT_LIST";
		}
		$ARC_OPTIONS = "$ARC_OPTIONS" . "$BSDTAR_OPTIONS_EXT" . " -f";
		$ARC_CHANGE_DIR_OPT = "$BSDTAR_CHANGE_DIR_OPT";
	}
}

# 作業開始前処理
PRE_PROCESS();

#####################
# メインループ 開始 #
#####################

if ( $action =~ m#^(?:i|install)$# ) {
	# 処理開始メッセージの表示
	print "\n";
	print "-I Package install has started.\n";

	# パッケージ一時ディレクトリの作成
	mkpath("$pkg_dir_wk");
	mkpath("$pkg_dir");

	# パッケージファイルの展開
	print "\n";print "==============================================================================\n";
	$cmd_line = "$ARC $ARC_OPTIONS " . QUOTE . "$pkg_file" . QUOTE . " $ARC_CHANGE_DIR_OPT " . QUOTE . "$pkg_dir_wk" . QUOTE;
	$rc = SYS_V "$cmd_line";
	if ( $rc != 0 ) {
		print STDERR "-E Command has ended unsuccessfully.\n";
		POST_PROCESS();exit 1;
	}

	# 省略ディレクトリ(cut_dir)の処理
	$count = 0;
	$cut_dir = "";
	while ($count < $CUT_DIRS_NUM) {
		$cut_dir = File::Spec->catdir("$cut_dir", "*");
		$count = $count + 1;
	}
	print "\n";print "==============================================================================\n";
	foreach $file (glob("$pkg_dir_wk$cut_dir/{*,.*}")) {
		if ( ( "$file" !~ m#/\.$# ) and ( "$file" !~ m#/\.\.$# ) ) {
			$file = File::Spec->catfile("$file");
			$file_dest = File::Spec->catfile($pkg_dir, basename("$file"));
			$rc = CMD_V "rename('$file', '$file_dest');";
			if ( $rc != 1 ) {
				print STDERR "-E Command has ended unsuccessfully.\n";
				POST_PROCESS();exit 1;
			}
		}
	}

	# DIFF_DIR オプションが指定されている場合
	if ( not "$diff_dir" eq "" ) {
		# fil_diff.pl の実行
		print "\n";print "==============================================================================\n";
		@cmd_line = grep {not m#^$#} ($PERL, $PERL_OPTIONS, $FIL_DIFF, $FIL_DIFF_OPTIONS);
		push @cmd_line, (QUOTE . "$pkg_dir" . QUOTE, QUOTE . "$diff_dir" . QUOTE);
		$rc = SYS_V "@cmd_line";
		if ( $rc != 0 ) {
			print STDERR "-E Command has ended unsuccessfully.\n";
			POST_PROCESS();exit 1;
		}
	}

	# LL_MODE オプションが指定されている場合
	if ( ( "$LL_MODE" eq "before" ) or ( "$LL_MODE" eq "both" ) ) {
		# fil_ll.pl の実行
		print "\n";print "==============================================================================\n";
		@cmd_line = grep {not m#^$#} ($PERL, $PERL_OPTIONS, $FIL_LL, $FIL_LL_OPTIONS);
		push @cmd_line, (QUOTE . "$pkg_dir" . QUOTE);
		$rc = SYS_V "@cmd_line";
		if ( $rc != 0 ) {
			print STDERR "-E Command has ended unsuccessfully.\n";
			POST_PROCESS();exit 1;
		}
	}

	# BKUP_DIR オプションが指定されている場合
	if ( not "$bkup_dir" eq "" ) {
		# fil_backup.pl の実行
		print "\n";print "==============================================================================\n";
		@cmd_line = grep {not m#^$#} ($PERL, $PERL_OPTIONS, $FIL_BACKUP, $FIL_BACKUP_OPTIONS);
		push @cmd_line, (QUOTE . "$pkg_dir" . QUOTE, QUOTE . "$bkup_dir" . QUOTE);
		$rc = SYS_V "@cmd_line";
		if ( $rc != 0 ) {
			print STDERR "-E Command has ended unsuccessfully.\n";
			POST_PROCESS();exit 1;
		}
	}

	# 処理継続確認
	print "-I The following packages will be INSTALLED:\n";
	print "     $pkg_name\n";
	# YES オプションが指定されていない場合
	if ( not $FLAG_OPT_YES ) {
		CALL_YESNO();
	}

	# fil_copy.pl の実行
	print "\n";print "==============================================================================\n";
	@cmd_line = grep {not m#^$#} ($PERL, $PERL_OPTIONS, $FIL_COPY, $FIL_COPY_OPTIONS);
	push @cmd_line, (QUOTE . "$pkg_dir" . QUOTE);
	$rc = SYS_V "@cmd_line";
	if ( $rc != 0 ) {
		print STDERR "-E Command has ended unsuccessfully.\n";
		POST_PROCESS();exit 1;
	}

	# LL_MODE オプションが指定されている場合
	if ( ( "$LL_MODE" eq "after" ) or ( "$LL_MODE" eq "both" ) ) {
		# fil_ll.pl の実行
		print "\n";print "==============================================================================\n";
		@cmd_line = grep {not m#^$#} ($PERL, $PERL_OPTIONS, $FIL_LL, $FIL_LL_OPTIONS);
		push @cmd_line, (QUOTE . "$pkg_dir" . QUOTE);
		$rc = SYS_V "@cmd_line";
		if ( $rc != 0 ) {
			print STDERR "-E Command has ended unsuccessfully.\n";
			POST_PROCESS();exit 1;
		}
	}

	# 処理終了メッセージの表示
	print "\n";
	print "-I Package install has ended successfully.\n";
	# 作業終了後処理
	POST_PROCESS();exit 0;
} elsif ( $action =~ m#^(?:P|purge)$# ) {
	# 処理継続確認
	print "-I The following packages will be REMOVED:\n";
	print "     $pkg_name\n";
	# YES オプションが指定されていない場合
	if ( not $FLAG_OPT_YES ) {
		CALL_YESNO();
	}

	# 処理開始メッセージの表示
	print "\n";
	print "-I Package removal has started.\n";

	# fil_rm.pl の実行
	print "\n";print "==============================================================================\n";
	$file = File::Spec->catfile($info_dir, "$pkg_name.$FILE_LIST_SUFFIX");
	@cmd_line = grep {not m#^$#} ($PERL, $PERL_OPTIONS, $FIL_RM, $FIL_RM_OPTIONS);
	push @cmd_line, (QUOTE . "$file" . QUOTE);
	$rc = SYS_V "@cmd_line";
	if ( $rc != 0 ) {
		print STDERR "-E Command has ended unsuccessfully.\n";
		POST_PROCESS();exit 1;
	}

	# パッケージファイル一覧の削除
	#print "\n";print "==============================================================================\n";
	print "\n";
	$file = File::Spec->catfile($info_dir, "$pkg_name.$FILE_LIST_SUFFIX");
	$rc = CMD_V "unlink('$file');";
	if ( $rc != 1 ) {
		print STDERR "-E Command has ended unsuccessfully.\n";
		POST_PROCESS();exit 1;
	}

	# 処理終了メッセージの表示
	print "\n";
	print "-I Package removal has ended successfully.\n";
	# 作業終了後処理
	POST_PROCESS();exit 0;
} elsif ( $action =~ m#^(?:c|contents)$# ) {
	# List contents of a package file.
	# パッケージファイル内容の一覧表示
	#print "\n";print "==============================================================================\n";
	$cmd_line = "$ARC $ARC_OPTIONS " . QUOTE . "$pkg_file" . QUOTE;
	$rc = SYS_V "$cmd_line";
	if ( $rc != 0 ) {
		print STDERR "-E Command has ended unsuccessfully.\n";
		POST_PROCESS();exit 1;
	}

	# 作業終了後処理
	POST_PROCESS();exit 0;
} elsif ( $action =~ m#^(?:l|list)$# ) {
	# List package names installed to the system.
	# システムにインストール済みのパッケージ名の一覧表示
	#print "\n";print "==============================================================================\n";
	# NOHEADER オプションが指定されていない場合
	if ( $FLAG_OPT_NOHEADER == 0 ) {
		print "Name\n";
		print "==============================================================================\n";
	}
	# ディレクトリのオープン
	if ( not defined(opendir(DH, "$info_dir")) ) {
		print STDERR "-E INFO_DIR cannot open -- \"$info_dir\": $!\n";
		POST_PROCESS();exit 1;
	}
	# ディレクトリ内ファイルのループ
	foreach $file (sort(readdir(DH))) {
		if ( $file =~ m#^[^\.].*\.\Q$FILE_LIST_SUFFIX\E$# ) {
			$pkg_name = $file;
			$pkg_name =~ s?^([^\.].*)\.\Q$FILE_LIST_SUFFIX\E$?$1?;
			print "$pkg_name\n";
		}
	}
	# ディレクトリのクローズ
	closedir(DH);

	# 作業終了後処理
	POST_PROCESS();exit 0;
} elsif ( $action =~ m#^(?:L|listfiles)$# ) {
	# List files installed to the system from a package file.
	# パッケージファイルからシステムにインストール済みのファイルの一覧表示
	#print "\n";print "==============================================================================\n";
	$file = File::Spec->catfile($info_dir, "$pkg_name.$FILE_LIST_SUFFIX");
	$rc = CMD_V "use Common_pl::Cat; CAT('$file');";
	if ( $rc != 0 ) {
		print STDERR "-E Command has ended unsuccessfully.\n";
		POST_PROCESS();exit 1;
	}

	# 作業終了後処理
	POST_PROCESS();exit 0;
} elsif ( $action =~ m#^(?:renamefile)$# ) {
	# fil_rename.pl の実行
	print "\n";print "==============================================================================\n";
	$file = File::Spec->catfile($info_dir, "$pkg_name.$FILE_LIST_SUFFIX");
	@cmd_line = grep {not m#^$#} ($PERL, $PERL_OPTIONS, $FIL_RENAME, $FIL_RENAME_OPTIONS);
	push @cmd_line, (QUOTE . "$file" . QUOTE, QUOTE . "$src_file" . QUOTE, QUOTE . "$dest_file" . QUOTE);
	$rc = SYS_V "@cmd_line";
	if ( $rc != 0 ) {
		print STDERR "-E Command has ended unsuccessfully.\n";
		POST_PROCESS();exit 1;
	}

	# 作業終了後処理
	POST_PROCESS();exit 0;
}

#####################
# メインループ 終了 #
#####################

