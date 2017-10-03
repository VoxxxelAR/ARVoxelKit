//
//  BKVoxelConvenience.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 10/3/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

public enum BKVoxelState {
    case normal
    case highlighted(face: [BKVoxelFace], alpha: CGFloat)
    case hidden
    
    var id: Int {
        switch self {
        case .normal: return 0
        case .highlighted: return 1
        case .hidden: return 2
        }
    }
}

public enum BKVoxelFace: Int {
    case front = 0, right, back, left, top, bottom
    
    static var all: [BKVoxelFace] {
        return [front, right, back, left, top, bottom]
    }
    
    var normalizedVector3: SCNVector3 {
        switch self {
        case .front:
            return SCNVector3(0, 0, 1)
        case .right:
            return SCNVector3(1, 0, 0)
        case .back:
            return SCNVector3(0, 0, -1)
        case .left:
            return SCNVector3(-1, 0, 0)
        case .top:
            return SCNVector3(0, 1, 0)
        case .bottom:
            return SCNVector3(0, -1, 0)
        }
    }
    
    var normalizedSimd: simd_float3 {
        switch self {
        case .front:
            return simd_float3(0, 0, 1)
        case .right:
            return simd_float3(1, 0, 0)
        case .back:
            return simd_float3(0, 0, -1)
        case .left:
            return simd_float3(-1, 0, 0)
        case .top:
            return simd_float3(0, 1, 0)
        case .bottom:
            return simd_float3(0, -1, 0)
        }
    }
}
