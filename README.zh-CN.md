# ![Boxer](http://boxerapp.com/static/images/gloves_96.png) Boxer

**Boxer** 是一款专为 macOS 设计的高端、现代 DOS 模拟器，旨在为游玩经典 DOS 游戏提供最完美、优雅且无痛的体验。

在底层，本版 Boxer 进行了重大的现代化架构重构，采用当今最活跃、最先进的 **DOSBox-Staging** 作为其模拟核心，并针对 Apple Silicon (M1/M2/M3/M4) 以及 Intel 芯片的 Mac 进行了完全的 Swift 6 严格并发安全性重写，提供纯原生运行效率。

*其他语言版本：[English](README.md) | [简体中文](README.zh-CN.md)*

---

## ✨ 核心特性与现代化架构

- **⚡ 原生 Apple Silicon 与 Swift 6.0+**：原生针对 ARM64 与 x86_64 双架构深度优化，完美兼容最新 macOS 系统（Ventura、Sonoma、Sequoia 及 macOS 15+）。
- **🎨 现代 Metal 着色器渲染管线**：基于纯 Swift 6 与 MetalKit 重构着色器引擎，搭载上游 OpenEmuShaders 与现代 SPIR-V 编译工具链，带来零延迟的 CRT Geom 显像管曲面、Smooth 双三次平滑滤镜与经典像素风格。
- **🎮 3D 鼠标指针捕获与完整输入子系统**：针对《创世纪地下世界》(Ultima Underworld)、《网络奇兵》(System Shock)、《毁灭战士》(DOOM)、《毁灭公爵 3D》(Duke Nukem 3D) 等复杂 3D 游戏提供精准的相对鼠标指针锁定与绝对坐标映射，同时支持完整 DOS 键盘布局与小键盘仿真。
- **🎼 升级版 Roland MT-32 音频引擎**：内置升级至 Munt 2.8.2 内核，大幅提升 Roland MT-32 与 CM-32L 仿真精度与音质表现，配合 Sound Blaster 16、Gravis UltraSound 以及多通道 SDL 混音器。
- **🕹️ 原生现代无线游戏手柄**：基于 Apple 原生 GameController 框架，即插即用支持 Xbox 无线手柄、PlayStation 5 DualSense 以及 Nintendo Switch Pro 手柄。
- **🌐 全新 String Catalogs (`.xcstrings`) 本地化规范**：UI 界面与底层字符串 100% 遵循 Apple 最新 String Catalogs 国际化标准，零硬编码文本，提供完整的高质量简体中文与英文支持。
- **📦 游戏库管理与独立 App 一键打包**：
  - **Boxer**：经典的木制书架游戏库管理、智能安装引导与全新 HUD 状态监控面板。
  - **Boxer Standalone**：轻量级封装内核，专为单个 `.boxer` 游戏包提供独立运行环境。
  - **Boxer Bundler**：图形化打包工具，将 DOS 游戏包快速制作为免安装、双击即玩的独立 macOS App。

---

## 🛠️ 构建要求

在本地编译 Boxer 项目需要满足以下环境：
*   **macOS 14.0 或更高版本** (Sonoma / Sequoia / macOS 15+)
*   **Xcode 16.0 或更高版本** (包含 Swift 6.0+ 工具链)
*   **XcodeGen** (用于声明式生成 `.xcodeproj` 项目文件)

所有必要的依赖项（DOSBox-Staging、OpenEmuShaders、Munt、DDHidLib 等）均已内置在仓库中或通过 Git Submodule 链接，无需配置任何第三方包管理器。

---

## 🚀 获取代码与编译步骤

1.  **克隆仓库及子模块**：
    ```bash
    git clone https://github.com/SteveShi/Boxer.git
    cd Boxer
    git submodule update --init --recursive
    ```

2.  **通过 XcodeGen 生成 Xcode 项目**：
    Boxer 采用 `project.yml` 声明式管理工程结构。运行以下命令生成：
    ```bash
    xcodegen
    ```
    这将在项目根目录下生成 `Boxer.xcodeproj` 文件。

3.  **编译项目**：
    - **通过 Xcode 界面编译**：双击打开 `Boxer.xcodeproj`，选择 **Boxer** 方案并按 `Cmd + B`（或菜单栏 `Product > Build`）。
    - **通过命令行编译 (`xcodebuild`)**：
        ```bash
        # 1. 编译主 Boxer 模拟器 App
        xcodebuild -scheme Boxer -configuration Release build

        # 2. 编译 Boxer Standalone
        xcodebuild -scheme "Boxer Standalone" -configuration Release build

        # 3. 编译 Boxer Bundler
        xcodebuild -scheme "Boxer Bundler" -configuration Release build
        ```

---

## 🎯 构建目标 (Targets)

| 目标名称 | 说明 |
| :--- | :--- |
| **Boxer** | 功能完整的 DOS 模拟器主程序，拥有精美书架游戏库、智能导入向导、检查器面板与着色器切换功能。 |
| **Boxer Standalone** | 轻量化独立播放器，专用于运行单个 `.boxer` 格式游戏包。 |
| **Boxer Bundler** | 图形化打包工具，将 DOS 游戏包与 Boxer Standalone 合并生成独立的 macOS 应用程序。 |

---

## 🔄 CI/CD 自动化

项目在 [`.github/workflows/`](.github/workflows/) 中配置了完善的 GitHub Actions 自动化流水线：
- **编译验证流水线 (`macos.yml`)**：在每次分支 Push 或 Pull Request 时触发，自动完成 Apple Silicon 下全部 3 个 Target 的编译构建，确保代码变更的稳定性。
- **版本发布流水线 (`macos-release.yml`)**：在推送版本 Tag（如 `v2.0.0-Alpha7`）时自动触发，编译并签名 3 个 App，分别打包为 `.zip` 与 `.dmg` 文件（共 6 个发布资产），智能解析 `CHANGELOG.md` 中对应的中英文更新日志并发布至 GitHub Release。

---

## 📄 开源协议

本项目采用 [GNU General Public License v2.0 (GPLv2)](./LICENSE) 开源协议。
原作者为 Alun Bestor 及贡献者，现由 Steve Shi / 轩楝 及开源社区现代化维护。
