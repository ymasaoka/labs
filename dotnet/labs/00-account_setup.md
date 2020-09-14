# アカウントのセットアップ

このラボでは、Cosmos DB ラボを実行するために必要なリソースをもつ Azure サブスクリプションをセットアップします。これらのラボを一度に実行する場合の推定費用は、最大約12,000円です。

## 前提条件

- Azure の有料サブスクリプション
- [Azure PowerShell Module](https://docs.microsoft.com/ja-jp/powershell/azure/install-az-ps)

## ラボコンテンツのセットアップ

1. セットアップを開始するには、これらの手順を含むリポジトリを [GitHub](https://github.com/ymasaoka/labs/tree/ja-jp) から Git clone もしくはダウンロードします。

2. Windows Powershell を起動します。
3. ダウンロードしたリポジトリのコピーを含むフォルダーに移動します
4. リポジトリ内で、**dotnet\setup** フォルダーに移動します:

   ```powershell
   cd .\dotnet\setup\
   ```

5. 現在の Powershell セッションでセットアップスクリプトを実行できるようにするには、次のように入力します:

   ```powershell
   Set-ExecutionPolicy Unrestricted -Scope Process
   ```

   > この設定は、現在の Powershell ウィンドウ内でのみ適用されます。

6. ラボの多くは、ラボの手順の開始点として使用するビルド済みのコードを参照しています。ラボのこのスターターコードを **Documents** フォルダー内の **CosmosLabs** フォルダーに自動的にコピーするには、labCodeSetup.ps1 スクリプトを実行します:

   ```powershell
   .\labCodeSetup.ps1
   ```

   > 各ラボのスターターコードは **templates** フォルダー内にあります。**Documents\CosmosLabs** 以外のフォルダーを使用するには、代わりにファイルを手動でコピーしてください。

7. Azure リソースのセットアップを開始するには、まず Azure アカウントに接続します:

   ```powershell
   Connect-AzAccount
   ```

   もしくは

   ```powershell
   Connect-AzAccount -subscription <サブスクリプション ID>
   ```

8. ラボ用の Azure リソースを作成するには、labSetup.ps1 スクリプトを実行します:

   ```powershell
   .\labSetup.ps1 -resourceGroupName 'name'
   ```

   一意である可能性が高い`名前`を選択してください。つまり、`cosmoslabsXXXXX`で、`XXXXX`はランダムな数字です。
    
    - このスクリプトは、デフォルトで _Japan East_ リージョンにリソースを作成します。別のリージョンを使用するには、上記のコマンドに **-location 'リージョン名'** を追加してください。
    
    - 指定したリソースグループが既に存在する場合、このスクリプトは失敗するため、別の `name`値を選択することもできます。または、この失敗を回避してリソースを作成するためには、上記のコマンドに **-overwriteGroup** を追加します。

9. 一部の Azure リソースはセットアップを完了するのに 10 分以上かかる場合があるため、完了までスクリプトがしばらく実行されることを想定しておいてください。スクリプトが完了すると、アカウントにはいくつかの事前構成されたリソースが含まれた **cosmoslabs** リソースグループが含まれるようになります:

   - Azure CosmosDB Account
   - Stream Analytics Job
   - Azure Data Factory
   - Event Hubs Namespace

## Azure ポータルへのログイン

1. 新しいウィンドウで、 **Azure ポータル** (<https://portal.azure.com>) にサインインします。

1. ログインすると、Azure ポータルのツアーを開始するように求められる場合があります。このステップは安全にスキップできます。

### アカウント資格情報を取得

.NET SDK では、Azure Cosmos DB アカウントに接続するための資格情報が必要です。ラボ全体で使用するこれらの資格情報を取得して保存します。

1. ポータルの左側で、**リソースグループ** リンクを選択します。

   ![Resource groups is highlighted](../media/02-resource_groups.jpg "Select resource groups")

1. **リソースグループ** ブレードで、**cosmoslabs** _リソースグループ_ を見つけて選択します。

   ![The recently cosmosdb resource group is highlighted](../media/02-lab_resource_group.jpg "Select the CosmosDB resource group")

1. **cosmoslabs** ブレードで、最近作成した **Azure Cosmos DB** アカウントを選択します。

   ![The Cosmos DB resource is highlighted](../media/02-cosmos_resource.jpg "Select the Cosmos DB resource")

1. **Azure Cosmos DB** ブレードで、**設定** セクションを見つけ、**キー** リンクを選択します。

   ![The Keys pane is highlighted](../media/02-keys_pane.jpg "Select the Keys Pane")

1. **キー**ペインで、**プライマリ接続文字列**、**URI** と **プライマリキー** フィールドの値を記録します。これらの値は、以降のラボにて使用します。

   ![The URI, Primary Key and Connection string credentials are highlighted](../media/02-keys.jpg "Copy the URI, primary key and the connection string")
