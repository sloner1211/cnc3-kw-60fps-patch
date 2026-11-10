# 开源归属声明 / Attribution

**本项目基于 @TheeHorse 的开源项目 SAGE-Unlocked 二次制作。**

- 上游项目名称：**SAGE-Unlocked**
- 上游作者：**@TheeHorse**（GitHub 登录名 `TheeHorse`；部分旧文档写作 `threehorse`）
- 上游地址：<https://github.com/TheeHorse/SAGE-Unlocked>
- 上游版本：**v1.9.5**
- 上游许可证：**GNU GPL v3.0**；源码头写 **`GPL v3 or later`**（见 `src/LICENSE.txt`）
- 本二次制作修改日期：**2026-11-10**

本仓库/压缩包中的 60 FPS 补丁是在上述项目基础上进行的二次制作，主要修改：

1. 针对《命令与征服3：凯恩之怒》1.0.2955.37387（`RetailExe\1.0\cnc3ep1.dat`）增加
   `isNewTick` 的 split 形态识别（`newtick 0x423CA2`），修复“电脑阵营步兵/坦克不显示”；
2. 从 fps 重定向集合中排除 `modeCheck`，避免覆盖 `newtick` 的 `jmp rel32`；
3. 生成 60 FPS 预设、安装/卸载脚本、验证数据与中文文档；
4. 未修改游戏本体文件，补丁仅作用于运行时内存。

## 上游 Credits（必须保留）

上游 README 的 Credits 段还列出：

- [red-alert-3-60fps-mod](https://github.com/isma3iloiso/red-alert-3-60fps-mod) by isma3iloiso
- [CNCStuff/cnc3_fps_patch](https://github.com/CNCStuff/cnc3_fps_patch)
- [apitrace](https://github.com/apitrace/apitrace)
- **Not affiliated with EA. Command & Conquer, Red Alert and Tiberium are trademarks of Electronic Arts.**

这些 credit 与商标声明随本补丁一并保留。

## 截图与游戏资产

`docs/verification/` 中可能包含游戏截图；游戏画面、模型、贴图、音频等属于 EA，
**不属于 GPLv3 授权的补丁代码**。为避免把 EA 游戏资产当作 GPL 内容分发，本包不包含
游戏截图，只保留不含画面的日志；补丁本身也不包含任何游戏本体文件。

## 再分发

若再分发本补丁，请保留：

1. 本声明与上游项目名称、上游地址；
2. `@TheeHorse` / `SAGE-Unlocked` 的 credit；
3. GPLv3 许可证（`src/LICENSE.txt` / 根目录 `LICENSE`）；
4. 上游 Credits 与 EA 商标声明；
5. 被修改源文件中的修改声明和日期。

本补丁按 **GPLv3** 分发；不得附加“禁止商用、禁止修改、禁止再分发”等额外限制。
