---
title: "Task tool of cli by python"
date: 2013-01-09 16:47
comments: true
tags: [Python, pynt]
---

# PythonでRakeみたいなものがほしい

[Scons](http://www.scons.org/)や[waf](http://code.google.com/p/waf/)などのビルドツールがあるけど、なんかRakeとは違う。
ソフトウェアをビルドする用途のものだし、タスクを実行するようなものではない。
[paver](http://paver.github.com/paver/)はタスクを登録して実行できるようだけど、setuputils風の関数に設定を書いたりとかちょっと面倒そう。
[Cake](https://github.com/alexcepoi/cake)はそこそこ良いけどもうちょっと簡単なものがないかな、
って思って探したら[pynt](https://github.com/rags/pynt)というものを見つけました。
ということで早速使ってみます。

<!-- more -->

# pyntをインストールする

## Python 2.xをご利用の方々

PyPIに登録されているので、以下のコマンドを実行するだけでOK。

```plain
> pip install pynt
```

または

```plain
> easy_install pynt
```

## Python 3.3をご利用の方々

forkしてPython 3.3に対応させました。
[ここのリポジトリ](https://github.com/futoase/pynt)をcloneし、
対応branchをcheckoutしてもらえるだけでOKです。

```plain
> git clone git://github.com/futoase/pynt.git
> cd pynt
> git checkout -b support-of-the-python3.3 origin/support-of-the-python3.3
> python setup.py install
```

# pyntを使ってtaskを構築する

[example.py](https://github.com/futoase/pynt/blob/support-of-the-python3.3/example.py)を参考に、taskを作ってみましょう。

```python 
#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys
import os
from pynt import task, build

@task()
def whoami():
    print(os.system('whoami'))

@task()
def one():
    print('one')

@task(one)
def two():
    print('two')

@task(two)
def three():
    print('three')

if __name__ == '__main__':
    build(sys.modules[__name__], sys.argv[1:])
```

以上のスクリプトに対し、実行権限(chmod +x)を付けて、叩いてみます。

```plain
> ./test_task.py 
usage: test_task.py [-h] [-l] [task [task ...]]

positional arguments:
  task              perform specified task and all it's dependancies

optional arguments:
  -h, --help        show this help message and exit
  -l, --list-tasks  List the tasks


Tasks in build file ./test_task.py:
  one                   
  three                 
  two                   
  whoami  
```

Tasks in build file... にてtask一覧が出たので、試しにtaskを実行してみます。

```plain
> ./test_task.py whoami                                                
[ test_task.py - Starting task "whoami" ]
matsuzakikeiji
0
[ test_task.py - Completed task "whoami" ]

> ./test_task.py one                                 
[ test_task.py - Starting task "one" ]
one
[ test_task.py - Completed task "one" ]
> ./test_task.py two                    
[ test_task.py - Starting task "one" ]
one
[ test_task.py - Completed task "one" ]
[ test_task.py - Starting task "two" ]
two
[ test_task.py - Completed task "two" ]
> ./test_task.py three 
[ test_task.py - Starting task "one" ]
one
[ test_task.py - Completed task "one" ]
[ test_task.py - Starting task "two" ]
two
[ test_task.py - Completed task "two" ]
[ test_task.py - Starting task "three" ]
three
[ test_task.py - Completed task "three" ]
```

Decolatorに関数オブジェクトを渡しておくと、そのtaskとして割り当てられた
関数を実行した後にデコレートした関数を実行する形になります。

... 簡易なtask管理スクリプトとしては良いかもしれません。けど、
できればやはりrakeのようなコマンドとして利用できるとよりいいかな。
taskを管理しているファイル名ごとに叩くファイル名、pathが異なると面倒なので。
