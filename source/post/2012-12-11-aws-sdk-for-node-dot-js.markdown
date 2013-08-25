---
title: "AWS SDK for Node.js"
date: 2012-12-11 22:30
comments: true
tags: [Advent Calendar 2012, AWS, node.js, JavaScript]
---

# AWS SDK for Node.js

[AWS SDK for Node.jsのプレビュー版がリリースされた](http://aws.typepad.com/aws_japan/2012/12/aws-sdk-for-nodejs-now-available-in-preview-form.html)という
話を聞いたので、試しに利用してみます。

[AWS Documentationに掲載されているサンプル](http://docs.amazonwebservices.com/nodejs/latest/dg/nodejs-dg-aws-sdk-for-node.js.html)を元に試します。

# npm aws-sdkのセットアップ

node.jsのセットアップについては、各自ご自由に。
個人的には[nodebrew](https://github.com/hokaccha/nodebrew)を利用する方法をオススメします。

```plain
> mkdir -p ~/Sandbox/aws-sdk-for-node
> cd ~/Sandbox/aws-sdk-for-node
> npm install aws-sdk
```

READMORE

# S3にオブジェクトをアップロードするテスト

AWSにアカウントを登録していることが前提になります。
accessKeyId, secretAccessKeyについてはAWSのsecurityCredentialsにある
アクセス証明書項を参考にしてください。

```javascript
var AWS = require('aws-sdk');

AWS.config.update({
  accessKeyId: '',
  secretAccessKey: ''
});

AWS.config.update({
  region: 'us-east-1'
});

var s3 = new AWS.S3();

s3.client.createBucket({
  Bucket: 'futoaseBucket'
}).done(function(response) {
  console.log('Put object!');
  var data = {Bucket: 'futoaseBucket', Key: 'age', Body: '30'};
  s3.client.putObject(data).done(function(response) {
    console.log('Success!');
  });
});
```

実行してみます。

```plain
> node s3-test.js
Put object!
Success!
```

S3のBucketについて、futoaseBucketが作成されているか確認してみます。

![Screen shot](https://dl.dropbox.com/u/614755/futoase.github.com/aws-sdk-for-node-js/screen-1.png)

作成されています。
APIのラッパーを自前やサードパーティーで実装されたものを使うよりも、
Amazonが出しているものを使うほうが安心感があるので良いですね(変更に追いつくのもだるいし...)。
