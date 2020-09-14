# アカウントのセットアップ

## ラボコンテンツのセットアップ

> これらのラボを開始する前に、ラボ全体で使用する Azure Cosmos DB アカウントを作成する必要があります。

1. セットアップを開始するには、これらの手順を含むリポジトリを [Github](https://github.com/CosmosDB/labs) から Git clone もしくはダウンロードします。

   > 各ラボに必要なリソースを自動でセットアップするには、Azure リソースセットアップ用の Powershell スクリプトを実行し、ローカルにコードファイルを作成する必要があります。Azure のセットアップには、Azure Powershell モジュールを使用します。まだインストールしていない場合は、続行する前に <https://docs.microsoft.com/ja-jp/powershell/azure/install-az-ps> にアクセスしてセットアップ手順を確認してください。 

1. Powershell セッションを開き、ダウンロードしたリポジトリのコピーを含むフォルダーに移動します。リポジトリ内で、**java\setup** フォルダーに移動します:

   ```powershell
   cd .\java\setup\
   ```

1. 現在の Powershell セッションでセットアップスクリプトを実行できるようにするには、次のように入力します:

   ```powershell
   Set-ExecutionPolicy Unrestricted -Scope Process
   ```

   > この設定は、現在の Powershell ウィンドウ内でのみ適用されます。

1. ラボの多くは、ラボの手順の開始点として使用するビルド済みのコードを参照しています。ラボのこのスターターコードを **Documents** フォルダー内の **CosmosLabs** フォルダーに自動的にコピーするには、labCodeSetup.ps1 スクリプトを実行します:

   ```powershell
   .\labCodeSetup.ps1
   ```

   > 各ラボのスターターコードは **templates** フォルダー内にあります。**Documents\CosmosLabs** 以外のフォルダーを使用するには、代わりにファイルを手動でコピーしてください。

1. Azure リソースのセットアップを開始するには、まず Azure アカウントに接続します:

   ```powershell
   Connect-AzAccount
   ```

   もしくは

   ```powershell
   Connect-AzAccount -subscription <サブスクリプション ID>
   ```

1. ラボ用の Azure リソースを作成するには、labSetup.ps1 スクリプトを実行します:

   ```powershell
   .\labSetup.ps1 -resourceGroupName 'name'
   ```

   一意である可能性が高い`名前`を選択してください。つまり、`cosmoslabsXXXXX`で、`XXXXX`はランダムな数字です。
    
    - このスクリプトは、デフォルトで _Japan East_ リージョンにリソースを作成します。別のリージョンを使用するには、上記のコマンドに **-location 'リージョン名'** を追加してください。
    
    - 指定したリソースグループが既に存在する場合、このスクリプトは失敗するため、別の `name`値を選択することもできます。または、この失敗を回避してリソースを作成するためには、上記のコマンドに **-overwriteGroup** を追加します。

1. 一部の Azure リソースはセットアップを完了するのに 10 分以上かかる場合があるため、完了までスクリプトがしばらく実行されることを想定しておいてください。スクリプトが完了すると、アカウントに **cosmoslabs** リソースグループが含まれ、リソースが事前構成されているはずです。

## Azure ポータルへのログイン

1. 新しいウィンドウで、**Azure ポータル** (<https://portal.azure.com>) にサインインします。

1. ログインすると、Azure ポータルのツアーを開始するように求められる場合があります。このステップは安全にスキップできます。

> Java SDK では、Azure Cosmos DB アカウントに接続するための資格情報が必要です。ラボ全体で使用するこれらの資格情報を取得して保存します。

1. ポータルの左側で、**リソースグループ** リンクを選択します。

   ![Resource groups](../media/02-resource_groups.jpg)

1. **リソースグループ** ブレードで、**cosmoslabs** _リソースグループ_ を見つけて選択します。

   ![Lab resource group](../media/02-lab_resource_group.jpg)

1. **cosmoslabs** ブレードで、最近作成した **Azure Cosmos DB** アカウントを選択します。

   ![Cosmos resource](../media/02-cosmos_resource.jpg)

1. **Azure Cosmos DB** ブレードで、**設定** セクションを見つけ、**キー** リンクを選択します。

   ![Keys pane](../media/02-keys_pane.jpg)

1. **キー**ペインで、**プライマリ接続文字列**、**URI** と **プライマリキー** フィールドの値を記録します。これらの値は、以降のラボにて使用します。

   ![Credentials](../media/02-keys.jpg)
