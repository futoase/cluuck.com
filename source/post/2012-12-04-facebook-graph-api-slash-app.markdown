---
title: "facebook graph api /app"
date: 2012-12-04 22:57
comments: true
tags: [Advent Calendar 2012, facebook, OAuth, Ruby]
---

# facebookのOAuth認証について

自分で作成したfacebookアプリケーションへの登録をしているか
確認した後、Graph APIの/meでユーザーの情報を取得する場合、
以下の問題が考えられます。

1. "A"というアプリケーションについて、"Z"というユーザーは登録した
2. "B"というアプリケーションについても、"Z"というユーザーは登録した
3. "B"アプリケーションのプロバイダーが、"Z"が自己のアプリに登録しているのか、"Z"が保持しているOAuthトークンを元に確認した。
4. この時、"Z"が払いだしてきたOAuthトークンは"A"のものだったが、facebook側では"A"を認証しているか、という確認になるため、SUCCESSを返す。
5. "B"アプリケーションのプロバイダーはfacebookからのレスポンスが正常だったため、Graph APIでユーザーの情報を取得しようとする。

これはありがちな問題、ということで[話に上がっていたり](http://oauth.jp/oauth-20-implicit-flow-78852)しています。
職場で教えてもらったりしました。OAuthトークンを元にしたアプリケーション情報の取得については
[Step 2. Make Requests to the API項](https://developers.facebook.com/docs/howtos/login/login-as-app/)に書かれています。

<!-- more -->

# 試してみる

先ほどのアプリケーション認証の抜け穴について
[koala](https://github.com/arsduo/koala)というrubyの便利なgemライブラリを利用して検証します。 

## facebook アプリケーションの登録　

[facebook developers](https://developers.facebook.com/)で、アプリケーションの登録を行うことができます。
テストアプリケーションを2つほど登録します。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/facebook-graph-api-app/screen-1.png)

登録後、[Graph API Explorer](https://developers.facebook.com/tools/explorer/)を利用しアクセストークンを取得し、
koalaを利用して確認をします。アクセストークン取得時に
アプリケーションの特定パーミッションへのアクセス許可も行うので大丈夫です。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/facebook-graph-api-app/screen-2.png)

```ruby 
require 'koala'
# アプリBのトークンを利用してGraph API /meへのアクセスを行う。
@graph = Koala::facebook::API.new("アプリBのアクセストークン")
profile = @graph.get_object("me")
# profileにはアプリBでアクセスを許可したパーミッションの情報が戻る
```

ここでGraph API経由で得たユーザー情報は
アプリケーションBのものです。きちんとOAuthトークンを要求した
アプリケーションに関して情報を取得するには、以下の形で、
Grap API appに対し問い合わせを行います。

```ruby
require 'koala'
@graph = Koala::facebook::API.new("アプリBのアクセストークン")
application_profile = @graph.get_object("app")
application_profile["id"]   # アプリBのアプリケーションID
application_profile["name"] # アプリBのアプリケーション名
```

OAuthアクセストークンがどのアプリで払いだされたか、を
アプリケーションIDでチェックするようにすれば
自分のアプリケーション向けに払いだされたOAuthトークンであるか確認が行えます。

ただ、いつまでGraph APIのappが有効なのかもわからないし、(今のところドキュメントできちんと明記されていない、)
facebookもうすこしドキュメント整備してくれないものか、と思ったりします。
