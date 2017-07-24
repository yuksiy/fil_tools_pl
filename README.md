# fil_tools_pl

## 概要

ファイルツールと簡易パッケージマネージャー (Perl)

このパッケージは、指定されたディレクトリの構造に従って、
ルートディレクトリ配下のファイルに対して各種の操作を行うツールを提供します。  
また、簡易的なパッケージマネージャーも含まれています。

## 使用方法

### fil_ll.pl, fil_backup.pl, fil_copy.pl

例えば、任意のディレクトリ「SRC_DIR」配下が以下のようになっている場合、

    # find SRC_DIR -print | xargs ls -ald
    drwxr-xr-x 3 root root 4096 Jul 11 16:54 SRC_DIR
    drwxr-xr-x 3 root root 4096 Jul 11 16:54 SRC_DIR/etc
    drwxr-xr-x 2 root root 4096 Jul 11 16:54 SRC_DIR/etc/any_dir
    -rw-r--r-- 1 root root    0 Jul 11 16:54 SRC_DIR/etc/any_dir/any_file
    lrwxrwxrwx 1 root root    8 Jul 11 16:54 SRC_DIR/etc/any_dir/any_link -> any_file

SRC_DIRの構造に従って、ルートディレクトリ配下のファイルを一覧表示します。

    # fil_ll.pl SRC_DIR

SRC_DIRの構造に従って、ルートディレクトリ配下のファイルをDEST_DIR配下にバックアップします。

    # mkdir DEST_DIR
    # fil_backup.pl SRC_DIR DEST_DIR

SRC_DIRの構造に従って、SRC_DIR配下のファイルをルートディレクトリ配下にコピーします。

    # fil_copy.pl SRC_DIR

fil_copy.plの実行結果を確認します。

    # fil_ll.pl SRC_DIR

### fil_pkg.pl

このツールで使用可能なパッケージファイルを作成します。

configureスクリプト付属パッケージの場合:

    $ PACKAGE=パッケージ名
    $ VERSION=バージョン
    $ SUFFIX=パッケージ識別用の任意文字列(例：debian.amd64)
    $ ./configure --prefix=/usr/local
    $ make
    $ make DESTDIR=`pwd`/${PACKAGE}-${VERSION}.${SUFFIX} install
    $ fakeroot tar -cvf ${PACKAGE}-${VERSION}.${SUFFIX}.tar ${PACKAGE}-${VERSION}.${SUFFIX}
      (Cygwin の場合は「fakeroot」を削ってください。)
    $ gzip ${PACKAGE}-${VERSION}.${SUFFIX}.tar

fil_pkg.pl対応パッケージの場合:

    (Debian の場合)
    $ fakeroot make ENVTYPE=debian pkg

    (Fedora の場合)
    $ fakeroot make ENVTYPE=fedora pkg

    (Cygwin の場合)
    $ make ENVTYPE=cygwin pkg

上記で作成したパッケージをインストールします。  
(旧バージョンのパッケージをインストール済みの場合は、
新バージョンをインストールする前にアンインストールしてください。)

    $ sudo fil_pkg.pl install -C 1 パッケージファイル名
      (Cygwin の場合は「sudo」を削ってください。)

インストール済みのパッケージ名を一覧表示します。

    $ fil_pkg.pl list

上記で一覧表示されたパッケージをアンインストールします。

    $ sudo fil_pkg.pl purge パッケージ名
      (Cygwin の場合は「sudo」を削ってください。)

***注意:***  
***以下のパッケージを上記の手順にてパッケージ化したものを、fil_pkg.plを使用してインストール・アンインストールすることは推奨しません。***  
***o 本パッケージ自身 (fil_tools_pl)***  
***o 本パッケージの依存パッケージ (下記参照)***

### その他

* 上記で紹介したツール、および本パッケージに含まれるその他のツールの詳細については、「ツール名 --help」を参照してください。

## 動作環境

OS:

* Linux
* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)
* perl
* [common_pl](https://github.com/yuksiy/common_pl)
* [Text-Diff](http://search.cpan.org/dist/Text-Diff/) (fil_diff.plを使用する場合のみ)
* bsdtar (fil_pkg.plを使用する場合のみ)

## インストール

ソースからインストールする場合:

    (Linux, Cygwin の場合)
    # make install

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/fil_tools_pl>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/fil_tools_pl/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2010-2017 Yukio Shiiya
