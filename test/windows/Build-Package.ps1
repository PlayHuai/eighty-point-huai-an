[CmdletBinding()]
param(
    [string]$ServerHost = '192.168.117.129',
    [string]$OutputDirectory = 'D:\huai_an_80\auto_test\manual_build'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($ServerHost -notmatch '^[a-zA-Z0-9.-]+$') { throw 'Invalid server host.' }
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$version = [IO.File]::ReadAllText((Join-Path $root 'VERSION')).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'VERSION must contain major.minor.patch.' }
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path -LiteralPath $vswhere)) { throw 'Visual Studio C++ tools were not found.' }
$visualStudio = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($LASTEXITCODE -ne 0 -or -not $visualStudio) { throw 'Visual Studio C++ tools were not found.' }
$crt = Get-ChildItem -LiteralPath (Join-Path $visualStudio 'VC\Redist\MSVC') -Filter vcruntime140.dll -Recurse |
    Where-Object { $_.FullName -match '\\\d+\.\d+\.\d+\\x64\\Microsoft\.VC\d+\.CRT\\' } |
    Sort-Object { [version]$_.VersionInfo.FileVersion.Split(' ')[0] } -Descending |
    Select-Object -First 1
if ($null -eq $crt) { throw 'The redistributable x64 MSVC runtime was not found.' }
$apiEndpoint = "http://${ServerHost}:8081"
$websocketEndpoint = "ws://${ServerHost}:8080/events"
Push-Location $root
try {
    $commit = git rev-parse HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Cannot determine source commit.' }
} finally { Pop-Location }
Push-Location (Join-Path $root 'client')
try {
    & flutter build windows --release "--build-name=$version" --build-number=1 `
        "--dart-define=API_ENDPOINT=$apiEndpoint" `
        "--dart-define=WEBSOCKET_ENDPOINT=$websocketEndpoint"
    if ($LASTEXITCODE -ne 0) { throw 'Windows release build failed.' }
} finally { Pop-Location }
$release = Join-Path $root 'client\build\windows\x64\runner\Release'
foreach ($required in @('eighty_point_huai_an.exe', 'flutter_windows.dll', 'data\app.so', 'data\icudtl.dat')) {
    if (-not (Test-Path -LiteralPath (Join-Path $release $required))) { throw "Missing release file: $required" }
}
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$OutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
$package = Join-Path $OutputDirectory ("package-$version-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 6))
$application = Join-Path $package 'app'
New-Item -ItemType Directory -Path $application -Force | Out-Null
Get-ChildItem -LiteralPath $release | Copy-Item -Destination $application -Recurse
Get-ChildItem -LiteralPath $crt.DirectoryName -Filter '*.dll' | Copy-Item -Destination $application -Force
$metadata = @{
    Version = $version
    Commit = $commit
    API_ENDPOINT = $apiEndpoint
    WEBSOCKET_ENDPOINT = $websocketEndpoint
    BuiltAt = (Get-Date -Format o)
    Environment = 'Local LAN autotest deployment; not for production'
}
[IO.File]::WriteAllText((Join-Path $application 'local-environment.json'), ($metadata | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))
$name = "HuaiAn80-$version-windows-x64-local"
$archive = Join-Path $package "$name.zip"
Compress-Archive -LiteralPath $application -DestinationPath $archive -CompressionLevel Optimal
if (-not (Test-Path -LiteralPath $archive)) { throw 'ZIP output was not generated.' }
$hash = Get-FileHash -LiteralPath $archive -Algorithm SHA256
[IO.File]::WriteAllText("$archive.sha256", "$($hash.Hash)  $name.zip`r`n", (New-Object Text.UTF8Encoding($false)))
Write-Output "ZIP: $archive"
Write-Output "Application: $application"
Write-Output "API_ENDPOINT=$apiEndpoint"
Write-Output "WEBSOCKET_ENDPOINT=$websocketEndpoint"
