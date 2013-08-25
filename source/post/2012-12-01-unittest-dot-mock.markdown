---
title: "unittest.mock"
date: 2012-12-01 23:59
comments: true
tags: [Advent Calendar 2012, Python]
---

# unittest.mock

Python 3.3から[unittest.mock](http://docs.python.org/3/library/unittest.mock.html)というライブラリが追加されたという話が
[pyfes 2012.11](http://togetter.com/li/412188)であったのでちょっとだけ触ってみます。

```python
>>> from unittest.mock import Mock
>>> import sqlite3
>>> con = mock.connect()
>>> con
<Mock name='mock.connect()' id='4492027600'>
>>> cur = con.cursor()
>>> cur
<Mock name='mock.connect().cursor()' id='4492027920'>
>>> cur.execute('SELECT * FROM test')
<Mock name='mock.connect().cursor().execute()' id='4492028304'>
```

Mockに対しspec引数に特定のオブジェクトを渡すとそのオブジェクトの振る舞いをします。
...これだけじゃあ使い物になるかどうか判断つかないなーと思ってドキュメントを見行ったら、
ら[create_autospec](http://docs.python.org/3/library/unittest.mock.html#unittest.mock.create_autospec)という便利なヘルパーがありました。

READMORE

```python
>>> from unittest.mock import create_autospec
>>> def test_func(a,b,c):
...   return 100
... 
>>> mock_func = create_autospec(test_func, return_value=555)
>>> mock_func(1,2,3)
555
>>> mock_func(1)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<string>", line 2, in test_func
TypeError: <lambda>() missing 2 required positional arguments: 'b' and 'c'
```

関数のフックを行うことができ、これは便利そうだなと思いました。
また、Mockインスタンスのside_effectメソッドに値を渡すと、
インスタンスを呼び出した(.__call__風に)場合は渡した値がリストであればイテレータ的に、例外を渡せば例外を吐いてくれたりするようになります。
関数を渡した場合は引数をside_effectに渡した関数に引き当てて実行します。

```python
>>> from unittest.mock import Mock
>>> mock = Mock()
>>> mock.side_effect = [1,2,3,4]
>>> mock()
1
>>> mock()
2
>>> mock()
3
>>> mock()
4
>>> mock()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/Users/matsuzakikeiji/local/Python-3.3.0/lib/python3.3/unittest/mock.py", line 846, in __call__
    return _mock_self._mock_call(*args, **kwargs)
  File "/Users/matsuzakikeiji/local/Python-3.3.0/lib/python3.3/unittest/mock.py", line 904, in _mock_call
    result = next(effect)
StopIteration
>>> mock = Mock(side_effect = lambda v : v * 2)
>>> mock(100)
200
>>> mock(1000)
2000
```

unittest.mockのオブジェクトを見る限り、
自分自身で便利なモックオブジェクトが作れたり、
[テストをしやすい用にヘルパーが用意されている](http://docs.python.org/3/library/unittest.mock.html#unittest.mock.Mock.assert_called_with)ので
色々と触ったほうがいいと思います。

ただ今のこのエントリだと何に使えてどういう便利な使い方があるのか、が表現できていないしひどいものだなぁと思うので後日補足します。
