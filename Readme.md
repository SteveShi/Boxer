# ![Boxer](http://boxerapp.com/static/images/gloves_96.png) Boxer

**Boxer** is a premium, modern DOS emulator for macOS, designed to make playing classic DOS games a painless and beautiful experience. 

Under the hood, Boxer features a major architectural modernization, leveraging the highly active and state-of-the-art **DOSBox-Staging** as its core emulation engine, and fully rewritten to run natively on Apple Silicon (M1/M2/M3/M4) and Intel Macs with strict Swift 6 concurrency safety.

*Read this in other languages: [English](#english), [简体中文](#简体中文)*

---

## English

### Build Requirements
To build the Boxer project, you will need:
*   **macOS 13.0 or higher** (Ventura / Sonoma / Sequoia)
*   **Xcode 15.0 or higher** (with Swift 6.0+ support)
*   **XcodeGen** (to generate the `.xcodeproj` file)

All necessary frameworks and other dependencies are included in the Boxer repo or integrated as git submodules, so you don't need any external build systems other than XcodeGen.

### Getting Started & Building

1.  **Clone the repository along with its submodules**:
    ```bash
    git clone https://github.com/SteveShi/Boxer.git
    cd Boxer
    git submodule update --init --recursive
    ```

2.  **Generate the Xcode Project using XcodeGen**:
    The Xcode project is generated programmatically from `project.yml` using `xcodegen`. Run:
    ```bash
    xcodegen
    ```
    This will create `Boxer.xcodeproj` in the root directory.

3.  **Build the Project**:
    *   **Via Xcode**: Open `Boxer.xcodeproj` and build the **Boxer** scheme using `Product > Build` (or `Cmd + B`).
    *   **Via Command Line (Release)**:
        ```bash
        # Build main Boxer emulator
        xcodebuild -scheme Boxer -configuration Release build

        # Build Boxer Standalone
        xcodebuild -scheme "Boxer Standalone" -configuration Release build

        # Build Boxer Bundler
        xcodebuild -scheme "Boxer Bundler" -configuration Release build
        ```

### Build Targets

*   **Boxer**: The premium DOS emulator app featuring a gorgeous gamebox library interface, automated game installer, and full HUD controls.
*   **Boxer Standalone**: A lightweight standalone wrapper that packages a single gamebox into a self-contained macOS app.
*   **Boxer Bundler**: A graphical utility that uses Boxer Standalone to package your DOS gameboxes into stand-alone apps.

### CI/CD Automation
The project includes a robust GitHub Actions CI/CD pipeline (`.github/workflows`):
*   **macOS Verification Workflow (`macos.yml`)**: Automatically triggers on all pushes and pull requests to build all three targets (**Boxer**, **Boxer Standalone**, and **Boxer Bundler**) for Apple Silicon to guarantee build stability.
*   **macOS Release Workflow (`macos-release.yml`)**: Automatically triggers when you push a version tag (e.g. `v2.0.0-Alpha3`). It compiles all three targets for Apple Silicon, packages them into individual `.zip` and `.dmg` files (6 assets in total), dynamically extracts localized Chinese and English release notes from `CHANGELOG.md` matching the tag version, and publishes a new GitHub Release with the correct notes and binaries.

### License
This project is licensed under the [GPLv2](./LICENSE). Originally developed by Alun Bestor and modernized by Steve Shi and other contributors.

---

## 简体中文

**Boxer** 是一款专为 macOS 设计的高端、现代 DOS 模拟器，旨在为游玩经典 DOS 游戏提供最完美、优雅且无痛的体验。

在底层，本版 Boxer 进行了重大的现代化架构重构，采用当今最活跃、最先进的 **DOSBox-Staging** 作为其模拟核心，并针对 Apple Silicon (M1/M2/M3/M4) 以及 Intel 芯片的 Mac 进行了完全的 Swift 6 严格并发安全性重写，提供纯原生运行效率。

### 构建要求
构建 Boxer 项目需要：
*   **macOS 13.0 或更高版本** (Ventura / Sonoma / Sequoia)
*   **Xcode 15.0 或更高版本** (支持 Swift 6.0+)
*   **XcodeGen** (用于生成 `.xcodeproj` 工程文件)

所有必要的 Framework 和依赖项均已内置于 Boxer 仓库中，或通过 Git Submodule 进行关联，除了 XcodeGen 之外无需任何额外的外部依赖包管理工具。

### 获取代码与编译步骤

1.  **克隆仓库及子模块**：
    ```bash
    git clone https://github.com/SteveShi/Boxer.git
    cd Boxer
    git submodule update --init --recursive
    ```

2.  **通过 XcodeGen 生成 Xcode 工程**：
    Boxer 现在采用 `project.yml` 对项目文件进行声明式管理，Xcode 工程文件本身已被忽略。运行以下命令生成：
    ```bash
    xcodegen
    ```
    这将在当前目录下生成 `Boxer.xcodeproj` 文件。

3.  **编译项目**：
    *   **使用 Xcode 打开**：双击打开 `Boxer.xcodeproj`，选择 **Boxer** 方案并按 `Cmd + B` 进行编译。
    *   **通过命令行编译 (Release 模式)**：
        ```bash
        # 编译主 Boxer 模拟器 App
        xcodebuild -scheme Boxer -configuration Release build

        # 编译 Boxer Standalone
        xcodebuild -scheme "Boxer Standalone" -configuration Release build

        # 编译 Boxer Bundler
        xcodebuild -scheme "Boxer Bundler" -configuration Release build
        ```

### 构建目标 (Targets)

*   **Boxer**：标准版本的 Boxer 模拟器，包含精美的游戏库管理界面、智能游戏导入向导和全套控制面板。
*   **Boxer Standalone**：轻量级封装版本，用于将单个 DOS 游戏包（gamebox）打包为独立的 macOS App。
*   **Boxer Bundler**：图形化打包工具，利用 Boxer Standalone 快速将您的 DOS 游戏包制作成免安装、双击即玩的 Mac 应用程序。

### CI/CD 自动化
项目内置了强大的 GitHub Actions 自动化构建与发布流程（位于 `.github/workflows`）：
*   **macOS 编译验证流 (`macos.yml`)**：在任何分支收到 push 或 pull request 时自动触发，同时编译 **Boxer**、**Boxer Standalone** 和 **Boxer Bundler** 三个 App (针对 Apple Silicon)，确保代码合并与演进过程中的编译稳定性。
*   **macOS 版本发布流 (`macos-release.yml`)**：当您推送版本 Tag（例如 `v2.0.0-Alpha3`）时自动触发。它会一键完成这三个 App 的编译，并将每个 App 分别打包成独立的 `.zip` 和 `.dmg` 文件（共 6 个发布产物）。同时，CI 会采用 Python 脚本智能、动态地解析并提取 `CHANGELOG.md` 中与当前版本完全匹配的中英文双语更新日志，完美排版并发布到 GitHub Release。

### 开源协议
本软件采用 [GPLv2 开源协议](./LICENSE)。最初由 Alun Bestor 等开发者开发，现由 Steve Shi 及其他贡献者完成现代化迁移与维护。
