---
title: "How to use git flow"
date: 2013-01-06 21:46
comments: true
tags: [git, git flow]
---

# How to use git flow

あけましておめでとうございます。
皆様いかがお過ごしでしょうか？

会社で[git flow](https://github.com/nvie/gitflow)を利用したリリース手順・サイクルを繰り返しているのですが、
正しいのかどうなのかを確認したいため、まとめてみたいと思います。

READMORE

# git flow とは

gitのbranch作成戦略の一つの手、というかテンプレートです。
branchの作成、mergeの方法(--no-ff有効にするとか)だのなんだの、
チーム内のメンバー間でバラバラだと困るし、統一するために利用するためのもの。
使わなくてもしっかりとlocal, remote branchそれぞれの命名規則や
mergeの仕方、リリースの仕方について決まっていれば導入する必要はないかもしれません。
けど、少人数、gitを利用した多人数開発での経験も浅めか、別にbranchを切ったり
pushしたりの手順を変えても影響がないものプロダクトであれば導入しても問題無いと思います。

# git flowを利用した場合のリリース手順

リリース手順について以下の手順になります。

1. issue単位でfeature branchを作る
    - commitやticketではなく、issue、プロダクトの最小単位でfeature branchを作成するようにします。
2. feature branch上でcommitしつづける
3. feature branchに対し、issueの内容を反映し終え、local上(開発者)での動作チェックが済んだらfeature branchをgit pushする
4. origin(upstream)より、development環境上からgit fetch、(3)のbranchの更新内容を取得。git checkout -b branch-name feature branchを行い、テストを出きる状態にする。
    - 既にfeature branch向けのlocal branchを作成しているのであればgit pull feature branchを行いlocal branchにmergeする。
5. development環境で動作確認ができたらrelease branchを作成する
    - git flow release start 1.0.0 という形でrelease branchを作成。
6. release branchをorigin(upstream)に対しgit push
7. staging環境上でgit fetch, (6)のbranchの更新内容を取得。git checkout -b branch-name release branchを行い、テストできる状態にする。
    - 既にrelease branch向けのlocal branchを作成しているのであればgit pull release branchを行いlocal branchにmergeする。
8. release branchについて動作チェック及びテストに問題がなければ、(5)で作成したrelease branchを閉じる。
    - git flow release finish 1.0.0
9. 1.0.0 のtagが作成される
10. master, 1.0.0のtagをorigin(upstream)にpushする。
11. production環境上でgit fetchを行い、git checkout -b tag-name tag-name を行なっておしまい。

## hotfix(リリース後に見つかった急遽のバグ対応)を利用する場合

hotfix、つまりリリース直後に見つかった問題を即日対応したい場合のbranchをさくっと作りたい、名前考えてる場合じゃねえや、ってときに使います。

1. git flow hotfix start 1.0.1 というbranchを作成します。
    - branchの名前は、修正を行うバージョンを対象にします。
    - [semver.org](http://semver.org/)に準拠するなら、1.0.1とする。(patch version)
        - ただ、本当に細かい内容とかであるなら1.0.0aとかしたほうがいいかも。
        - バージョンの付け方については一定であれば問題無いと思うし...
2. hotfixで対応した内容をdevelopment環境、staging環境で動作チェック、及びテストを行う
3. 動作チェック、テストについて(2)で問題がでなければ、git flow hotfix finish 1.0.1 とし、hotfixを閉じる。
4. 1.0.1 のtagが作成されるので、git push origin master, git push origin 1.0.1 を行い、中央リポジトリにbranchをpushする
5. production環境上でgit fetchを行い、git checkout -b 1.0.1 1.0.1 を行う

# git flow をインストール

マシンにgitがインストールされていることを確認したら、
[gitflow](https://github.com/nvie/gitflow)のプロダクトページの
[wikiページに掲載されているワンライナー](https://github.com/nvie/gitflow/wiki/Linux)をコピーして、
ターミナル上でペーストして実行します。

```plain
> wget --no-check-certificate -q -O - https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh | sudo bash
```

これだけでインストールが完了します

# git flow を既存のリポジトリに適用する

以下のコマンドを既存のリポジトリのディレクトリに移動して実行すればOK。
develop, masterなどのbranchについてはgit flowで利用するデフォルトのbranch名を
利用すれば良いのですが、prefixだけは"v"をつけるようにしておきましょう。
git flow release start 1.0.0 -> git flow release finish 1.0.0とすると、
v1.0.0と、release tagにprefixを付けてくれます。

```plain
> cd product
> git flow init
Which branch should be used for bringing forth production releases?
   - master
Branch name for production releases: [master] 
Branch name for "next release" development: [develop] 

How to name your supporting branch prefixes?
Feature branches? [feature/] 
Release branches? [release/] 
Hotfix branches? [hotfix/] 
Support branches? [support/] 
Version tag prefix? [] v
```

以上でgit flowを利用できるようになります。

中央リポジトリ(upstream)に対して、以下の形でdevelop, masterそれぞれの
branchをpushしておきましょう。

```plain
> git push origin develop
> git push origin master
```

あとは、release branchが作成したときとか、tag作成したときは都度、
tagやbranch、developやmaster(tagポインタが参照しているから)各branchをpushしましょう。

# チームメンバー間のコードリーディングについて

pull request戦略を取ると、リポジトリをメンバーごとにforkしなければならず、
それはgithubのクラウド版(GoldとかSilverとか)でそれやると作成できる
private repositoryの数を減らしまくることになるので、
feature branchでupstreamに対してpushして対応することにしています。

といってもまだ会社だと開発チーム小さく、ほぼ分業みたいなことになっているので
mergeしてもらいたいからbranchを作成しpushするというより
直接口で話して直してもらうことが多々あるのでfeature branch pushで
会話をする回数は少ない感じです。

# 参考

- [O'reillyに掲載されているgit flowの使い方](http://www.oreilly.co.jp/community/blog/2011/11/branch-model-with-git-flow.html)
