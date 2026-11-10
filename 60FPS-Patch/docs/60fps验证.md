# 60 FPS 模式验证记录

日期：2026-11-08
环境：Windows，RTX 3060 Laptop，165 Hz；游戏内场景（Scrin 矿场/单位）
游戏：`RetailExe\1.0\cnc3ep1.dat`，SHA-256 `f0c621ed35aad6b9cc773249925f30236976040c48ac32fa45010697ff516d40`
补丁：SAGE-Unlocked v1.9.5，`SAGEUnlocked.ini` 中 `fps=60`
工具：Frida（REA）挂 `0x570C79`（每帧 update）与 `0x583577`（phase 派发）

---

## 1. 前台测量（验收数据）

```json
{"seconds":"5.001","frames":300,"fps":"59.99","dispCalls":152,"ticks":"76.00","tps":"15.197","patchFps":60}
{"seconds":"5.002","frames":299,"fps":"59.78","dispCalls":151,"ticks":"75.50","tps":"15.094","patchFps":60}
```

- 渲染：**59.78～59.99 FPS**（目标 60；两次采样，Frida 插桩有少量开销）
- 逻辑：**15.094～15.197 tick/s**（原版 15.200 tick/s，差 ≤0.7%）
- 每 tick 派发 2 次（phase 1-3 一次、4-6 一次），因此 `ticks = dispCalls / 2`
- 补丁单元 `fps=60`，逻辑常量 `0xB72ADC=15`，渲染常量 `0xB72AE0=30`
- 两次采样差值来自 60 FPS 下 4 帧/tick 的量化、场景负载与 Frida 采样窗口，不是速度漂移

## 2. 原版基线（补丁关闭，主菜单）

```json
{"seconds":"5.000","frames":152,"fps":"30.40","dispCalls":152,"ticks":"76.00","tps":"15.200"}
```

## 3. 后台窗口测量（非验收）

把游戏窗口切到后台后采样：

```json
{"seconds":"5.002","frames":194,"fps":"38.78","dispCalls":101,"ticks":"50.50","tps":"10.096"}
```

这是窗口失焦后 Windows/DWM 对后台窗口的渲染节流（约 39 FPS），逻辑随之下降；
前台游玩不受影响。60 FPS 模式的验收数据以第 1 节为准。

## 4. 插值

60 FPS 下每个逻辑 tick 有 `60/15 = 4` 个渲染帧，`interp` 在 tick 内按约 1/4 步进：
5 秒采样中观察到 63 个不同值（0 → 1 连续变化），说明动画在 tick 间平滑插值。

## 5. 启动日志

见 `verification/SAGEUnlocked-60fps.log`：

```
2026/11/8 16:06:15  SAGE Unlocked 1.9.5-kw1.0-drawfix, drop-in DLL, fps=60, zoom=1, exe=cnc3ep1.dat
found: sched ffwd scroll camerakeys interp limiter models particles fades camsteps
       fxframes throb shake stream audio floattext fpsframes blinks tint modeltimer
       turrets offscreenanim
missing: construction anim2d zoom traillock sway pulse topple
patch memory 0x5B50000-0x5B51FFF
sites: ... | sched 0x570CD7 0x570DA6 | newtick 0x423CA2 | ...
```

## 6. 截图（未随 GPL 包分发）

游戏截图属于 EA 游戏画面，不属于 GPLv3 授权的补丁代码，为避免把 EA 游戏资产混入
GPL 分发包，本包不包含 `verification/*.png`，仅保留不含画面的
`verification/SAGEUnlocked-60fps.log`。

## 7. drawfix（单位不显示修复）验证

版本 `1.9.5-kw1.0-drawfix`。修复前 `0x423CA2` 的原函数在 batches 调度下永远返回 0
（只认 phase==1，而 phase 停在 3），drawable 不更新，新出现的电脑阵营单位不绘制。
修复后日志出现 `| newtick 0x423CA2`，该函数被替换为读取调度器 flag 的 stub。

60 FPS 前台 5 秒测量：

```json
{"seconds":"5.002","frames":299,"fps":"59.78","dispCalls":152,"ticks":"76.00","tps":"15.194",
 "tickCalls":916,"tickTrue":243,"truePerSec":"48.58","patchFps":60,"logic":15,"render":30}
```

- 渲染 59.78 FPS、逻辑 15.194 tick/s（原版 15.200，差 0.04%）。
- `isNewTick` 返回 yes 约 48.6 次/秒（每 tick 的多个调用点），修复前为 0。
- 视觉：`newtick 0x423CA2` 生效后，Scrin 传送门与 Nod 步兵同时绘制；截图未随 GPL 包分发。
- 版本 DLL SHA-256：`d2c1979abd5cfcbe1b5ca7061891fc9eb47a11480adc6e333acbc60ab54545d8`。
