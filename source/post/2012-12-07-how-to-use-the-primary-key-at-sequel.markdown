---
title: "How to use the primary key at sequel"
date: 2012-12-07 22:30
comments: true
tags: [Advent Calendar 2012, Ruby, Sequel]
---

# SequelのModelでPrimary keyで指定した値を設定したい場合

ふつーに[Sequel](http://sequel.rubyforge.org/)でTableとModel作って、
Primary keyに好きな値を指定してレコードを作ろうとすると
エラーを吐いてしまいます。

```ruby
# -*- coding:utf-8 -*-

require 'sequel'

Sequel::Model.plugin(:timestamps, :update_on_create=>true)
DB = Sequel.sqlite
DB.create_table :users do
  primary_key :id
  String :name, :null=>false
  DateTime :created_at, :null=>false
  DateTime :updated_at, :null=>false
end

class User < Sequel::Model(DB)
end

User.new(:name => "Mario").save
User.new(:id => 3, :name => "Luigi").save

puts "Mario: " + User.find(:name => "Mario")[:id].to_s
puts "Luigi: " + User.find(:name => "Luigi")[:id].to_s
```

以上のコードを実行すると、

```plain
vendor/bundle/ruby/1.9.1/gems/sequel-3.42.0/lib/sequel/model/base.rb:1775:in `block in set_restricted': id is a restricted primary key (Sequel::Error)
```

うおっ、Luigiのidに3を指定することができない...

READMORE

# unrestrict_primary_key

Modelに対し[unrestrict_primary_key](http://sequel.rubyforge.org/rdoc/classes/Sequel/Model/ClassMethods.html#method-i-unrestrict_primary_key)を定義することで問題が解決します。
本来のprimary_keyの役割は、とか思ったりするけど仕方ない場面があったりするでしょう。
(例えばデータ依存度合いが大きく、結合度合いも大きい仕方なしなコードの動作検証したいとか)


上記のコードに対し対応を行ったコードを提示いたします。

```ruby
# -*- coding:utf-8 -*-

require 'sequel'

Sequel::Model.plugin(:timestamps, :update_on_create=>true)
DB = Sequel.sqlite
DB.create_table :users do
  primary_key :id
  String :name, :null=>false
  DateTime :created_at, :null=>false
  DateTime :updated_at, :null=>false
end

class User < Sequel::Model(DB)
  unrestrict_primary_key
end

# 以下の形でもOK
# User.unrestrict_primary_key

User.new(:name => "Mario").save
User.new(:id => 3, :name => "Luigi").save

puts "Mario: " + User.find(:name => "Mario")[:id].to_s
puts "Luigi: " + User.find(:name => "Luigi")[:id].to_s
```

以上の形に修正し、コードを実行します。

```plain
> bundle exec ruby test.rb
Mario: 1
Luigi: 3
```

解決しましたね。
