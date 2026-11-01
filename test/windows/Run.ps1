[CmdletBinding()]
param(
    [ValidateRange(1, 100)][int]$MaxTurn = 2,
    [ValidateRange(1, 100)][int]$StartRound = 1,
    [string]$ServerHost = '192.168.117.129',
    [string]$OutputDirectory = 'D:\huai_an_80\auto_test',
    [switch]$SkipDeploy,
    [switch]$SkipBuild
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($StartRound -gt $MaxTurn) { throw 'StartRound exceeds MaxTurn.' }
$utf8 = New-Object Text.UTF8Encoding($false)
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$catalog = Join-Path $PSScriptRoot 'case.list'
$selection = Join-Path $OutputDirectory 'need_test.list'
New-Item -ItemType Directory -Force $OutputDirectory | Out-Null
$rows = @(Import-Csv -LiteralPath $catalog -Delimiter "`t" -Encoding UTF8 -Header Id,Title,Status,Layer,Expected | Select-Object -Skip 1)
if ($StartRound -gt 1) {
    $previousName = [string][char]0x7b2c + ($StartRound - 1) + [char]0x8f6e
    $previousResults = Join-Path $OutputDirectory "$previousName\results.tsv"
    if (-not (Test-Path -LiteralPath $previousResults)) {
        throw "Previous round report is required: $previousResults"
    }
    $previous = @(Import-Csv -LiteralPath $previousResults -Delimiter "`t" -Header Id,Title,Status -Encoding UTF8)
    $retryIds = @($previous | Where-Object { $_.Status -ne 'PASS' -and $_.Status -ne 'TODO' } | Select-Object -ExpandProperty Id -Unique)
    if ($retryIds.Count -eq 0) {
        Write-Output 'Previous round has no remaining cases; stopping.'
        exit 0
    }
    $retryText = New-Object 'Collections.Generic.List[string]'
    foreach ($id in $retryIds) {
        $row = $rows | Where-Object { $_.Id -eq $id }
        if ($null -eq $row) { throw "Unknown case in previous report: $id" }
        $issuePath = Join-Path $OutputDirectory "$previousName\issues\$($row.Title)-$id\issue.txt"
        if (Test-Path -LiteralPath $issuePath) {
            $retryText.Add([IO.File]::ReadAllText($issuePath).Trim())
        } else {
            $retryText.Add("$id`t$($row.Title)")
        }
        $retryText.Add('')
    }
    [IO.File]::WriteAllLines($selection, $retryText.ToArray(), $utf8)
} elseif (-not (Test-Path -LiteralPath $selection)) {
    [IO.File]::WriteAllLines($selection, @($rows | Where-Object { $_.Status -ne 'TODO' } | ForEach-Object { "$($_.Id)`t$($_.Title)" }), $utf8)
}
$roundName = [string][char]0x7b2c + $StartRound + [char]0x8f6e
$round = Join-Path $OutputDirectory $roundName
if (Test-Path (Join-Path $round 'results.tsv')) {
    throw "Round already has results. Choose a new StartRound; never overwrite review evidence: $round"
}
New-Item -ItemType Directory -Force (Join-Path $round 'issues') | Out-Null
[IO.File]::WriteAllText((Join-Path $OutputDirectory 'run-settings.json'), (@{
    N = $StartRound; MaxTurn = $MaxTurn
    API_ENDPOINT = "http://${ServerHost}:8081"
    WEBSOCKET_ENDPOINT = "ws://${ServerHost}:8080/events"
} | ConvertTo-Json), $utf8)
[IO.File]::WriteAllText((Join-Path $round 'passed_case.txt'), '', $utf8)
$ErrorActionPreference = 'Continue'
try {
    if (-not $SkipDeploy) {
        & (Join-Path $PSScriptRoot 'Deploy.ps1') -ServerHost $ServerHost -OutputDirectory $OutputDirectory 2>&1 |
            ForEach-Object { "$_" } | Tee-Object -FilePath (Join-Path $round 'deployment.log')
        if (-not $?) { throw 'Deployment failed.' }
    }
    $health = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 "http://${ServerHost}:8080/healthz" -ErrorAction Stop
    if ($health.StatusCode -ne 204) { throw 'HTTP endpoint is not healthy: expected 204 No Content.' }
    $arguments = @(
        "--dart-define=API_ENDPOINT=http://${ServerHost}:8081",
        "--dart-define=WEBSOCKET_ENDPOINT=ws://${ServerHost}:8080/events",
        "--dart-define=AUTO_TEST_CATALOG=$catalog",
        "--dart-define=AUTO_TEST_SELECTION=$selection",
        "--dart-define=AUTO_TEST_ROUND=$round"
        "--dart-define=AUTO_TEST_UI=$(Join-Path $OutputDirectory 'ui')"
    )
    Push-Location (Join-Path $root 'client')
    try {
        if (-not $SkipBuild) {
            & flutter build windows --debug @arguments 2>&1 | ForEach-Object { "$_" } |
                Tee-Object -FilePath (Join-Path $round 'build.log')
            if ($LASTEXITCODE -ne 0) { throw 'Windows client build failed.' }
        }
        & flutter drive -d windows --driver=test_driver\windows_driver.dart --target=integration_test\windows_real_test.dart @arguments 2>&1 |
            ForEach-Object { "$_" } | Tee-Object -FilePath (Join-Path $round 'integration.log')
        if ($LASTEXITCODE -ne 0) { throw "flutter drive failed with exit code $LASTEXITCODE; preserving framework and per-case failures." }
    } finally { Pop-Location }
} catch {
    $issue = Join-Path $round 'issues\Environment-runner-failed-ENV-RUN'
    New-Item -ItemType Directory -Force $issue | Out-Null
    [IO.File]::WriteAllText((Join-Path $issue 'issue.txt'), "ENV-001`tEnvironment or runner failed`n$_`n$($_.ScriptStackTrace)`n", $utf8)
    Write-Error $_
} finally {
    $ErrorActionPreference = 'Stop'
    $resultFile = Join-Path $round 'results.tsv'
    $finishedIds = @()
    if (Test-Path $resultFile) {
        $finishedIds = @(Get-Content -LiteralPath $resultFile -Encoding UTF8 | ForEach-Object { ($_ -split "`t")[0] })
    }
    $selectedIds = @(Get-Content -LiteralPath $selection -Encoding UTF8 | ForEach-Object {
        if ($_ -match '^([A-Z]+-\d+)\b') { $matches[1] }
    } | Select-Object -Unique)
    foreach ($id in $selectedIds) {
        if ($finishedIds -notcontains $id) {
            $row = $rows | Where-Object { $_.Id -eq $id }
            if ($null -eq $row) { throw "Unknown case ID: $id" }
            $title = $row.Title
            $issue = Join-Path $round "issues\$title-$id"
            New-Item -ItemType Directory -Force $issue | Out-Null
            [IO.File]::WriteAllText((Join-Path $issue 'issue.txt'), "$id`t$title`nNOT_RUN`nEnvironment or runner stopped before this case. See deployment.log, build.log and integration.log.`n", $utf8)
            [IO.File]::AppendAllText($resultFile, "$id`t$title`tNOT_RUN`n", $utf8)
        }
    }
    & (Join-Path $PSScriptRoot 'Report.ps1') -OutputDirectory $OutputDirectory
    $issues = @(Get-ChildItem (Join-Path $round 'issues') -Filter issue.txt -Recurse)
    if ($issues.Count -gt 0) {
        $retry = New-Object 'Collections.Generic.List[string]'
        foreach ($issue in $issues) {
            $text = [IO.File]::ReadAllText($issue.FullName)
            $retry.Add($text.Trim())
            $retry.Add('')
        }
        [IO.File]::WriteAllLines($selection, $retry.ToArray(), $utf8)
        $next = $StartRound + 1
        $prompt = @"
Review every issue.txt under $round\issues, plus deployment.log/build.log/integration.log.
Work only in $root on the current branch. MaxTurn=$MaxTurn, completed round=$StartRound.
Fix root causes with minimal changes and targeted tests. Do not mark unexecuted tests PASS.
Do not delete review evidence or alter acceptance thresholds to hide failures.
Commit only verified bug fixes, referencing the local issue path in each commit.
Include Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>.
Never commit generated credentials, tokens, logs or screenshots.
After fixes, if $next <= $MaxTurn, run test\windows\Run.ps1 -StartRound $next -MaxTurn $MaxTurn.
Otherwise stop. Always regenerate the final case report.
"@
        [IO.File]::WriteAllText((Join-Path $round 'repair-prompt.txt'), $prompt, $utf8)
        Write-Warning "Issues recorded. Copilot handoff: $round\repair-prompt.txt. Next round=$next, MaxTurn=$MaxTurn."
        exit 1
    }
}
