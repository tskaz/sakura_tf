# [Deproying Sample] さくらのクラウドでterraform - apprun専有型をterraformで一撃deploy

## Deployment Summary
さくらのクラウドAppRun専有型を、terraformで実行するコードです。
事前に実行したいコンテナイメージは作成済であること、コンテナイメージや環境変数はvariables.tf、指定可能です。
※secret値等、環境変数で扱いづらい変数はapprun_d.tf側でも指定可能。

## 動作確認日
2026/10/18

## 動作確認済バージョン

|tools||
|---|---|
|terraform|1.14.6|

|terraform-providers||
|---|---|
|sacloud/sakura|3.14.1 |
|hashicorp/local|2.9.1|
|hashicorp/null|3.3.2|


## 利用する手順

1. コードをcloneで取得、本コードのフォルダへ移動します。
~~~
git clone https://github.com/tskaz/sakura_tf.git
cd 02_apprun_dedicated_sample
~~~

2. 作成したい環境に合わせ、 variables.tf ファイルを編集します。
~~~
vi variables.tf
~~~


3. terraformを init/plan/apply の順で実行します。
password変数に初期値を指定しない場合はplan/applyの際に入力してください。
~~~
terraform init
terraform plan
terraform apply

var.secret_db_pass
  Enter a value: #PWを入力後Enter
~~~

deploy直後はoutputで表示されるurlにはアクセスできないので注意！

4. さくらのクラウド コントロールパネルからアプリケーションのアクティブ化

deploy完了後、さくらのクラウド apprun専有型コントロールパネルで対象アプリケーションのバージョンをアクティブ化します。

https://manual.sakura.ad.jp/cloud/apprun-dedicated/operation.html#id29

5. アプリケーションのURLへアクセスする
outputで表示されたurlへアクセスする

--------------------

Outputs:

apr_info = {
  "apr_appurl" = "http://[IPアドレス].sslip.io"
  "apr_lb_global_ip" = "[IPアドレス]"
}
--------------------

6. (環境削除の前に) アプリケーションの非アクティブ化

deploy完了後、さくらのクラウド apprun専有型コントロールパネルで対象アプリケーションのバージョンを非アクティブ化にします。

https://manual.sakura.ad.jp/cloud/apprun-dedicated/operation.html#id29

7. 環境の削除

destroyコマンドで削除します。
password変数の入力を求められる場合は任意の値(構築時と同じでなくてもOK)を入力してください。
```
terraform destroy --auto-approve
```
