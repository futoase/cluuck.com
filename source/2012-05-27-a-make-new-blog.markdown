---
title: a make new blog
date: 2012-05-27 18:24
comments: true
tags: A NoteBook
---

#Octopressを使うようにしてみた。

Markdownで書いていくし、記事についてはgitで
履歴管理がなされるし、これでいいやって思ったので
使ってみる。技術記事について書きやすそうだし。

#Octopressをgithub上で展開していくためには

以下に簡単に構築手順を書いておく。オフィシャルにある
[ドキュメント](http://octopress.org/docs/setup/)を参考にしながらやった。

<!-- more -->

## 必要な環境

2012-05-27 現在、利用するrubyのバージョンが1.9.2を
要求しているため、rvm及びrbenvなどを利用して指定バージョンの
rubyを入れておくこと。ソースからのビルドでも良いけれど。

- 参考(オフィシャル)

```plain
$ rvn install 1.9.2 && rvn use 1.9.2
```

```plain
$ rbenv install 1.9.2-p290
$ rbenv global 1.9.2-p290
$ rbenv rehash
```

- それぞれ、リポジトリROOTの[.rvmrc](https://github.com/imathis/octopress/blob/master/.rvmrc), [.renv-version](https://github.com/imathis/octopress/blob/master/.rbenv-version)で指定されている

## Octopressのダウンロードから初期動作確認まで

```plain
$ git clone git://github.com/imathis/octopress.git octopress
$ cd octopress
$ gem install bundler
$ rbenv rehash
$ bundler install
$ rake install
$ rake generate
$ rake preview
```

- rake previewを行うとサーバが立ち上がり、確認可能な状態になる

```plain
% rake preview
Starting to watch source with Jekyll and Compass. Starting Rack on port 4000
Configuration from /Users/matsuzakikeiji/Sandbox/test_oct/_config.yml
[2012-05-27 20:18:50] INFO  WEBrick 1.3.1
[2012-05-27 20:18:50] INFO  ruby 1.9.2 (2011-07-09) [x86_64-darwin11.4.0]
[2012-05-27 20:18:50] INFO  WEBrick::HTTPServer#start: pid=83303 port=4000
Auto-regenerating enabled: source -> public
[2012-05-27 20:18:51] regeneration: 94 files changed
  
Dear developers making use of FSSM in your projects,
FSSM is essentially dead at this point. Further development will
be taking place in the new shared guard/listen project. Please
let us know if you need help transitioning! ^_^b
- Travis Tilley
```

## _config.yml

octopressのルート直下にある_config.ymlの内容を変更し、適切なブログ名を設定する。

```yaml
# ----------------------- #
#      Main Configs       #
# ----------------------- #

url: http://futoase.github.com
title: futoase Blog
subtitle: A Tech Blog.
author: Keiji Matsuzaki
simple_search: http://google.com/search
description:
```

編集し終えたら、rake generateをやり直し、内容を確認する。

```plain
$ rake generate
$ rake preview
```

タイトルが変わっている。

## 記事投稿について

記事投稿は、rake "new_post[title]" という形で行う。
実行するとsource/_postsの下に記事用のファイルが作成される。

```plain
$ rake "new_post[test title]"
mkdir -p source/_posts
Creating new post: source/_posts/2012-05-27-test-title.markdown
$ cd source/_posts
$ ls
2012-05-27-test-title.markdown
```

既に著者名などは設定されているので(Markdown形式)、
あとは記事を書き進めていけばよい。

```plain
---
layout: post
title: "test title"
date: 2012-05-27 20:29
comments: true
tags: 
---

# 今日も毎日が日曜日だ

- た、楽しいなあ
- う、うれしいなあ

## いつの間にか時間が経過したらもう夕方

- 明日がんばろう 
```

rake previewでサーバを起動したままの状態で記事の編集をすれば、都度リロードしてくれる。

## github pages上で利用したい

[オフィシャルのドキュメント](http://octopress.org/docs/deploying/github/)にて方法が記載されている。

```plain
$ rake setup_github_pages
Enter the read/write url for your repository: git@github.com:futoase/futoase.github.com.git
rm -rf public
mkdir -p public/hoge
## Site's root directory is now '/hoge' ##
rm -rf _deploy
mkdir _deploy
cd _deploy
Initialized empty Git repository in /Users/matsuzakikeiji/SandBox/octopress/_depl
oy/.git/
[master (root-commit) c079225] Octopress init
 1 file changed, 1 insertion(+)
 create mode 100644 index.html
cd -
  
---
## Now you can deploy to http://futoase.github.com/hoge with `rake deploy` ##
$ rake generate
$ rake deploy
```

rake deployを行った後、futoase.github.comにアクセスして確認できれば終了。
あとは毎日、rake "new_post[title]"して、rake generate して rake preview して確認した後に git add して git commit して rake deployすれば良い。気楽。

## 悩んでること

画像ファイル、image pluginで画像をエントリに使えるけど置き場所どこにしようか...と。githubで管理するなら、souces/_images とか作成しちゃえばいいんだろうけど。
