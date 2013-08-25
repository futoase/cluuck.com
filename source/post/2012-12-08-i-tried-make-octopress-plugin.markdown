---
title: "I tried make octopress plugin"
date: 2012-12-08 22:30
comments: true
tags: [Advent Calendar 2012, Octopress, Ruby]
---

# Octopressのpluginを作る

[ニコニコ動画](http://www.nicovideo.jp/)の外部プレイヤーをOctopressのエントリで表示させたい。
[SlideShareの表示プラグイン](https://github.com/PeterHamilton/Octopress-Slideshare-Plugin)を元に書いてみましょう。

{% gist 4244901 %}

試しに使ってみます。

{% nicovideo sm19523929 %}

無事、Octopressのエントリにニコニコ動画の
外部プレイヤーを埋め込めるようになりました。

使い方、はsmXXXXを入れるだけです。

```ruby
{% nicovideo sm19523929 %}
```

[githubリポジトリとして公開](https://github.com/futoase/Octopress-Nicovideo-Plugin)しました。
