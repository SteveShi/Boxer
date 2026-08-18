# Boxer Changelog / 更新日志

## Version 2.0.0-Alpha7 (English)

This release modernizes Boxer's core dependencies, featuring a pure Swift 6 Metal rendering pipeline with the latest OpenEmuShaders, updated Roland MT-32 emulation via Munt 2.8.2, and native Apple GameController framework integration for modern wireless gamepads.

### Key Changes
- **Swift 6 Metal Rendering Pipeline**: Rebuilt the Metal video rendering view and screenshot capture extensions in pure Swift 6, directly integrating with the latest upstream `OpenEmuShaders` framework (`2ac33a9`) and modernized SPIRV toolchains.
- **Roland MT-32 Munt 2.8.2 Engine**: Upgraded `Vendor/MT32Emu` to the latest `munt_2_8_2` release, delivering enhanced MIDI synthesis accuracy, modernized DSP filters, and universal Apple Silicon / Intel binary support.
- **Native Wireless Gamepad Support**: Introduced `BXGameControllerMonitor` leveraging Apple's `GameController.framework`, providing out-of-the-box support for modern Bluetooth wireless controllers including Xbox Wireless, PlayStation DualSense / DualShock 4, and Nintendo Switch Pro controllers.
- **What's New in Boxer**: Added a native SwiftUI `WhatsNewSheetView` with full localization for highlighting new features on major updates.

---

## 版本 2.0.0-Alpha7 (中文)

本版本全面完成了 Boxer 核心 Vendor 依赖库的现代化重构，包含基于纯 Swift 6 的 Metal 渲染管线与最新 OpenEmuShaders 升级、基于 Munt 2.8.2 的 Roland MT-32 仿真引擎升级，以及基于 Apple GameController 框架的原生现代无线手柄支持。

### 主要更新
- **纯 Swift 6 Metal 渲染管线**：使用纯 Swift 6 全面重构了 Metal 画面渲染视图与截图捕获扩展，直接接入上游最新 `OpenEmuShaders` 框架（`2ac33a9`）及全新 SPIRV 工具链。
- **Roland MT-32 Munt 2.8.2 仿真引擎**：升级 `Vendor/MT32Emu` 核心引擎至最新的 `munt_2_8_2` 正式版，大幅提升 MIDI 音乐合成精度与 DSP 滤波质量，并全面支持 Apple Silicon 与 Intel 双架构。
- **原生现代无线手柄支持**：引入基于 Apple 官方 `GameController.framework` 的 `BXGameControllerMonitor`，原生支持 Xbox 无线手柄、PlayStation DualSense / DualShock 4 及 Nintendo Switch Pro 手柄的即插即用与无线蓝牙连接。
- **新功能特性弹窗**：新增原生 SwiftUI `WhatsNewSheetView` 弹窗与多语言本地化支持，用于在版本更新时直观展示新特性。

---

## Version 2.0.0-Alpha6 (English)

This release fixes the DOSBox command execution failure where custom emulator startup commands were not intercepted by the Objective-C frontend, preventing the game from launching automatically and showing "Illegal command" errors.

### Key Changes
- **Fix Custom Command Interception**: Re-introduced the `boxer_shellShouldRunCommand` check inside `DOS_Shell::DoCommand` (`shell_cmds.cpp`). This ensures Boxer-specific shell commands like `boxer_preflight` and `boxer_launch` are correctly intercepted and handled by the app frontend instead of falling through to the emulator shell and raising errors.
- **Restore Game Auto-Launch**: Intercepting `boxer_launch` correctly triggers the emulator delegate to boot the target executable immediately, resolving the issue where the game box would stop at the Favorites/Launch Panel on load.

---

## 版本 2.0.0-Alpha6 (中文)

本版本修复了自定义虚拟机启动指令未被 Cocoa 前端拦截，从而导致 DOSBox 执行报错并无法自动进入游戏的问题。

### 主要更新
- **修复自定义指令拦截**：重新在 `DOS_Shell::DoCommand`（`shell_cmds.cpp`）中接入了 `boxer_shellShouldRunCommand` 检查，确保 `boxer_preflight` 和 `boxer_launch` 等 Boxer 专属控制指令能被 Cocoa 框架正确捕获与执行，避免这些指令被传导至 DOSBox 终端引发 `Illegal command` 报错。
- **恢复游戏自动运行**：修复了拦截逻辑后，`boxer_launch` 会正确驱动虚拟机代理以直接运行目标游戏程序，解决了双击打开游戏包（Gamebox）时直接卡在 Favorites 快捷启动界面的问题。

---

## Version 2.0.0-Alpha5 (English)

This release fixes the process launch hang and loading spinner freeze issues by resolving a thread exception crash.

### Key Changes
- **Fix Emulator Thread Exception**: Fixed a fatal `NSInvalidArgumentException` when initializing the process info dictionary with a `nil` drive during the launch of `AUTOEXEC.BAT`. Refactored dictionary creation in `BXEmulator+BXShell` to safely check for `nil` pointers.
- **Multithreaded Emulation Stability**: Restored full stability to the multithreaded emulation run loop, ensuring the Cocoa event loop and the emulator thread run seamlessly in parallel.

---

## 版本 2.0.0-Alpha5 (中文)

本版本解决了虚拟机启动挂起和 Loading 转圈冻结的问题，修复了子线程字典空值异常崩溃。

### 主要更新
- **修复仿真线程异常崩溃**：修复了在启动 `AUTOEXEC.BAT` 批处理文件时，由于 `drive` 驱动器为 `nil` 从而在初始化 `processInfo` 字典时引发的致命 `NSInvalidArgumentException` 异常。重构了 `BXEmulator+BXShell` 中的字典构建逻辑以安全防御 `nil` 指针。
- **多线程仿真稳定性**：恢复了多线程仿真模式下虚拟机主循环与前台 Cocoa 事件 RunLoop 并行运转的稳定性，确保游戏和提示符界面能够流畅载入并消除转圈挂起。

---

## Version 2.0.0-Alpha4 (English)

This release updates the Sparkle auto-update framework to the latest version.

### Key Changes
- **Sparkle Framework Update**: Updated Sparkle dependency from 2.9.1 to 2.9.2, ensuring compatibility with the latest auto-update features and security improvements.

---

## 版本 2.0.0-Alpha4 (中文)

本版本更新了 Sparkle 自动更新框架到最新版本。

### 主要更新
- **Sparkle 框架更新**：将 Sparkle 依赖从 2.9.1 升级到 2.9.2，确保与最新的自动更新功能和安全改进兼容。

---

## Version 2.0.0-Alpha3 (English)

This release establishes our modern, premium CI/CD pipelines, automates localized release notes parsing, and unifies the release scheme for all three software targets.

### Key Changes
- **CI/CD Automation Pipeline**: Fully re-designed and expanded the GitHub Actions CI/CD workflows to simultaneously compile all three software targets (**Boxer**, **Boxer Standalone**, and **Boxer Bundler**) for Apple Silicon.
- **Sparkle-Ready Localized Release Notes**: Built an intelligent Python-based automatic parser for localized Release Notes. Upon pushing a version tag, the CI dynamically extracts English and Chinese sections from `CHANGELOG.md` matching the tag version, perfect for Sparkle's multi-lingual update dialogs.
- **Multi-App Distribution Packages**: Integrated automated `.zip` and `.dmg` creation and signing-free packaging for all three platforms (6 distribution files in total) and automated GitHub Release publishing.
- **Repository and Branch Pruning**: Fully cleaned up and deleted outdated or obsolete local and remote tracking branches across the main codebase and DOSBox-Staging submodules, locking the environment onto a pure and clean `main` branch setup.
- **Unified Software Versioning**: Standardized and synchronized the software version numbers to `2.0.0-Alpha3` across all targets.

---

## 版本 2.0.0-Alpha3 (中文)

本版本建立了现代、高级的 CI/CD 自动化流水线，实现了本地化更新日志的自动截取解析，并统一了所有三个软件目标的发布方案。

### 主要更新
- **CI/CD 自动化流水线**：重构并扩展了 GitHub Actions CI/CD 工作流，实现针对 Apple Silicon 架构同时自动编译 **Boxer**、**Boxer Standalone** 和 **Boxer Bundler** 三个软件目标。
- **支持 Sparkle 的双语 Release Notes 提取**：构建了智能 Python 脚本解析器。当您推送版本 Tag 时，CI 会动态从 `CHANGELOG.md` 中隔离提取出与该版本完全对应的中英文更新日志，完美适配 Sparkle 的多语言更新弹窗。
- **多应用分发打包**：整合了三大目标平台独立 `.zip` 与 `.dmg` 文件（共 6 个发布资产）的自动化压缩、打包和 GitHub Release 发布流程。
- **仓库与分支深度清理**：彻底清理并删除了主仓库和 DOSBox-Staging 子模块中所有陈旧、无用的本地与远程跟踪分支，将构建环境锁定在极度纯净的 `main` 分支上。
- **统一软件版本号**：将所有三个软件目标的 MARKETING_VERSION 统一升级并同步为 `2.0.0-Alpha3`。

---

## Version 2.0.0-Alpha2 (English)

This is an alpha release of Boxer featuring a major architectural migration under the hood, updating our emulation core to the modern and highly active **DOSBox-Staging**.

### Key Changes
- **Core Migration**: Successfully ported Boxer's emulation backend to the latest **DOSBox-Staging** codebase.
- **Modern Memory Management**: Refactored directory cache and drive management stack to use C++ standard smart pointers (`std::shared_ptr` / `std::unique_ptr`), ensuring robust memory safety and preventing resource leaks.
- **Audio Stack Modernization**: Refactored the core audio mixer and channels to interface with the strictly typed `MixerChannelPtr` API in DOSBox-Staging.
- **Modern API Adoption**: Replaced the deprecated `NSReadPixel` call with modern `NSBitmapImageRep` rendering APIs in `CoverArt.swift`.
- **UI & Cleanups**: Updated the About window information to correctly credit DOSBox-Staging, updated copyright to 2025, and corrected building/plist configurations.

---

## 版本 2.0.0-Alpha2 (中文)

这是一个测试版本，在底层进行了重大的架构迁移，将我们的模拟核心升级到了现代且高度活跃的 **DOSBox-Staging** 项目。

### 主要更新
- **核心移植**：成功将 Boxer 模拟后端移植到最新的 **DOSBox-Staging** 源码库。
- **现代内存管理**：重构了目录缓存和驱动器管理模块，全面使用 C++ 标准智能指针 (`std::shared_ptr` / `std::unique_ptr`)，提升内存安全性并防止资源泄漏。
- **音频栈现代化**：重构了核心音频混音器与通道，以适配 DOSBox-Staging 中强类型的 `MixerChannelPtr` API。
- **现代化 API 适配**：替换了 `CoverArt.swift` 中已被废弃的 `NSReadPixel` 调用，转而采用现代的 `NSBitmapImageRep` 渲染接口。
- **界面与清理**：更新了「关于」窗口的信息，正确致谢了 DOSBox-Staging 项目，更新版权信息至 2025 年，并修正了构建与 Plist 的相关配置。
