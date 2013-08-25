---
title: "pyqcheck-release"
date: 2012-09-01 15:05
comments: true
tags: [python, Quick Check]
---

# PyQCheckをリリースしました。

  [Github上のリポジトリ](https://github.com/futoase/PyQCheck)のREADME.mdにインストール方法を書いておきました。ここで改めてインストール方法については記載することは省略します。

## PyQCheckとはなんなのか

  README.mdに書いているんですが、Quick check-likeなランダムデータをとある関数に対して渡して返り値を確認することでとある関数が正常に動作しているのかテストを行うことができるテストフレームワークとなっております。

## 注意点

  Python 2.7.3 での動作を確認しています。Python 3.xは多分対応していません。(エラー処理のキャッチ部分を直さないといけないので...) 2to3 した後の動作確認を行うのが面倒なので、今後のバージョンアップに関しては Python 3.3 以上を対象としていきます...

# テストを書いてみよう

  適当なテストスクリプトについては以下にありますが、例を書いてみましょう。

READMORE

```python
from pyqcheck.pyqcheck import PyQCheck, set_arbitrary

class ColdError(BaseException):
  pass

class HotError(BaseException):
  pass

@set_arbitrary(
  ('integer', dict(min=-20, max=50)),
  exceptions=(ColdError, HotError)
)
def tropical(temperature):
  if temperature < -10:
    raise ColdError
  if temperature > 40:
    raise HotError

  return True

if __name__ == '__main__':
  PyQCheck(verbose=True).run(10).result()
```

以上のコードをpyqcheck-test.pyというファイルに書き出し、ファイルを保存して実行をしてみると、テスト結果が表示されます。

```python:test-result
start test.
finish.
----- PyQCheck test results... -----
label: no label
success: 7
failure: 0
exceptions: 
  HotError: 2
  ColdError: 1
verbose: 
  ☃  tropical(45)
  ☃  tropical(41)
  ☀  tropical(6)
  ☀  tropical(31)
  ☀  tropical(37)
  ☀  tropical(10)
  ☀  tropical(-4)
  ☀  tropical(30)
  ☃  tropical(-15)
  ☀  tropical(-10)
-----
```

エラーがきちんと補足されていますね。
正常な場合の返り値については、TrueやFalse以外にtupleやstrなどを指定することができます。
Arbitraryについては範囲指定を行うこともできます。(README.mdには細かく記載していない)
ランダムテスト以外に使える用途としてはテスト用のレコードを1億行分作りたい、ランダムデータ入りで、みたいな感じでしょうか。

# 今後

もうちょっと便利に利用できるようにしたいと思います。
