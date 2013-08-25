---
title: "try of rbenv"
date: 2012-05-28 00:16
comments: true
tags: [Ruby, Development]
---

# rbenvを使うように改めてみた。

## rbenvを使おうと思ったきっかけとか

…nodeであれば[nave](https://github.com/isaacs/nave)や[nvm](https://github.com/creationix/nvm)、pythonであれば
[virtualenv](http://pypi.python.org/pypi/virtualenv)(切り替えというより環境を作るだけだけど)、
[pythonbrew](https://github.com/utahta/pythonbrew)、perlなら[perlbrew](http://perlbrew.pl/)があるように
バージョン管理及び現状のシェルで利用する
インタプリタのバージョンを切り替えたい場合、
rubyだと[rvm](https://rvm.io/)かなーということぐらいしか知らなかった。
とある人からrvmじゃなくてrbenvがいいよと言われたので
rbenvを入れてみた。

- [rbenv](https://github.com/sstephenson/rbenv)

…MacOS Xな環境であればhomebrewを利用すればすぐに利用できる。

READMORE

```plain
$ brew install rbenv
$ brew install ruby-build
```

他のプラットフォーム、例えばLinuxディストリビューションの
場合はgithubリポジトリからgit cloneを行えば良い。
詳しくはリポジトリの[README.md](https://github.com/sstephenson/rbenv/blob/master/README.md#section_2.1)に書いてある。

```plain
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshenv
$ echo 'eval "$(rbenv init -)"' >> ~/.zshenv
```

[ruby-build](https://github.com/sstephenson/ruby-build)(rbenvで指定したバージョンのrubyをビルドするためのplugin)を入れているのでバージョンを指定して
インストール指定をするだけで終わる。

```plain
$ rbenv install 
  Available versions:
    1.8.6-p383
    1.8.6-p420
    1.8.7-p249
    1.8.7-p302
    1.8.7-p334
    1.8.7-p352
    1.8.7-p357
    1.8.7-p358
    1.9.1-p378
    1.9.2-p180
    1.9.2-p290
    1.9.2-p318
    1.9.2-p320
    1.9.3-dev
    1.9.3-p0
    1.9.3-p125
    1.9.3-p194
    1.9.3-preview1
    1.9.3-rc1
    2.0.0-dev
    jruby-1.6.3
    jruby-1.6.4
    jruby-1.6.5
    jruby-1.6.5.1
    jruby-1.6.6
    jruby-1.6.7
    jruby-1.7.0-dev
    maglev-1.0.0
    rbx-1.2.4
    rbx-2.0.0-dev
    ree-1.8.6-2009.06
    ree-1.8.7-2009.09
    ree-1.8.7-2009.10
    ree-1.8.7-2010.01
    ree-1.8.7-2010.02
    ree-1.8.7-2011.03
    ree-1.8.7-2011.12
    ree-1.8.7-2012.01
    ree-1.8.7-2012.02
```

```plain
$ rbenv install 1.9.2-p320
$ rbenv install 1.9.3-p194
```

```plain
$ rbenv global 1.9.2-p320
$ rbenv global
1.9.2-p320
$ rbenv rehash #ruby, irb, gemなどのコマンドについて新しいバージョンを認識させる
```

```plain
$ mkdir project
$ cd project
$ rbenv local 1.9.2-p320 # .rbenv-bersion ファイルが作成される
$ rbenv local
1.9.2-p320
$ rbenv rehash
$ cd ..
$ rbenv local # 親ディレクトリには.rbenv-version ファイルが無い
rbenv: no local version configured for this directory
```

バージョン切り替える度にrehash...を行うわけだが、
煩わしさを解決するためのスクリプトは
ググれば沢山でてくるので問題無いと思う。
rbenvは軽量な感じがする。最低限の機能しかないというか。
でもまあ必要充分かなぁ。
