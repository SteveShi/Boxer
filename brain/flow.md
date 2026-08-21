---
slug: flow
title: Key flows
role: key flows
updated: "2026-08-21T06:38:31"
---

# Key flows

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant App as Boxer App
    participant Box as Gamebox Manager
    participant Core as DOSBox-Staging Engine
    participant Audio as Audio Mixer
    participant Metal as Metal Renderer

    User->>App: Launch Game (.boxer or imported DOS app)
    App->>Box: Load game profile & mount virtual drives
    App->>Core: Initialize emulation core with machine config
    App->>Audio: Prepare low-latency mixer stream
    App->>Metal: Bind Metal surface view
    Core->>Audio: Stream synthesized audio (silenced on pause)
    Core->>Metal: Push 70Hz / 60Hz frame buffers
    User->>App: Pause / Resume / Exit
    App->>Core: Safe state freeze & audio drain
```
