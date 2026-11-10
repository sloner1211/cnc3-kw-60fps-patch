# 对上游 SAGE-Unlocked 的代码改动与效果

本补丁基于 **@TheeHorse** 的开源项目 **SAGE-Unlocked v1.9.5**
（<https://github.com/TheeHorse/SAGE-Unlocked>，GPL-3.0；源码头为 `GPL v3 or later`）二次制作。

**修改日期：2026-11-10**。`src/Unlocker.cs` 文件头已按 GPLv3 §5a 加入修改声明和日期；
本文件记录具体改动与效果。

`src/Unlocker.cs` 相对上游的差异：**18 insertions, 2 deletions**（`git diff --no-index`）。

## 1. 增加 split 形态 `isNewTick` 识别（核心修复）

**位置**：`ApplyPatches`，`modeCheck` 计算之后。

```csharp
if (modeCheck.Count == 0)
{
    var splitNewTick = sites.Where(s =>
        img[s - 1 - ImageBase] == 0xA1 &&      // mov eax,[renderFps]
        img[s - 2 - ImageBase] == 0xCC &&      // int3 padding: function entry
        img[s + 4 - ImageBase] == 0xE9).ToList(); // jmp body (split form)
    if (splitNewTick.Count == 1) modeCheck = splitNewTick;
}
```

**背景**：

- 1.0 版本的 `isNewTick` 是 `0x423CA2: mov eax,[0xB72AE0]` → `jmp 0x56DAC3` 的 split 形态；
- 原函数在 `ratio >= 6` 时只认 `phase == 1`，而 batches 调度把 phase 停在 3；
- 上游的 `newtick` 特征扫描找不到这个 split 函数，导致 `isNewTick` 永远返回 0，
  drawable 不更新，**电脑阵营步兵/坦克完全不显示但仍能攻击**。

**效果**：

- `isNewTick` 被替换为读取调度器 flag 的 stub，每 tick 首帧返回 1；
- 日志出现 `| newtick 0x423CA2 |`；
- 敌方单位恢复正常绘制；
- 不改变逻辑 tick（仍约 15.1～15.2 次/秒）。

## 2. 从 fps 重定向集合中排除 `modeCheck`

**位置**：`ApplyPatches` 的 `Redirect` 调用。

```diff
- Redirect(proc, sites.Except(ratio).ToList(), (uint)mem);
+ Redirect(proc, sites.Except(ratio).Except(modeCheck).ToList(), (uint)mem);
```

**原因**：`newtick` 会把 `0x423CA2` 的 5 个字节替换为 `jmp rel32`；
如果随后又把 `0x423CA3` 当 fps 操作数写入 4 字节，会覆盖 jmp 的相对偏移，导致跳转损坏。

**效果**：保证 `newtick` stub 的跳转完整，修复稳定生效。

## 3. 版本号与打包（非引擎逻辑改动）

- `Version` 改为 `"1.9.5-kw1.0-drawfix"`，便于日志识别；
- 增加 60 FPS 预设 `SAGEUnlocked.ini`（`fps=60`）；
- 增加 `ATTRIBUTION.md`、`BUILD.md`、`build-from-source.bat`、`src/build-proxy.bat`；
- 增加中文验证文档、截图、安装/卸载脚本；
- 这些改动不改变补丁的运行时行为，只影响分发与可复现性。

## 4. 没有改动的内容

- 没有修改游戏本体文件（`.dat`、`.big`、模型、贴图、音效、动画曲线均未动）；
- 没有修改上游的调度器、粒子、相机、动画等既有修复；
- 没有把 30 当成 120（仍保留 30 Hz 特效时钟）。

## 5. 实测效果

| 项目 | 原版 | 60 FPS 补丁 | 120 FPS 补丁 |
|---|---|---|---|
| 渲染帧率 | 30.40 FPS | 59.78～59.99 FPS | 118.35～118.78 FPS |
| 逻辑 tick | 15.200/s | 15.09～15.20/s | 15.094～15.194/s |
| 敌方单位 | 正常 | 正常（修复后） | 正常（修复后） |
| 逻辑帧率常量 | 15 | 15（未改） | 15（未改） |

> 逻辑 tick 的差异来自采样与帧率量化，在 0.7% 以内；游戏速度和动画速度不变。
