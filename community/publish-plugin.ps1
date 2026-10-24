param([Parameter(Mandatory=$true)][string]$PackagePath,[string]$GhPath='gh',[string]$PythonPath='python')
$ErrorActionPreference='Stop'
$repo='OrestHudyma/BatteryGuard-Releases'
$entryText=& $PythonPath (Join-Path $PSScriptRoot 'validate-package.py') $PackagePath
if($LASTEXITCODE -ne 0){throw 'Static package validation failed'}
$entry=$entryText | ConvertFrom-Json
$scratch=Join-Path ([IO.Path]::GetTempPath()) ('BatteryGuard-publish-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $scratch | Out-Null
$releaseJson=& $GhPath release view plugins-api-v1 --repo $repo --json assets,isPrerelease 2>$null
if($LASTEXITCODE -ne 0){
 'Community provider catalog for API 1. Packages require explicit execution approval and local testing. This is not an installer release; a successful build is not hardware verification.' | Set-Content (Join-Path $scratch 'notes.md')
 & $GhPath release create plugins-api-v1 --repo $repo --prerelease --title 'Community plugins · API 1' --notes-file (Join-Path $scratch 'notes.md')
 if($LASTEXITCODE -ne 0){throw 'Catalog release creation failed'}
 $releaseJson=& $GhPath release view plugins-api-v1 --repo $repo --json assets,isPrerelease
}
$release=$releaseJson | ConvertFrom-Json
if(-not $release.isPrerelease){throw 'Plugin catalog must remain a prerelease so it cannot replace the stable installer'}
if(@($release.assets | Where-Object name -eq $entry.AssetName).Count -gt 0){throw 'Immutable version already published'}
$catalog=[pscustomobject]@{ApiVersion=1;Packages=@()}
if(@($release.assets | Where-Object name -eq 'catalog.json').Count -gt 0){
 & $GhPath release download plugins-api-v1 --repo $repo --pattern catalog.json --dir $scratch
 if($LASTEXITCODE -ne 0){throw 'Existing catalog download failed'}
 $catalog=Get-Content (Join-Path $scratch 'catalog.json') -Raw | ConvertFrom-Json
 if($catalog.ApiVersion -ne 1){throw 'Wrong catalog API'}
}
if(@($catalog.Packages | Where-Object { $_.Id -eq $entry.Id -and $_.Version -eq $entry.Version }).Count -gt 0){throw 'Version already in catalog'}
& $GhPath release upload plugins-api-v1 $PackagePath --repo $repo
if($LASTEXITCODE -ne 0){throw 'Package upload failed; catalog not changed'}
$catalog.Packages=@($catalog.Packages)+@($entry)
$catalog | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $scratch 'catalog.json') -Encoding utf8
& $GhPath release upload plugins-api-v1 (Join-Path $scratch 'catalog.json') --repo $repo --clobber
if($LASTEXITCODE -ne 0){throw 'Package uploaded but catalog update failed; inspect release before retrying'}
Write-Output ('Published Community package '+$entry.Id+' '+$entry.Version)
