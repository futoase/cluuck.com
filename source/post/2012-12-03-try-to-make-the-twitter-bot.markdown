---
title: "Try to make the twitter bot"
date: 2012-12-03 23:30
comments: true
tags: [Advent Calendar 2012, Ruby, Heroku, Twitter bot]
---

# HerokuでTwitter botを作る

[Heroku](http://www.heroku.com/)を利用し、Twitter botを作るための環境及びサンプルを作ってみましょう。
言語については[Ruby](http://www.ruby-lang.org/)を使います。簡単なので。

# Twitterアプリケーションの登録

Twitterアプリケーションについては、[Twitter Developers](https://dev.twitter.com/)より
アプリケーションの追加を行えます。詳細は端折ります...
アプリケーションの登録を済ませたら、Consumer key, Consumer secretをメモっておきます。
また、今回は自分自身のアカウントで発言を行うbotを登録するつもりですので、
アプリケーションの設定画面の"Your access token"項より、
"Create my access token"ボタンを押してAccess token、Access token secretを取得しましょう。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-make-the-bot/screen-1.png)

## Twitter bot用アカウントについてアプリケーション認証に通す

[gem twitter](https://github.com/sferik/twitter)を利用すれば簡単に行えます。

READMORE

gem twitterを利用しテスト用アカウントに対し書き込みのテストをします。
書き込みのテストをする場合はアプリケーションの設定をRead & Writeにしなければならないことに注意をしてください。

```ruby
require 'twitter'

t = Twitter::Client.new(
  :consumer_key => 'Consumer key',
  :consumer_secret => 'Consumer secret',
  :oauth_token => 'OAuth token',
  :oauth_token_secret => 'OAuth token secret'
)
t.update('hoge') 
```

ツイートされたかテストアカウントを確認してみます。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-make-the-bot/screen-3.png)

無事"hoge"とツイートされました。

# Herokuとの連携

## Heroku toolbelt

ここまででやっとHerokuとの連携を開始します。
Herokuを利用するには[Heroku toolbelt](https://toolbelt.heroku.com/)を使います。
インストール後、herokuコマンドを実行し認証を済ませます。

```plain
> heroku login
Enter your Heroku credentials.
Email: login@hogehoge.com
Password (typing will be hidden):
Authentication successful.
```

## アプリケーションの作成

認証が通ったので、アプリケーションの作成に取り掛かります。 

```plain
> mkdir twitter-bot
> cd twitter-bot
```

Gemfileに依存するgemを書きます。
一旦認証してしまったので、botアカウントへの書き込みに関して
gem twitterしか利用しません。Gemfileに記述する内容は以下の形になります。

```ruby
source "https://rubygems.org" 
gem "twitter", :group => :production 
```

bundlerを利用し、依存するgemのインストールを行います。

```plain
> bundle install --path vendor/bundle
Fetching gem metadata from https://rubygems.org/...........
Fetching gem metadata from https://rubygems.org/..
Installing multipart-post (1.1.5)
Installing multi_json (1.4.0)
Installing simple_oauth (0.1.9)
Installing twitter (4.4.0)
Using bundler (1.2.2)
Your bundle is complete! It was installed into ./vendor/bundle
```

Procfileを作成します。Herokuアプリケーションの
ワーカー起動に関する記述をします。
ここでは、bundle execにてrubyを起動する形を取ります。

```plain
web: bundle exec ruby app.rb
```

## app.rbの記述

app.rbについてテスト動作を確認したいため、以下の内容を記述しましょう

```ruby
# -*- coding:utf-8 -*-

puts "hello world"
```

foremanコマンドを利用し、ローカルにてアプリケーションの挙動を確認します。

```plain
foreman start

01:46:02 web.1  | started with pid 25763
01:46:03 web.1  | hello world
01:46:03 web.1  | exited with code 0
```

無事、app.rbはhello worldを行いました。
gem twitterを利用しツイートを行うか確認してみます。

```ruby
# -*- coding:utf-8 -*-
require 'twitter'

client = Twitter::Client.new(
  :consumer_key => 'Consumer key',
  :consumer_secret => 'Consumer secret',
  :oauth_token => 'OAuth token',
  :oauth_token_secret => 'OAuth token secret'
)
client.update('ugege')
```

foremanにて動作させます。
動作させたあと、アカウントの内容を確認すると、
きちんとツイートされていました。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-make-the-bot/screen-4.png)

## herokuアプリとして登録をしてみる

herokuアプリとして登録するためには、以下の手順が必要です。
- git init を行う
- git commit を行う
- heroku create を行う(remote herokuにリポジトリが結び付けられて便利)
- git push heroku masterを行う

先ほどbundleによるgemのインストール先をvendor/bundleにしたため、
以下の形で無視リスト(.gitignore)に追加します。

```plain
> touch .gitignore
> vi .gitignore
.gitignore
.bundle/*
vendor/*
```

.gitignoreを追加したら、git init, git add ., git commitを行い、
heroku createを実行します。

```plain
> heroku create                               
Creating boiling-coast-9332... done, stack is cedar
```

heroku create後にgit push heroku masterを実行し、アプリをpublishします。
これでアプリケーションを作成できました。だけどこれだと無意味なツイートを1回だけ行うアプリを作っただけなので、きちんとcronを利用しジョブを定期的に実行するようなサンプルを作ってみましょう。

## Heroku Schedulerを利用する

[Heroku Scheduler](https://addons.heroku.com/catalog/scheduler)を利用すれば、10分毎の粒度でジョブを立ちあげさせることが可能です。
先ほど作成したアプリケーションより、Add on追加を選択し、Heroku Schedulerを追加します。

追加後、以下の形で10分毎ごとにジョブを実行させるようにします。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-make-the-bot/screen-5.png)

10分毎ごとにTime.now.to_sをつぶやく意味のあるのかわからないような動作をさせてみるサンプルコードを書きます。

```ruby
# -*- coding:utf-8 -*-

require 'time'
require 'twitter'

client = Twitter::Client.new(
  :consumer_key => 'Consumer key',
  :consumer_secret => 'Consumer secret',
  :oauth_token => 'OAuth token',
  :oauth_token_secret => 'OAuth token secret'
)
client.update(Time.now.to_s)
```

以上のコードをapp.rbに反映し終えたらgit push heroku masterを実行し、
... Heroku Schedulerが実行されるのを静かに待ちます。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-make-the-bot/screen-6.png)

反映されたようです。(LAST RUNの内容を見ればわかる)
早速ツイートの内容を見てみます。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-make-the-bot/screen-7.png)

おお、更新された...とはいえ、時刻がUTCのままになっています。

### heroku consoleによるTime Zoneの変更

一旦アプリケーションをHerokuにpublishすれば、heroku run consoleコマンドによりアプリケーション側のインスタンス内にてconsoleが実行できます。

```plain
> heroku run console
Running `console` attached to terminal... up, run.3037
irb(main):002:0> Time.now.to_s
=> "2012-12-03 17:29:19 +0000"
```

時差については+0000 であり、タイムゾーンはUTCであることがわかります。
東京に設定します。heroku consoleを終了させてから、以下のコマンドを実行します。

```plain
> heroku config:add TZ=Asia/Tokyo
Setting config vars and restarting boiling-coast-9332... done, v5
TZ: Asia/Tokyo
```

再度 heroku consoleを実行し、Time.now.to_sの内容を確認します。

```plain
> heroku run console
irb(main):001:0> Time.now.to_s
=> "2012-12-04 02:30:42 +0900"
```

やりました。これでbot作りが捗りそうです。

日本語の取り扱いを行う場合は、環境変数LANGをja_JP.UTF-8にしておきます。

```plain
heroku config:add LANG=ja_JP.UTF-8
```
