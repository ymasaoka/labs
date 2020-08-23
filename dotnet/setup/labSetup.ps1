param($session = $null, $location = "Japan East", $resourceGroupName = "cosmoslabs", [switch]$teardown, [switch]$overwriteGroup)

# 新しいデプロイに適用する設定
$randomNum = if ($null -eq $session) { Get-Random -Maximum 100000 } else { $session } # 一部のリソースには一意の名前が必要です - これは代わりにユーザーが入力できます
$accountName = "cosmoslab$($randomNum)"
$eventHubNS = "shoppingHub$($randomNum)"

if ($teardown) {
    if ($resourceGroupName -ieq "cosmoslabs"){
        $resourceGroupName = Read-Host -Prompt "リソースグループの名前を入力します。リソースグループ名がわからない場合は、Azure ポータルにてラボで使用するリソースを見つけてください。"
    }

    # リソースグループ全体を削除
    Write-Output "'$($resourceGroupName)' 内にあるすべてのリソースを削除する準備をしています..."

    try {
        $accounts = Get-AzResource -ResourceType "Microsoft.DocumentDb/databaseAccounts" -ApiVersion "2020-04-01" -ResourceGroupName $resourceGroupName -ErrorAction Stop | Select -ExpandProperty Name
    }
    catch {
        Write-Output "削除するリソースグループ '$($resourceGroupName)' が見つかりません。正しい Azure サブスクリプションにログインしていることを確認してください。"
        exit
    }

    $structureMatch = $FALSE
    if ($accounts.count -eq 1) {
        $oneAccount = $accounts | Select -First 1
        if ($oneAccount.StartsWith("cosmoslab")) {
            $structureMatch = $TRUE
        }
    }

    if (-not $structureMatch) {
        Read-Host "リソースグループ '$($resourceGroupName)' にラボリソースが含まれていることを確認できませんでした。リソースグループの内容を確認し、https://portal.azure.com から手動で削除してください。Enter キーを押してスクリプトを終了します。"
        exit
    }

    $confirmation = Read-Host -Prompt "Azure リソースグループ '$($resourceGroupName)' を削除すると、リソースグループ内のすべてのリソースも削除されます。削除を続行してもよろしいですか? (yes or no)"
    
    if ($confirmation -eq 'yes') {
        Remove-AzResourceGroup -Name $resourceGroupName
        Write-Output "ラボリソースの削除が完了しました。"
    }
    else {
        Write-Output "ラボリソースの削除がキャンセルされました。"
    }

    exit
}

Write-Output "リージョン '$($location)' にリソースを設定しています:" $resourceGroupName $accountName "  FinancialDatabase" "  NutritionDatabase" "  StoreDatabase" $eventHubNS


### ヘルパー関数 #####
function New-Database ($resourceGroupName, $accountName, $databaseName) {
    $databaseResourceName = $accountName + "/sql/" + $databaseName

    $databaseProperties = @{
        "resource" = @{ "id" = $databaseName };
    } 
    New-AzResource -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases" `
        -ApiVersion "2015-04-08" -ResourceGroupName $resourceGroupName `
        -Name $databaseResourceName -PropertyObject $databaseProperties -Force
}

function New-Container ($resourceGroupName, $accountName, $databaseName, $containerName, $partition, $throughput = 400) {
    $containerResourceName = $accountName + "/sql/" + $databaseName + "/" + $containerName

    $containerProperties = @{
        "resource" = @{
            "id"           = $containerName; 
            "partitionKey" = @{
                "paths" = @($partition); 
                "kind"  = "Hash"
            }; 
            
            "indexingPolicy"=@{
                "indexingMode"="Consistent"; 
                "includedPaths"= @(@{
                    "path"="/*";
                    "indexes"= @(@{
                            "kind"="Range";
                            "dataType"="number";
                            "precision"=-1
                        },
                        @{
                            "kind"="Range";
                            "dataType"="string";
                            "precision"=-1
                        },
                        @{
                            "kind"="Spatial";
                            "dataType"="point";
                            }
                        )
                    });
            };
        };
        "options"  = @{ "Throughput" = $throughput }
    } 

    New-AzResource -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases/containers" `
        -ApiVersion "2015-04-08" -ResourceGroupName $resourceGroupName `
        -Name $containerResourceName -PropertyObject $containerProperties -Force
}

function Add-DataSet ($resourceGroupName, $dataFactoryName, $location, $cosmosAccount, $cosmosDatabase, $cosmosContainer) {
    $cosmosLocation = "https://$cosmosAccount.documents.azure.com:443/"

    # Blob のロケーションは、新しいホストされた読み取りコンテナーの SAS に置き換える必要があります
    $storageAccountLocation = "https://cosmosdblabsv3.blob.core.windows.net"
    $storageAccountSas = "?sv=2018-03-28&ss=bfqt&srt=sco&sp=rlp&se=2022-01-01T04:55:28Z&st=2019-08-05T20:02:28Z&spr=https&sig=%2FVbismlTQ7INplqo6WfU8o266le72o2bFdZt1Y51PZo%3D"
    $sourceBlobFolder = "nutritiondata"
    $sourceBlobFile = "NutritionData.json"
    $pipelineName = "ImportLabNutritionData"

    $cosmosKey = Invoke-AzResourceAction -Action listKeys `
        -ResourceType "Microsoft.DocumentDb/databaseAccounts" -ApiVersion "2015-04-08" -Force `
        -ResourceGroupName $resourceGroupName -Name $cosmosAccount | Select-Object -First 1 -ExpandProperty primaryMasterKey

    # Azure Data Factory V2を作成
    $df = Set-AzDataFactoryV2 -ResourceGroupName $resourceGroupName -Location $location -Name $dataFactoryName -Force

    # Azure Data Factory で Az.Storage リンクサービスを作成

    ## リンクサービスの JSON 定義
    $storageLinkedServiceDefinition = @"
{
    "name": "AzureStorageLinkedService",
    "properties": {
        "type": "AzureStorage",
        "typeProperties": {
            "connectionString": {
                "value": "BlobEndpoint=$storageAccountLocation;SharedAccessSignature=$storageAccountSas",
                "type": "SecureString"
            }
        }
    }
}
"@

    $cosmosLinkedServiceDefinition = @"
    {
        "name": "CosmosDbSQLAPILinkedService",
        "properties": {
            "type": "CosmosDb",
            "typeProperties": {
                "connectionString": {
                    "type": "SecureString",
                    "value": "AccountEndpoint=$cosmosLocation;AccountKey=$cosmosKey;Database=$cosmosDatabase"
                }
            }
        }
    }
"@

    ## 重要: JSON 定義を Set-AzDataFactoryLinkedService コマンドで使用されるファイルに保存します。
    $storageLinkedServiceDefinition | Out-File StorageLinkedService.json
    $cosmosLinkedServiceDefinition | Out-File CosmosLinkedService.json
    
    ## Azure Data Factory でリンクサービスを作成
    Set-AzDataFactoryV2LinkedService -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name "AzureStorageLinkedService" -File StorageLinkedService.json -Force
    Set-AzDataFactoryV2LinkedService -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name "CosmosLinkedService" -File CosmosLinkedService.json -Force

    # Azure Data Factory で Azure Blob データセットを作成

    ## データセットの JSON 定義
    $datasetDefinition = @"
{
    "name": "BlobDataset",
    "properties": {
        "type": "AzureBlob",
        "typeProperties": {
            "format": {
                "type": "JsonFormat",
                "filePattern": "arrayOfObjects"
            },
            "fileName": "$sourceBlobFile",
            "folderPath": "$sourceBlobFolder"
        },
        "linkedServiceName": {
            "referenceName": "AzureStorageLinkedService",
            "type": "LinkedServiceReference"
        },
        "parameters": {
        }
    }
}
"@
    $cosmosDatasetDefinition = @"
{
    "name": "CosmosDbSQLAPIDataset",
    "properties": {
        "type": "DocumentDbCollection",
        "linkedServiceName":{
            "referenceName": "CosmosLinkedService",
            "type": "LinkedServiceReference"
        },
        "typeProperties": {
            "collectionName": "$cosmosContainer"
        }
    }
}
"@

    ## 重要: Set-AzDataFactoryDataset コマンドで使用されるファイルに JSON 定義を保存します。
    $datasetDefinition | Out-File BlobDataset.json
    $cosmosDatasetDefinition | Out-File CosmosDataset.json

    ## Azure Data Factory でデータセットを作成
    Set-AzDataFactoryV2Dataset -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name "BlobDataset" -File "BlobDataset.json" -Force
    Set-AzDataFactoryV2Dataset -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name "CosmosDataset" -File "CosmosDataset.json" -Force

    # Azure Data Factory でパイプラインを作成

    ## パイプラインの JSON 定義
    $pipelineDefinition = @"
{
    "name": "$pipelineName",
    "properties": {
        "activities": [
            {
                "name": "ImportLabData",
                "type": "Copy",
                "inputs": [
                    {
                        "referenceName": "BlobDataset",
                        "type": "DatasetReference"
                    }
                ],
                "outputs": [
                    {
                        "referenceName": "CosmosDataset",
                        "type": "DatasetReference"
                    }
                ],
                "typeProperties": {
                    "source": {
                        "type": "BlobSource"
                    },
                    "sink": {
                        "type": "DocumentDbCollectionSink",
                        "nestingSeparator": ".",
                        "writeBehavior": "insert"
            }
                }
            }
        ],
        "parameters": {
        }
    }
}
"@

    ## 重要: Set-AzDataFactoryPipeline コマンドで使用されるファイルに JSON 定義を保存します。
    $pipelineDefinition | Out-File CopyPipeline.json

    ## Azure Data Factory でパイプラインを作成
    Set-AzDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -Name $pipelineName -File "CopyPipeline.json" -Force

    # パイプライン実行を作成

    # パラメーターを使用して実行するパイプラインを作成
    $runId = Invoke-AzDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -PipelineName $pipelineName

    # コピー操作が完了するまでパイプラインの実行ステータスを確認
    while ($True) {
        $result = Get-AzDataFactoryV2ActivityRun -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName -PipelineRunId $runId -RunStartedAfter (Get-Date).AddMinutes(-30) -RunStartedBefore (Get-Date).AddMinutes(30)

        if (($result | Where-Object { $_.Status -eq "InProgress" } | Measure-Object).count -ne 0) {
            Write-Host "パイプライン実行ステータス: 進行中" -foregroundcolor "Yellow"
            Start-Sleep -Seconds 30
        }
        else {
            Write-Host "パイプライン '$pipelineName' の実行が終了しました。結果:" -foregroundcolor "Yellow"
            $result
            break
        }
    }

    # アクティビティ実行の詳細を取得 
    $result = Get-AzDataFactoryV2ActivityRun -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName `
        -PipelineRunId $runId `
        -RunStartedAfter (Get-Date).AddMinutes(-10) `
        -RunStartedBefore (Get-Date).AddMinutes(10) `
        -ErrorAction Stop

    $result

    if ($result.Status -eq "Succeeded") {
`
            $result.Output -join "`r`n"`
    
    }`
        else {
`
            $result.Error -join "`r`n"`
    
    }
}

function Add-EventHub($resourceGroupName, $location, $eventHubNS, $eventHubName, $retentionDays) {
    New-AzEventHubNamespace -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNS -Location $location
    New-AzEventHub -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNS -EventHubName $eventHubName -MessageRetentionInDays $retentionDays
}

function Add-StreamProcessor($resourceGroupName, $location, $eventHubNS, $jobName) {
    # 備考 - C スクリプトによる Power BI 出力の作成はサポートされていません

    $jobDefinition = @"
    {
        "location": "$location",
        "properties": {
            "sku":{
                "name": "standard"
            },
            "eventsOutOfOrderPolicy": "adjust",
            "eventsOutOfOrderMaxDelayInSeconds": 10,
            "compatibilityLevel": 1.1
        }
    }
"@  

    $jobDefinition | Out-File JobDefinition.json

    New-AzStreamAnalyticsJob -ResourceGroupName $resourceGroupName -File "JobDefinition.json" -Name $jobName

    $inputDefintion = @"
    {
        "properties": {
            "type": "Stream",
            "datasource": {
                "type": "Microsoft.ServiceBus/EventHub",
                "properties": {
                    "serviceBusNamespace": "$EventHubNS",
                    "sharedAccessPolicyName": "RootManageSharedAccessKey",
                    "sharedAccessPolicyKey": "RootManageSharedAccessKey",
                    "eventHubName": "carteventhub"
                }
            },
            "serialization": {
                "type": "Json",
                "properties": {
                    "encoding": "UTF8"
                }
            }            
        },
        "name": "cartInput",
        "type": "Microsoft.StreamAnalytics/streamingjobs/inputs"
        }
"@

    $inputDefintion | Out-File InputDefinition.json

    New-AzStreamAnalyticsInput -ResourceGroupName $resourceGroupName -JobName $jobName -File "InputDefinition.json"  

    $transformationDefintiion = @"
    {
        "properties": {
            "streamingUnits": 1,
            "query": "/*TOP 5*/\r\n WITH Counter AS\r\n (\r\n SELECT Item, Price, Action, COUNT(*) AS
                    countEvents\r\n FROM cartinput\r\n WHERE Action = 'Purchased'\r\n GROUP BY Item, Price, Action,
                    TumblingWindow(second,300)\r\n ), \r\n top5 AS\r\n (\r\n SELECT DISTINCT\r\n CollectTop(5)  OVER
                    (ORDER BY countEvents) AS topEvent\r\n FROM Counter\r\n GROUP BY TumblingWindow(second,300)\r\n ),
                    \r\n arrayselect AS \r\n (\r\n SELECT arrayElement.ArrayValue\r\n FROM top5\r\n CROSS APPLY
                    GetArrayElements(top5.topevent) AS arrayElement\r\n ) \r\n SELECT arrayvalue.value.item,
                    arrayvalue.value.price, arrayvalue.value.countEvents\r\n INTO top5Output\r\n FROM
                    arrayselect\r\n\r\n /*REVENUE*/\r\n SELECT System.TimeStamp AS Time, SUM(Price)\r\n INTO
                    incomingRevenueOutput\r\n FROM cartinput\r\n WHERE Action = 'Purchased'\r\n GROUP BY
                    TumblingWindow(minute, 5)\r\n\r\n /*UNIQUE VISITORS*/\r\n SELECT System.TimeStamp AS Time,
                    COUNT(DISTINCT CartID) as uniqueVisitors\r\n INTO uniqueVisitorCountOutput\r\n FROM cartinput\r\n
                    GROUP BY TumblingWindow(second, 30)\r\n\r\n  /*AVERAGE PRICE*/      \r\n SELECT System.TimeStamp
                    AS Time, Action, AVG(Price)  \r\n INTO averagePriceOutput  \r\n FROM cartinput  \r\n GROUP BY
                    Action, TumblingWindow(second,30) "             
        },                                    
        "name": "Transformation",
        "type": "Microsoft.StreamAnalytics/streamingjobs/transformations"        
    }
"@

    $transformationDefintiion | Out-File TransformationDefinition.json

    New-AzStreamAnalyticsTransformation -ResourceGroupName $resourceGroupName -JobName $jobName -File "TransformationDefinition.json"    
}

##################


# セットアップを開始
if(!$overwriteGroup){
    Get-AzResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

    if(!$notPresent){
        throw $resourceGroupName + " というリソースグループは既に存在します。上書きする場合は、-overwriteGroup スイッチを使用します。";
    }

}

New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

$locations = @(
    @{ "locationName" = $location; "failoverPriority" = 0 }
)

$CosmosDBProperties = @{
    "databaseAccountOfferType" = "Standard";
    "locations"                = $locations;
}

New-AzResource -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
    -ApiVersion "2015-04-08" -ResourceGroupName $resourceGroupName -Location $location `
    -Name $accountName -PropertyObject $CosmosDBProperties -Force

New-Database $resourceGroupName $accountName "FinancialDatabase"
New-Container $resourceGroupName $accountName "FinancialDatabase" "PeopleCollection" "/accountHolder/LastName"
New-Container $resourceGroupName $accountName "FinancialDatabase" "TransactionCollection" "/costCenter" 10000

New-Database $resourceGroupName $accountName "NutritionDatabase"
New-Container $resourceGroupName $accountName "NutritionDatabase" "FoodCollection" "/foodGroup" 11000

#Lab08
New-Database $resourceGroupName $accountName "StoreDatabase"
New-Container $resourceGroupName $accountName "StoreDatabase" "CartContainer" "/Item"
New-Container $resourceGroupName $accountName "StoreDatabase" "CartContainerByState" "/BuyerState"
New-Container $resourceGroupName $accountName "StoreDatabase" "StateSales" "/State"

Add-EventHub $resourceGroupName $location $eventHubNS "CartEventHub" 1
Add-StreamProcessor $resourceGroupName $location $eventHubNS "CartStreamProcessor"
#END Lab08

Add-DataSet $resourceGroupName "importNutritionData$randomNum" $location $accountName "NutritionDatabase" "FoodCollection"
