@echo off
rem ---------------------------------------------------------------
rem  ICT judge  --  DOUBLE-CLICK THIS FILE
rem
rem  ASCII-ONLY ON PURPOSE: cmd.exe reads .cmd files with the OEM
rem  codepage (936 here), NOT UTF-8. UTF-8 Chinese in this file gets
rem  mangled and the mangled bytes are executed as bogus commands.
rem  All Chinese UI text lives in messages.json instead.
rem
rem  Double-click : interactive -- type a level number, press Enter.
rem  Command line : (this launcher) -Level 7
rem                 (this launcher) -Problem L7-A
rem ---------------------------------------------------------------

rem NOTE: do NOT add `chcp 65001` here. Changing the console codepage makes
rem [Console]::ReadLine() inside judge.ps1 return EOF immediately, which kills
rem the interactive prompt. Encoding is handled in judge.ps1 instead.

title ICT judge
pushd "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0judge.ps1" %*
set RC=%ERRORLEVEL%

popd

rem Pause only when launched with no arguments (= double-clicked) so the
rem window stays open long enough to read the result. CLI use never pauses.
if "%~1"=="" (
  echo.
  pause
)

exit /b %RC%
