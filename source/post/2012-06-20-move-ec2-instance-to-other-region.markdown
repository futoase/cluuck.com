---
title: "move ec2 instance to other region"
date: 2012-06-20 12:31
comments: true
tags: [AWS, EC2, EBS]
---

# EC2インスタンスを他のリージョンに移動したい
- EBSを利用したEC2インスタンスを他リージョンに移動させるための手順がよくわからんのでまとめた。

## 作業手順
1. [S3 bucket](http://aws.amazon.com/jp/s3/)に現行のAMI(Amazon Machine Image)をアップロードする
2. S3 bucketにイメージをアップロードした後、移行先でインスタンスを作成
3. インスタンスの動作を確認できたら[EBS](http://aws.amazon.com/jp/ebs/)をattachした形でインスタンスを起動できるようAMI(Amazon Machine Image)を作成する
4. 作成したAMIを元にインスタンスを作成する
5. インスタンスの動作を確認して問題がなければ終わり

# 事前作業

注意点として、EC2インスタンスのデータ転送量はAWS内(リージョンが異なったとしても)以外でのやり取りでは[お金が無駄にかかると言う点](http://aws.amazon.com/jp/ec2/#pricing)。そのため、EC2インスタンス内での作業を行うようにしている。

- セッション切れをおこなさないようにするためにServerAliveInterval設定をする

```plain:~/.ssh/config
ServerAliveInterval 30
```

- sshdの PermitRootLogin を yes にする

```plain:/etc/ssh/sshd_config
PermitRootLogin yes
```

- X.509秘密鍵及び証明書、及びEC2インスタンス作成時に利用しているcert-ec2.pem(証明書)を用意しておく

READMORE

# 移動対象(移動元)のインスタンス内での作業
## AMIを作成する

- 作成時にアーキテクチャを問われるので適切なものを選択する

```plain:create-AMI 
$ ec2-bundle-vol \
> -d /mnt \
> -k {秘密鍵} \
> -c {証明書} \
> -u {AWSアカウントUser ID}
```

- [ec2-bundole-volについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/CLTRG-ami-bundle-vol.html)

## 移動先のリージョンで利用できるようにする
- ec2-migrate-manifestを実行することで移動先リージョンで利用できるようにする

```plain:migrate-manifest
$ ec2-migrate-manifest \
> -k 秘密鍵 \
> -c 証明書 \
> --manifest /mnt/image.manifest.xml \
> --region "移動先リージョン名" \
> --access-key "アクセスキー" \
> --secret-key "シークレットキー"
```

- [ec2-migrate-manifestについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/CLTRG-ami-migrate-manifest.html)

- 作成が無事終了したら標準出力に以下の表示が出る

```plain:ec2-migrate-manifest-success
Successfully migrated /mnt/image.manifest.xml
It is now suitable for use in {移動先のリージョン名}
```

## 作業イメージをS3 bucketに対してアップロードを行う

```plain:ec2-upload-bundle
$ ec2-upload-bundle \
> -a {AWSアクセスキー} \
> -s {シークレットキー} \
> -b {アップロードを行うS3バケット名} \
> -d /mnt \
> -m /mnt/image.manifest.xml
```
- [ec2-upload-bundleについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/CLTRG-ami-upload-bundle.html)

## ec2-migrate-imageを実行する
- S3 bucketにアップロードしたイメージについて他のリージョンで利用できるようにする

```plain:ec2-migrate-bundle
$ ec2-migrate-bundle \
> -k {秘密鍵} \
> -c {証明書} \
> -a {AWSアクセスキー} \
> -s {AWSシークレットキー} \
> --bucket {AMIをアップロードしたS3 bucket名} \
> --manifest "image.manifest.xml" \
> --location {アップロードを行うS3 bucketのregion(EU,USなど)}  \
> --region {EC2の移動先対象region} \
> --destination-bucket {移動先のregionで利用するAMIをアップロードするS3 bucket名}"
```

- [ec2-migrate-bundleについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/CLTRG-ami-migrate-bundle.html)

## AMIを作成する
- S3 bucketにアップロードしたAMIを使ってAMIを作成する

```plain:ec2-register
$ ec2-register 
> {ec2-migrate-bundleでアップロードしたbundle-imageのS3 bucket名}/image.manifest.xml \
> -K {秘密鍵} \
> -C {証明書} \
> --region {移動先対象リージョン}
```

- AMI作成が移動先のregionにて正常に終了した場合、作成されたAMIのIDが表示される

```plain:ec2-register-success
IMAGE   ami-hogehoge
```

- [ec2-registerについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RegisterImage.html)

# 移動先regionでのAmazon Management Consoleで作業をする
- 作成したAMIを元にEC2の新規インスタンスを作成し、起動できるか確認を行う
1. Amazon Management Consoleにて作成したAMIが存在することを確認する
    - 移動先regionに切り替えて確認する
2. AMIの存在を確認できたら、作成したAMIを元にEC2インスタンスを新規に作成する
    - AvailavilityZone(AZ)については、今後のEBSへのイメージ作成のために利用するので設定をきちんとしておくこと(適当に割り当てられても良いならそのままでよい...)
3. instance storeという形でRoot Deviceが設定されているか確認する
4. EC2インスタンスを作成し終え、Stateが"running"になっていることを確認できたら、ssh経由でサーバにログインが行えるか確認する。
    - ssh -i {EC2インスタンス作成時に利用した秘密鍵} root@{EC2インスタンスホスト名}
5. 新規作成したEC2インスタンスに対し、X.509の鍵ペア(秘密鍵,証明書)及びcert-ec2.pem(移動元のEC2インスタンス作成時に設定されるEC2証明書)をアップロードしておく
6. root以外のユーザーでもログインが行えるよう、公開鍵を作成したEC2インスタンスに対してアップロードする。(authorized_keysとか...id_rsa.pubとかそんなの)

# 移動先regionで起動したEC2インスタンス内での作業

## EBSイメージの作成

- インスタンスにログインを行い、EBSイメージを作成する

```plain:ec2-create-volume
$ ec2-create-volume \
> --size 30 \ # 30GBで作成している
> --availability-zone {EC2インスタンスを作成したときに選択したavailability-zone} \
> --region {対象リージョン} \
> -K {秘密鍵} \
> -C {証明書}
```
- 作成が正常に終了したあと、作成したボリューム情報が表示される

```plain:ec2-create-volume-success
VOLUME  vol-hogehoge    30              {region名}      creating        2012-03-01T00:01:35+0000
```

- [ec2-create-volumeについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-CreateVolume.html)

## EC2インスタンスに対してEBSボリュームをattachする
- attachを行うことでEC2インスタンスがEBSを利用することができる

```plain:ec2-attach-volume
$ ec2-attach-volume {対象ボリューム名} \
> --instance {attachするインスタンス名} \
> -d {デバイス名} \
> --region {対象リージョン} \
> -K {秘密鍵} \
> -C {証明書}
```

- attachが正常に終了したあと、EBSボリュームをEC2インスタンスにAttachした旨の情報が表示される

```plain:ec2-attach-volume-success
ATTACHMENT      vol-hogehoge    i-hugahuga      /dev/sdf       attaching      2012-03-01T00:04:03+0000 
```

- [ec2-attach-volumeについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-AttachVolume.html)

### attachする際に利用できるデバイス名について
- 指定できるデバイスについてはLinux/Unix系のインスタンスではsd[f-z][1-6]となっている
    - [ソース元](http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/ebs-attaching-volume.html)
- /dev/sdfをattachするデバイスとして指定した場合、/dev/xvdfというデバイスでmappingが行われる
    - AWSそのものがXenを利用して構築されたサービスであり、Xen Virtual Storageによるデバイスマッピングが行われるため。
    - /dev/xvd[f-z][1-6]にマッピングされる

## attachされたEBSボリュームについてext3でフォーマットを行う

```plain:format-for-ebs-volume
$ mkfs.ext3 /dev/xvdf
$ fsck /dev/xvdf # 念のため
```

## 移行したEC2インスタンスのイメージを/mnt以下に作成する

```plain:ec2-bundle-vol
$ ec2-bundle-vol \
> -d /mnt \
> -k {秘密鍵} \
> -c {公開鍵} \
> -u {AWSのUserID} \
> --ec2cert {EC2インスタンス作成時に利用した証明書(cert-ec2.pem)}
```

## ec2-bundle-volの分割AMIを結合する

```plain:unbundle
$ mkdir -p /mnt/unbundle
$ ec2-unbundle \
> -m /mnt/image.manifest.xml \
> -k {秘密鍵} \
> -s /mnt \ # source
> -d /mnt/unbundle #destination
```

- [ec2-unbundleについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/CLTRG-ami-unbundle.html)

## 作成した結合AMIをattachしたEBSに対して書き込む
- ddコマンドを利用してEBSイメージに対し書き込みを行う

```plain:data-copy
$ dd if=/mnt/unbundle/image of=/dev/xvdf
$ fsck /dev/xvdf # 念のため
```

## EBSボリュームのsnapshotを作成する
- EBSイメージのsnapshotを作成し、インスタンス作成のためのAMIとして利用する
- snapshot作成にはかなり時間がかかる

```plain:ec2-create-snapshot
$ ec2-create-snapshot \
> {/dev/xvdfとしてattachしたEBS ボリューム名} \
> --region {対象リージョン} \
> -K {秘密鍵} \
> -C {証明書}
```

- [ec2-create-snapshotについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-CreateSnapshot.html)

## snapshotからAMIを作成する
- EC2インスタンスを作成するためのAMIを作成する

```plain:ec2-register-snapshot
$ ec2-register \
> --snapshot {対象スナップショット名} \
> --description="snapshotの説明" \
> --architecture {指定アーキテクチャ} \
> --root-device-name /dev/sda1 \
> --name "AMI名称" \
> --region {対象リージョン} \
> -K 秘密鍵 \
> -C 証明書 \
> --kernel {インスタンスで利用しているKernel ID(AKI)}
```

- AMIの作成に成功するとAMI名が表示される

```plain:ec2-register-success
IMAGE   ami-hogehoge
```

## Amazon Manage ConsoleでEC2インスタンスを作成する
- 作成したAMIでEC2インスタンスを新規に作成する
- インスタンス作成後、ログインが行えることを確認する
- 移動前に利用していたX.509の秘密鍵,証明書のペア及び移動前のEC2インスタンスで利用していた証明書(cert-ec2.pem)を新規作成したEC2インスタンスにアップロードする

# EBSボリュームを拡張する
- EC2インスタンスを作成後、rootボリュームは10GB分としてしか認識されていない。
- AMIを作成したインスタンス(S3 bucketにて作成したInstanceイメージ)のHDD容量のままになってしまうため。
- デバイスのファイルシステムサイズがシステム上でのマウントポイントでは利用されていないためだ。
- [resize2fs](http://linuxjm.sourceforge.jp/html/e2fsprogs/man8/resize2fs.8.html)によりマウントポイントをデバイスサイズと同容量のものにする。

```plain:df-of-before-resize2fs
$ df
Filesystem           1K-ブロック    使用   使用可 使用% マウント位置
/dev/xvda1            10321208   3900136   5896784  40% /
tmpfs                   313260         8    313252   1% /lib/init/rw
udev                    291840        28    291812   1% /dev
tmpfs                   313260         4    313256   1% /dev/shm
```

- resize2fsによりEBSボリュームのファイルシステムサイズとマウントポイントのサイズを合わせる

```plain:execute-resize2fs
$ resize2fs /dev/xvda1

resize2fs 1.41.12 (17-May-2010)
Filesystem at /dev/xvda1 is mounted on /; on-line resizing required
old desc_blocks = 1, new_desc_blocks = 2
Performing an on-line resize of /dev/xvda1 to 7864320 (4k) blocks.
The filesystem on /dev/xvda1 is now 7864320 blocks long.
```

```plain:df-of-after-resize2fs
$ df 

/dev/xvda1            30963708   3905204  25485896  14% /
tmpfs                   313260         8    313252   1% /lib/init/rw
udev                    291840        28    291812   1% /dev
tmpfs                   313260         4    313256   1% /dev/shm
```

- resize2fsによってEBSボリュームのファイルサイズとマウントポイント(root)が一致するようになった

# インスタンス移動終了後に気をつけておくべき点
- EC2インスタンス作成時に利用していた鍵でログインを行うため、rootユーザでのログインを許容していた設定を修正する
    - /etc/ssh/sshd_configにあるPermitRootLogin yesをPermitRootLogin noにする

# インスタンスが起動しない場合のトラブル
ec2-get-console-output {対象インスタンス名}を実行する。

- [ec2-get-console-outputについて(公式ドキュメント)](http://docs.amazonwebservices.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-GetConsoleOutput.html)
