#Requires -Version 5.1
<#
  verify_all.ps1 -- acceptance sweep for the whole problem bank.

  THIS FILE MUST STAY 100% ASCII. Windows PowerShell 5.1 decodes a BOM-less
  .ps1 with the system ANSI codepage (936 here), so any non-ASCII byte turns
  into a syntax error or a regex that never matches. Success is therefore
  detected via the judge's EXIT CODE, not by matching its Chinese output.

  Usage (from the DSA_Cangjie_topic root):
      powershell -NoProfile -ExecutionPolicy Bypass -File _build\verify_all.ps1
      powershell -NoProfile -ExecutionPolicy Bypass -File _build\verify_all.ps1 -Level 8

  For every problems\<ID> it runs
    1. _build\check.py <ID>                              (statement/data consistency)
    2. judge.ps1 -Problem <ID> -Source _build\ref\<ID>.cj (real replay)
  and prints one table, exiting non-zero if anything failed.
#>
param([int]$Level = 0)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$probRoot = Join-Path $root 'problems'
$judge = Join-Path $root 'judge.ps1'
$checker = Join-Path $root '_build\check.py'
$py = 'D:\python\python.exe'
if (-not (Test-Path $py)) { $py = 'python' }

$dirs = @(Get-ChildItem $probRoot -Directory |
          Where-Object { $_.Name -match '^D\d+-' } |
          Sort-Object @{ Expression = { [int]($_.Name -replace '^D(\d+)-.*$', '$1') } }, Name)
if ($Level -gt 0) { $dirs = @($dirs | Where-Object { $_.Name -match ('^D' + $Level + '-') }) }
if ($dirs.Count -eq 0) { Write-Host 'no problems matched'; exit 2 }

$rows = @()
$fail = 0
foreach ($d in $dirs) {
    $id = $d.Name
    $ref = Join-Path (Join-Path $root '_build\ref') ($id + '.cj')

    $null = & $py $checker $id 2>&1
    $checkOk = ($LASTEXITCODE -eq 0)

    $judgeOk = $false
    $maxMs = 0
    if (Test-Path $ref) {
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $judge -Problem $id -Source $ref 2>&1
        $judgeOk = ($LASTEXITCODE -eq 0)
        foreach ($m in [regex]::Matches((($out | Out-String)), '\((\d+)ms\)')) {
            $v = [int]$m.Groups[1].Value
            if ($v -gt $maxMs) { $maxMs = $v }
        }
    }

    if (-not ($checkOk -and $judgeOk)) { $fail++ }
    $rows += [pscustomobject]@{
        ID    = $id
        Check = $(if ($checkOk) { 'ok' } else { 'FAIL' })
        Judge = $(if ($judgeOk) { 'pass' } else { 'FAIL' })
        MaxMs = $maxMs
    }
    $color = if ($checkOk -and $judgeOk) { 'Green' } else { 'Red' }
    Write-Host ("{0,-6} check={1,-4} judge={2,-4} max={3,5}ms" -f $id, $rows[-1].Check, $rows[-1].Judge, $maxMs) -ForegroundColor $color
}

Write-Host ''
Write-Host ("=" * 60) -ForegroundColor DarkGray
$pass = $rows.Count - $fail
$slowest = ($rows | Sort-Object MaxMs -Descending | Select-Object -First 1)
Write-Host ("TOTAL {0} problems: {1} pass / {2} fail" -f $rows.Count, $pass, $fail) `
    -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
if ($slowest) { Write-Host ("slowest case: {0} at {1}ms" -f $slowest.ID, $slowest.MaxMs) -ForegroundColor DarkGray }
Write-Host ("=" * 60) -ForegroundColor DarkGray
if ($fail -eq 0) { exit 0 } else { exit 1 }
