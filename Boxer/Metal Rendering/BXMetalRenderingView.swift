//
//  BXMetalRenderingView.swift
//  Boxer
//
//  Created by Steve Shi on 2026-08-19.
//  Copyright © 2026 Boxer Team. All rights reserved.
//

import Cocoa
import Metal
import MetalKit
import OpenEmuShaders
import QuartzCore
import os.log

private let MAX_INFLIGHT = 1

private let kStyleNormal = BXRenderingStyle(rawValue: 0) ?? BXRenderingStyle(rawValue: -1)!
private let kStyleSmoothed = BXRenderingStyle(rawValue: 1) ?? BXRenderingStyle(rawValue: -1)!
private let kStyleCRT = BXRenderingStyle(rawValue: 2) ?? BXRenderingStyle(rawValue: -1)!

@MainActor
@objc(BXMetalRenderingView)
@objcMembers
public final class BXMetalRenderingView: MTKView, @preconcurrency BXFrameRenderingView, CAAnimationDelegate {
    
    // MARK: - Properties
    
    private var _renderingStyle: BXRenderingStyle = kStyleNormal
    public var renderingStyle: BXRenderingStyle {
        get { _renderingStyle }
        set {
            guard newValue != _renderingStyle || filterChain?.hasShader == false else { return }
            willChangeValue(forKey: "renderingStyle")
            _renderingStyle = newValue
            switch newValue {
            case kStyleNormal:
                loadShader(resourceName: "Pixellate", subdirectory: "Shaders/Pixellate")
            case kStyleCRT:
                loadShader(resourceName: "CRT Geom", subdirectory: "Shaders/CRT Geom")
            case kStyleSmoothed:
                loadShader(resourceName: "Smooth", subdirectory: "Shaders/Smooth")
            default:
                loadShader(resourceName: "Pixellate", subdirectory: "Shaders/Pixellate")
            }
            didChangeValue(forKey: "renderingStyle")
        }
    }
    
    public var managesViewport: Bool = false {
        didSet {
            if oldValue != managesViewport {
                if let current = currentFrame {
                    setViewportRect(viewport(for: current), animated: false)
                }
            }
        }
    }
    
    public var maxViewportSize: NSSize = .zero
    
    private var _viewportRect: NSRect = .zero
    @objc public dynamic var viewportRect: NSRect {
        get { _viewportRect }
        set {
            if !NSEqualRects(_viewportRect, newValue) {
                _viewportRect = newValue
                needsDisplay = true
            }
        }
    }
    
    public private(set) var currentFrame: BXVideoFrame?
    public private(set) var maxFrameSize: NSSize = NSSize(width: 16384, height: 16384)
    public private(set) var parameterGroups: [OEShaderParamGroup] = []
    
    // Internal access for screenshot capture
    internal var filterChain: FilterChain?
    internal var currentTexture: MTLTexture?
    
    private var videoLayer: CAMetalLayer?
    private var inflightSemaphore = DispatchSemaphore(value: MAX_INFLIGHT)
    private var skippedFrames: Int = 0
    private var commandQueue: MTLCommandQueue?
    
    private var inViewportAnimation: Bool = false
    private var targetViewportRect: NSRect = .zero
    
    // MARK: - Initialization
    
    public override init(frame frameRect: NSRect, device: MTLDevice?) {
        let selectedDevice = device ?? MTLCreateSystemDefaultDevice()
        super.init(frame: frameRect, device: selectedDevice)
        initDefaults()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        if self.device == nil {
            self.device = MTLCreateSystemDefaultDevice()
        }
        initDefaults()
    }
    
    private func initDefaults() {
        inflightSemaphore = DispatchSemaphore(value: MAX_INFLIGHT)
        framebufferOnly = true
        presentsWithTransaction = false
        isPaused = false
        enableSetNeedsDisplay = true
        self.clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        wantsLayer = true
        videoLayer = self.layer as? CAMetalLayer
        
        if let dev = self.device {
            commandQueue = dev.makeCommandQueue()
            do {
                filterChain = try FilterChain(device: dev)
                filterChain?.setDefaultFilteringLinear(false)
                filterChain?.setSourceRect(CGRect(x: 0, y: 0, width: 648, height: 480),
                                           aspect: CGSize(width: 4, height: 3))
            } catch {
                os_log("Failed to initialize FilterChain: %{public}@", log: .default, type: .error, error.localizedDescription)
            }
        }
        
        renderingStyle = kStyleNormal
        updateRenderState()
    }
    
    // MARK: - BXFrameRenderingView Protocol
    
    public func supportsRenderingStyle(_ style: BXRenderingStyle) -> Bool {
        return true
    }
    
    private func loadShader(resourceName: String, subdirectory: String) {
        guard let filterChain = filterChain,
              let path = Bundle.main.url(forResource: resourceName, withExtension: "slangp", subdirectory: subdirectory)
        else { return }
        
        do {
            try filterChain.setShader(fromURL: path, options: ShaderCompilerOptions())
        } catch {
            os_log("Failed to load shader at '%{public}@': %{public}@", log: .default, type: .error, path.path, error.localizedDescription)
        }
    }
    
    public func update(with frame: BXVideoFrame?) {
        guard let frame = frame else {
            currentFrame = nil
            currentTexture = nil
            return
        }
        
        let sourceRect = CGRect(x: 0, y: 0, width: CGFloat(frame.size.width), height: CGFloat(frame.size.height))
        filterChain?.setSourceRect(sourceRect, aspect: frame.scaledSize)
        
        if frame !== currentFrame || currentTexture == nil {
            if viewportRect.isEmpty {
                let vp = viewport(for: frame)
                setViewportRect(vp, animated: false)
            }
            
            currentFrame = frame
            let td = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                              width: Int(frame.size.width),
                                                              height: Int(frame.size.height),
                                                              mipmapped: false)
            currentTexture = self.device?.makeTexture(descriptor: td)
        }
        
        currentTexture?.replace(region: MTLRegionMake2D(0, 0, Int(sourceRect.width), Int(sourceRect.height)),
                                mipmapLevel: 0,
                                withBytes: frame.bytes,
                                bytesPerRow: Int(frame.pitch))
        
        if managesViewport {
            setViewportRect(viewport(for: frame), animated: true)
        }
    }
    
    // MARK: - Drawing
    
    public override func draw(_ dirtyRect: NSRect) {
        guard let texture = currentTexture,
              let filterChain = filterChain,
              let commandQueue = commandQueue,
              let videoLayer = videoLayer
        else { return }
        
        autoreleasepool {
            if inflightSemaphore.wait(timeout: .now()) != .success {
                skippedFrames += 1
            } else {
                guard let offscreenCB = commandQueue.makeCommandBuffer() else {
                    inflightSemaphore.signal()
                    return
                }
                offscreenCB.label = "offscreen"
                offscreenCB.enqueue()
                filterChain.renderOffscreenPasses(sourceTexture: texture, commandBuffer: offscreenCB)
                offscreenCB.commit()
                
                if let drawable = videoLayer.nextDrawable() {
                    let rpd = MTLRenderPassDescriptor()
                    rpd.colorAttachments[0].clearColor = self.clearColor
                    rpd.colorAttachments[0].loadAction = .clear
                    rpd.colorAttachments[0].texture = drawable.texture
                    
                    guard let finalCB = commandQueue.makeCommandBuffer(),
                          let rce = finalCB.makeRenderCommandEncoder(descriptor: rpd)
                    else {
                        inflightSemaphore.signal()
                        return
                    }
                    
                    finalCB.label = "final"
                    filterChain.renderFinalPass(withCommandEncoder: rce, flipVertically: false)
                    rce.endEncoding()
                    
                    let sem = inflightSemaphore
                    finalCB.addCompletedHandler { _ in
                        sem.signal()
                    }
                    
                    finalCB.present(drawable)
                    finalCB.commit()
                } else {
                    inflightSemaphore.signal()
                }
            }
        }
    }
    
    // MARK: - Viewport & Layout
    
    private func updateRenderState() {
        guard let videoLayer = videoLayer else { return }
        videoLayer.bounds = self.bounds
        let backingSize = convertToBacking(self.bounds).size
        videoLayer.drawableSize = backingSize
        filterChain?.drawableSize = videoLayer.drawableSize
        
        if let current = currentFrame {
            setViewportRect(viewport(for: current), animated: false)
        }
    }
    
    public override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        if !inLiveResize {
            updateRenderState()
        }
    }
    
    public override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        updateRenderState()
    }
    
    public func windowDidChangeBackingProperties(_ notification: Notification?) {
        updateRenderState()
    }
    
    public func viewport(for frame: BXVideoFrame?) -> NSRect {
        guard let frame = frame, managesViewport else {
            return bounds
        }
        
        let frameSize = frame.scaledSize
        let frameRect = NSRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        let canvasRect = bounds
        var maxViewportRect = canvasRect
        
        if !NSEqualSizes(maxViewportSize, .zero) && sizeFitsWithinSize(maxViewportSize, canvasRect.size) {
            maxViewportRect = resizeRectFromPoint(canvasRect, maxViewportSize, NSPoint(x: 0.5, y: 0.5))
        }
        
        return fitInRect(frameRect, maxViewportRect, NSPoint(x: 0.5, y: 0.5))
    }
    
    public func setViewportRect(_ newRect: NSRect, animated: Bool) {
        guard !NSEqualRects(targetViewportRect, newRect) else { return }
        
        if !animated || viewportRect.isEmpty {
            targetViewportRect = newRect
            viewportRect = newRect
        } else {
            targetViewportRect = newRect
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                self.animator().viewportRect = targetViewportRect
            }
        }
    }
    
    // MARK: - Animation
    
    public override class func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        if key == "viewportRect" {
            let anim = CABasicAnimation()
            anim.duration = 0.2
            anim.timingFunction = CAMediaTimingFunction(name: .easeIn)
            return anim
        }
        return super.defaultAnimation(forKey: key)
    }
    
    nonisolated public func animationDidStart(_ anim: CAAnimation) {
        Task { @MainActor [weak self] in
            self?.inViewportAnimation = true
        }
    }
    
    nonisolated public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        anim.delegate = nil
        Task { @MainActor [weak self] in
            self?.inViewportAnimation = false
        }
    }
}
