param (
    [Parameter(Mandatory = $true)]
    [string]$TargetDir
)

# meta削除用パターン
$metaPattern = '<meta[^>]*(charset|Content-Type)[^>]*>'

# UTF-8(BOMなし)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

Get-ChildItem -Path $TargetDir -Recurse -File -Include *.htm,*.html | ForEach-Object {

    $path = $_.FullName
    Write-Host "Processing: $path"

    # Shift-JIS として読み込み
    $content = Get-Content $path -Encoding Default -Raw

    # 既存 meta 削除
    $content = $content -replace $metaPattern, ''

    # <head> 直後に UTF-8 meta を挿入
    if ($content -match '<head[^>]*>') {
        $content = $content -replace '(<head[^>]*>)', ('$1' + "`r`n<meta charset=`"UTF-8`">")
    }

    # UTF-8で書き戻し
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
}
