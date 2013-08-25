---
title: "backup repository of octopress"
date: 2012-05-29 23:31
comments: true
tags: [Octopress]
---

# 忘れていた。

octopressについてリポジトリをgit cloneして、そのあとrake setup github pages を行った後、rake deployしていた(_deployリポジトリ以下にgithub pages向けのリモートリポジトリが設定される)。でもこのままだとローカルにあるoctopressもといBlogの元データがバックアップされてねーじゃん、ということに気がついたのでgithubにfutoase.github.com.souceなるリポジトリを作成した。

## バックアップ用リポジトリ作成から投稿できるようにするまで

1. githubにバックアップ用のリポジトリを作成する
2. octopressローカルリポジトリよりgit add remoteを行い、sourceブランチを(1)で作成したリポジトリにpushする
3. rake setup_github_pages で、念の為にdeploy先をfutoase.github.comにする

READMORE

```plain
$ cd octopress # octopressをgit cloneしたディレクトリ
$ git add remote backup git@github.com:futoase/futoase.github.com.source.git
$ git add remote octopress git://github.com/imathis/octopress.git # octopressが更新された場合にpullできるように
$ git push backup source
```

- Blog作成元用のリポジトリをcloneし、rake deployする

```plain 
$ git clone git@github.com:futoase/futoase.github.com.source.git
$ cd futoase.github.com.source
$ rake setup_github_pages
$ rake generate
$ rake preview
$ rake deploy
```

これで大丈夫なはず。ただ、書きかけのエントリについてもgithubに持たせたいとなるとpublicで公開しているので、privateリポジトリを利用できるようお金を使うか、bitbucketにprivateリポジトリを作成してそこでoctopressのソースを管理するか、になりそうだ。
