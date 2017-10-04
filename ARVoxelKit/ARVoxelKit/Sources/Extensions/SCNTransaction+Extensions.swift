//
//  SCNTransaction+Extensions.swift
//  ARVoxelKit
//
//  Created by Gleb on 9/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

enum SCNTransactionTimingFunction {
    case linear, easeIn, easeOut, easeInOut, `default`
    
    var value: String {
        switch self {
        case .linear:
            return kCAMediaTimingFunctionLinear
        case .easeIn:
            return kCAMediaTimingFunctionEaseIn
        case .easeOut:
            return kCAMediaTimingFunctionEaseOut
        case .easeInOut:
            return kCAMediaTimingFunctionEaseInEaseOut
        case .default:
            return kCAMediaTimingFunctionDefault
        }
    }
}

extension SCNTransaction {
    static func animate(with duration: TimeInterval,
                        timingFunction: SCNTransactionTimingFunction = .default,
                        _ animation: @escaping () -> Void,
                        _ completion: (() -> Void)? = nil) {
        
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: timingFunction.value)
        SCNTransaction.animationDuration = duration
        
        animation()
        
        SCNTransaction.completionBlock = completion
        
        SCNTransaction.commit()
    }
}
