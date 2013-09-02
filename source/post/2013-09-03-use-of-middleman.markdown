---
title: "TravisCI auto Use of Middlemanleman"
date: 2013-09-03 2:00
comments: true
tags: A NoteBook
---

# TravisCIとMiddlemanの連携

色々とネット上で連携してみた、という
エントリが出てきていたので、試しにやってみた。
```gh-pages branch``` については--orphanオプションで親無しのブランチを作成して
予め用意しておくぐらい。

あとは、[Middleman で作った web サイトを Travis + GitHub pages でお手軽に運用する](http://tricknotes.hateblo.jp/entry/2013/06/17/020229)を参考に.travis.ymlを書いて、
TravisCIでリポジトリを監視対象にして、終わり。

...```GIT_COMMITTER_NAME``` , ```GIT_COMMITTE_EMAIL``` をtypoしてて
```git commit``` が反映されず、1日ハマってた。。。
