---
title: "Try to use the Sakura board"
date: 2012-12-05 22:48
comments: true
tags: [Advent Calendar 2012, Sakura board]
---

# Sakura board をいじる

[Sakura board](http://sakuraboard.net/) を買ったままそのまま時が過ぎてしまい、
書くこともないし試しにいじってみようかな、と思ったので
Sakura board をいじる、という内容で書いてみます。

# Sakura board とは

[Arduino](http://www.arduino.cc/)互換のボードで、基盤がピンク色。
プログラムを実行するための環境として
クラウド上でのコンパイル環境が整備されており、
ユーザーとして最初にボードの挙動などを確認する程度であれば
用意するものはUSB <-> mini USBケーブル1本と
PC (MacもOK)があれば良いという親切な環境が整っています。

READMORE

# テストコードを実行してみる

[sakuraboard.net](http://sakuraboard.net/)を見ながら、作業を進めていきます。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-use-the-sakura-board/screen-1.png)

Sakura board を Mac Book Pro Retina 13 inch に接続し、
SW1ボタン(茶色いボタン)を押します。
すると、システム側にSakura boardがマウントされます。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-use-the-sakura-board/screen-2.png)

システム側にマウントされたのを確認した後、
[Runesas Web Compiler](http://tool-cloud.renesas.com/)へゲストとしてログインし、
最初から用意されているテンプレートを選択、
適当なプロダクト名を付け、プロダクトの作成を行います。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-use-the-sakura-board/screen-3.png)

Runesas Web Compiler にて、プロジェクトのビルドを選択します。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-use-the-sakura-board/screen-4.png)

ビルドが成功すると思います。(何もいじっていなければ...)

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/try-to-use-the-sakura-board/screen-5.png)

ビルドが成功した後、sketch.bin ファイルが作成されているので(Runesas Web Compilerの左ペインに出ます)、
ファイルをダウンロードし、Sakura board に転送します。
すると、[Sakura board にあるLEDが光ります。](http://youtu.be/xolHe6-W6mk?hd=1)

開発環境を整えるのに頭を抱えなくても出きるあたりがすごいと思いました。
しばらくはコードを書いて評価させて、を繰り返した後にスイッチやLEDや、
はたまたサーボでも買ってテストしてみたいな、と思いました。
