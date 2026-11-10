@echo off
setlocal
set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%CSC%" (
  echo csc.exe not found: %CSC%
  exit /b 1
)
if not exist "%~dp0bin" mkdir "%~dp0bin"
"%CSC%" /nologo /platform:x86 /optimize /target:library /r:System.Core.dll "/out:%~dp0bin\CnCFpsUnlocker.dll" "%~dp0src\Unlocker.cs"
if errorlevel 1 (
  echo Build failed.
  exit /b 1
)
echo Built bin\CnCFpsUnlocker.dll
