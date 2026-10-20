#Requires -Version 5.1
<#
  gen_out.ps1 -- build-time helper: regenerate problems\<ID>\out\*.txt
  from a reference solution.

  Usage (from the topic root):
      powershell -File _build\gen_out.ps1 -Problem D1-A -Source _build\ref\D1-A.cj

  What it does:
    1. compiles the reference solution with cjc into a temp dir
    2. for every problems\<ID>\in\NN.txt, runs it and writes out\NN.txt
       (UTF-8 no BOM, LF endings, single trailing newline)
    3. reports per-case wall time, so the case size can be sanity-checked
       against the 5 s judge limit

  NOTE: this only WRITES expected outputs; the judge is the thing that
  verifies them. Always run judge.ps1 -Problem <ID> -Source <same source>
  afterwards.
#>
param(
    [Parameter(Mandatory = $true)][string]$Problem,
    [string]$Source
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$pdir = Join-Path (Join-Path $root 'problems') $Problem
if (-not (Test-Path $pdir)) { throw "problem dir not found: $pdir" }
if (-not $Source) { $Source = Join-Path $root ('_build\ref\' + $Problem + '.cj') }
if (-not (Test-Path $Source)) { throw "source not found: $Source" }
$Source = (Resolve-Path -LiteralPath $Source).Path

$cjc = (Get-Command cjc -ErrorAction SilentlyContinue).Source
if (-not $cjc) { throw 'cjc not found on PATH' }

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('dsa-gen-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
$exe = Join-Path $tmp ($Problem + '.exe')

Write-Host "compile $Source"
$out1 = Join-Path $tmp 'cjc.out'
$err1 = Join-Path $tmp 'cjc.err'
$p = Start-Process -FilePath $cjc -ArgumentList ('"' + $Source + '" -o "' + $exe + '"') `
        -NoNewWindow -PassThru -Wait -RedirectStandardOutput $out1 -RedirectStandardError $err1
if ($p.ExitCode -ne 0 -or -not (Test-Path $exe)) {
    Write-Host 'COMPILE FAILED' -ForegroundColor Red
    Get-Content $out1, $err1 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_ }
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}
$warn = ((Get-Content $out1, $err1 -ErrorAction SilentlyContinue) -join "`n").Trim()
if ($warn) { Write-Host $warn -ForegroundColor DarkYellow }

$inDir = Join-Path $pdir 'in'
$outDir = Join-Path $pdir 'out'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$utf8 = New-Object System.Text.UTF8Encoding $false
$files = @(Get-ChildItem $inDir -Filter '*.txt' | Sort-Object Name)
foreach ($f in $files) {
    $o = Join-Path $tmp ('o-' + $f.BaseName + '.tmp')
    $e = Join-Path $tmp ('e-' + $f.BaseName + '.tmp')
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $pr = Start-Process -FilePath $exe -NoNewWindow -PassThru -Wait `
            -RedirectStandardInput $f.FullName -RedirectStandardOutput $o -RedirectStandardError $e
    $sw.Stop()
    if ($pr.ExitCode -ne 0) {
        Write-Host ("  x {0} exit={1}" -f $f.Name, $pr.ExitCode) -ForegroundColor Red
        Get-Content $e -ErrorAction SilentlyContinue | ForEach-Object { Write-Host ('      ' + $_) }
        continue
    }
    $txt = [System.IO.File]::ReadAllText($o)
    $txt = ($txt -replace "`r`n", "`n") -replace "`r", "`n"
    $txt = $txt.TrimEnd("`n") + "`n"
    [System.IO.File]::WriteAllText((Join-Path $outDir $f.Name), $txt, $utf8)
    $kb = [Math]::Round((Get-Item $f.FullName).Length / 1KB, 1)
    $ob = (Get-Item (Join-Path $outDir $f.Name)).Length
    Write-Host ("  v {0}  in={1}KB  out={2}B  {3}ms" -f $f.Name, $kb, $ob, $sw.ElapsedMilliseconds) -ForegroundColor Green
    if ($sw.ElapsedMilliseconds -gt 2000) {
        Write-Host '      ! slow case (>2s): shrink the data or fix the algorithm' -ForegroundColor Yellow
    }
}
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'done. now verify with:  judge.ps1 -Problem <ID> -Source <ref>' -ForegroundColor DarkGray
