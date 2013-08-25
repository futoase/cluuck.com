---
title: "try knockout.js"
date: 2012-06-07 20:43
comments: true
tags: [Programming, Java Script, Knockout.js] 
---

# Knockout.jsを使ってみたい

なんだか、社内で使ってる人がいるようだったから
触ってみよっかなーってことで確認します。

## Knockout.jsは何か

- Java Script Application Flarmework
- [MVVMアプリケーションアーキテクチャパターン](http://ja.wikipedia.org/wiki/Model_View_ViewModel)を利用している

... そのぐらいしか認識していない。

## Knockout.jsを使う環境を整える

[オフィシャルサイト](http://knockoutjs.com/)よりKnockout.jsをダウンロードするか、[githubにあるKnockout.jsのリポジトリ](https://github.com/SteveSanderson/knockout)からcloneして利用する。
今回はgithubにあるKnockout.jsのリポジトリよりclone, 特定tagをcheckoutして利用する。

```plain
$ git clone git://github.com/SteveSanderson/knockout.git knockoutjs
$ chmod +x knockoutjs/tools/check-trailing-space-linux
$ sh knockoutjs/build/build-linux
```

knockoutjs/output以下に２つのファイルが作成される。
- output/knockout-latest.debug.js
- output/knockout-latest.js

knockout-latest.debug.jsはminifyされていないものではあるのだが、今回はKnockout.jsを使ってみよう、ということなのでminifyされたjsを利用する。

<!-- more -->

## Knockout.jsを使ってみる

[簡単なサンプル](http://knockoutjs.com/examples/helloWorld.html)を元にKnockout.jsを利用してみる。

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8"/> 
    <title>Hello World</title>
  </head>
  <body>
    <div>
      <p>First name: <input data-bind="value: firstName"/></p>
      <p>Last name: <input data-bind="value: lastName"/></p>
      <h2>Hello, <span data-bind="text: fullName"/></h2>
    </div>
  </body>
  <script type="text/javascript" src="../src/knockout-latest.js"></script>
  <script type="text/javascript" src="./hello.js"></script>
  <script type="text/javascript">
    ko.applyBindings(new ViewModel("Taro", "Yamada"));
  </script>
</html>
```

```javascript
var ViewModel = function(first, last) {
  this.firstName = ko.observable(first);
  this.lastName = ko.observable(last);

  this.firstName = ko.computed(function(){
    return this.firstName() + " " + this.lastName();
  }, this);
};
```

## 動作サンプル 

[動作サンプル](http://futoase.github.com/assets/2012-06-07-sample/hello/hello.html)を置いておいた。
input form内の値を変更すると、自動的にfirstName, lastNameの値がたされた結果がh2要素内に反映される。これはko.computedメソッドにより、View側で束縛されている要素(data-bind=firstName, data-bind=lastName)の内容が変更されるとUI側に反映されるため。MVVMアーキテクチャは意識をせずにModelの変更内容がViewに反映される形のもの(反映するのはView-Model側)ということ。

# 試しに何か簡単なものを作りたい

[公式のドキュメント](http://knockoutjs.com/documentation/introduction.html)を参考にしながら、よさそうなbindingを使って見ながら何か作ってみたい。メモ書きできるものでも作ってみよう。

## メモ書きアプリ

- メモが書ければ良い
- localStorageに内容を保存できればよい

### 参考にしたもの
公式に[foreach bindings](http://knockoutjs.com/documentation/foreach-binding.html)のドキュメントが
あったので参考にした。

```html:memo.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8"/>
    <title>メモ</title>
  </head>
  <body>
    <div>
      <p>メモ: <input size="100" data-bind="value: description"/></p>
      <button data-bind="click: addMemo">Add Memo</button>
    </div>
    <hr/>
    <div>
      <h1>書かれたメモ</h1>
      <table>
        <thead>
          <tr>
            <th>時間</th>
            <th>内容</th>
            <th>削除</th>
          </tr>
        </thead>
        <tbody data-bind="foreach: memos">
          <tr>
            <td data-bind="text: date"></td>
            <td data-bind="text: memo"></td>
            <td><a href="#" data-bind="click: $parent.removeMemo">remove</a></td>
          </tr>
        </tbody>
      </table>
    </div>
  </body>
  <script type="text/javascript" src="../src/knockout-latest.js"></script>
  <script type="text/javascript" src="./memo.js"></script>
  <script type="text/javascript">
    ko.applyBindings(new MemoViewModel());
  </script>
</html>
```

```javascript
var Utils = (function(){
  return {
    now: function(){
      var d = new Date();
      var month = (month = d.getMonth() + 1) < 10 ? '0' + month : month;
      var date = (date = d.getDate()) < 10 ? '0' + date : date;
      var hour = (hour = d.getHours()) < 10 ? '0' + hour : hour;
      var minute = (minute = d.getMinutes()) < 10 ? '0' + minute : minute;
      var second = (second = d.getSeconds()) < 10 ? '0' + second : second;
      return (d.getFullYear() + '-' + 
              month + '-' + date + ' ' +
              hour + ':' +  minute + ':' + second);
    }
  };
})();

var Memos = (function(){
  return {
    saveMemos: function(memos){
      localStorage['memos'] = JSON.stringify(memos);
    },
    getMemos: function(memos){
      return localStorage['memos'] ? JSON.parse(localStorage['memos']) : undefined;
    }
  };
})();

var MemoViewModel = function(){
  // current element
  var self = this;

  self.description = ko.observable();
  var memos = Memos.getMemos();
  if (memos){
    self.memos = ko.observableArray(memos);
  }
  else{
    self.memos = ko.observableArray();
  }

  self.addMemo = function(){
    if (self.description() !== undefined &&
        self.description().length !== 0){
      self.memos.unshift({
        date: Utils.now(), 
        memo: self.description()
      });
      self.description('');
      Memos.saveMemos(self.memos());
    }
  };
};
```

## 結果
[動作サンプル](http://futoase.github.com/assets/2012-06-07-sample/memo/memo.html)。

Viewで受け付けた変更をModelに即時反映される(View-Modelが)というのがなんとなく不思議。
色々作ってみたほうがいいだろう。
[node.js + express + Knockout.js + Zombie.js という組み合わせがあるらしい。](http://www.slideshare.net/iloire/building-web-apps-with-nodejs-socketio-knockoutjs-and-zombiejs-codemotion-2012)
