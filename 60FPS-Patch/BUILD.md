# 构建说明（60 FPS 补丁）

本目录包含补丁的完整源码：

| 文件 | 作用 |
|---|---|
| `src/Unlocker.cs` | `CnCFpsUnlocker.dll` 的完整 C# 源码（含 1.0 drawfix） |
| `src/proxy.c` | `dinput8.dll` 代理的完整 C 源码 |
| `src/LICENSE.txt` | GPLv3 许可证 |
| `bin/CnCFpsUnlocker.dll` | 已编译的补丁 DLL（SHA-256 `d2c1979a…`） |
| `bin/dinput8.dll` | 已编译的代理 DLL（MinGW 32 位） |
| `bin/SAGEUnlocked.ini` | 60 FPS 配置 |

## 1. 编译 CnCFpsUnlocker.dll

需要 Windows 自带的 .NET Framework 4.x C# 编译器：

```bat
build-from-source.bat
```

它等价于：

```bat
"%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe" /nologo /platform:x86 /optimize ^
  /target:library /r:System.Core.dll /out:bin\CnCFpsUnlocker.dll src\Unlocker.cs
```

源码与随包的 `bin\CnCFpsUnlocker.dll` 对应；重新编译得到的 DLL 大小一致，
PE 的 MVID/时间戳可能不同，因此哈希不保证逐字节相同。

## 2. 编译 dinput8.dll（可选）

随包已提供编译好的 `bin\dinput8.dll`。如需从 `src/proxy.c` 重建，需要
**32 位 MinGW-w64**（`i686-w64-mingw32-gcc`）：

```bat
src\build-proxy.bat
```

等价于：

```bat
i686-w64-mingw32-gcc -m32 -shared -o bin\dinput8.dll src\proxy.c ^
  -DPROXY_DINPUT8 -Wl,--kill-at -static-libgcc -lole32
```

只做凯恩之怒的 `dinput8.dll` 代理，不需要 `-DPROXY_D3D9`（那是 RA3 的 d3d9 代理）。
上游的 `Forwarder.cs` 只用于 RA3 的独立启动器，本 KW 补丁不使用，故未包含。

## 3. 验证

```powershell
Get-FileHash .\bin\CnCFpsUnlocker.dll -Algorithm SHA256
Get-FileHash .\bin\dinput8.dll -Algorithm SHA256
Get-Content .\docs\SHA256SUMS.txt
```

运行游戏后查看 `SAGEUnlocked.log`，应包含：

```
SAGE Unlocked 1.9.5-kw1.0-drawfix, drop-in DLL, fps=60, ...
sites: ... | sched 0x570CD7 0x570DA6 | newtick 0x423CA2 | ...
```

## 4. 许可证

本补丁基于 @TheeHorse 的 **SAGE-Unlocked** 二次制作，
按 **GPL-3.0** 分发；详见 `ATTRIBUTION.md` 与 `src/LICENSE.txt`。
