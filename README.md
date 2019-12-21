# タスク&ナレッジ管理システム (プロジェクト毎)
Ruby on Railsの練習用に作成したものです。 作業日数3日(Railsで3作目)

DEMO ※管理ユーザーでのデモ動作です。     
[https://www.petitmonte.com/rails-demo/ptkms](https://www.petitmonte.com/rails-demo/ptkms)  
      
[mpp_ptkmsの意味]  
mpp = My Practice Project  
ptkms = Project Task & Knowledge Management System 
   
## 1. 環境
・Ruby 2.6.5  
・Rails 6.0.2 (2019/12/18版)  
・MariaDB 10.2.2以上 (MySQL5.5.8以上でも可)  
 
 
## 2. インストール方法
私のメモ用に書いておきます。  
  
### database.yml  
config/database.ymlでデータベース設定を行います。  
  
### bundle  
```rb
bundle install 
```

### マスタキーの生成 
・/config/master.key  
・/config/credentials.yml.enc  
は削除しています。次のコマンドで再生成します。  
```rb
EDITOR=vi bin/rails credentials:edit   
```  
ファイル生成後、credentials.yml.encの編集画面が表示されるので:q!で終了します。

development.rb/production.rbの両方に  
```rb
config.require_master_key = true  
``` 
を定義しているのでマスタキーの生成は必須です。   
  
### Webpackerのインストール  
node_modulesフォルダ及びyarn.lockファイルを削除していますので次のコマンドでインストールします。  
```rb  
bin/rails webpacker:install  
```
### フォルダの生成
app/assetsにimagesフォルダを手動で生成する。※GitHubが空のディレクトリを生成できない為。  
※コレを行わないと「Completed 500 Internal Server Error」になりますのでご注意。  
  
### CSS/JSファイルをプリコンパイルする
```rb  
bin/rails assets:precompile  
```  

### 管理ユーザーの作成
```rb  
bin/rails c  
  
user = PtkmsUser.new(name: '名前', password: 'パスワード', password_confirmation:'パスワード', admin: true)  
user.save  
exit 
```  

### 一般ユーザーの作成
```rb  
bin/rails c  
  
user = PtkmsUser.new(name: '名前', password: 'パスワード', password_confirmation:'パスワード', admin: false)  
user.save  
exit 
```  
  
## 3. Rails6プロジェクトの各種初期設定
その他は次の記事を参照してください。  
  
[Rails6プロジェクトの各種初期設定](https://www.petitmonte.com/ruby/rails6_project.html)  
