# 60 FPS 动画补丁（Command & Conquer 3: Kane's Wrath / 凯恩之怒）

> ## 开源归属声明（必须保留）
>
> **本项目基于 @TheeHorse 的开源项目 SAGE-Unlocked 二次制作。**
>
> - 上游项目名称：**SAGE-Unlocked**
> - 上游作者：**@TheeHorse**（GitHub 登录名 `TheeHorse`；部分旧文档写作 `threehorse`）
> - 上游地址：<https://github.com/TheeHorse/SAGE-Unlocked>
> - 许可证：**GPL-3.0**（源码头写 `GPL v3 or later`，见 `src/LICENSE.txt`）
> - 本二次制作：1.0 版本的 `isNewTick` split 修复（drawfix）、60 FPS 预设与验证文档。
>
> 代码改动与效果详见 [`MODIFICATIONS.md`](MODIFICATIONS.md)；完整归属、上游 Credits 与 EA 商标声明见 [`ATTRIBUTION.md`](ATTRIBUTION.md)。

这是 120 FPS 补丁的 60 FPS 版本，用于在性能较弱或希望降低 GPU/CPU 占用时自由选择。
**补丁 DLL 与 120 FPS 版完全相同**（`1.9.5-kw1.0-drawfix`），只是 `SAGEUnlocked.ini`
中的 `fps=60`；同一个 DLL 支持 30/45/60/75/90/105/120/135/150/165 等 15 的倍数。

## 重要修复（单位不显示）

本版本包含 `drawfix`：修复上游 1.9.5 在 1.0 版本上“电脑阵营步兵/坦克完全不显示、
但仍能攻击”的严重问题。根因是 SAGE 的 `isNewTick`（0x423CA2 → 0x56DAC3）在 batches
调度下永远返回 0，drawable 不更新；本版本识别 split 形态并启用 `newtick` stub，
日志会多出 `| newtick 0x423CA2`。

详细分析见 [`docs/修复说明-单位不显示.md`](docs/修复说明-单位不显示.md)，
验证日志见 `docs/verification/SAGEUnlocked-60fps.log`（为避免 EA 游戏画面版权问题，
游戏截图不随 GPL 包分发）。

## 安装

把 `bin\` 下三个文件复制到：

```
<游戏目录>\RetailExe\1.0\
```

（`cnc3ep1.dat` 所在目录），正常启动 `cnc3ep1.exe`。

或运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

卸载：`powershell -ExecutionPolicy Bypass -File .\uninstall.ps1`

## 验证结果

测试场景：遭遇战内（Scrin 矿场/单位画面），游戏窗口在前台，165 Hz 显示器。

| 项目 | 原版（补丁关闭） | 60 FPS 补丁（drawfix） |
|---|---|---|
| 渲染帧率 | 30.40 FPS | **59.78～59.99 FPS** |
| 逻辑 tick | 15.200 次/秒 | **15.09～15.20 次/秒（多次采样）** |
| 逻辑帧率常量 | 15 | 15（未改） |
| 渲染帧率常量 | 30 | 30（代码读取重定向到 60） |
| `newtick` 单位更新 | 原版按 phase==1 | `newtick 0x423CA2`，约 48 次/秒（每 tick 的多个调用点） |

逻辑 tick 与原版差 **≤0.7%**（采样误差与 60/4 帧量化的范围内），游戏速度与原动画速度不变；
60 FPS 下每个逻辑 tick 有 4 个渲染帧，动画用 `interp` 在 tick 间插值。

> 测量必须让游戏窗口处于前台。窗口切到后台时 Windows/游戏会把渲染节流到约 39 FPS，
> 此时测得的 tick 会下降，不代表前台游玩表现；验收数据均在前台采集。

## 与 120 FPS 版的关系

- 两个包里的 `dinput8.dll`、`CnCFpsUnlocker.dll` 完全相同（SHA-256 一致）。
- 唯一区别是 `SAGEUnlocked.ini` 的 `fps` 值。
- 想随时切换：使用工作区根目录的 `切换帧率.ps1`（或双击 `切换到60帧.bat` /
  `切换到120帧.bat`），它会修改 ini 并提示重启游戏；加 `-Restart` 会自动重启。

## 上游 Credits 与商标

上游 `SAGE-Unlocked` README 的 Credits 段还列出：

- [red-alert-3-60fps-mod](https://github.com/isma3iloiso/red-alert-3-60fps-mod) by isma3iloiso
- [CNCStuff/cnc3_fps_patch](https://github.com/CNCStuff/cnc3_fps_patch)
- [apitrace](https://github.com/apitrace/apitrace)
- **Not affiliated with EA. Command & Conquer, Red Alert and Tiberium are trademarks of Electronic Arts.**

这些 credit 与商标声明随本补丁一并保留；本补丁不是 TheeHorse 或 EA 的官方发布，也未获得其背书。

## 说明与限制

- 目标帧率必须是 15 的倍数；工具会把目标帧率限制在显示器刷新率向下取整的 15 倍数。
- 本版本针对 `1.0.2955.37387` 验证；其他版本/模组查看 `SAGEUnlocked.log` 的 found/missing。
- 未测试联机同步；单机战役/遭遇战已验证。补丁只改内存，不修改游戏文件。
- 上游 SAGE-Unlocked v1.9.5 为 GPLv3；完整源码与许可证在 `src/` 中（含本次 1.0 版本的
  `newtick` split 修复），引擎逆向说明见 `docs/引擎逆向与实现原理.md`。
