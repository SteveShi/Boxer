//
//  BXGameControllerMonitor.swift
//  Boxer
//
//  Created by Steve Shi on 2026-08-19.
//  Copyright © 2026 Boxer Team. All rights reserved.
//

import Cocoa
import GameController
import os.log

private let kJoystickButton1 = BXEmulatedJoystickButton(rawValue: 1) ?? BXEmulatedJoystickButton(rawValue: 0)!
private let kJoystickButton2 = BXEmulatedJoystickButton(rawValue: 2) ?? BXEmulatedJoystickButton(rawValue: 0)!
private let kJoystickButton3 = BXEmulatedJoystickButton(rawValue: 3) ?? BXEmulatedJoystickButton(rawValue: 0)!
private let kJoystickButton4 = BXEmulatedJoystickButton(rawValue: 4) ?? BXEmulatedJoystickButton(rawValue: 0)!

@MainActor
@objc(BXGameControllerMonitor)
@objcMembers
public final class BXGameControllerMonitor: NSObject {
    
    public static let shared = BXGameControllerMonitor()
    
    public private(set) var connectedControllers: [GCController] = []
    
    public var hasConnectedControllers: Bool {
        return !connectedControllers.isEmpty
    }
    
    private override init() {
        super.init()
        setupMonitoring()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidConnect(_:)),
            name: .GCControllerDidConnect,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidDisconnect(_:)),
            name: .GCControllerDidDisconnect,
            object: nil
        )
        
        GCController.startWirelessControllerDiscovery {
            os_log("Wireless controller discovery stopped", log: .default, type: .debug)
        }
        
        updateConnectedControllers()
    }
    
    @objc private func controllerDidConnect(_ notification: Notification) {
        if let controller = notification.object as? GCController {
            os_log("GameController connected: %{public}@", log: .default, type: .info, controller.vendorName ?? "Unknown")
            configureController(controller)
        }
        updateConnectedControllers()
    }
    
    @objc private func controllerDidDisconnect(_ notification: Notification) {
        if let controller = notification.object as? GCController {
            os_log("GameController disconnected: %{public}@", log: .default, type: .info, controller.vendorName ?? "Unknown")
        }
        updateConnectedControllers()
    }
    
    private func updateConnectedControllers() {
        connectedControllers = GCController.controllers()
        for controller in connectedControllers {
            configureController(controller)
        }
    }
    
    private func configureController(_ controller: GCController) {
        if let gamepad = controller.extendedGamepad {
            gamepad.valueChangedHandler = { [weak self] (gamepad, element) in
                DispatchQueue.main.async {
                    self?.handleGamepadInput(gamepad: gamepad, element: element)
                }
            }
        } else if let microGamepad = controller.microGamepad {
            microGamepad.valueChangedHandler = { [weak self] (gamepad, element) in
                DispatchQueue.main.async {
                    self?.handleMicroGamepadInput(gamepad: gamepad, element: element)
                }
            }
        }
    }
    
    // MARK: - Input Dispatching
    
    private func activeEmulatedJoystick() -> (any BXEmulatedJoystick)? {
        guard let appDelegate = NSApp.delegate as? BXBaseAppController,
              let keyWindow = NSApp.keyWindow,
              let activeSession = appDelegate.document(for: keyWindow) as? BXSession
        else { return nil }
        
        return activeSession.emulator?.joystick
    }
    
    private func setButton(_ button: BXEmulatedJoystickButton, pressed: Bool, on joystick: any BXEmulatedJoystick) {
        if pressed {
            joystick.buttonDown(button)
        } else {
            joystick.buttonUp(button)
        }
    }
    
    private func handleGamepadInput(gamepad: GCExtendedGamepad, element: GCControllerElement) {
        guard let joystick = activeEmulatedJoystick() else { return }
        
        // Left Thumbstick -> Axis X & Axis Y
        if element === gamepad.leftThumbstick {
            joystick.setPosition(gamepad.leftThumbstick.xAxis.value, forAxis: BXAxisX)
            // Note: GameController Y is up-positive, gameport standard Y is down-positive (inverted)
            joystick.setPosition(-gamepad.leftThumbstick.yAxis.value, forAxis: BXAxisY)
        }
        
        // Right Thumbstick -> Axis X2 & Axis Y2
        if element === gamepad.rightThumbstick {
            joystick.setPosition(gamepad.rightThumbstick.xAxis.value, forAxis: BXAxisX2)
            joystick.setPosition(-gamepad.rightThumbstick.yAxis.value, forAxis: BXAxisY2)
        }
        
        // D-Pad
        if element === gamepad.dpad {
            if let flightstick = joystick as? (any BXEmulatedFlightstick) {
                var direction: BXEmulatedPOVDirection = []
                if gamepad.dpad.up.isPressed { direction.insert(.north) }
                if gamepad.dpad.down.isPressed { direction.insert(.south) }
                if gamepad.dpad.left.isPressed { direction.insert(.west) }
                if gamepad.dpad.right.isPressed { direction.insert(.east) }
                
                flightstick.pov(0, changedTo: direction)
            } else if gamepad.leftThumbstick.xAxis.value == 0 && gamepad.leftThumbstick.yAxis.value == 0 {
                // Fallback D-Pad to primary axis if left thumbstick is idle
                joystick.setPosition(gamepad.dpad.xAxis.value, forAxis: BXAxisX)
                joystick.setPosition(-gamepad.dpad.yAxis.value, forAxis: BXAxisY)
            }
        }
        
        // Buttons
        if element === gamepad.buttonA {
            setButton(kJoystickButton1, pressed: gamepad.buttonA.isPressed, on: joystick)
        }
        if element === gamepad.buttonB {
            setButton(kJoystickButton2, pressed: gamepad.buttonB.isPressed, on: joystick)
        }
        if element === gamepad.buttonX {
            setButton(kJoystickButton3, pressed: gamepad.buttonX.isPressed, on: joystick)
        }
        if element === gamepad.buttonY {
            setButton(kJoystickButton4, pressed: gamepad.buttonY.isPressed, on: joystick)
        }
        
        // Triggers / Bumpers
        if element === gamepad.leftShoulder {
            if gamepad.leftShoulder.isPressed {
                setButton(kJoystickButton3, pressed: true, on: joystick)
            } else if !gamepad.buttonX.isPressed {
                setButton(kJoystickButton3, pressed: false, on: joystick)
            }
        }
        if element === gamepad.rightShoulder {
            if gamepad.rightShoulder.isPressed {
                setButton(kJoystickButton4, pressed: true, on: joystick)
            } else if !gamepad.buttonY.isPressed {
                setButton(kJoystickButton4, pressed: false, on: joystick)
            }
        }
    }
    
    private func handleMicroGamepadInput(gamepad: GCMicroGamepad, element: GCControllerElement) {
        guard let joystick = activeEmulatedJoystick() else { return }
        
        if element === gamepad.dpad {
            joystick.setPosition(gamepad.dpad.xAxis.value, forAxis: BXAxisX)
            joystick.setPosition(-gamepad.dpad.yAxis.value, forAxis: BXAxisY)
        }
        if element === gamepad.buttonA {
            setButton(kJoystickButton1, pressed: gamepad.buttonA.isPressed, on: joystick)
        }
        if element === gamepad.buttonX {
            setButton(kJoystickButton2, pressed: gamepad.buttonX.isPressed, on: joystick)
        }
    }
}
