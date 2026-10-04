#Requires -Version 5.1
<#
  ICT judge harness -- ENCODING-PROOF SOURCE
  ==========================================
  This file is deliberately 100% ASCII. Windows PowerShell 5.1 decodes
  BOM-less .ps1 files using the system ANSI codepage (936/GBK here), so any
  non-ASCII byte in this source would turn into a syntax error the moment the
  file loses its BOM. All Chinese UI text therefore lives in messages.json and
  is read with an EXPLICIT UTF-8 decoder, which no codepage setting can break.

  Usage
  -----
  Just double-click the launcher (.cmd) that sits next to this script -- it
  prompts for a level number and passes everything through. Or drive it from
  a command line, from this script's own folder:

      <launcher>.cmd -Level 1
      <launcher>.cmd -Level 2
      <launcher>.cmd -Problem L1-A
      <launcher>.cmd -Problem L1-A -ShowInput

  This script locates everything relative to its OWN location, so it works
  from any working directory and after the folder is moved or renamed.

  Answers live in answers/<problem-id>.cj
  Drafts in answers/default/src/*.cj are synced into answers/ before judging.
#>
param(
    [string]$Problem,
    [int]$Level = 0,
    [string]$Source,
    [int]$TimeoutMs = 5000,
    [switch]$ShowInput
)

$ErrorActionPreference = 'Stop'

# Deliberately NOT touching [Console]::OutputEncoding, and deliberately NOT
# running `chcp 65001` in the launcher .cmd.
#
# Two hard-won facts on this machine (both verified by bisection):
#   * `chcp 65001` makes [Console]::ReadLine() return empty/EOF immediately,
#     because changing the console codepage invalidates .NET's cached input
#     stream. That silently killed the whole interactive prompt.
#   * Leaving the output encoding alone makes PowerShell adopt whatever the
#     console uses (cp936 on this box), so the Chinese strings render correctly
#     with no help. The one place where bytes come from outside -- cjc's
#     diagnostics -- is handled explicitly with $AnsiEnc in Invoke-Cjc.

$OjRoot    = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProbRoot  = Join-Path $OjRoot 'problems'
$AnsRoot   = Join-Path $OjRoot 'answers'
$BuildRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'cj-judge-build'
if (-not (Test-Path $BuildRoot)) { New-Item -ItemType Directory -Path $BuildRoot -Force | Out-Null }

$CjcExe = (Get-Command cjc -ErrorAction SilentlyContinue).Source
if (-not $CjcExe) { $CjcExe = 'cjc' }

# cjc emits diagnostics in the system ANSI codepage, not UTF-8. Detect it once.
$AnsiEnc = [System.Text.Encoding]::GetEncoding(
    [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ANSICodePage)

$script:PassCount = 0
$script:FailCount = 0

# --------------------------------------------------------------------------
# UI strings: ASCII fallback table + explicit-UTF8 override from messages.json
# --------------------------------------------------------------------------
$Fallback = @{
    title              = 'ICT judge harness   (timeout {0}ms / case)'
    answersDir         = 'answers dir: {0}'
    problemHeader      = '  PROBLEM {0}'
    noProblemDir       = '  [skip] problem dir not found: {0}'
    notSubmitted       = '  [NOT SUBMITTED] missing answer file: {0}'
    notSubmittedHint   = '           create that file, then re-run this problem.'
    compiling          = '  compiling...'
    compileFailed      = '  x COMPILE FAILED -- read the compiler output before changing code.'
    compileWarn        = '  (compile warnings)'
    caseTimeout        = '  x case {0}  TIMEOUT (>{1}ms)  <- likely a read loop that never ends'
    casePass           = '  v case {0}  PASS  ({1}ms)'
    caseWrong          = '  x case {0}  WRONG ANSWER  ({1}ms)'
    stderrLabel        = '      program stderr:'
    exitCode           = '      exit code = {0} (should be 0)'
    diffCol1           = 'line'
    diffCol2           = 'expected'
    diffCol3           = 'your output'
    missing            = '<none>'
    inputPreview       = '      first 12 lines of input:'
    allPass            = '  -> all cases passed'
    notPass            = '  -> problem NOT passed. fix and re-run.'
    usageTitle         = 'Usage:'
    usageLine1         = '  <launcher>.cmd        (double-click works too: interactive)'
    usageLine2         = '  <launcher>.cmd -Level 7   or   <launcher>.cmd -Problem L7-A'
    noProblemsInLevel  = 'no problems found under level {0}.'
    summary            = '  SUMMARY: {0} passed / {1} not passed'
    askLevel           = 'Level number (e.g. 7), or problem id (e.g. L7-E), a = all; Enter = quit > '
    syncHeader         = '-- sync drafts: answers\default\src  ->  answers --'
    syncItem           = '   synced  {0}'
    syncDone           = '  {0} file(s) synced'
    noSrcDir           = '  (no answers\default\src, sync skipped)'
    srcEmpty           = '  (no .cj files in answers\default\src, sync skipped)'
    badInput           = '  unrecognised "{0}" -- enter 7 / L7-E / a.'
    noProblemsAtAll    = '  no problems found.'
    noCjc1             = 'x cjc not found -- the Cangjie compiler is missing, or not on PATH.'
    noCjc2             = '  Install it, confirm that "cjc -v" prints a version, then re-run.'
    noCjc3             = '  (Judging compiles your .cj with cjc; without it nothing can be judged.)'
    bye                = '  bye.'
}

function Get-MsgTable {
    $p = Join-Path $OjRoot 'messages.json'
    if (-not (Test-Path $p)) { return $Fallback }
    try {
        # Explicit UTF-8: immune to the system ANSI/OEM codepage.
        $json = [System.IO.File]::ReadAllText($p, (New-Object System.Text.UTF8Encoding $false))
        $obj  = $json | ConvertFrom-Json
        $t = @{}
        foreach ($prop in $obj.PSObject.Properties) { $t[$prop.Name] = [string]$prop.Value }
        foreach ($k in $Fallback.Keys) { if (-not $t.ContainsKey($k)) { $t[$k] = $Fallback[$k] } }
        return $t
    } catch {
        Write-Host ('  [warn] messages.json unreadable, falling back to ASCII: ' + $_.Exception.Message) `
            -ForegroundColor DarkYellow
        return $Fallback
    }
}

$M = Get-MsgTable
function T([string]$key) {
    if ($M.ContainsKey($key)) { return $M[$key] }
    if ($Fallback.ContainsKey($key)) { return $Fallback[$key] }
    return $key
}

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
function Get-Normalized([string]$text) {
    if ([string]::IsNullOrEmpty($text)) { return '' }
    $t = $text -replace "`r`n", "`n" -replace "`r", "`n"
    $lines = @($t -split "`n" | ForEach-Object { $_.TrimEnd() })
    $n = $lines.Count
    while ($n -gt 0 -and $lines[$n - 1] -eq '') { $n-- }
    if ($n -eq 0) { return '' }
    return ($lines[0..($n - 1)] -join "`n")
}

function Invoke-Program([string]$exe, [string]$inputText, [int]$timeoutMs) {
    # Redirect stdin/stdout/stderr through FILES, never pipes.
    #
    # Why not pipes: writing a large stdin synchronously while the child streams a
    # large stdout deadlocks. The child fills the stdout pipe buffer, blocks on
    # write, stops draining stdin, and our StandardInput.Write never returns -- so
    # WaitForExit (and therefore the timeout) is never even reached.
    # That bites as soon as a case has ~1MB of input *and* ~1MB of output.
    $inFile  = Join-Path $BuildRoot 'stdin.tmp'
    $outFile = Join-Path $BuildRoot 'stdout.tmp'
    $errFile = Join-Path $BuildRoot 'stderr.tmp'
    [System.IO.File]::WriteAllText($inFile, $inputText, (New-Object System.Text.UTF8Encoding $false))
    foreach ($f in @($outFile, $errFile)) {
        if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
    }

    $p = Start-Process -FilePath $exe -NoNewWindow -PassThru `
            -RedirectStandardInput $inFile `
            -RedirectStandardOutput $outFile `
            -RedirectStandardError $errFile

    $tle = $false
    $code = 0
    $exited = $false
    try { $exited = $p.WaitForExit($timeoutMs) } catch { $exited = $false }
    if (-not $exited) {
        $tle = $true
        try { $p.Kill() } catch {}
        try { $p.WaitForExit(3000) } catch {}
    } else {
        try { $code = $p.ExitCode } catch {}
    }

    $o = ''; $e = ''
    if (Test-Path $outFile) { try { $o = [System.IO.File]::ReadAllText($outFile) } catch {} }
    if (Test-Path $errFile) { try { $e = [System.IO.File]::ReadAllText($errFile) } catch {} }
    return [pscustomobject]@{ Output = $o; Err = $e; Timeout = $tle; ExitCode = $code }
}

function Show-Diff([string]$expected, [string]$got) {
    $e = @($expected -split "`n")
    $g = @($got -split "`n")
    if ($null -eq $expected) { $e = @() }
    if ($null -eq $got)      { $g = @() }
    $max = [Math]::Max($e.Count, $g.Count)
    Write-Host ("      {0,-4} | {1,-22} | {2}" -f (T 'diffCol1'), (T 'diffCol2'), (T 'diffCol3')) -ForegroundColor DarkGray
    for ($i = 0; $i -lt $max; $i++) {
        $ev = if ($i -lt $e.Count) { $e[$i] } else { T 'missing' }
        $gv = if ($i -lt $g.Count) { $g[$i] } else { T 'missing' }
        if ($ev -ceq $gv) {
            Write-Host ("      {0,-4} | {1,-22} | {2}" -f ($i + 1), $ev, $gv) -ForegroundColor DarkGray
        } else {
            Write-Host ("  >>  {0,-4} | {1,-22} | {2}" -f ($i + 1), $ev, $gv) -ForegroundColor Yellow
        }
    }
}

# Compile with cjc, capturing diagnostics as PLAIN TEXT.
# Do NOT use "& cjc ... 2>&1" here: with $ErrorActionPreference='Stop', any
# native stderr output (e.g. "warning: unused variable") becomes a terminating
# PowerShell error and aborts the whole run before the exit code is even read.
function Invoke-Cjc([string]$srcPath, [string]$exePath) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName               = $CjcExe
    $psi.Arguments              = '"' + $srcPath + '" -o "' + $exePath + '"'
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute        = $false
    # Compile inside the per-run dir so cjc's package-named intermediates do not
    # land in the repo folder or collide between runs.
    $psi.WorkingDirectory       = (Split-Path -Parent $exePath)
    $psi.CreateNoWindow         = $true
    # cjc writes its diagnostics in the SYSTEM ANSI codepage (936 here), NOT in
    # UTF-8. Decoding them as UTF-8 turns any Chinese character inside a
    # compiler message -- typically our own file path -- into mojibake.
    try {
        $psi.StandardOutputEncoding = $AnsiEnc
        $psi.StandardErrorEncoding  = $AnsiEnc
    } catch {}
    $p = [System.Diagnostics.Process]::Start($psi)
    $outT = $p.StandardOutput.ReadToEndAsync()
    $errT = $p.StandardError.ReadToEndAsync()
    $p.WaitForExit()
    $txt = (($outT.Result + $errT.Result)).Trim()
    return [pscustomobject]@{ ExitCode = $p.ExitCode; Text = $txt }
}

function Test-Problem([string]$probId, [string]$srcPath) {
    Write-Host ''
    Write-Host ("=" * 66) -ForegroundColor DarkGray
    Write-Host ((T 'problemHeader') -f $probId) -ForegroundColor Cyan
    Write-Host ("=" * 66) -ForegroundColor DarkGray

    $pdir = Join-Path $ProbRoot $probId
    if (-not (Test-Path $pdir)) {
        Write-Host ((T 'noProblemDir') -f $pdir) -ForegroundColor Red
        $script:FailCount++; return $false
    }
    if (-not (Test-Path $srcPath)) {
        Write-Host ((T 'notSubmitted') -f $srcPath) -ForegroundColor Red
        Write-Host (T 'notSubmittedHint') -ForegroundColor DarkGray
        $script:FailCount++; return $false
    }

    # Unique build dir per judged problem: a shared folder collides when two runs
    # overlap or a stale run still holds a handle (cjc also drops package-named
    # intermediates such as default.cjo into its working directory).
    $runDir = Join-Path $BuildRoot ("run-" + $probId + "-" + [System.Guid]::NewGuid().ToString('N'))
    if (-not (Test-Path $runDir)) { New-Item -ItemType Directory -Path $runDir -Force | Out-Null }
    $exe = Join-Path $runDir "$probId.exe"

    Write-Host (T 'compiling') -ForegroundColor DarkGray
    $r = Invoke-Cjc -srcPath $srcPath -exePath $exe
    $cjcMsg = $r.Text
    if ($r.ExitCode -ne 0 -or -not (Test-Path $exe)) {
        Write-Host (T 'compileFailed') -ForegroundColor Red
        Write-Host ''
        Write-Host $cjcMsg.TrimEnd() -ForegroundColor Gray
        $script:FailCount++
        Remove-Item $runDir -Recurse -Force -ErrorAction SilentlyContinue
        return $false
    }
    if ($cjcMsg.Trim()) {
        Write-Host (T 'compileWarn') -ForegroundColor DarkYellow
        Write-Host $cjcMsg.TrimEnd() -ForegroundColor DarkGray
    }

    $inFiles = @(Get-ChildItem (Join-Path $pdir 'in') -Filter '*.txt' | Sort-Object Name)
    $allOk = $true
    foreach ($f in $inFiles) {
        $outFile = Join-Path (Join-Path $pdir 'out') $f.Name
        $inputText = [System.IO.File]::ReadAllText($f.FullName)
        $expText   = [System.IO.File]::ReadAllText($outFile)
        $exp = Get-Normalized $expText

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $r = Invoke-Program -exe $exe -inputText $inputText -timeoutMs $TimeoutMs
        $sw.Stop()
        $ms = $sw.ElapsedMilliseconds

        if ($r.Timeout) {
            Write-Host ((T 'caseTimeout') -f $f.BaseName, $TimeoutMs) -ForegroundColor Red
            $allOk = $false; continue
        }

        $got = Get-Normalized $r.Output
        if ($got -ceq $exp) {
            Write-Host ((T 'casePass') -f $f.BaseName, $ms) -ForegroundColor Green
            continue
        }

        $allOk = $false
        Write-Host ((T 'caseWrong') -f $f.BaseName, $ms) -ForegroundColor Red
        if ($r.Err.Trim()) {
            Write-Host (T 'stderrLabel') -ForegroundColor DarkYellow
            Write-Host ("      " + $r.Err.TrimEnd().Replace("`n", "`n      ")) -ForegroundColor DarkYellow
        }
        # $null -ne 0 is TRUE in PowerShell, so the old check printed this line
        # (with an empty value) even on a clean run. Only report a real non-zero code.
        if ($null -ne $r.ExitCode -and $r.ExitCode -ne 0) {
            Write-Host ((T 'exitCode') -f $r.ExitCode) -ForegroundColor DarkYellow
        }
        Show-Diff -expected $exp -got $got
        if ($ShowInput) {
            $preview = @($inputText -split "`n" | Select-Object -First 12)
            Write-Host (T 'inputPreview') -ForegroundColor DarkGray
            foreach ($l in $preview) { Write-Host ("        | " + $l) -ForegroundColor DarkGray }
        }
    }

    if ($allOk) {
        Write-Host (T 'allPass') -ForegroundColor Green
        $script:PassCount++
    } else {
        Write-Host (T 'notPass') -ForegroundColor Red
        $script:FailCount++
    }
    Remove-Item $runDir -Recurse -Force -ErrorAction SilentlyContinue
    return $allOk
}

# --------------------------------------------------------------------------
# Draft sync:  answers\default\src\*.cj   ->   answers\
# Runs before every judging batch, so the file you just edited is what gets
# judged. Reports every file it touched (never silently overwrites).
# --------------------------------------------------------------------------
function Sync-Drafts {
    $srcDir = Join-Path $AnsRoot 'default\src'
    if (-not (Test-Path $srcDir)) {
        Write-Host (T 'noSrcDir') -ForegroundColor DarkGray
        return
    }
    $files = @(Get-ChildItem $srcDir -Filter '*.cj' -File -ErrorAction SilentlyContinue | Sort-Object Name)
    if ($files.Count -eq 0) {
        Write-Host (T 'srcEmpty') -ForegroundColor DarkGray
        return
    }
    Write-Host ''
    Write-Host (T 'syncHeader') -ForegroundColor DarkCyan
    foreach ($f in $files) {
        Copy-Item $f.FullName (Join-Path $AnsRoot $f.Name) -Force
        Write-Host ((T 'syncItem') -f $f.Name) -ForegroundColor DarkGray
    }
    Write-Host ((T 'syncDone') -f $files.Count) -ForegroundColor DarkCyan
}

# --------------------------------------------------------------------------
# Target list + one judging batch
# --------------------------------------------------------------------------
function Get-Targets {
    # NOTE: do not name any parameter/variable $pid, $Pid, $PID ... PowerShell
    # variable names are case-INsensitive and $PID (current process id) is
    # read-only, so assigning to it throws "Cannot overwrite variable Pid".
    param([string]$ProbId, [int]$Lv, [switch]$All)
    $list = @()
    if ($ProbId) {
        $s = if ($Source) { $Source } else { Join-Path $AnsRoot "$ProbId.cj" }
        $list += [pscustomobject]@{ Pid = $ProbId; Src = $s }
        return $list
    }
    if ($All) {
        $dirs = @(Get-ChildItem $ProbRoot -Directory -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -match '^L\d+-' } | Sort-Object Name)
        foreach ($d in $dirs) {
            $list += [pscustomobject]@{ Pid = $d.Name; Src = (Join-Path $AnsRoot "$($d.Name).cj") }
        }
        return $list
    }
    $dirs = @(Get-ChildItem $ProbRoot -Directory -Filter "L$Lv-*" -ErrorAction SilentlyContinue | Sort-Object Name)
    foreach ($d in $dirs) {
        $list += [pscustomobject]@{ Pid = $d.Name; Src = (Join-Path $AnsRoot "$($d.Name).cj") }
    }
    return $list
}

function Invoke-Batch {
    param([object[]]$Targets)
    $script:PassCount = 0
    $script:FailCount = 0
    Write-Host ''
    Write-Host ((T 'title') -f $TimeoutMs) -ForegroundColor White
    Write-Host ((T 'answersDir') -f $AnsRoot) -ForegroundColor DarkGray
    foreach ($t in $Targets) { Test-Problem -probId $t.Pid -srcPath $t.Src | Out-Null }
    Write-Host ''
    Write-Host ("=" * 66) -ForegroundColor DarkGray
    Write-Host ((T 'summary') -f $script:PassCount, $script:FailCount) `
        -ForegroundColor $(if ($script:FailCount -eq 0) { 'Green' } else { 'Yellow' })
    Write-Host ("=" * 66) -ForegroundColor DarkGray
}

function Read-Reply {
    param([string]$Prompt)
    Write-Host ''
    Write-Host $Prompt -ForegroundColor Cyan -NoNewline
    try { return [Console]::ReadLine() } catch { return $null }
}

# --------------------------------------------------------------------------
# Fail fast and clearly when the Cangjie compiler is unavailable.
#
# On a machine without Cangjie, Start-Process used to throw a raw .NET
# exception ("The system cannot find the file specified"), which tells the
# user nothing about what is actually wrong or what to do. Checked here so
# both the CLI and the interactive path behave the same way.
# --------------------------------------------------------------------------
if (-not (Get-Command cjc -ErrorAction SilentlyContinue)) {
    Write-Host ''
    Write-Host (T 'noCjc1') -ForegroundColor Red
    Write-Host (T 'noCjc2') -ForegroundColor Yellow
    Write-Host (T 'noCjc3') -ForegroundColor DarkGray
    Write-Host ''
    exit 3
}

# --------------------------------------------------------------------------
# Mode A: driven by command-line arguments (scriptable / non-interactive)
# --------------------------------------------------------------------------
if ($Problem -or $Level -ne 0) {
    $targets = @(Get-Targets -ProbId $Problem -Lv $Level)
    if ($targets.Count -eq 0) {
        Write-Host ((T 'noProblemsInLevel') -f $Level) -ForegroundColor Red
        exit 2
    }
    if (-not $Source) { Sync-Drafts }
    Invoke-Batch -Targets $targets
    if ($script:FailCount -eq 0) { exit 0 } else { exit 1 }
}

# --------------------------------------------------------------------------
# Mode B: interactive -- this is what double-clicking the launcher gives you
# --------------------------------------------------------------------------
while ($true) {
    $line = Read-Reply -Prompt (T 'askLevel')
    if ($null -eq $line) { Write-Host ''; break }
    $line = $line.Trim()
    if ($line -eq '') { break }

    $wantPid = $null; $wantLv = 0; $wantAll = $false
    if ($line -match '^\d+$') {
        $wantLv = [int]$line
    } elseif ($line -match '^[Ll]\d+-[A-Za-z]+$') {
        $wantPid = $line.ToUpper()
    } elseif ($line -match '^(a|A|all|ALL)$') {
        $wantAll = $true
    } else {
        Write-Host ((T 'badInput') -f $line) -ForegroundColor Red
        continue
    }

    Sync-Drafts
    $targets = @(Get-Targets -ProbId $wantPid -Lv $wantLv -All:$wantAll)
    if ($targets.Count -eq 0) {
        Write-Host (T 'noProblemsAtAll') -ForegroundColor Red
        continue
    }
    Invoke-Batch -Targets $targets
}

Write-Host (T 'bye') -ForegroundColor DarkGray
exit 0
