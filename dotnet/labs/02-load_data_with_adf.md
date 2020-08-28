# ADF を使用した Cosmos DB へのデータのロード

このラボでは、Azure に組み込まれているツールを使用して、既存のデータセットから Azure Cosmos DB コンテナーにデータを入力します。インポート後、Azure ポータルを使用してインポートしたデータを表示します。

> ラボコンテンツのセットアップをまだ完了していない場合は、このラボを開始する前に [アカウントのセットアップ](00-account_setup.md) の手順を参照してください。これにより、ラボ全体で使用する Azure Cosmos DB データベースとコンテナーが作成されます。また、**Azure Data Factory（ADF）** リソースを使用して、既存のデータをコンテナーにインポートします。

## Azure Cosmos DB データベースとコンテナーの作成

Azure Cosmos DB アカウント内にデータベースとコンテナーを作成します。

1. [Azure ポータル](https://portal.azure.com) に移動します。

2. ポータルの左側で、**リソースグループ** リンクを選択します。

    ![Resource groups is highlighted](../media/03-resource_groups.jpg "Select the Resource Groups")

3. **リソースグループ** ブレードで、**cosmoslabs** リソースグループを見つけて選択します。

    ![The cosmoslabs resource group is highlighted](../media/03-lab_resource_group.jpg "Select the cosmoslabs resource group")

4. **cosmoslabs** ブレードで、最近作成した **Azure Cosmos DB** アカウントを選択します。

    ![The Cosmos DB resource is highlighted](../media/03-cosmos_resource.jpg "Select the cosmoslabs resource")

5. **Azure Cosmos DB** ブレードで、ブレードの左側にある **概要** リンクを見つけて選択します。上部にある **Add Container** ボタンを選択します。

    ![Add container link is highlighted](../media/03-add_collection.jpg "Add a new container")

6. **Add Container** ポップアップで、次のアクションを実行します:

    1. **Database id** フィールドで、**Create new** オプションを選択し、**ImportDatabase** を入力します。

    2. **Provision database throughput** オプションはオンにしないでください。

        > データベースのスループットをプロビジョニングすると、そのデータベースに属するすべてのコンテナー間でスループットを共有できます。Azure Cosmos DB データベース内では、スループットを共有する一連のコンテナーと、専用のスループットを持つコンテナーを使用できます。

    3. **Container Id** フィールドに、**FoodCollection** を入力します。

    4. **Partition key** フィールドに、`/foodGroup` を入力します。

    5. **Throughput** フィールドに、`11000`　を入力します。*注意: データがインポートされた後、これを 400 RU/s に減らします。*

    6. **OK** ボタンを選択します。

7. このラボを続行する前に、新しい**データベース**と**コンテナー**の作成が完了するのを待ってください。

## コンテナーへのラボデータのインポート

**Azure Data Factory （ADF）** を使用して、**nutrition.json** ファイルに格納されている JSON 配列を Azure Blob Storage からインポートします。

You do not need to do Steps 1-4 in this section and can proceed to Step 4 by opening your Data Factory (named importNutritionData with a random number suffix)if you are completing the lab through Microsoft Hands-on Labs or ran the setup script, you can use the pre-created Data Factory within your resource group.
マイクロソフトハンズオンラボを通じてラボを完了するか、このラボのセットアップスクリプトを実行した場合は、このセクションの手順 1 〜 4 を実行する必要はなく、Data Factory（ランダムな番号のサフィックスが付いたimportNutritionDataという名前）を開いて手順 4 に進むことができ、リソースグループ内で事前に作成された Data Factory を使用することができます。

1. ポータルの左側で、**リソースグループ** リンクを選択します。

    > ADF を使用して Cosmos DB にデータをコピーする方法の詳細については、[ADF のドキュメント](https://docs.microsoft.com/ja-jp/azure/data-factory/connector-azure-cosmos-db) をご覧ください。

    ![Resource groups link is highlighted](../media/03-resource_groups.jpg "Select Resource Groups")

2. **リソースグループ** ブレードで、**cosmoslabs** リソースグループを見つけて選択します。

3. Data Factory リソースが表示された場合は、ステップ 4 にスキップできます。それ以外の場合は、**追加** を選択して新しいリソースを追加します。

    ![A data factory resource is highlighted](../media/03-adf-isntance.png "Review if you have data factory already")

    ![Select Add in the nav bar](../media/03-add_adf.jpg "Add a new resource")

   - **Data Factory** を検索して選択します。
   - 新しい **Data Factory** を作成します。この Data Factory に **importnutritiondata** という名前を付け、一意の番号を追加して、関連する Azure サブスクリプションを選択する必要があります。既存の **cosmoslabs** リソースグループとバージョン **V2** が選択されていることを確認する必要があります。
   - 地域として **東日本** を選択します。
   - Git configure タブにて、**Configure Git later** を選択しないでください (これはデフォルトでオンになっている場合があります)。
   - **確認及び作成** を選択し、環境を作成します。

        ![The new data factory dialog is displayed](../media/03-adf_selections.jpg "Add a new Data Factory resource")

4. 作成後、新しく作成した Data Factory を開きます。**Author & Monitor** を選択すると、ADFが起動します。

    ![The overview blade is displayed for ADF](../media/03-adf_author&monitor.jpg "Select Author and Monitor link")

5. **Copy Data** を選択します。

   - Azure Blob Storage 上にある JSON ファイルのソースから Cosmos DB の SQL API のデータベースへの 1 回限りのデータコピーに ADF を使用します。ADF は、Cosmos DB から他のデータストアへの、より頻繁なデータ転送にも使用できます。

    ![The main workspace page is displayed for ADF](../media/03-adf_copydata.jpg "Select the Copy Data activity")

6. このデータコピーの基本的なプロパティを編集します。タスクに **ImportNutrition** という名前を付け、**Run once now** を選択して、**Next** を選択します。

   ![The copy data activity properties dialog is displayed](../media/03-adf_properties.jpg "Enter a task name and the schedule")

7. **Create a new connection** を選択して、**Azure Blob Storage** を選択します。Azure Blob Storage の JSON ファイルからデータをインポートします。Blob ストレージに加え、ADF を使用してさまざまなソースから移行が可能です。このチュートリアルでは、これらのソースからの移行については取り上げません。

    ![Create new connection link is highlighted](../media/03-adf_blob.jpg "Create a new connection")

    ![Azure Blog Storage is highlighted](../media/03-adf_blob2.jpg "Select the Azure Blob Storage connection type")

8. ソースに **NutritionJson** という名前を付け、認証方法として **SAS URI** を選択します。この Blob ストレージコンテナーへの読み取り専用アクセスには、次の SAS URI を使用してください:

    `https://cosmosdblabsv3.blob.core.windows.net/?sv=2018-03-28&ss=bfqt&srt=sco&sp=rlp&se=2022-01-01T04:55:28Z&st=2019-08-05T20:02:28Z&spr=https&sig=%2FVbismlTQ7INplqo6WfU8o266le72o2bFdZt1Y51PZo%3D`

    ![The New linked service dialog is displayed](../media/03-adf_connecttoblob.jpg "Enter the SAS url in the dialog")

9. **Create** を選択します。
10. **Next** を選択します。
11. **Browse** を選択し、ダブルクリックして **nutritiondata** フォルダを開きます。
12. **NutritionData.json** ファイルを選択してから、**Choose** を選択します。

    ![The nutritiiondata folder is displayed](../media/03-adf_choosestudents.jpg "Select the NutritionData.json file")

13. **Recursively** または **Binary Copy** にチェックが入っている場合は、チェックを外します。また、他のフィールドが空であることを確認してください。**Next** を選択します。

    ![The input file or folder dialog is displayed](../media/03-adf_source_next.jpg "Ensure all other fields are empty, select next")

14. **JSON format** としてファイル形式を選択します。**Next** を選択します。

    !["The file format settings dialog is displayed"](../media/03-adf_source_dataset_format.jpg "Ensure JSON format is selected, then select Next")

15. これで、Blob ストレージコンテナーがソースとして nutrition.json ファイルに正常に接続されました。

16. **Destination data store** に Cosmos DB ターゲットデータストアを追加するには、**Create new connection** を選択し、**Azure Cosmos DB (SQL API)** を選択します。

    !["The New Linked Service dialog is displayed"](../media/03-adf_selecttarget.jpg "Select the Azure Cosmos DB service type")

17. リンクされたサービスに **targetcosmosdb** という名前を付け、Azure サブスクリプションと Cosmos DB アカウントを選択します。以前に作成したCosmos DB の **ImportDatabase** も選択する必要があります。

    !["The linked service configuration dialog is displayed"](../media/03-adf_selecttargetdb.jpg "Select the ImportDatabase database")

18. 新しく作成した **targetcosmosdb** 接続を宛先データストアとして選択します。

    !["The destination data source dialog is displayed"](../media/03-adf_destconnectionnext.jpg "Select your recently created data source")

19. ドロップダウンメニューから **FoodCollection** コンテナを選択します。Blob ストレージファイルを正しい Cosmos DB コンテナにマップします。**Next** を選択して続行します。

    !["The table mapping dialog is displayed"](../media/03-adf_correcttable.jpg "Select the FoodCollection container")

20. `Settings` を変更する必要はありません。**next** を選択します。

    !["The settings dialog is displayed"](../media/03-adf_settings.jpg "Review the dialog, select next")

21. **Next** を選択してデプロイを開始し、デプロイが完了したら **Monitor** を選択します。

    !["The pipeline runs are displayed"](../media/03-adf_progress.jpg "Notice the pipeline is In progress")

22. 数分後、ページを更新すると、ImportNutrition パイプラインのステータスが **Succeeded** と表示されます。

    !["The pipeline runs are displayed"](../media/03-adf_progress_complete.jpg "The pipeline has succeeded")

23. インポートプロセスが完了したら、ADF を閉じます。次に、インポートしたデータの検証に進みます。

## インポートしたデータの検証

Azure Cosmos DB データエクスプローラーを使用すると、ドキュメントを表示し、Azure ポータル内でクエリを直接実行することができます。この演習では、データエクスプローラーを使用して、コンテナーに格納されているデータを表示します。

**データエクスプローラー** の **Items** ビューを使用して、データがコンテナーに正常にインポートされたことを検証します。

1. **Azure ポータル** (<http://portal.azure.com>) に戻ります。

1. ポータルの左側で、**リソースグループ** リンクを選択します。

    ![Resource groups link is highlighted](../media/03-resource_groups.jpg "Select your resource group")

1. **リソースグループ** ブレードで、**cosmoslabs** リソースグループを見つけて選択します。

    ![The Lab resource group is highlighted](../media/03-lab_resource_group.jpg "Select the resource group")

1. **cosmoslabs** ブレードで、最近作成した **Azure Cosmos DB** アカウントを選択します。

    ![The Cosmos DB resource is highlighted](../media/03-cosmos_resource.jpg "Select the Cosmos DB resource")

1. **Azure Cosmos DB** ブレードで、ブレードの左側にある **データエクスプローラー** リンクを見つけて選択します。

    ![The Data Explorer link was selected and is blade is displayed](../media/03-data_explorer_pane.jpg "Select Data Explorer")

1. **データエクスプローラー** セクションで、**ImportDatabase** データベースノードを展開し、**FoodCollection** コンテナーノードを展開します。

    ![The Container node is displayed](../media/03-collection_node.jpg "Expand the ImportDatabase node")

1. **FoodCollection** ノード内で、**Scale and Settings** リンクを選択して、コンテナーのスループットを表示します。スループットを **400 RU/s** に減らします。

    ![Scale and Settings](../media/03-collection-settings.png "Reduce throughput")

1. **FoodCollection** ノード内で、**Items** リンクを選択して、コンテナー内のさまざまなドキュメントのサブセットを表示します。いくつかのドキュメントを選択し、ドキュメントのプロパティと構造を観察します。

    ![Items is highlighted](../media/03-documents.jpg "Select Items")

    ![An Example document is displayed](../media/03-example_document.jpg "Select a document")

> これが最後のラボである場合は、[ラボアセットの削除](11-cleaning_up.md) の手順に従って、すべてのラボリソースを削除します。
