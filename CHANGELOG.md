# Boxer Changelog / 更新日志

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
