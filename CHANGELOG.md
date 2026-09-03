# Boxer Changelog / 更新日志

## Version 2.0.0-Beta1 (English)

This landmark Beta release marks the full modernization of Boxer's emulation core, upgrading to the latest **DOSBox-Staging 0.83.0** specifically optimized for Apple Silicon (ARM64). It incorporates deep architectural advancements, C++20 modernizations, native ARM64 dynamic recompiler core, enhanced audio synthesis, and improved FAT filesystem handling while preserving Boxer's native macOS interface, Metal shaders, and CoreAudio integration.

### Key Changes
- **DOSBox-Staging 0.83.0 Core**: Completely upgraded the core DOS emulation engine to 0.83.0, incorporating modern C++20 design, modern configuration management, improved CPU emulation accuracy, and new sound modules.
- **Native Apple Silicon (ARM64) Dynamic Core**: Fully adapted upstream `C_TARGET_CPU_ARM` dynrec core, ensuring blazing-fast native JIT emulation on Apple Silicon.
- **Physical Drive Noise Emulation**: Integrated 22 authentic floppy drive and mechanical hard drive head seek audio samples from DOSBox-Staging 0.83.0. Added settings toggles in Preferences (General) and Drives menu with instant runtime hot-reloading.
- **Roland Sound Canvas (SC-55) Support**: Bundled the latest universal Nuked-SC55 CLAP plugin with native ARM64 & x86_64 binaries. Added automatic ROM discovery in `~/Library/Application Support/Boxer/Sound Canvas ROMs/` and one-click reveal actions in Preferences and Help menu.
- **FMV Video Deinterlacing**: Integrated DOSBox-Staging's adaptive deinterlacer for FMV cutscenes, with real-time strength controls (Off, Light, Medium, Strong, Full) directly in the Display menu.
- **Native MDS/MDF Disc Image Support**: Added native UTI recognition and mounting support for multi-track CD images in `.mds`/`.mdf` format.
- **CoreMIDI & MT-32 Sound Pipeline Integration**: Hooked DOSBox-Staging 0.83.0 MIDI message streaming directly into Boxer's built-in General MIDI (`BXMIDISynth`) and Roland MT-32 (`BXEmulatedMT32`) synthesis pipelines, ensuring authentic music playback for all classic titles without requiring external hardware.
- **Batch & Executable Type Resolution**: Updated DOS batch (.BAT) and COM UTIs to conform to modern macOS UniformTypeIdentifiers standards, ensuring reliable automatic program execution.
- **FAT File System & Media ID Detection**: Upgraded drive mounting and floppy drive emulation with explicit 1.44MB media identification, enabling authentic floppy seek acoustics and improved disc image compatibility.
- **Seamless Cocoa & Metal Host Bridge**: Re-architected `BXCoalface` run loop, window, and render event callbacks, cleanly bridging DOSBox-Staging 0.83.0 into Boxer's pure Swift 6 Metal pipeline and native macOS UI.
- **Updated What's New Sheet**: Highlights the new DOSBox-Staging 0.83.0 features upon launching this major milestone.

---

## 版本 2.0.0-Beta1 (中文)

本里程碑 Beta 版本标志着 Boxer 底层仿真内核的全面现代化飞跃，正式将仿真引擎全面升级至最新的 **DOSBox-Staging 0.83.0**，专为 Apple Silicon (ARM64) 架构深度优化。本次升级深度适配了其 C++20 现代架构、原生 ARM64 动态重译核心、升级音频合成器以及更精准的 FAT 软驱介质模拟，同时完美保留了 Boxer 原生 macOS Cocoa 界面、Metal 着色器和 CoreAudio 原生音效管线。

### 主要更新
- **全面升级 DOSBox-Staging 0.83.0 内核**：将底层 DOSBox 核心升级至 0.83.0 正式版，引入现代 C++20 代码架构、全新配置系统、更精准的 CPU 周期与中断仿真及全新音频合成器。
- **原生 Apple Silicon (ARM64) 动态重译核心**：深度适配 0.83.0 的 `C_TARGET_CPU_ARM` dynrec 核心，在 Apple Silicon 上提供极致流畅的原生 JIT 动态重译仿真性能。
- **物理驱动器机械寻道音效仿真**：完整提取并集成 DOSBox-Staging 0.83.0 全部 22 个真实软盘与机械硬盘磁头寻道音效样本，在“偏好设置 - 通用”及“驱动器”菜单中提供开关控制，并支持运行时热重载。
- **Roland Sound Canvas (SC-55) 仿真支持**：集成最新通用架构（ARM64 + x86_64）Nuked-SC55 CLAP 插件，原生支持扫描 `~/Library/Application Support/Boxer/Sound Canvas ROMs/` 目录，并在帮助菜单与音频设置中提供一键在访达中定位 ROM 文件夹功能。
- **全动态视频 (FMV) 去隔行器**：接入 0.83.0 官方自适应视频去隔行算法，并在“显示”菜单中提供关闭、轻度、适中、强力、完全 5 档实时切换选项。
- **原生 MDS/MDF 多音轨光盘镜像支持**：注册 `org.cdemu.mds-image` 原生类型，支持直接挂载与导入含多音轨的 MDS/MDF 复杂光盘镜像。
- **CoreMIDI 与内置 MT-32 音频管线桥接**：深度重构并打通 0.83.0 与 Boxer 内置音频合成器的消息总线，使 General MIDI（`BXMIDISynth`）与 Roland MT-32（`BXEmulatedMT32`）无需外接物理硬件即可享受原汁原味的内置高品质数字音乐与音效。
- **批处理文件与执行体类型修正**：更新 DOS 批处理文件（.BAT）及 COM 程序的 UTI 标准，对齐 macOS UniformTypeIdentifiers 规范，彻底解决批处理脚本无法直接启动运行的问题。
- **FAT 文件系统与软驱寻道音效**：升级虚拟驱动器构造器，精准支持 1.44MB 介质类型识别与更真实的物理软驱寻道音效。
- **无缝衔接 Cocoa 与 Metal 宿主桥接**：在 `BXCoalface` 中完全对齐 0.83.0 的主事件循环、窗口及渲染管理新接口，让 0.83.0 的仿真数据无缝流经 Boxer 原生 Swift 6 Metal 着色器引擎与系统界面。
- **新版本特性弹窗**：更新了应用启动时的“新功能”弹窗（WhatsNewSheetView），直观向用户展示 0.83.0 全新内核特性。

---

## Version 2.0.0-Alpha10 (English)

This release ports key stability enhancements and diagnostics from upstream (`MaddTheSane/Boxer`), suppressing intrusive macOS Accessibility prompts, resolving emulator state leaks on unrecoverable exceptions, introducing a local crash dump and diagnostics system, and improving multithreaded startup resilience.

### Key Changes
- **TCC Accessibility Spam Fix**: Replaced intrusive accessibility checks with a non-prompting status query. Key event capturing is enabled only when authorization has already been granted, falling back to system media key listening and eliminating repetitive macOS TCC permission dialogs on every launch.
- **Emulator State Leak Remediation**: In `_startDOSBox`, explicitly teardown SDL, the video renderer, and the global emulator configuration whenever an unrecoverable exception is caught before re-raising as an Objective-C exception, preventing configuration leaks and IO state corruption across sessions.
- **Local Crash Dump & Diagnostics System**: Retired defunct legacy bug report URLs and added an automated local diagnostic system that saves structured Markdown and plain text crash dumps to `~/Library/Application Support/Boxer/Crash Dumps/`. Selecting "Report" in error alerts reveals the crash dump directly in Finder.
- **Multithreaded Background Startup Protection**: Wrapped background emulator startup in structured exception handling, ensuring unrecoverable errors on background threads are cleanly surfaced to the main thread instead of terminating the application silently.
- **Gamebox Bundle Compatibility Fallback**: Added resource URL and path fallback handling in `BXGamebox` for packages lacking explicit bundle directory structures.

---

## 版本 2.0.0-Alpha10 (中文)

本版本合入了来自上游（`MaddTheSane/Boxer`）的核心稳定性改进与诊断增强，彻底杜绝了 macOS 辅助功能授权弹窗的频繁骚扰，修复了底层致命异常退出时的状态泄漏隐患，引入了本地 Crash Dump 诊断系统，并加强了多线程启动的异常容错。

### 主要更新
- **辅助功能弹窗防骚扰**：将系统权限检查调整为非侵入式检测，仅在已授权辅助功能时挂载按键监听，未授权时优雅降级为仅监听媒体键，彻底杜绝了每次打开应用反复弹出 macOS TCC 辅助功能授权请求的困扰。
- **模拟器底层状态泄漏清理**：在 `_startDOSBox` 捕获致命底层异常重抛为 Objective-C 异常前，显式释放 SDL、关闭视频渲染器并重置全局 Config 配置，彻底根除了跨语言异常绕过 C++ 栈展开析构导致的全局状态与 IO 句柄残留问题。
- **本地 Crash Dump 诊断系统**：彻底废弃失效的旧官网报错外链，崩溃时自动在 `~/Library/Application Support/Boxer/Crash Dumps/` 本地生成详尽的结构化 Markdown/文本诊断文件（包含 DOS 进程、驱动器挂载与完整调用栈），并在错误对话框点击“Report”时一键在 Finder 中定位。
- **多线程启动异常安全防护**：为多线程仿真启动流程包裹线程级异常捕获并安全调度回主线程展示，防止后台线程未恢复异常导致应用静默闪退。
- **游戏包资源路径容错兜底**：在 `BXGamebox` 中为缺少标准包层级结构的旧格式 Gamebox 增加了资源路径回退，增强旧游戏包的加载容错性。

---

## Version 2.0.0-Alpha9 (English)

This release resolves the audio freezing/stuttering bug during game pause, refines Simplified Chinese localization across the entire application, and removes legacy code and unused dependencies.

### Key Changes
- **Fix Audio Stutter on Pause**: Connected `BXEmulator` pause/resume cycle directly to `MIXER_Mute()` and `MIXER_Unmute()` in DOSBox-Staging's audio mixer. This cleanly mutes audio and empties the buffer upon pausing, eliminating the buzzing/stutter loop on the last audio sample.
- **Comprehensive UI Localization**: Fixed untranslated and machine-translated menu items and panels across all `.xcstrings` string catalogs, delivering native, polished macOS Simplified Chinese terminology.
- **Legacy Cleanup & Modernization**: Removed deprecated macOS 10.6/10.7 shims (`ADBForwardCompatibility`, `ADBAppKitVersionHelpers`), obsolete documentation files, and modernized AppKit / `UniformTypeIdentifiers` APIs for macOS 13+.

---

## 版本 2.0.0-Alpha9 (中文)

本版本彻底修复了游戏暂停时音频卡死在最后一声的循环杂音问题，完成了全软件界面的规范简体中文本地化精修，并清理了历史遗留兼容代码与冗余文件。

### 主要更新
- **修复暂停时音频卡死杂音**：将虚拟机的暂停/恢复生命周期接入 DOSBox-Staging 混音器的 `MIXER_Mute()` 与 `MIXER_Unmute()` 机制，在暂停时彻底静音并清空音频缓冲区，彻底根除了暂停时卡在最后一段声音持续循环（蜂鸣/卡死）的问题。
- **全界面精细汉化**：全面校对并修复了主菜单、检查器、启动面板、打印机对话框与状态栏中的所有中英文混杂与机翻残留，提供符合 macOS 规范的纯正简体中文体验。
- **清理遗留兼容层与冗余代码**：剔除了针对早期 OS X 10.6/10.7 的历史兼容补丁（如 `ADBForwardCompatibility`、`ADBAppKitVersionHelpers`）及第三方冗余文档，全面升级现代化 AppKit 与 `UniformTypeIdentifiers` API。

---

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
