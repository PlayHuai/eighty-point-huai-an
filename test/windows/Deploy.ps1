[CmdletBinding()]
param(
    [string]$ServerHost = '192.168.117.129',
    [string]$OutputDirectory = 'D:\huai_an_80\auto_test'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if ($ServerHost -notmatch '^[a-zA-Z0-9.-]+$') { throw 'Invalid server host.' }
New-Item -ItemType Directory -Force $OutputDirectory | Out-Null
$staging = Join-Path $OutputDirectory ('upload-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $staging | Out-Null
try {
    $files = Join-Path $staging 'files.txt'
    $archive = Join-Path $staging 'source.tar.gz'
    Push-Location $root
    try {
        $paths = @(git -c core.quotepath=false ls-files --cached --others --exclude-standard)
        if ($LASTEXITCODE -ne 0) { throw 'git ls-files failed.' }
        [IO.File]::WriteAllLines($files, $paths, (New-Object Text.UTF8Encoding($false)))
        & python (Join-Path $PSScriptRoot 'archive_source.py') $archive $files
        if ($LASTEXITCODE -ne 0) { throw 'Source archive failed.' }
        $commit = git rev-parse HEAD
        if ($LASTEXITCODE -ne 0) { throw 'Cannot determine source commit.' }
        [IO.File]::WriteAllText((Join-Path $staging 'source-commit.txt'), "$commit`n")
    } finally { Pop-Location }
    & ssh -o BatchMode=yes -o ConnectTimeout=10 "derek@$ServerHost" 'mkdir -p /home/derek/auto_test'
    if ($LASTEXITCODE -ne 0) { throw 'SSH preflight failed.' }
    & scp -o BatchMode=yes $archive "derek@${ServerHost}:/home/derek/auto_test/source.tar.gz"
    if ($LASTEXITCODE -ne 0) { throw 'Source upload failed.' }
    & ssh -o BatchMode=yes "derek@$ServerHost" 'cd /home/derek/auto_test && tar -xzf source.tar.gz && rm source.tar.gz'
    if ($LASTEXITCODE -ne 0) { throw 'Source extraction failed.' }
    & scp -o BatchMode=yes (Join-Path $staging 'source-commit.txt') "derek@${ServerHost}:/home/derek/auto_test/test/windows/source-commit.txt"
    if ($LASTEXITCODE -ne 0) { throw 'Build metadata upload failed.' }
    $ErrorActionPreference = 'Continue'
    & ssh -o BatchMode=yes "derek@$ServerHost" 'cd /home/derek/auto_test && bash test/windows/deploy-ubuntu.sh' 2>&1 | ForEach-Object { "$_" }
    $deployExit = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($deployExit -ne 0) { throw 'Ubuntu deployment failed; see deployment.log.' }
    $health = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 "http://${ServerHost}:8080/healthz"
    if ($health.StatusCode -ne 204) { throw 'HTTP health probe failed: expected 204 No Content.' }
    $tcp = New-Object Net.Sockets.TcpClient
    try {
        $connect = $tcp.ConnectAsync($ServerHost, 8081)
        if (-not $connect.Wait(10000)) { throw 'gRPC TCP probe timed out.' }
        $connect.GetAwaiter().GetResult()
    } finally { $tcp.Dispose() }
} finally {
    Remove-Item -LiteralPath $staging -Recurse -Force
}
