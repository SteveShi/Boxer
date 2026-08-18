//
//  BXShaderParamModels.swift
//  Boxer
//
//  Created by Steve Shi on 2026-08-19.
//  Copyright © 2026 Boxer Team. All rights reserved.
//

import Foundation

@objc(OEShaderParameter)
@objcMembers
public final class OEShaderParameter: NSObject {
    public var name: String
    public var desc: String
    public var group: String = ""
    public var initial: Float = 0.0
    public var minimum: Float = 0.0
    public var maximum: Float = 1.0
    public var step: Float = 0.01
    
    @objc public dynamic var value: Float = 0.0
    
    public init(name: String,
                desc: String,
                group: String = "",
                initial: Float = 0.0,
                minimum: Float = 0.0,
                maximum: Float = 1.0,
                step: Float = 0.01,
                value: Float = 0.0) {
        self.name = name
        self.desc = desc
        self.group = group
        self.initial = initial
        self.minimum = minimum
        self.maximum = maximum
        self.step = step
        self.value = value
        super.init()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? OEShaderParameter else { return false }
        return name == other.name &&
            desc == other.desc &&
            initial == other.initial &&
            minimum == other.minimum &&
            maximum == other.maximum &&
            step == other.step
    }
    
    public override var description: String {
        return "\(desc) (\(value))"
    }
}

@objc(OEShaderParamGroup)
@objcMembers
public final class OEShaderParamGroup: NSObject {
    public var name: String
    public var desc: String
    public var hidden: Bool
    public var parameters: [OEShaderParameter] = []
    
    public init(name: String, desc: String, hidden: Bool = false, parameters: [OEShaderParameter] = []) {
        self.name = name
        self.desc = desc
        self.hidden = hidden
        self.parameters = parameters
        super.init()
    }
}
