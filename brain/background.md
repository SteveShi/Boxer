---
slug: background
title: Project background
role: project background
updated: "2026-08-21T06:38:31"
---

# Project background

Boxer is a premium, modern DOS emulator for macOS designed to make playing classic DOS games a painless and beautiful experience.
Under the hood, Boxer features a major architectural modernization: it leverages DOSBox-Staging as its core emulation engine and has transitioned to exclusively support Apple Silicon (M-series) with pure Swift 6 concurrency safety.

## Goals
- Provide a native, elegant macOS gaming experience for classic DOS titles.
- Deliver peak Apple Silicon performance and ultra-low audio/video latency.
- Provide painless game importing with self-contained `.boxer` game packages.

## Non-Goals
- Supporting legacy x86_64 Intel prebuilt releases (users may compile from source if needed).
- Raw, unconfigured command-line DOSBox workflows for non-macOS platforms.
