# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Boxer is a premium DOS emulator for macOS that makes playing classic DOS games painless and beautiful. It uses DOSBox-Staging as its core emulation engine and is written in a mix of Objective-C, C++, and Swift 6.0 with strict concurrency safety. The project targets macOS 13.0+ and runs natively on both Apple Silicon and Intel Macs.

## Build System

The project uses **XcodeGen** to generate the Xcode project from `project.yml`. Never edit `Boxer.xcodeproj` directly—all project configuration changes must be made in `project.yml`.

### Essential Commands

```bash
# Generate Xcode project (required after cloning or modifying project.yml)
xcodegen generate

# Build all targets (Release configuration)
xcodebuild -scheme Boxer -configuration Release build
xcodebuild -scheme "Boxer Standalone" -configuration Release build
xcodebuild -scheme "Boxer Bundler" -configuration Release build

# Build for specific architecture
xcodebuild -scheme Boxer -configuration Release -destination 'platform=macOS,arch=arm64' build

# Open in Xcode
open Boxer.xcodeproj
```

### Submodules

The project includes git submodules that must be initialized:

```bash
git submodule update --init --recursive
```

Key submodules:
- `Vendor/DDHidLib` - HID device support for joysticks/controllers
- `Vendor/MT32Emu` - Roland MT-32 emulation
- `Vendor/OpenEmuShaders` - Shader rendering system
- `DOSBox-Staging` - Core DOS emulation engine

## Build Targets

1. **Boxer**: The main DOS emulator application with full UI, game library, installer wizard, and HUD controls
2. **Boxer Standalone**: Lightweight wrapper that packages a single gamebox into a self-contained macOS app
3. **Boxer Bundler**: Graphical utility for packaging DOS gameboxes into standalone apps using Boxer Standalone

## Architecture

### Core Components

- **DOSBox-Staging Integration** (`DOSBox-Staging/`): The emulation core. C++ codebase that handles CPU emulation, DOS filesystem, hardware emulation, and audio/video rendering.

- **Emulation Layer** (`Boxer/BXEmulator.*`, `Boxer/BXCoalface.*`): Objective-C++/C++ bridge between Boxer's Cocoa UI and DOSBox-Staging. `BXCoalface` is the primary interface to DOSBox internals.

- **Session Management** (`Boxer/BXSession.*`): Manages the lifecycle of a DOS gaming session, including drive mounting, audio controls, file management, and printing.

- **Application Delegate** (`Boxer/Application Delegate/`): Main app controller, games folder management, hot keys, and support files.

- **DOS Window** (`Boxer/DOS window/`): The main emulation window, input handling (keyboard/mouse/joystick), program panel, and status bar.

- **Metal Rendering** (`Boxer/Metal Rendering/`): Modern Metal-based video rendering with shader support via OpenEmuShaders.

- **Drive System** (`Boxer/BXDrive.*`, `Boxer/BXDriveImport.*`): Virtual drive management, CD/ISO image mounting, and drive importing.

- **Input System** (`Boxer/DOS window/BXInputController.*`, `Boxer/BXEmulatedJoystick.*`, `Boxer/BXEmulatedKeyboard.*`, `Boxer/BXEmulatedMouse.*`): Maps macOS input events to DOS-compatible input.

- **MIDI/Audio** (`Boxer/BXEmulatedMT32.*`, `Boxer/BXExternalMIDIDevice.*`, `Boxer/BXMIDIDeviceMonitor.*`): MT-32 emulation and external MIDI device support.

- **ADBToolkit** (`Other Sources/ADBToolkit/`): Shared utility library providing filesystem helpers, image processing, HID extensions, and UI utilities.

### Swift Components

Swift code uses Swift 6.0 with strict concurrency checking:
- `Boxer/BootlegCoverArt.swift` - Cover art generation
- `Boxer/CoverArt.swift` - Cover art rendering
- `Boxer/MT32LCDDisplay.swift` - MT-32 LCD display UI
- `Boxer/DummyMIDIDevice.swift` - MIDI device stub
- `Boxer/Shaders/BXShadersModel.swift` - Shader management

Swift-ObjC bridging headers:
- `Boxer/Boxer-Bridging-Header.h` (main Boxer)
- `Standalone/Boxer Standalone-Bridging-Header.h` (standalone)

### Memory Management

- Most Objective-C code uses ARC (Automatic Reference Counting)
- **Exceptions**: `BXEmulator.mm` and `BXImportSession.m` use manual memory management (`-fno-objc-arc`)
- DOSBox-Staging C++ code uses modern smart pointers (`std::shared_ptr`, `std::unique_ptr`)
- `RegexKitLite.m` uses manual memory management with spinlock optimization

## Swift Concurrency

The project is migrating to Swift 6 strict concurrency mode. When working with Swift code:
- Use `@MainActor` for UI-related classes and methods
- Ensure `Sendable` conformance for types crossing concurrency boundaries
- Use `async`/`await` for asynchronous operations
- Recent commits fixed Swift Concurrency compilation errors for Release builds

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- **`macos.yml`**: Runs on all pushes and PRs. Builds all three targets for Apple Silicon to verify build stability.
- **`macos-release.yml`**: Triggers on version tags (e.g., `v2.0.0-Alpha3`). Builds all targets, packages them into `.zip` and `.dmg` files, extracts localized release notes from `CHANGELOG.md`, and publishes a GitHub Release.

### Release Process

1. Update version in `project.yml` (search for `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`)
2. Update `CHANGELOG.md` with bilingual (English/Chinese) release notes
3. Commit changes
4. Tag the release: `git tag v2.0.0-AlphaX && git push origin v2.0.0-AlphaX`
5. CI automatically builds, packages, and publishes the release

## Code Style

- **Objective-C**: Use `BX` prefix for Boxer classes, `ADB` prefix for ADBToolkit classes
- **C++**: Follow DOSBox-Staging conventions for emulation core code
- **Swift**: Use Swift naming conventions; prefer value types and protocols
- **Comments**: Minimal comments; code should be self-documenting. Only comment non-obvious behavior, workarounds, or constraints.

## Common Development Patterns

### Adding a New Emulated Device

1. Create device class in `Boxer/` (e.g., `BXEmulatedDevice.mm`)
2. Implement DOSBox-Staging integration in `BXCoalface.mm`
3. Add UI controls in appropriate window controller
4. Update `BXEmulator` to manage device lifecycle

### Modifying DOSBox-Staging Integration

- Core integration code is in `Boxer/BXCoalface.*` and `Boxer/BXEmulator.*`
- DOSBox-Staging source is in `DOSBox-Staging/src/`
- Use `BXCoalface` as the interface layer; avoid direct DOSBox calls from UI code
- Memory management: DOSBox uses smart pointers; wrap them appropriately when exposing to Objective-C

### Working with Shaders

- Shaders are in `Resources/Shaders/`
- Shader system uses OpenEmuShaders framework (submodule)
- Swift model: `Boxer/Shaders/BXShadersModel.swift`
- Metal rendering: `Boxer/Metal Rendering/BXMetalRenderingView.m`

## Dependencies

### Frameworks (included in `Frameworks/`)
- SDL2.framework - Input and audio
- SDL2_net.framework - Networking

### Swift Packages
- Sparkle (2.9.1+) - Auto-update framework

### System Frameworks
- Cocoa, Carbon, CoreServices, IOKit
- AudioUnit, AudioToolbox, CoreMIDI
- Quartz, QuartzCore
- ScriptingBridge, DiskArbitration

## Localization

The project supports multiple languages (English, Chinese, Spanish, French, Portuguese, Czech):
- XIB files in `Resources/Base.lproj/`
- String catalogs in `Resources/mul.lproj/*.xcstrings`
- Legacy `.strings` files in language-specific `.lproj/` folders
- DOSBox strings in `Resources/*/DOSBox.strings` and `Resources/*/Shell.strings`

## Known Build Considerations

- **OpenEmuShaders CMake**: CI patches `Vendor/OpenEmuShaders/3rdparty/Makefile` to add `CMAKE_POLICY_VERSION_MINIMUM=3.5` for compatibility with newer CMake versions
- **Architecture**: Project supports both arm64 (Apple Silicon) and x86_64 (Intel)
- **Code Signing**: Development builds use manual signing with no identity (`CODE_SIGN_IDENTITY: "-"`)
- **Hardened Runtime**: Currently disabled (`ENABLE_HARDENED_RUNTIME: NO`)
- **PIE (Position Independent Executable)**: Disabled for x86_64, enabled for arm64

## Testing

The project currently has no unit tests in the main Boxer targets. OpenEmuShaders submodule contains its own tests.

When adding new features, manual testing is essential:
1. Build and run the app
2. Test the specific feature with actual DOS games
3. Verify no regressions in existing functionality
4. Test on both Apple Silicon and Intel if possible
