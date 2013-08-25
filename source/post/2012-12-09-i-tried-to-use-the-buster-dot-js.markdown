---
title: "I tried to use the Buster.js"
date: 2012-12-09 23:40
comments: true
tags: [Advent Calendar 2012, JavaScript, Buster.js]
---

# Buster.js

Buster.jsが良いというプレゼンを見たので、試しにいじってみようかな、と思います。
(以下、株式会社マピオン 中村 浩士さんのslide share上に上がっているプレゼン資料です)
{% slideshare 15514542 %}

# 動作を確認する
## 環境整備

[Geting Started](http://docs.busterjs.org/en/latest/getting-started/)を見ながら環境を整備します。

```plain
npm install -g buster
```

READMORE

## 最低限の動作テストを書く

Getting Startedに書かれているコードをそのまま書いてみます。

test/buster.jsかspec/buster.jsを書くことで、
busterコマンドを実行した時に自動的にtest/buster.jsかspec/buster.jsを
読みに行きます。

```javascript
var config = module.exports;

config["My tests"] = {
  rootPath: "../",
  env: "node",
  sources: [
  ],
  tests: [
    'test/*-test.js'
  ]
}
``` 

```javascript
var buster = require("buster");

buster.testCase("Sample test", {
  "test 01": function() {
    assert(true);
  }
});
```

今回はテストとして、nodeでの実行を行うため、
busterのパスが通るようにローカルディレクトリでもbusterを入れておきます。

```plain
npm install buster
```

buster test でテストを実行します。

```plain
> buster test
Sample test: .
1 test case, 1 test, 1 assertion, 0 failures, 0 errors, 0 timeouts
Finished in 0.003s
```

実行されました。

# ブラウザ向けのテスト

ブラウザ向けのテストを書くことも可能です。
その場合は、config(test/buster.js)のenvironmentをbrowserに変更します。

```javascript
var config = module.exports;

config["My tests"] = {
  rootPath: "../",
  environment: "browser",
  sources: [
  ],
  tests: [
    'test/*-test.js'
  ]
}
```

また、requireはブラウザでは行えないのでコードをコメントアウトします。

```javascript
//var buster = require("buster");

buster.testCase("Sample test", {
  "test 01": function() {
    assert(true);
  }
});
```

buster serverを実行します。

```plain
> buster server                                                        
buster-server running on http://localhost:1111
```

サーバーを起動したら、ブラウザーにて
http://localhost:1111にアクセスをします。
ブラウザーでのアクセス後、"Capture browser"ボタンをクリックします。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/i-tried-to-use-the-buster-js/screen-1.png)

今回は、ChromeとSafari、2つのブラウザで接続をします。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/i-tried-to-use-the-buster-js/screen-2.png)

ブラウザでサーバーに接続した後、サーバーを立ちあげたまま
buster testを実行します。 

```plain
> buster test                                                          
Chrome 23.0.1271.95, Mac OS X 10.8.2:                                                                                  
Safari 6.0.2, Mac OS X 10.8.2:        .                                                                                                    .
2 test cases, 2 tests, 2 assertions, 0 failures, 0 errors, 0 timeouts
Finished in 0.007s
```

各ブラウザでのjsテストが走りました。

BDD形式のテストコードをかける形、というのと
各ブラウザでのwebフロント側のテストが行えるのでよさそうだな、と思いました。
