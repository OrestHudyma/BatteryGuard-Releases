param([Parameter(Mandatory=$true)][string]$PluginDirectory,[string]$OutputDirectory=(Join-Path $PSScriptRoot 'artifacts'))
$ErrorActionPreference='Stop'
$plugin=(Resolve-Path -LiteralPath $PluginDirectory).Path
$manifest=Get-Content (Join-Path $plugin 'manifest.json') -Raw | ConvertFrom-Json
if($manifest.Id -notmatch '^[a-z0-9][a-z0-9-]{2,63}$' -or $manifest.Version -notmatch '^\d+\.\d+\.\d+$' -or $manifest.ApiVersion -ne 1){throw 'Invalid plugin identity/API'}
$compiler=Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
New-Item -ItemType Directory $OutputDirectory -Force | Out-Null
$stage=Join-Path $OutputDirectory ([guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $stage | Out-Null
$api=Join-Path $stage 'BatteryGuard.PluginApi.dll'
& $compiler /nologo /target:library /platform:anycpu ('/out:'+$api) (Join-Path $PSScriptRoot 'sdk\Contract.cs')
if($LASTEXITCODE -ne 0){throw 'SDK compilation failed'}
$sources=@(Get-ChildItem -LiteralPath $plugin -Filter '*.cs' | ForEach-Object FullName)
if($sources.Count -eq 0){throw 'No provider sources'}
& $compiler /nologo /target:library /platform:x64 /reference:System.dll /reference:System.Core.dll /reference:System.Management.dll ('/reference:'+$api) ('/out:'+(Join-Path $stage 'provider.dll')) @sources
if($LASTEXITCODE -ne 0){throw 'Provider compilation failed'}
Copy-Item (Join-Path $plugin 'manifest.json'),(Join-Path $plugin 'README.md') $stage
$name='BatteryGuard-Plugin-'+$manifest.Id+'-'+$manifest.Version+'.zip'
$destination=Join-Path $OutputDirectory $name
if(Test-Path -LiteralPath $destination){throw 'Package already exists; use a fresh output directory or increment the version'}
Compress-Archive -LiteralPath (Join-Path $stage 'manifest.json'),(Join-Path $stage 'provider.dll'),(Join-Path $stage 'README.md') -DestinationPath $destination
Write-Output $destination
Write-Output ('SHA256: '+(Get-FileHash $destination -Algorithm SHA256).Hash.ToLowerInvariant())
