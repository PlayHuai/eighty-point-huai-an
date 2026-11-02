[CmdletBinding()]
param([string]$OutputDirectory = 'D:\huai_an_80\auto_test')
$ErrorActionPreference = 'Stop'
$rounds = @(Get-ChildItem -LiteralPath $OutputDirectory -Directory |
    Where-Object { $_.Name -match '^\u7b2c\d+\u8f6e$' } |
    Sort-Object { [int]([regex]::Match($_.Name, '\d+').Value) })
$report = New-Object 'Collections.Generic.List[string]'
$report.Add('Windows / Ubuntu real environment case report')
$report.Add('Generated: ' + (Get-Date -Format o))
$previousFailures = @{}
$lastFailures = @{}
$latestResults = @{}
foreach ($round in $rounds) {
    $report.Add('')
    $report.Add($round.Name)
    $file = Join-Path $round.FullName 'results.tsv'
    if (Test-Path $file) {
        $results = @(Get-Content -LiteralPath $file -Encoding UTF8 |
            Where-Object { $_.Trim() } | ForEach-Object {
                $fields = $_ -split "`t"
                [pscustomobject]@{ Id = $fields[0]; Title = $fields[1]; Status = $fields[2] }
            })
        foreach ($group in @($results | Group-Object Status)) {
            $report.Add("$($group.Name): $($group.Count)")
        }
        foreach ($result in $results) {
            $latestResults[$result.Id] = $result
            if ($result.Status -eq 'PASS') {
                if ($previousFailures.ContainsKey($result.Id)) {
                    if ($previousFailures[$result.Id] -eq 'FAIL') {
                        $report.Add("Verified resolved (see assessment for product/test distinction): $($result.Id) $($result.Title)")
                    } else {
                        $report.Add("Now executed and passed (not previously verified as a product defect): $($result.Id) $($result.Title)")
                    }
                    $lastFailures.Remove($result.Id)
                }
            } else {
                $previousFailures[$result.Id] = $result.Status
                $lastFailures[$result.Id] = "$($result.Status) $($result.Title)"
            }
        }
    } else { $report.Add('No integration results: environment/build did not complete.') }
    foreach ($issue in @(Get-ChildItem (Join-Path $round.FullName 'issues') -Filter issue.txt -Recurse -ErrorAction SilentlyContinue)) {
        $report.Add('Evidence: ' + $issue.FullName)
    }
}
$report.Add('')
$report.Add('Latest known result per case across all rounds (earlier PASS cases are not rerun):')
foreach ($group in @($latestResults.Values | Group-Object Status)) {
    $report.Add("$($group.Name): $($group.Count)")
}
$report.Add('')
$report.Add('Remaining issues (only a later PASS removes a prior failure):')
foreach ($id in @($lastFailures.Keys | Sort-Object)) { $report.Add("$id $($lastFailures[$id])") }
$report.Add('Commits are not proof of a fix; only a subsequent real test PASS verifies it.')
$uiCatalog = Join-Path $PSScriptRoot 'ui.list'
if (Test-Path -LiteralPath $uiCatalog) {
    $coverage = New-Object 'Collections.Generic.List[string]'
    $coverage.Add("Feature`tStatus`tPath")
    $missing = 0
    foreach ($row in @(Import-Csv -LiteralPath $uiCatalog -Delimiter "`t" -Encoding UTF8 -Header Feature,Name,Notes | Select-Object -Skip 1)) {
        $image = Join-Path $OutputDirectory ("ui\" + $row.Name + '.png')
        $status = 'MISSING'
        if ((Test-Path -LiteralPath $image) -and (Get-Item -LiteralPath $image).Length -gt 0) { $status = 'CAPTURED' } else { $missing++ }
        $coverage.Add("$($row.Feature)`t$status`t$image")
    }
    $report.Add('')
    $report.Add("UI page/dialog inventory: missing=$missing. See ui-coverage.tsv; screenshots are visual evidence, not case PASS.")
    [IO.File]::WriteAllLines((Join-Path $OutputDirectory 'ui-coverage.tsv'), $coverage.ToArray(), (New-Object Text.UTF8Encoding($false)))
}
$assessment = Join-Path $OutputDirectory 'review-assessment.txt'
if (Test-Path -LiteralPath $assessment) {
    $report.Add('')
    $report.Add('Review assessment:')
    foreach ($line in [IO.File]::ReadAllLines($assessment)) { $report.Add($line) }
}
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllLines((Join-Path $OutputDirectory 'case_report.txt'), $report.ToArray(), $utf8)
