# ![Boxer](http://boxerapp.com/static/images/gloves_96.png) Boxer

**Boxer** is a premium, modern DOS emulator for macOS, designed to make playing classic DOS games a painless and beautiful experience. 

Under the hood, Boxer features a major architectural modernization, leveraging the state-of-the-art **DOSBox-Staging** as its core emulation engine, and fully modernized to run natively on Apple Silicon (M1/M2/M3/M4) and Intel Macs with strict Swift 6 concurrency safety.

*Read this in other languages: [English](README.md) | [简体中文](README.zh-CN.md)*

---

## ✨ Key Features & Modern Architecture

- **⚡ Native Apple Silicon & Swift 6.0+**: Built natively for ARM64 and x86_64, fully compliant with modern macOS standards (Ventura, Sonoma, Sequoia, and macOS 15+).
- **🎨 Modern Metal Shader Rendering Pipeline**: Rebuilt on pure Swift 6 and MetalKit using upstream OpenEmuShaders with modern SPIR-V translation. Enjoy zero-latency CRT Geom, Smooth bicubic interpolation, and pixel-crisp rendering styles.
- **🎮 3D Pointer Locking & Input Subsystem**: Comprehensive relative mouse capture and absolute pointer coordination for complex 3D titles (e.g., *Ultima Underworld*, *System Shock*, *DOOM*, *Duke Nukem 3D*), alongside full keyboard layouts and numpad emulation.
- **🎼 Upgraded Roland MT-32 Audio Engine**: Integrated with Munt 2.8.2 for superior Roland MT-32 and CM-32L emulation accuracy, full Sound Blaster 16, Gravis UltraSound, and multi-channel SDL mixer output.
- **🕹️ Native Wireless Game Controllers**: Plug-and-play support for modern wireless controllers (Xbox Wireless, PlayStation 5 DualSense, Nintendo Switch Pro) powered by Apple's native GameController framework.
- **🌐 Modern String Catalogs (`.xcstrings`)**: 100% localized with Apple's modern String Catalogs standard, zero hardcoded user-facing strings, with comprehensive English and Simplified Chinese translations.
- **📦 Gamebox Library & Standalone App Bundling**:
  - **Boxer**: Premium gamebox library management and automated DOS installer.
  - **Boxer Standalone**: Lightweight wrapper for single-game execution.
  - **Boxer Bundler**: Graphical utility to convert gameboxes into standalone Mac applications.

---

## 🛠️ Build Requirements

To build the Boxer project locally, you will need:
*   **macOS 14.0 or higher** (Sonoma / Sequoia / macOS 15+)
*   **Xcode 16.0 or higher** (with Swift 6.0+ toolchain)
*   **XcodeGen** (to generate the `.xcodeproj` file)

All required dependencies and frameworks (DOSBox-Staging, OpenEmuShaders, Munt, DDHidLib) are bundled within the repository or integrated as Git submodules. No external package managers are needed.

---

## 🚀 Getting Started & Building

1.  **Clone the repository along with its submodules**:
    ```bash
    git clone https://github.com/SteveShi/Boxer.git
    cd Boxer
    git submodule update --init --recursive
    ```

2.  **Generate the Xcode Project using XcodeGen**:
    Boxer uses `project.yml` for declarative project specification. Generate the project by running:
    ```bash
    xcodegen
    ```
    This will generate `Boxer.xcodeproj` in the project root.

3.  **Build the Project**:
    - **Using Xcode GUI**: Open `Boxer.xcodeproj`, select the **Boxer** scheme, and press `Cmd + B` (or `Product > Build`).
    - **Using Command Line (`xcodebuild`)**:
        ```bash
        # 1. Build main Boxer emulator
        xcodebuild -scheme Boxer -configuration Release build

        # 2. Build Boxer Standalone
        xcodebuild -scheme "Boxer Standalone" -configuration Release build

        # 3. Build Boxer Bundler
        xcodebuild -scheme "Boxer Bundler" -configuration Release build
        ```

---

## 🎯 Build Targets

| Target | Description |
| :--- | :--- |
| **Boxer** | The full-featured DOS emulator application featuring the wooden shelf library, automated import wizard, inspector HUD, and shader switching. |
| **Boxer Standalone** | A streamlined, self-contained player tailored for single `.boxer` game packages. |
| **Boxer Bundler** | A Mac GUI packaging tool that bundles DOS games and Boxer Standalone into double-clickable, independent macOS apps. |

---

## 🔄 CI/CD Automation

The repository contains automated GitHub Actions workflows in [`.github/workflows/`](.github/workflows/):
- **Verification Workflow (`macos.yml`)**: Builds all three targets on every push and pull request to ensure strict compilation correctness on macOS Apple Silicon.
- **Release Workflow (`macos-release.yml`)**: Triggered when a semantic version tag is pushed (e.g. `v2.0.0-Alpha7`). Automatically builds and signs all three targets, packages them into individual `.zip` and `.dmg` binaries (6 release assets), dynamically extracts bilingual release notes from `CHANGELOG.md`, and creates a GitHub Release.

---

## 📄 License

This project is licensed under the [GNU General Public License v2.0 (GPLv2)](./LICENSE).
Originally created by Alun Bestor and contributors. Maintained and modernized by Steve Shi / 轩楝 and the community.
