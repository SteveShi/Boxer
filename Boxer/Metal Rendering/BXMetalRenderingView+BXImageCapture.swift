//
//  BXMetalRenderingView+BXImageCapture.swift
//  Boxer
//
//  Created by Steve Shi on 2026-08-19.
//  Copyright © 2026 Boxer Team. All rights reserved.
//

import AppKit
import Metal
import OpenEmuShaders

extension BXMetalRenderingView {
    @objc(bitmapImageRepForCachingDisplayInRect:)
    public override func bitmapImageRepForCachingDisplay(in rect: NSRect) -> NSBitmapImageRep? {
        guard let dev = self.device,
              let fc = self.filterChain,
              let tex = self.currentTexture
        else { return nil }
        
        let screenshot = Screenshot(device: dev)
        guard let cgImage = screenshot.applyFilterChain(fc, to: tex, flip: false) else {
            return nil
        }
        
        return NSBitmapImageRep(cgImage: cgImage)
    }
    
    @objc(cacheDisplayInRect:toBitmapImageRep:)
    public override func cacheDisplay(in rect: NSRect, to bitmapImageRep: NSBitmapImageRep) {
        // Do nothing, because the image is captured in bitmapImageRepForCachingDisplay
    }
}
