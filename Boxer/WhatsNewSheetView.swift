//
//  WhatsNewSheetView.swift
//  Boxer
//
//  Created by Steve Shi on 2026-08-19.
//  Copyright © 2026 Boxer Team. All rights reserved.
//

import SwiftUI
import AppKit

public struct WhatsNewFeatureItem: Identifiable {
    public let id = UUID()
    public let systemImage: String
    public let color: Color
    public let titleKey: LocalizedStringKey
    public let subtitleKey: LocalizedStringKey
    
    public init(systemImage: String, color: Color, titleKey: LocalizedStringKey, subtitleKey: LocalizedStringKey) {
        self.systemImage = systemImage
        self.color = color
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
    }
}

public struct WhatsNewSheetView: View {
    public var onDismiss: (() -> Void)?
    
    private let features: [WhatsNewFeatureItem] = [
        WhatsNewFeatureItem(
            systemImage: "display.2",
            color: .blue,
            titleKey: LocalizedStringKey("Modern Metal Rendering Pipeline"),
            subtitleKey: LocalizedStringKey("Migrated to upstream OpenEmuShaders with pure Swift 6 Metal rendering and upgraded SPIRV compiler toolchains.")
        ),
        WhatsNewFeatureItem(
            systemImage: "pianokeys",
            color: .purple,
            titleKey: LocalizedStringKey("Upgraded MT32 MIDI Engine"),
            subtitleKey: LocalizedStringKey("Updated to Munt 2.8.2 for superior Roland MT-32 emulation accuracy and stability.")
        ),
        WhatsNewFeatureItem(
            systemImage: "gamecontroller.fill",
            color: .green,
            titleKey: LocalizedStringKey("Native Wireless Game Controllers"),
            subtitleKey: LocalizedStringKey("Seamless support for modern Xbox, PlayStation DualSense, and Nintendo Switch Pro controllers via Apple GameController framework.")
        )
    ]
    
    public init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                
                Text(LocalizedStringKey("What's New in Boxer"), tableName: "WhatsNew")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(features) { feature in
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: feature.systemImage)
                            .font(.system(size: 28))
                            .foregroundStyle(feature.color)
                            .frame(width: 36, height: 36)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(feature.titleKey, tableName: "WhatsNew")
                                .font(.headline)
                            
                            Text(feature.subtitleKey, tableName: "WhatsNew")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer(minLength: 16)
            
            Button {
                if let onDismiss = onDismiss {
                    onDismiss()
                } else if let window = NSApp.keyWindow {
                    if let parent = window.sheetParent {
                        parent.endSheet(window)
                    } else {
                        window.close()
                    }
                }
            } label: {
                Text(LocalizedStringKey("Continue"), tableName: "WhatsNew")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 480, height: 500)
    }
}

@objc(BXWhatsNewController)
@objcMembers
public final class BXWhatsNewController: NSObject {
    @MainActor
    public static func showWhatsNewSheet(presentingWindow: NSWindow? = nil) {
        let targetWindow = presentingWindow ?? NSApp.keyWindow ?? NSApp.mainWindow
        var windowRef: NSWindow?
        
        let view = WhatsNewSheetView {
            if let window = windowRef {
                if let parent = window.sheetParent {
                    parent.endSheet(window)
                } else {
                    window.close()
                }
            }
        }
        
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hostingController)
        windowRef = window
        window.styleMask = [.titled, .closable]
        window.title = String(localized: "What's New in Boxer", table: "WhatsNew")
        
        if let parent = targetWindow {
            parent.beginSheet(window, completionHandler: nil)
        } else {
            window.center()
            window.makeKeyAndOrderFront(nil)
        }
    }
}
