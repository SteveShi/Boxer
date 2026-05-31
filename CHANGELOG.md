# Boxer Changelog / 更新日志

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
