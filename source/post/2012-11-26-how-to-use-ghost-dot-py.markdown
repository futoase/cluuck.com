---
title: "How to use Ghost.py"
date: 2012-11-26 20:42
comments: true
tags: [Python, Ghost.py, PySide]
---

# Ghost.py

[Ghost.py](http://jeanphix.me/Ghost.py/)という、[PySide](http://www.pyside.org) or [PyQt](http://www.riverbankcomputing.co.uk/software/pyqt/intro)を利用し[QtWebKit](http://trac.webkit.org/wiki/QtWebKit)を利用するためのラッパーが存在します。似たようなものだと[phantom.js](http://phantomjs.org)や[Capybara-WebKit](https://github.com/thoughtbot/capybara-webkit)があります。これを試しに使ってみようかな〜と思ったので以下に使用手順をMac OS X、Ubuntu Server 12.04.1 LTSでの内容を書きます。

Ghost.pyはPySide,PyQtどちらでも利用できるように書かれているのですが、今回はPySideを利用する形をとりました。

## Ghost.pyとは

- PySide及びPyQtを利用しQtWebKitを使ったウェブブラウジングが可能なラッパー
    - Javascriptの実行もOK。
    - QtWebKitを利用してスクショが撮れます。

<!-- more -->

# Mac OS X で利用
以下には、Mac OS X 10.8.2 Mountain Lion で利用するための手順を記載します。

## homebrew で環境を構築
Mac OS X でQt周りを手作業で環境構築するとだるそうなので[homebrew](http://mxcl.github.com/homebrew/)を利用してインストールするようにします。

```plain
> brew install python piside
```

PySideは以下のディレクトリに入ります。

```plain
> /usr/local/Cellar/python/2.7.3/lib/python2.7/site-packages/PySide
```
[Formulaはこちら](https://github.com/mxcl/homebrew/blob/master/Library/Formula/pyside.rb)

続けて、[distribute](http://pypi.python.org/pypi/distribute)をインストールします。

```plain
> curl -O http://python-distribute.org/distribute_setup.py
> python distribute_setup.py
```

easy_installがインストールできたら続けて[pip](http://pypi.python.org/pypi/pip)を入れます。

```plain
> rehash
> easy_install-2.7 pip
```

さらに、pipを利用して[virtualenv](http://www.virtualenv.org/en/latest/)を入れます。

```plain
> pip install virtualenv
```

以上で気軽に汚せる環境を整える準備ができたので、$HOME/local以下にでもvirtualenvで環境を整えましょう。

```plain
> mkdir -p $HOME/local
> virtuelenv $HOME/local/python --system-site-packages
```

(注) [--system-site-packageオプション](http://www.virtualenv.org/en/latest/#the-system-site-packages-option)は、ベースとなるPythonにインストールされているsite-packagesを利用するためには必須となるオプションです。

以上でGhost.pyを手軽にMac OS X上でテストできる環境が整いました。早速Ghost.pyをインストールすることにします。

## Ghost.pyのテスト

先ほどvirtualenvで作成したプライベートなpython環境上でインストール、実行をしていきます。virtualenvで作成したpythonの環境を利用する場合は、以下の形でactivateスクリプトをsourceコマンドで設定として読み出します。そうするとpythonのパスがvirtualenvで作成したpythonの環境のものに設定されます。元の環境に戻る場合は"deactivate"コマンドを実行してください。

```plain
> source $HOME/local/python/bin/activate
(python)> 
```

Ghost.pyをpip経由でインストールします

```plain
(python)> pip install Ghost.py
```

インストールが終わったら、オフィシャルサイトに掲載されているCode snipetを実行してみます。

```python
(python)> python
Python 2.7.3 (default, Apr 12 2012, 23:12:34)[GCC 4.2.1 Compatible Apple Clang 3.1 (tags/Apple/clang-318.0.45)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> from ghost import Ghost
>>> ghost = Ghost()
2012-11-24 22:55:43.762 python[97682:707] *** WARNING: Method userSpaceScaleFactor in class NSView is deprecated on 10.7 and later. It should not be used in new applications. Use convertRectToBacking: instead.
>>> page, extra_resources = ghost.open("http://jeanphi.fr")
>>> assert page.http_status == 200 and 'jeanphi' in ghost.content
```

途中で出てきた、以下のエラー

```plain
2012-11-24 22:55:43.762 python[97682:707] *** WARNING: Method userSpaceScaleFactor in class NSView is deprecated on 10.7 and later. It should not be used in new applications. Use convertRectToBacking: instead.
```

このエラーについてぐぐってみたところ、[問題ありませんとか書かれてるエントリ](http://victorquinn.com/blog/2012/10/11/using-capybara-and-rspec-to-test-drupal/)が出てくるぐらいだったので、developer.apple.comのドキュメントを調べたら[userSpaceScaleFactor methodはdeprecateされたことが確認できました](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/Classes/NSScreen_Class/DeprecationAppendix/AppendixADeprecatedAPI.html%23//apple_ref/occ/instm/NSScreen/userSpaceScaleFactor)。

ghost.contentは、オフィシャルのcode snipetを見れば推測できると思うけど取得コンテンツの中身が入っています。

```html
u'<!DOCTYPE html><html lang="fr"><head>\n        <meta charset="utf-8">\n        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n        <link rel="alternate" type="application/atom+xml" title="Post feeds" href="/atom.xml">\n…
```

ghost.openの返り値については2つの値が含まれたタプルとなっており、(取得できたresource且つ指定したurlと同一のresouce,resourceすべて)となっています。resourceについてはリソースからリンクが張られているjavascript、cssを含みます。

```python
>>> extra_resources
[<ghost.ghost.HttpResource object at 0x10747bd10>, <ghost.ghost.HttpResource object at 0x10747bd90>, <ghost.ghost.HttpResource object at 0x10747be10>, <ghost.ghost.HttpResource object at 0x10747bf10>, <ghost.ghost.HttpResource object at 0x107489050>, <ghost.ghost.HttpResource object at 0x107489150>]
>>> len(extra_resources)
6
>>> extra_resources[0].url
u'http://jeanphi.fr/'
>>> extra_resources[1].url
u'http://jeanphix.me/'
>>> extra_resources[2].url
u'http://jeanphix.me/static/css/normalize.css/normalize.css'
>>> extra_resources[3].url
u'http://jeanphix.me/static/css/pygments.css'
>>> extra_resources[4].url
u'http://jeanphix.me/static/css/style.css'
>>> extra_resources[5].url
u'https://a248.e.akamai.net/assets.github.com/img/7afbc8b248c68eb468279e8c17986ad46549fb71/687474703a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67'
```

ghost.openの返り値については以下のコードを見ることで確認できます。

```python
def wait_for_page_loaded(self):
    """Waits until page is loaded, assumed that a page as been requested.
    """
    self.wait_for(lambda:self.loaded,
        'Unable to load requested page')
    resources = self._release_last_resources()
    page = None
    url = self.main_frame.url().toString()
    for resource in resources:
        if url == resource.url:
            page = resource
    return page, resources
```

(注)細かくコードの内容を確認するには[GhostWebPage Class](https://github.com/jeanphix/Ghost.py/blob/781dd0a16d7cc0c47429f28d7aed4236e8b2f74e/ghost/ghost.py#L45)、及びその親クラスである[QtWebkit.QWebPage](http://srinikom.github.com/pyside-docs/PySide/QtWebKit/QWebPage.html)の内容を見ないといけないので割愛します。。。(あとで書くかも)

### yahoo.co.jpのスクショを撮る

サイトのスクショはとても簡単に撮れます。

```python
>>> _ = ghost.open("http://www.yahoo.co.jp/")
>>> ghost.capture_to("render.png")
```

PythonのREPLを起動した時のカレントディレクトリ以下にrender.pngができています。内容を見てみるときちんとyahoo.co.jpのキャプチャができていることを確認することができます。

```plain
> open render.png
```

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/how-to-use-ghost-py/render.png)

バッチリ写ってる！…ウインドウサイズは変えることはできないんだろうか？と思って[Ghost.pyのソースをチェックしてみたらviewport_sizeに渡す形になっていました。](https://github.com/jeanphix/Ghost.py/blob/781dd0a16d7cc0c47429f28d7aed4236e8b2f74e/ghost/ghost.py#L168)デフォルト値は800x600。

```python
>>> ghost = Ghost(viewport_size=(1024, 768))
2012-11-24 23:34:14.216 python[97814:707] *** WARNING: Method userSpaceScaleFactor in class NSView is deprecated on 10.7 and later. It should not be used in new applications. Use convertRectToBacking: instead.
>>> ghost.open("http://yahoo.co.jp/")
>>> ghost.capture_to("render_1024x768.png")
>>> exit()
> open render_1024x768.png
```

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/how-to-use-ghost-py/render_1024x768.png)

きちんと解像度を変更した形でスクショを撮ることができました。

## 動的なサイトのテスト

オフィシャルのサンプルだと[DOMを操作する旨のCode snipetが載っています。](http://jeanphix.me/Ghost.py/#javascript)ということでテスト的な動的サイトを用意して、Ghost.pyで操作できるか確認してみます。

簡単なhtmlとjsとcssをこさえてテスト環境を作ります。

{% gist 4149488 %}
{% gist 4149492 %}
{% gist 4149495 %}

内容はしょぼくて、"fire"ボタンを押下すると"input[name='smile']"要素のvalueを"precure!"に設定するサンプルです。

[DropBox上にあげてあるサンプル](https://dl.dropbox.com/u/614755/futoase.github.com/how-to-use-ghost-py/ghost-test.html)

Ghost.pyを利用して、"fire"ボタンをクリックし、"input[name='smile']"要素のvalueを"precure!"に設定した後、"input[name='smile']"要素の内容を取得して返す短いコードを書いてみます。

```python
>>> ghost = Ghost()
>>> ghost.open("https://dl.dropbox.com/u/614755/futoase.github.com/tried-using-ghost-py/ghost-test.html")
>>> ghost.evaluate("document.getElementById('fire').click(); document.getElementsByName('smile')[0].value;")
(u'precure!', [])
```

きちんとvalueの中身が取れています。よかった。

# Ubuntu Server での動作 

[Ubuntu Server 12.04.1 LTS](http://www.ubuntu.com/download/server) をVirtualBoxを利用してゲスト上にインストールし、動作確認を行います。Xが動作していない環境での動作を想定しています。(エロ画像とかなんかまあそんな感じのクローラ作るときとか。)
Pythonはソースコードをオフィシャルから落としてインストールする形を取ります。

VirtualBoxで作成するVMについては、ネットワークの項でホストオンリーアダプタを追加しておくことを忘れないようにしておきます。(ホストと通信できなくなるから)

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/how-to-use-ghost-py/virtual-box-network-adaptor.png)

ホストオンリーアダプタの設定が終わったら適切な感じでUbuntu Server 12.04.1 LTSをインストールしてください。(OpenSSH Serverパッケージを選択し忘れないように)

ネットワーク設定は以下の要領で行います。

追加したホストオンリーアダプタが有効か、確認します。

```plain
> /sbin/ifconfig -a
```

...ホストオンリーアダプタが見つかったら、/etc/networking/interfacesに以下の項目を追記します。

```plain
auto eth1
iface eth1 inet dhcp
```

interfacesの編集が終わったら、/etc/init.d/networking restart をします。(update-rc.d使えとかはまた後で)

VirtualBoxのVMを直接操作するのはだるいので、Mac OS Xのターミナル経由で操作しましょう...だるいし。

## Ghost.pyを実行するための環境整備

まだまだ続く... Pythonのセットアップなど。

### Pythonのセットアップ

まず、Pythonのビルドに必要なパッケージ群をインストールします。

```plain
> sudo apt-get update
> sudo apt-get install build-essential zlib1g-dev libbz2-dev libreadline6-dev libsqlite3-dev libssl-dev
> mkdir ~/download
> cd ~/download
> curl -O http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz
> tar -xvzf Python-2.7.3.tgz
> mkdir ~/local
> cd Python-2.7.3
```

共通ライブラリ(--enable-sharedオプションをつける)にしないとpyside-setupでコケるため([対策のコミット](https://github.com/PySide/pyside-setup/commit/b63c2f35b268f270a926e2f40f0042d9e7507da6)が入ってるのを確認したがだめだった...)、[@methane](https://twitter.com/methane)さんの[Qitaの投稿](http://qiita.com/items/bf0b74550bee125cdea4)を参考に以下の形でビルドオプションを付け、Pythonをビルドします。ただ共有ライブラリオプションを有効にしてもzlibとかそこら辺のライブラリをビルドするときにライブラリパスを通さないととかめんどいことが発生するので...

```plain
> ./configure --prefix=$HOME/local/Python-2.7.3 --enable-shared \
  LDFLAGS=-Wl,-rpath,$HOME/local/Python-2.7.3/lib
> make
> make install
> make clean
```

インストールに成功したら、~/.bashrcにPATHを通します。

```plain
> export PATH="$HOME/local/Python-2.7.3/bin:$PATH";
> source ~/.bashrc
```

distribute、pipのインストールを行います。

```plain
> mkdir ~/download
> cd ~/download
> curl -O http://python-distribute.org/distribute_setup.py
> python distribute_setup.py
> rehash
> easy_install-2.7 pip
```

Qtやcmakeをインストールします。[PySideのPyPIに書かれている手順](http://pypi.python.org/pypi/PySide#installing-pyside-from-source-on-a-unix-system-ubuntu-12-04-lts)を参考に、必要なaptパッケージをインストールします。

```plain
> sudo apt-get install qt-sdk cmake git
```

virtualenvを使ってでテストできる環境を構築します。
この時にPySideとGhost.pyをpipを利用してインストールします。

```plain
> pip install virtualenv
> cd
> mkidr ghost
> rehash
> virtualenv-2.7 ghost/python
> source ghost/python/bin/activate
(python)> rehash
(python)> pip install PySide
(python)> pip install Ghost.py
```

インストールが終わったので早速テストを...

```python
>>> from ghost import Ghost
>>> ghost = Ghost()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/futoase/ghost/python/lib/python2.7/site-packages/ghost/ghost.py", line 180, in __init__
    'an X instance')
Exception: Xvfb is required to a ghost run oustside an X instance
```

... [Xvfb](http://en.wikipedia.org/wiki/Xvfb)の設定をしなければ。(Xvfbは、Xの仮想フレームバッファです)。

```plain
> sudo apt-get install xvfb libicu48 xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable x-ttcidfont-conf
```

(注)以上のパッケージをインストールしても、以下のエラーが出てしまうのですがここでは割愛します...設定ファイルをいじってコメントアウトすれば良いだけ。

```plain
[dix] Could not init font path element /var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType, removing from list!
```

```plain
> rehash
> Xvfb :10 -screen 0 1024x768x24 &
```

Xvfbが起動したら、早速再テストしてみます。

```python
Python 2.7.3 (default, Nov 25 2012, 20:43:34)[GCC 4.6.3] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> from ghost import Ghost
>>> ghost = Ghost()
[dix] Could not init font path element /var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType, removing from list!
>>> page, resources = ghost.open("http://yahoo.co.jp")
>>> page.http_status200
>>> 'Yahoo' in ghost.contentTrue
>>> ghost.capture_to('yahoo.png')
```

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/how-to-use-ghost-py/yahoo-1.png)

キャプチャーには成功しました。が文字が豆腐になっちゃっています。フォントがないから。フォントをインストールします。

```plain
> sudo apt-get install ttf-vlgothic
> fc-cache -fv
```

再度キャプチャ。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/how-to-use-ghost-py/yahoo-2.png)

ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!ということで成功。これでサーバー上でクロールさせて画像キャプチャだの、mechanize的な使い方もできるようになりました。

Ghost.py便利だし、何か活かしていきたいな。
