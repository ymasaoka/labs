param($codePath = "$Home\Documents")

$targetPath = "$codePath\CosmosLabs"

try{
    New-Item -Name CosmosLabs -Path $codePath -ItemType Directory -ErrorAction Stop
}
catch{
    $directoryInfo = Get-ChildItem $targetPath | Measure-Object

    if ($directoryInfo.count -eq 0){
        Write-Output "既存のフォルダ '$targetPath' が見つかりました。"
    }
    else{
        Write-Output "フォルダ '$targetPath' には既存のファイルがあります。新しいラボコードのセットアップを開始する前に、フォルダーからファイルを削除または移動して、競合を回避してください。"
        exit
    }
}

Copy-Item -Path .\templates\* -Filter "*.*" -Recurse -Destination $targetPath -Container -Force

Write-Output "" "すべてのラボコードファイルを '$targetPath' にコピーしました。"

