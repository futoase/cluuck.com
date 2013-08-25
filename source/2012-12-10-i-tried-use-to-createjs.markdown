---
title: "I tried use to CreateJS"
date: 2012-12-10 20:14
comments: true
tags: [Advent Calendar 2012, JavaScript, CreateJS]
---

# CreateJS

[CreateJS](http://www.createjs.com/)というライブラリをAtariが作成した、
というニュースが今年に夏にありました。

[EaselJS](http://www.createjs.com/#!/EaselJS)、
[TweenJS](http://www.createjs.com/#!/TweenJS)、 
[SoundJS](http://www.createjs.com/#!/SoundJS)、
[PreloadJS](http://www.createjs.com/#!/PreloadJS)、
それぞれのライブラリをまとめたものになっています。

## EaselJS

Canvasを扱い、オブジェクトのアニメーションを簡単に扱えるようにするものです。

## TweenJS

オブジェクトのアニメーションを簡単に扱えるようにするものです。

## SoundJS

サウンドに関してのライブラリです。
複数のブラウザに関して扱いに問題がでないように吸収された作りになっています。

## PreloadJS

画像のあと読み込みを行うためのライブラリです。

# PreloadJSについて触ってみる

時間がないため、PreloadJSについて触ってみます。
[PreloadJSリポジトリのREADME.md](https://github.com/CreateJS/PreloadJS/blob/master/README.md)に書かれているサンプルを参考にします。

```html
<!DOCTYPE html>
<html>
  <head>
    <title>CreateJS Test</title>
    <meta charset="UTF-8"/>
    <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <script type="text/javascript" src="//raw.github.com/CreateJS/PreloadJS/02997fbd4c4139b4bd7cde1d7efe0e9210739095/lib/preloadjs-0.1.0.min.js"></script>

    <script type="text/javascript">
      $(document).ready(function() {
        var preload = new PreloadJS();
        preload.onFileLoad = loadComplete;
        function loadComplete(event) {
          $("#preload-image").append(event.result);
        };
        $("#preload-button").click(function() {
          preload.loadFile('https://dl.dropbox.com/u/614755/futoase.github.com/i-tried-to-use-the-create-js/test.png'); 
        });
      });
    </script>
  </head>
  <body>
    <div>
      <button id="preload-button">Preload!</button>
    </div>
    <div id="preload-image">
    </div>
  </body>
</html>
```

[ここのページ](https://dl.dropbox.com/u/614755/futoase.github.com/i-tried-to-use-the-create-js/test.html)を開いて、Preloadボタンを押すとイメージが後読みされます。

※PreloadJS、CDNに2.0でminifyされたものがあるのですがloadするとPreloadJSを初期化することができなくなっていました...あとで確認。
