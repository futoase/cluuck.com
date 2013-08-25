---
title: "ctype_digit vs preg_match"
date: 2012-07-10 02:52
comments: true
tags: [PHP, Programming, Benchmark] 
---

# ctype digit と preg matchでの文字列比較速度
  そういやctype_digitのほうが早いみたいなの言われていないっけ、と思ったので確認してみた。

# スクリプトの準備

ランダムな文字列を生成するロジックを用意する。文字列判定のためだけに利用する単純な奴。

```php
<?php

function generate_random_strings($type='letters')
{
    switch($type){
      case 'digits':
        $asset = '0123456789';
        break;
      case 'letters':
      default:
        $asset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        break;
    }

    $length = strlen($asset);
    $max = rand(4, 32);
    $result = array();
    for($i = 0; $i < $max; $i++){
        array_push($result, $asset[rand(0, $length-1)]); 
    }

    return implode($result);
}

function generate_list($max=100, $type='letters')
{
  $result = array();
  for($i = 0; $i < $max; $i++){
    array_push($result, generate_random_strings($type));
  }
  return $result;
}

function generate_letters_list($max=100)
{
  return generate_list($max);
}

function generate_digits_list($max=100)
{
  return generate_list($max, 'digits');
}
```

READMORE

generate letters listを呼び出してやるとランダムな文字列を生成する。文字列を生成してマッチングするかどうかとかは以下のようになる...

```plain:stdout
is invalid 0cvIDbih
is invalid oD6MJS9zbgVqpg8po14Md
is invalid DfAbJC
is invalid Qcyk8aTR
is invalid iTg4avb8Lp0G13Lu9bwIDGpG5zF6jn6s
is invalid cn7xo69EWFvQgQPidoMKDjF3OBc2xvZ
is invalid IWXWSWqEsMlzt1Iw
is invalid l6JuCC
is invalid 3F1r0QQyDEllrCQJe19ySHUYSRxdj0cd
is invalid 4umLaLfFWqWo7v
is invalid YuRH2CvLkSOuI
is invalid x4MRhnSSsnEJ9TGvduQV2Jnn
is invalid y6YSEFfz
is invalid XGvFoOT
is invalid nTDUeGfVr7uFkE4gtMLZSa6FH
is invalid aW6UGkD94IG9
is invalid X6OthjnnC0ZsI
is invalid odxHekEYQOrPI0lIj9FYtM8H0AxP
is invalid 5F893Fdd92TOkzmaLVkLq8526
is invalid SxZyhU4fTXKX1KPLoa
is valid 3634128239310
is valid 455261892945378
is valid 021362545948052518
is valid 796615068753784147792731794
is valid 0217273423111
is valid 494909688952031472789953
is valid 875982376386975
is valid 38970342022085362851099727425
is valid 18806830042341887073182165907408
is valid 8997398721239
is valid 108426
is valid 32223974803700198920169
is valid 7002268690
is valid 30679607618607909691301628498
is valid 816495003711419328919
is valid 219404480207603
...
```

<!-- more -->

# ctype_digitsでの計測スクリプト

```php
<?php

require_once('string_generator.php');

function validate($variables)
{
  foreach($variables as $v){
    if(ctype_digit($v)){
      echo "is valid ";
    }
    else{
      echo "is invalid ";
    }
    echo $v . "\n";
  }
}

validate(generate_letters_list(100000));
validate(generate_digits_list(100000));
```

# preg_matchでの計測スクリプト

```php
<?php

require_once('string_generator.php');

function validate($variables)
{
  foreach($variables as $v){
    if(preg_match('/^[0-9]+$/', $v) !== 0){
      echo "is valid ";
    }
    else{
      echo "is invalid ";
    }
    echo $v . "\n";
  }
}

validate(generate_letters_list(100000));
validate(generate_digits_list(100000));
```

まあ、どっちもどっちで変わらないですよね。比較の箇所しか違わない。生成する数も100,000と変わらない。

# 計測結果
以下の環境で計測した。

- MacOS X 10.7 Lion
    - 2011 Mid model
    - CPU Core i7(Sandy) 2core 4thread
    - Memory 4GB
    - SSD 256GB
- PHP
    - Version 5.3.10 (古い...)
- iTerm2上でコマンドを実行
    - screenやtmuxは使わず、別タブを開き単独のプロセスとして動作させる     

## ctype_digit での計測結果

```plain
# 1回目
php ctype_digit_count.php  4.05s user 0.74s system 84% cpu 5.697 total
# 2回目
php ctype_digit_count.php  4.06s user 0.62s system 85% cpu 5.461 total
# 3回目
php ctype_digit_count.php  4.00s user 0.62s system 85% cpu 5.410 total
```

## preg_match での計測結果

```plain
# 1回目
php preg_match_count.php  4.46s user 0.66s system 87% cpu 5.851 total
# 2回目
php preg_match_count.php  4.38s user 0.66s system 86% cpu 5.857 total
# 3回目
php preg_match_count.php  4.34s user 0.65s system 86% cpu 5.778 total
```

変わらない... 若干preg_matchのほうが遅いかなぁってところだけど、チェックするための生成文字列リストの量を考えると、この程度の差って変わらないと言えるよなぁ...

# 結論
  測定方法がまずいのかと思い、オーバーヘッドが出ることを承知でPearのBenchmarkパッケージを利用して計測してみたのだけどそれでも変わらなかった。ctype_digitについては"渡された文字列がすべて数値であればtrueを返すことを保証する"という関数であるということだけ頭におけばよい、早いとか最適とか色々と他のBlogで書かれているけど、そんなことなかったのか...リストの生成コストやforeachによるリストのイテレーション速度とか、echoの標準出力への転送とか、改行コードと文字列の連結とか、色々コストかかるところはあるが同一だし、そこで大きな差がないというのがなぁ。
