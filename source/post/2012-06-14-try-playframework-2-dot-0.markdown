---
title: "try playframework 2.0"
date: 2012-06-14 14:04
comments: true
tags: [Scala, PlayFramework, Programming]
---

[PlayFramework 公式サイト](http://www.playframework.org/)

# PlayFrameworkとはなんだろう

[原さんのプレゼン](http://www.slideshare.net/karadweb/playframework-20-java-websocket-mvc-web)に概要(含まれているライブラリなど)が書かれている。

- 元々Javaのみで書かれたWebFramework。
   - フルスタック
- version 1.2からScalaもサポートされるようになった。
   - Scalaはモジュールとして利用する
- version 2.0からScalaが主体な形でサポートされるようになった。
   - sbtベース(インタラクティブシェル)
   - Javaもサポートされている

## PlayFrameworkの主要要素

以下のライブラリ・フレームワークがバンドルされています。

- Scala
   - Javaも利用できるが、Scalaに振った形になっている
   - テンプレートはScalaで書かれている

- sbt
   - PlayFramework のインタラクティブシェルとして利用されている
   - build, test, run などのsbt コマンドを利用する
- netty
   - Webserver
- anorm
   - PlayFramework 2.0 独自のO/RM
       - O/RM といえるほどの抽象化はされていない
       - ほぼ生のSQLを書く必要がある

# PlayFrameworkのインストール

MacOS Lionを基準に話を進めてしまう。

READMORE

1. [Homebrew](http://mxcl.github.com/homebrew/)をインストールする
2. brew install scala を実行し、Scalaをインストールする
3. PlayFramework 2.0を[公式サイトから落としてくる](http://download.playframework.org/releases/)
4. play コマンドに対しPATHを設定する(落としたファイルについて解凍したディレクトリ直下にある)

以上で終わり。
他のOS・環境についてもScalaさえいれてしまえば動くと思う。

# playコマンドによるscaffold作成から動作確認まで

## playコマンドを叩いてみる

```plain:playコマンド実行
       _            _ 
 _ __ | | __ _ _  _| |
| '_ \| |/ _' | || |_|
|  __/|_|\____|\__ (_)
|_|            |__/ 
             
play! 2.0.1, http://www.playframework.org

This is not a play application!

Use `play new` to create a new Play application in the current directory, 
or go to an existing application and launch the development console using `play`.

You can also browse the complete documentation at http://www.playframework.org.
```
上記が表示されるならOK 

## アプリ名を指定しscaffoldを作成させる

play アプリ名を実施し、scaffoldを作成させる。

```plain:scaffoldからのアプリ作成
       _            _ 
 _ __ | | __ _ _  _| |
| '_ \| |/ _' | || |_|
|  __/|_|\____|\__ (_)
|_|            |__/ 
             
play! 2.0.1, http://www.playframework.org

The new application will be created in /Users/matsuzakikeiji/Sandbox/Play/testapp

What is the application name? 
> testapp

Which template do you want to use for this new application? 

  1 - Create a simple Scala application
  2 - Create a simple Java application
  3 - Create an empty project

> 1

OK, application testapp is created.

Have fun!

```

## 作成したアプリを試しに動作させる

カレントディレクトリを作成したアプリのディレクトリに切り替え、
play run を実行することでアプリケーションを実行させることができる。

play run を実行した後、しばらくIvyの中央リポジトリからパッケージダウンロード作業などが行われる。

```plain:アプリケーション実行
play run
...
...

[info] Resolving org.hibernate.javax.persistence#hibernate-jpa-2.0-api;1.0.1.Fin                                                                                [info] Done updating.                                                        
--- (Running the application from SBT, auto-reloading is enabled) ---

[info] play - Listening for HTTP on port 9000...

(Server started, use Ctrl+D to stop and go back to the console...)
```

サーバーが起動したらブラウザーでhttp://localhost:9000/にアクセスしてみる。
以下の画面がきちんと表示されればOK。(フットプリントは大きいのでしばらく待つ)

![ScreenShot](http://futoase.github.com/assets/2012-06-14-sample/images/play_framework_screen_shot.png)

既に用意されたアプリ向けのテンプレートより、scaffoldを作成して動作確認ができた。次は簡易なWebアプリを書くことにする。
