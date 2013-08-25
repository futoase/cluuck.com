---
title: "nginx custom 503 page"
date: 2012-11-23 23:05
comments: true
tags: [nginx, Server setting]
---

# サイトメンテナンス時のHTTP Status codeについて

ついうっかり、サイトのメンテナンス状態にするときにHTTP Status codeを200で返してしまう状態にしていて、メンテナンス状態の内容がGoogleにキャッシュされるようになってしまっていた。メンテナンス中はHTTP Status code 503を吐き出すようにしたい。


# nginxでのカスタム503ページ設定

メンテナンス時にだけ起動するEC2インスタンスを用意しちゃう、ということでアプリ用のインスタンスについて影響を出来るだけ出さないようにする、という前提で。

- / (root path)にアクセスしてきた場合にカスタム・メンテナンスページを出す
- /static 以下にはcss, js, jpg, pngなどの静的ファイルを置くが、そのリソースを要求しても503を返してはいけない

以上の要求を満たす、nginxの設定ファイルの書き方は以下の通り。

READMORE

```nginx 
server {
  listen 80;
  
  server_name hoge.com;
  root /path/to/web/maintenance;
  index index.html;

  location ~ "^/static/(.*)" { # /static 以下にあるリソースは直接読み込める形にする
    try_files $uri $uri/ /index.html;
  }

  location / {
    index index.html; 
    return 503; # error_page 503 に飛ばす
  }

  error_page 503 @maintenance; # 503 を @maintenance に飛ばす
  location @maintenance {
    rewrite ^(.*)$ /index.html break;
  }
}
```

これで、http://hoge.com/ にアクセスすると常にHttp status 503、且つindex.htmlで利用している静的リソースは正常に読み込める状態になる。

なんか、色々と今更感があるが気をつけないと...

# 参考

- [サイトのダウン タイムへの対処の仕方](http://googlewebmastercentral-ja.blogspot.jp/2011/02/blog-post.html)
- [Google ウェブマスターツール HTTP ステータスコード](http://support.google.com/webmasters/bin/answer.py?hl=ja&answer=40132)
