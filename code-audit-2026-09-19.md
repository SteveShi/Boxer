# Boxer 主应用代码审计报告

- **审计日期**：2026-09-19（HEAD `4ad0c387`，工作区干净，最近发版 v2.0.0-Beta2）
- **审计范围**：`Boxer/` 主应用 + `Other Sources/`（不含 DOSBox-Staging 子模块与 Vendor），约 5.1 万行 ObjC/C++/Swift
- **审计维度**：内存管理 / Swift 并发 / 错误处理与线程安全 / 架构与代码异味
- **方法**：四路并行深读源码，关键 HIGH 发现均经人工读码复核

---

## 一、严重问题（HIGH，建议立即修复）

### H1. `BXShadersModel.swift:92-100` — `allShaderNames` 必然崩溃 ✅已复核
缓存 getter 中 `if _allShaderNames == nil { }` 是**空实现**，缓存从未被赋值，随后 `return _allShaderNames!` 对必然为 nil 的 IUO 强制解包。该属性是 `@objc public`，ObjC 侧随时可调，一次调用即崩溃。静态方法 `loadShaders()`（193-212 行）同属死代码。
**修复**：getter 中用 `systemShaders + customShaders` 的名称填充缓存。

### H2. `BXExternalMIDIDevice.m:304-331` — Sysex 固定栈缓冲区可越界写入 ✅已复核
`dispatchSysex:` 声明 4096 字节栈缓冲后，把未校验的 `message.length` 直接传给 `MIDIPacketListAdd`。注释自认安全性完全依赖 DOSBox 侧的 sysex 截断行为；上游缓冲限制一旦变化，来自被模拟程序的超长 sysex 会直接造成栈溢出/内存损坏。
**修复**：入队前 `MIN(message.length, MAX_SYSEX_PACKET_SIZE - sizeof(MIDIPacketList))` 截断并告警。

### H3. `BXShadersModel.swift:49-56` — `nonisolated(unsafe)` 单例掩盖数据竞争
可变单例（`systemShaders`/`customShaders`/三个名称缓存 + 全量改写的 `reload()`）用 `nonisolated(unsafe)` 关闭编译器检查，经 `@objc` 暴露可从任意线程访问，却无任何锁保护。
**修复**：标注 `@MainActor` 或加锁，而非压制检查。

### H4. `BXMetalRenderingView.swift:25` — `@preconcurrency` 使 ObjC→MainActor 帧路径绕过隔离检查
渲染视图是 `@MainActor`，但经 `@preconcurrency BXFrameRenderingView` 协议接入，实际调用方是 DOSBox C++ 渲染回调经四层 ObjC 转发。一旦回调偏离主线程，编译器不会报错，直接产生 UI 数据竞争。
**修复**：移除 `@preconcurrency`，或在 ObjC 委托入口显式断言/调度到主线程。

---

## 二、中等问题（MEDIUM）

### 内存管理
| # | 位置 | 问题 |
|---|------|------|
| M1 | `BXSession.m:2518-2604` | 通知注册/注销**名称不匹配**：注册 `DidMiniaturize`/`DidResignActive`，注销的却是 `Will…` 版本，观察者永不注销；emulator 重建时累积重复注册 |
| M2 | `BXSession+BXFileManagement.m:1567-1582` | `_deregisterForFilesystemNotifications` 漏移除 defaultCenter 上的 `NSApplicationDidBecomeActiveNotification` |
| M3 | `BXCoalface.mm:400-421` | `CFBridgingRetain` 的目录枚举句柄依赖 DOSBox 侧必须调用 close，异常路径每次泄漏整个枚举器 |

### 线程与状态
| # | 位置 | 问题 |
|---|------|------|
| M4 | `BXEmulator.mm:315-327` + `BXSession.m:1882-1896` | 用**进程级 CWD** 充当每会话 baseURL（`changeCurrentDirectoryPath`），多会话互相干扰，且主线程改 CWD 与模拟线程文件操作无同步 |
| M5 | `BXSession.m:700-713, 2349-2363` | 会话关闭是「发即忘」异步取消，`_cleanup` 不等模拟线程退出就删临时目录，存在关闭竞态 |
| M6 | `BXEmulator.mm:418-580` + `BXVideoHandler.mm:155-200` | 主线程**无锁直改 DOSBox 模拟状态**（`CPU_CycleMax`、`cpudecoder` 等）；同文件 `reset` 已示范正确的线程跳转模式 |
| M7 | `BXEmulatedMT32.mm:345-352` | ROM 文件流 `open()` 返回值未检查，路径无效时解引用空指针崩溃，而非走报错路径 |
| M8 | `BXSession.m:2321-2345` | 配置解析/写回 `error: NULL`，失败静默，配置不生效无任何提示 |

### Swift 健壮性
| # | 位置 | 问题 |
|---|------|------|
| M9 | `BXShadersModel.swift:110, 249` | `self["Pixellate"]!` 兜底崩溃；`vals[1]` 对损坏 UserDefaults 字符串越界 |
| M10 | `MT32LCDDisplay.swift:19-98` | 初始化路径六连强解包（`NSImage(named:)!` 等）+ `as!`，资源改名即 nib 加载崩溃 |
| M11 | `CoverArt.swift:56,132-136` | 三连强解包/强转，IUO 返回值 |
| M12 | `NSImage+ADBImageEffects.swift:141-215` | 无焦点视图即崩溃（`focusView!`、`NSGraphicsContext.current!`） |
| M13 | `BXGameControllerMonitor.swift:13-16` | 进程启动期 `?? rawValue… !` 兜底，枚举缺失即启动崩溃 |
| M14 | `project.yml:35,741` | Swift 6 语言模式已生效，但 `nonisolated(unsafe)`/`@preconcurrency` 逃生舱未登记管控 |

### 架构
| # | 位置 | 问题 |
|---|------|------|
| M15 | `BXSession.m`（2667 行 / 102 方法） | **god-class**：文档生命周期 + 窗口管理 + 崩溃报告 + 640 行策略方法 + 暂停状态机混装 |
| M16 | `BXEmulatedPrinter.mm`（2547 行） | 内嵌完整 ESC/P 解释器，`_executeESCCommand:` 单方法约 580 行 |
| M17 | `BXSession+BXFileManagement.m`（2280 行） | 第二个 god-category：挂载一节约 880 行，混有影子驱动、通知监听、导入、截图等 4-5 种职责 |
| M18 | `BXCoalface.h` | 公开头 `#import "video.h"` 并 `#define` 重映射 GFX 宏，把 DOSBox 类型泄漏给所有引入者 |

---

## 三、分层违规（UI 侧干净，边界侧漏风）

UI 目录（`DOS window/`、`Application Delegate/`）**零 DOSBox 依赖**，`BXFileTypes` 收敛良好——纪律执行得好。问题集中在 3 个绕过 Coalface 的直连文件：

- **`BXEmulatedMouse.mm`（最严重）**：引入 DOSBox `private/` 内部头
- **`BXKeyBuffer.mm`**：直连 `bios.h`/`pic.h`
- **`BXVideoHandler.h/.mm`**：绕过 Coalface 直连 `video.h`/`render.h`

---

## 四、低危问题与技术债（摘要）

- **内存 LOW**：`BXEmulator.mm:247-280` 异常路径 `_currentEmulator` 泄漏（建议 `@try/@finally`）；`BXCoalface.mm` 跨语言返回 `cStringUsingEncoding:` 的隐式生命周期契约；`BXOutputBinding.m:246` repeating NSTimer 强持有 target，dealloc 清理不可达
- **线程/错误 LOW**：SDL_Init 失败仅打日志继续跑；对已退出线程 `performSelector:onThread:` 静默失效；MIDI 断连返回值忽略；挂载回滚失败无提示；gamebox 回滚残留半成品包
- **技术债总量**：151 处 TODO/FIXME/HACK（63 个文件），Top：FileManagement 19、DOSFileSystem 13、ImportSession 10。架构级：`BXGamebox.h:14` 承认 NSBlob 子类化根基问题；`DOSFileSystem.mm:1001` 有上游已移除 API 的调用残留
- **杂项**：约 93 处 NSLog（含 6 处遗留 BXDIAG 调试日志）；`WhatsNewSheetView` 同一按钮叠加两个 keyboardShortcut

---

## 五、已核实无问题的重点区域

- MRC 文件（BXEmulator.mm / BXImportSession.m）retain/release 配对规范；C++ 桥 unique_ptr/shared_ptr 单向所有权清晰，无双重释放
- RegexKitLite 为未修改上游代码，CFRelease 配对完整
- 跨线程通知统一经 `_postNotificationName:` 跳主线程；命令队列/进程表/joystick 有 `@synchronized` 保护
- 崩溃转储 + 用户告警 + 重启链路完善；CoverArt/BootlegCoverArt 的 Swift/ObjC 协议边界是健康示范

---

## 六、修复优先级建议

1. **立刻**：H1（一行修复）、H2（截断一行）、M1/M2（通知名对齐，各一行）
2. **短期**：H3/H4 并发逃生舱、M4（弃用进程 CWD）、M5（关闭时 join 模拟线程）、M6（setter 转发到模拟线程）、M7（ROM open 返回值）
3. **中期**：拆 BXSession 的崩溃报告与策略段、拆打印机解释器、收敛 `BXCoalface.h` 头文件暴露面、清理强解包
4. **长期**：BXGamebox NSFileWrapper 重构（对应既有 TODO）、清偿 151 处技术债

---

## 七、修复记录（2026-09-19，Debug 构建验证通过）

| 项 | 文件 | 修复内容 |
|---|---|---|
| H1 | `BXShadersModel.swift` | `allShaderNames` 补上缓存填充（system + custom 名称合并） |
| H3 | `BXShadersModel.swift` | 单例全部可变状态（shaders 数组、三个名称缓存、reload/subscript）纳入 `NSLock` 保护；`reload()` 在锁外发通知 |
| H2 | `BXExternalMIDIDevice.m` | `dispatchSysex:` 按缓冲容量钳制 `message.length`（扣除 packet list/packet 头部），超长时 NSLog 告警 |
| H4 | `BXSession.m` + `BXMetalRenderingView.swift` | 实测发现 `useMultithreadedEmulation` 开启时帧回调确实在后台线程直接驱动视图：`emulator:didFinishFrame:` 增加主线程跳转；Swift 侧 `@preconcurrency` 保留（去掉无法通过 Swift 6 编译）但注释写明运行时契约。顺手清除了该方法内遗留的 BXDIAG 调试日志 |
| M1 | `BXSession.m` | 注销名改为与注册一致的 `NSWindowDidMiniaturize` / `NSApplicationDidResignActive` |
| M2 | `BXSession+BXFileManagement.m` | 补上 `NSApplicationDidBecomeActiveNotification` 的 removeObserver |
| 存量 | `DOSBox-Staging/src/dos/cdrom_image.cpp` | 修复三处 `#ifdef DEBUG` 位腐烂（`std::chrono::microseconds` 限定名、`track_rate`→`track->file->getRate()`、`upc.c_str()`），使 Debug 构建在新 Xcode/SDK 27.0 下可用 |

`git diff --stat`：5 个主应用文件 +1 个子模块文件，+57/-20。`xcodebuild -scheme Boxer -configuration Debug build` → **BUILD SUCCEEDED**。

遗留（本次未修）：M4 进程级 CWD、M5 关闭竞态、M6 主线程直改 DOSBox 状态、M7 MT-32 ROM open 返回值、M9-M13 Swift 强解包群、M15-M18 架构拆分。

---

## 八、第二批修复记录（2026-09-19 晚，Debug 构建验证通过）

| 项 | 文件 | 修复内容 |
|---|---|---|
| M7 | `BXEmulatedMT32.mm` | ROM `open()` 返回值检查，失败填充 `BXEmulatedMT32InvalidROM` 错误并走 `[self close]` 清理；`close` 改为无论 ROMImage 是否存在都释放 handle（消除半初始化路径泄漏） |
| M9 | `BXShadersModel.swift` | `defaultShader` 兜底链 `Pixellate → 任意可用 shader → 占位模型`；`parameters(forIdentifier:)` 加 `guard vals.count == 2` 防损坏 UserDefaults 越界 |
| M10 | `MT32LCDDisplay.swift` | 模板资源/颜色全部改可选 + 默认值兜底；资源缺失时降级为纯色屏幕而非崩溃；`copy() as!` → `as?` |
| M11 | `CoverArt.swift` | `shine(for:)`/`representation(for:scale:)` 去强解包改 Optional 返回；`coverArt()` 用 compactMap 语义适配 |
| M12 | `NSImage+ADBImageEffects.swift` | `focusView!`/`NSGraphicsContext.current!`/`baseImage!`/两处 `makeImage()!` 全部 guard 提前返回；`copy() as!` → `as? ?? self` |
| M13 | `BXGameControllerMonitor.swift` | 枚举兜底改 `preconditionFailure` + 明确报错信息（枚举变更时清晰失败而非裸崩） |
| LOW | `BXMetalRenderingView.swift` | `BXRenderingStyle(rawValue: -1)!` 假兜底同改 |
| M5 | `BXSession.m` | `_cleanup` 删临时目录前对模拟线程做**有上限（5 秒）**的退出等待，收窄关闭竞态窗口且不阻塞 UI 死锁 |
| M6 | `BXEmulator.mm` + `BXVideoHandler.mm` | `setFixedSpeed:`/`setAutoSpeed:`/`setTurboSpeed:`/`setCoreMode:` 的 CPU 全局变量改动全部经 `performSelector:onThread:`（NSNumber 包装）转发到模拟线程；`BXVideoHandler` 三个 `_sync*` 同模式转发。单线程模式下行为不变 |

第二批 `git diff`：主应用 8 个文件。子模块修复已单独提交：`DOSBox-Staging @ 33ffc0e1d`（本地提交，未推送）。

仍未修（需要更大改动/独立方案）：M4 进程级 CWD、M15-M18 架构拆分（god-class 拆分、Coalface 头文件收敛、BXEmulatedMouse private 头直连）。

---

## 九、第三批修复记录（2026-09-19 晚，Debug 构建验证通过）

| 项 | 文件 | 修复内容 |
|---|---|---|
| M3 | `BXCoalface.mm/.h` + `BXEmulator.mm` | 枚举句柄注册表（NSMutableArray + @synchronized），close 时注销，新增 `boxer_closeAllLocalDirectories()` 在模拟器 teardown 的 `@finally` 中兜底释放未关闭句柄 |
| LOW-内存 | `BXEmulator.mm` | `start` 中 `_startDOSBox` 包 `@try/@finally`：异常展开路径不再泄漏 emulator 实例与 `_currentEmulator` 全局 |
| LOW-错误 | `BXEmulator.mm` | `SDL_Init` 失败从仅 NSLog 改为抛 `BXEmulatorUnrecoverableException`，走会话既有崩溃报告链路 |
| LOW-线程 | `BXEmulator.mm` + `BXVideoHandler.mm` | 所有 `performSelector:onThread:` 跳转点（cancel/pause/resume/4 个 _apply 转发/reset/3 个 _sync*）统一加 `isExecuting` 前置检查，避免对已退出线程静默失效 |
| M8 | `BXSession.m` | Preflight/profile 配置解析失败与 gamebox conf 写回失败均记录 `[Boxer]` 前缀日志，不再静默 |
| LOW-错误 | `BXMIDIDeviceMonitor.m` | `stopListening` 检查 `MIDIPortDisconnectSource` 返回值并记录 |
| LOW-错误 | `BXSession+BXFileManagement.m` | 挂载回滚失败记录日志且回滚失败时不再切驱动器盘符 |
| LOW-错误 | `BXGamebox.m` | 中间目录清理失败记录日志（防残缺 .gamebox 包静默残留） |
| 日志卫生 | 4 个文件 | 清除全部 5 处遗留 BXDIAG NSLog（Coalface/BXSession×2/DOSWindowController/BXShell） |

第三批 `git diff`：主应用 8 个文件。三批累计：主应用 15 个文件（两批间的 BXEmulator/BXSession 等有重叠）。

---

## 十、第四批修复记录：M4 会话基准路径（2026-09-19 深夜，Debug 构建验证通过）

**方案调研**（动手前核实了全部 CWD 消费面）：
- Boxer 侧：`baseURL` 读写即进程 CWD（`BXEmulator.mm`）；唯一读者是 `_driveFromDOSBoxDriveAtIndex:` 里解析相对盘符路径（DOSFileSystem.mm:1037）
- DOSBox 侧：`init_config_dir()` 用可执行路径/用户配置目录，不依赖 CWD；MOUNT 相对路径按「最后一个 conf 所在目录」解析（`-pr`）；`autoexec.cpp:352` 只影响 `CONFIG` 命令行参数（Boxer 不用）；运行时 MOUNT/IMGMOUNT 全部经 Boxer 委托流拦截
- 结论：进程 CWD 是历史遗产，可安全改为每模拟器实例存储

**修复内容**：
| 文件 | 改动 |
|---|---|
| `BXEmulator.mm` | `baseURL` 改为 ivar `_sessionBaseURL` 存储；setter 不再调 `changeCurrentDirectoryPath`；getter 首次访问时惰性捕获启动时 CWD 作为默认值（单会话行为与旧版完全一致） |
| `BXEmulator.h` | 更新属性文档：不再改变进程工作目录，多会话/多线程互不干扰 |
| `BXEmulator+BXDOSFileSystem.mm` | 新增 `_absoluteHostPathForDrivePath:`，两个 `_DOSBoxDriveFromPath` 变体在 `new localDrive` 前把相对路径解析到会话 baseURL——保证 DOSBox localDrive 存储的 basedir 恒为绝对路径，运行时文件操作彻底不依赖 CWD |

**效果**：主线程改 CWD 与模拟线程文件操作的竞态消除；理论上同时开第二个会话不再互相踩路径。**需要实机回归验证**：正常启动游戏、盘符切换、DOS 内手动 MOUNT、影子驱动写入是否正常。

---

## 十一、实机验证与新增修复（2026-09-19 深夜）

- Debug 版实机启动：Underworld Demo 会话正常（标题画面渲染、音频控制就位）
- **用户实测发现新崩溃**：X-COM Demo.boxer 启动即 SIGABRT。崩溃栈定位到 `BXEmulator+BXShell.mm` `_willExecuteFileAtDOSPath:` 的存量越界 UB：`char driveIndex = dosPath[0] - 'A'`——`char` 在 arm64 上有符号，路径首字节非大写 A-Z 时索引越界；旧工具链下侥幸运行，本 Debug 构建的 libc++ 加固模式直接 abort
- **修复**：索引做范围校验 + `toupper`，无效路径按「无驱动器」处理（nil drive 对下游 `_filesystemURLForDOSPath:` 安全，且不影响 `_didExecuteFileAtDOSPath:` 的配对语义）
- 重建后 X-COM Demo 正常进入 MicroProse 片头，实机验证通过
- 附带发现：Debug 构建的 libc++ 加固会系统性暴露此类裸数组索引 UB，`Drives[]`/`dosPath[0]` 同类写法值得后续专项排查（本次已核查全部 `driveIndex` 计算点，其余均经 `_indexOfDriveLetter:`（有断言）或 `DOS_MakeName` 成功校验后访问）
