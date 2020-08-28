# Workshop PowerPoint Deck





**Two Day Suggested Schedule**

- [Sample Schedule](./decks/CosmosDBWorkshopSchedule2019.docx)

**Deep-Dive Powerpoint Decks**

- [Overview, Value Proposition & Use Cases](./decks/Overview-Value-Proposition-Use-Cases.pptx)
- [Resource Model](./decks/Resource-Model.pptx)
- [Request Units & Billing](./decks/Request-Units-Billing.pptx)
- [Data Modeling](./decks/Data-Modeling.pptx)
- [Partitioning](./decks/Partitioning.pptx)
- [SQL API Query](./decks/SQL-API-Query.pptx)
- [Server Side Programming](./decks/Server-Side-Programming.pptx)
- [Troubleshooting](./decks/Troubleshooting.pptx)
- [Concurrency](./decks/Concurrency.pptx)
- [Change Feed](./decks/Change-Feed.pptx)
- [Global Distribution](./decks/Global-Distribution.pptx)
- [Security](./decks/Security.pptx)

**References**

- [Use-Case cheat sheet (1-pager)](./decks/1Pager-Use-Cases.pptx)

上記の workshop decks の他に、ハンズオンラボがあります。以下の .NET SDK と Java SDK を使用できるラボがあります:
# .NET (V3) Labs

**.NET Lab の前提条件**

これらのラボを開始する前に、ローカルマシンで次のオペレーティングシステムとソフトウェアを構成しておく必要があります:

**オペレーティングシステム**

- Windows 10 64ビット オペレーティングシステム
  - [ダウンロード](https://www.microsoft.com/windows/get-windows-10)

**ソフトウェア**

| ソフトウェア                                    | ダウンロードリンク                                                |
| ------------------------------------------- | ------------------------------------------------------------ |
| Git                                         | [/git-scm.com/downloads](https://git-scm.com/downloads)      |
| .NET Core 3.1 (もしくは以上) SDK <sup>1</sup> | [/download.microsoft.com/dotnet-sdk-3.1](https://dotnet.microsoft.com/download/dotnet-core/thank-you/sdk-3.1.401-windows-x64-installer) |
| Visual Studio Code                          | [/code.visualstudio.com/download](https://go.microsoft.com/fwlink/?Linkid=852157) |

------

**.NET Lab ガイド**

*以下に指定された順序でラボを完了することをお勧めします:*

- [ラボの準備: Azure Cosmos DB アカウントの作成](dotnet/labs/00-account_setup.md)
- [Lab 1: Azure Cosmos DB でのコンテナー作成](dotnet/labs/01-creating_partitioned_collection.md)
- [Lab 2: Azure Data Factory を使用した Azure Cosmos DB へのデータのインポート](dotnet/labs/02-load_data_with_adf.md)
- [Lab 3: Azure Cosmos DB でのクエリ実行](dotnet/labs/03-querying_in_azure_cosmosdb.md)
- [Lab 4: Azure Cosmos DB でのインデックス作成](dotnet/labs/04-indexing_in_cosmosdb.md)
- [Lab 5: Azure Cosmos DB を使った .NET コンソールアプリのビルド](dotnet/labs/05-build_net_app.md)
- [Lab 6: Azure Cosmos DB のマルチドキュメントトランザクション](dotnet/labs/06-multi-document-transactions.md)
- [Lab 7: Azure Cosmos DB でのトランザクションの継続](dotnet/labs/07-transactions-with-continuation.md)
- [Lab 8: Azure Cosmos DB 変更フィードの概要](dotnet/labs/08-change_feed_with_azure_functions.md)
- [Lab 9: Azure Cosmos DB パフォーマンスのトラブルシューティング](dotnet/labs/09-troubleshooting-performance.md)
- [Lab 10: Azure Cosmos DB の楽観的並行性制御](dotnet/labs/10-concurrency-control.md)
- [ラボが終わった後は: クリーンアップ](dotnet/labs/11-cleaning_up.md)

------

**注意事項**

1. ローカルマシンに .NET Core がすでにインストールされている場合は、 `dotnet --version` コマンドを使用して、.NET Core インストールのバージョンを確認する必要があります。

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Java Labs

**Java Lab の前提条件**

これらのラボを開始する前に、ローカルマシンで次のオペレーティングシステムとソフトウェアを構成しておく必要があります:

**オペレーティングシステム**

- Windows 10 64ビット オペレーティングシステム
    - [ダウンロード](https://www.microsoft.com/windows/get-windows-10)

**ソフトウェア**

| ソフトウェア | ダウンロードリンク |
| --- | --- |
| Git | [/git-scm.com/downloads](https://git-scm.com/downloads) 
Java 8 JDK (もしくは以上) | [/jdk8-downloads](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) |
Java 8 JRE (もしくは以上) | [/jre8-downloads](https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) |
| Visual Studio Code | [/code.visualstudio.com/download](https://go.microsoft.com/fwlink/?Linkid=852157) |
| Java Extension Pack (VS Code を使用している場合) | [/vscode-java-pack](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack) |
| Maven | [/maven.apache.org/](https://maven.apache.org/) |

---

**Java Lab ガイド**

*以下に指定された順序でラボを完了することをお勧めします:*

- [ラボの準備: Azure Cosmos DB アカウントの作成](java/labs/00-account_setup.md)
- [Lab 1: Azure Cosmos DB でのコンテナーの作成](java/labs/01-creating_partitioned_collection.md)
- [Lab 2: Azure Data Factory を使用した Azure Cosmos DB へのデータのインポート](java/labs/02-load_data_with_adf.md)
- [Lab 3: Azure Cosmos DB でのクエリ実行](java/labs/03-querying_in_azure_cosmosdb.md)
- [Lab 4: Azure Cosmos DB でのインデックス作成](java/labs/04-indexing_in_cosmosdb.md)
- [Lab 5: Azure Cosmos DB を使った Java コンソールアプリのビルド](java/labs/05-build_java_app.md)
- [Lab 6: Azure Cosmos DB のマルチドキュメントトランザクション](java/labs/06-multi-document-transactions.md)
- [Lab 7: Azure Cosmos DB でのトランザクションの継続](java/labs/07-transactions-with-continuation.md)
- [Lab 8: Azure Cosmos DB 変更フィードの概要](java/labs/placeholder_WIP.md)
- [Lab 9: Azure Cosmos DB パフォーマンスのトラブルシューティング](java/labs/09-troubleshooting-performance.md)
- [Lab 10: Azure Cosmos DB の楽観的並行性制御](java/labs/10-concurrency-control.md)
- [ラボが終わった後は: クリーンアップ](java/labs/11-cleaning_up.md)

---


**注意事項**

1. Java 11 SDK 以降をインストールすると、Java ランタイム環境 (JRE) がバンドルされます。JRE パス(例: C:\Program Files\Java\jdk-11.0.2\bin\) がシステム変数のパス変数の上部にあることを確認します。
2. ローカルマシンにすでに Java がインストールされている場合は、``java -version`` コマンドを使用して、Java ランタイム環境 (JRE) インストールのバージョンを確認する必要があります。
3. バージョン8以降の Java のバージョンを使用している場合、一部のプロジェクト (ベンチマークアプリケーションなど) がコンパイルされない場合があります。

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Appendix: ステッカー

宇宙ステッカーを印刷するための Adobe Illustrator ファイル (例: stickermule)
- [2x2 inch black circle](./stickers/2x2-circle-template-CosmosBlack.ai)
- [2x2 inch clear circle](./stickers/2x2-clear-sticker-template-CosmosClear.ai)
- [Die-cut color logo](./stickers/cosmos-die-cut-sticker-template-v2.ai)
