@echo off
setlocal
where i686-w64-mingw32-gcc >nul 2>nul
if errorlevel 1 (
  echo i686-w64-mingw32-gcc not found.
  echo Install a 32-bit MinGW-w64 toolchain, or use the prebuilt bin\dinput8.dll.
  exit /b 1
)
if not exist "%~dp0..\bin" mkdir "%~dp0..\bin"
i686-w64-mingw32-gcc -m32 -shared -o "%~dp0..\bin\dinput8.dll" "%~dp0proxy.c" -DPROXY_DINPUT8 -Wl,--kill-at -static-libgcc -lole32
if errorlevel 1 (
  echo Build failed.
  exit /b 1
)
echo Built bin\dinput8.dll
