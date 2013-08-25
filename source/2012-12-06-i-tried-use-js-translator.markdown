---
title: "I tried use js translator"
date: 2012-12-06 23:39
comments: true
tags: [Advent Calendar 2012, JavaScript]
---

# 沢山あるJavaScriptへのトランスレータ

[CoffeeScript](https://github.com/jashkenas/coffee-script)や、
Microsoftが出した[TypeScript](http://www.typescriptlang.org/)、
Googleが出した[Dart](http://www.dartlang.org/)、DeNAが出した[JSX](http://jsx.github.com/)などなど、
沢山のJavaScriptへのトランスレータ(テンプレート言語)があります。

全部どのぐらい有るんだろう、ということについては把握していないんですが、
この前Twitterのタイムラインで[List-of-languages-that-compile-to-JS](https://github.com/jashkenas/coffee-script/wiki/List-of-languages-that-compile-to-JS)というCoffeeScript-github-repositoryのwikiにある記事へのリンクが流れていたので、
色々あるんだなぁと感心しました。

<!-- more -->

# せっかくなので

個人的にいいんじゃないかな、って思ってるのがTypeScriptです。
Microsoftが出している、というのが主な理由だったりします。

## TypeScriptのインストール

インストールについては、node.jsのインストールが必要です。
[nodebrew](https://github.com/hokaccha/nodebrew)や[homebrew](http://mxcl.github.com/homebrew/)を利用してnode.jsをインストールしましょう。
node.jsをインストール後(敢えて古いバージョンを指定する人はいないと思いますが)、
npmコマンドにて、TypeScriptをインストールします。

```plain
npm install typescript
```

以上で終了です。

## node.jsのサンプルを書いてみる

[http://nodejs.org/](http://nodejs.org/)にある[サーバーを書くサンプル](https://github.com/joyent/node/blob/v0.9.3/doc/index.html#L85)について、TypeScriptで書くと以下の形になります。

```javascript
declare function require(name: string);

interface Http {
  createServer(callback: (req: Request, res: Response) => any): CreateServer;
}
interface CreateServer {
  listen(port?: number, host?: string);
}
interface Request {
  url: string;
}
interface Response {
  writeHead(port: number, header: any);
  end(message: string);
}

declare var http: Http;

http = require('http');

http.createServer(function (req: Request, res: Response){
  console.log('path: ' + req.url);
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello world');
}).listen(3000, '127.0.0.1');

console.log('Server running at http://127.0.0.1/')
```

- declare 構文により、他で既に定義されている関数である、と定義しています。
- interface 構文により、インターフェースが保持しているメソッドを定義しています。
- 変数の宣言にもdeclare 構文を利用します。
- http.createServerの中で、自動引数に型(インターフェース)を定義しています。

それほど違いはありません。
server.tsというファイル名で保存した後、
試しにコンパイル(JavaScriptに変換)してみましょう。

```plain
tsc server.ts
``` 

server.jsができるので、中身を確認しましょう。

```javascript
http = require('http');
http.createServer(function (req, res) {
    console.log('path: ' + req.url);
    res.writeHead(200, {
        'Content-Type': 'text/plain'
    });
    res.end('Hello world');
}).listen(3000, '127.0.0.1');
console.log('Server runnning at http://127.0.0.1/');
```

...きちんと変換されました。元に戻ってる感が...

# JavaScriptへのトランステータについて

リリース・メンテは最後までされるのか、とか
サポートしていない書き方があるとか、
色々と思うことがあるのですが、

- 2人以上の大規模なJavaScript開発プロダクトがある

以上の点があるだけで、共通のフォーマットである
テンプレート言語を利用することで、
色々な書き方の流派があるJavaScriptに対する疲れが
軽減されるだろうと考えています。ただ、本当に
テンプレート言語については慎重にしないとまずいと思うわけで、
結局トランスレートされたJavaScriptを面倒みることになるかも
しれないわけで(パフォーマンスなどの問題が発生したら変換後のJavaScriptを見ざるを得なくなるし)、
取り扱う人間の技量に合うかとか、
そもそもJavaScriptと深く関わらないとこういった
トランスレータには関われないというか、そんなものを感じます。

プログラミングは難しい。
