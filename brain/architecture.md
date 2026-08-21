---
slug: architecture
title: System architecture
role: system architecture
updated: "2026-08-21T06:38:31"
---

# System architecture

```mermaid
graph TD
    App[Boxer macOS App] --> UI[AppKit & SwiftUI UI Surface]
    App --> GameBox[Gamebox Package Manager]
    UI --> Render[Metal / Display Rendering Surface]
    UI --> Audio[Audio Mixer Subsystem]
    App --> Core[DOSBox-Staging Emulation Core]
    Core --> CPU[ARM64 JIT / Dynamic Core]
    Core --> Mem[DOS Memory & Hardware Emulation]
    Core --> Audio
    Core --> Render
```

## Layers & Modules
- **UI & Presentation**: AppKit and SwiftUI hybrid frontend with modern macOS design.
- **Emulation Engine**: Embedded DOSBox-Staging core configured for Apple Silicon.
- **Media Pipelines**: Low-latency audio mixer and Metal-accelerated video scaling.
- **Gamebox Bundle**: Self-contained DOS game container management.
