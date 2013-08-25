---
title: "I tried to use redis 2.6"
date: 2012-12-02 23:16
comments: true
tags: [Advent Calendar 2012, Lua, Redis]
---

# Redis 2.6から内包されているLuaを試す

[Redis 2.6](http://redis.io/)に内包されている[Lua](http://www.lua.org/)について挙動を確認したいと思います。
というかいつの間にかRedis 2.6.6がリリースされているし、チェックを怠りすぎてしまっていました。

# Mac OS X で動作チェック

homebrewを利用してRedisをインストールするのがとても簡単です。というかそれで充分です。

```plain
> homebrew install redis
```

redis-serverコマンドによってredisを起動します。

```plain
> redis-server /usr/local/etc/redis.conf       
[3295] 02 Dec 22:59:46.845 * Max number of open files set to 10032

                _._                                                 
           _.-``__ ''-._                                            
      _.-``    `.  `_.  ''-._           Redis 2.6.6 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                  
 (    '      ,       .-`  | `,    )     Running in stand alone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 3295
  `-._    `-._  `-./  _.-'    _.-'                                  
 |`-._`-._    `-.__.-'    _.-'_.-'|                                 
 |    `-._`-._        _.-'_.-'    |           http://redis.io       
  `-._    `-._`-.__.-'_.-'    _.-'                                  
 |`-._`-._    `-.__.-'    _.-'_.-'|                                 
 |    `-._`-._        _.-'_.-'    |                                 
  `-._    `-._`-.__.-'_.-'    _.-'                                  
      `-._    `-.__.-'    _.-'                                      
          `-._        _.-'                                          
              `-.__.-'                                              
[3295] 02 Dec 22:59:46.846 # Server started, Redis version 2.6.6
[3295] 02 Dec 22:59:46.849 * DB loaded from disk: 0.003 seconds
[3295] 02 Dec 22:59:46.849 * The server is now ready to accept connections on port 6379
```

いつの間にAAがでるように...

READMORE

起動したので、redis-clientを利用して起動してみます。

```plain
> redis-cli
redis 127.0.0.1:6379>
```

OK。試しに何かsetしてみましょう。

```plain
redis 127.0.0.1:6379> hset futoase age 30
(integer) 1
redis 127.0.0.1:6379> hget futoase age
"30"
```

動作確認はOK。ということで早速内包されたLuaでチェックしてみましょう。
[Redisに内包されたLuaを利用するにはevalコマンドを利用する](http://redis.io/commands/eval)ようです。

```plain
redis 127.0.0.1:6379> eval "return {KEYS[1], KEYS[2], ARGV[1], ARGV[2]}" 2 key1 key2 first second
1) "key1"
2) "key2"
3) "first"
4) "second"
```

Redisに内包されているLuaのバージョンは、[ドキュメントに書かれているけど5.1](http://redis.io/commands/eval)。
evalの第二引数(ここで2としているもの)は、KEYSに引き渡す引数の数を指定する形になっています。
ARGVには、引数が渡される形になっています。(KEYSのうまい活用方法なんだろう？)

for文を使って繰り返し、且つforで利用している値を突っ込むことができます。

```plain
redis 127.0.0.1:6379> eval "for i = 1, 100  do redis.call('set', 'num-'.. i, i) end" 0
(nil)
redis 127.0.0.1:6379> eval "local res = {} for i = 1, 100 do table.insert(res, redis.call('get', 'num-'..i)) end return res" 0
  1) "1"
  2) "2"
  3) "3"
  4) "4"
  5) "5"
  6) "6"
  7) "7"
…
 95) "95" 
 96) "96"
 97) "97"
 98) "98"
 99) "99"
100) "100"
```

素晴らしい…resというテーブルに値を突っ込んで返すというものを書いてみました。

とあるkeyからfieldすべてを取得し、
且つとある文字列にマッチするものだけ、resに突っ込んで返す(hashから選択)というものを書いてみます。

```plain
redis 127.0.0.1:6379> hset 'user' 'takeshi' 100
(integer) 1
redis 127.0.0.1:6379> hset 'user' 'moyashi' 50
(integer) 1
redis 127.0.0.1:6379> hset 'user' 'momonga' 60
(integer) 1
redis 127.0.0.1:6379> hset 'user' 'shishido' 900
(integer) 1
redis 127.0.0.1:6379> hset 'user' 'dododo' 10
(integer) 1
redis 127.0.0.1:6379> hkeys 'user'
1) "takeshi"
2) "moyashi"
3) "momonga"
4) "shishido"
redis 127.0.0.1:6379> eval "local res = {} for k,v in pairs(redis.call('hkeys', 'user')) do table.insert(res,v) end return res" 0
1) "dododo"
2) "momonga"
3) "moyashi"
4) "shishido"
5) "takeshi"
redis 127.0.0.1:6379> eval "local res = {} for k,v in pairs(redis.call('hkeys', 'user')) do if string.match(v, 'do') then table.insert(res,v) end end return res" 0
1) "dododo"
2) "shishido"
```

... redis-cliで長いスクリプトを書くのは面倒、改行すると評価されてしまうので...
次からはきちんと言語バインディングを利用して、使ってみようと思います。
便利機能だなーと思いましたとさ！

Luaのテーブルについて[pairsをforで使う場合は必要](http://www.lua.org/manual/5.1/manual.html#pdf-pairs)とか、
[table.insertを使ってテーブルに値をpushする](http://www.lua.org/manual/5.1/manual.html#pdf-table.insert)とか、
ちょっとやれば慣れると思うのだろうけどきちんと仕様確認しつつ学ばないと。
今後、インフラをやるにあたってLua覚えとくと助けになると思ってます。

