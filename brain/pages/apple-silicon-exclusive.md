---
id: apple-silicon-exclusive
title: Exclusively support Apple Silicon architecture
category: decision
status: active
created: "2026-08-21T06:38:31"
updated: "2026-08-21T06:38:31"
---

<!-- compiled_truth -->
Boxer exclusively targets Apple Silicon (M1/M2/M3/M4/M-series) Macs for official prebuilt releases. This eliminates universal binary bloat and allows full optimization for ARM64 NEON/JIT and Swift 6 concurrency.


## Timeline

- time: 2026-08-21T06:38:31
  kind: decision
  summary: "Created this page: Exclusively support Apple Silicon architecture"
  source: git log
  affects: [apple-silicon-exclusive]

- time: 2026-08-21T06:38:31
  kind: decision
  summary: Decided to drop official x86_64 binary releases in favor of pure Apple Silicon optimization.
  source: git log
  affects: [apple-silicon-exclusive]
