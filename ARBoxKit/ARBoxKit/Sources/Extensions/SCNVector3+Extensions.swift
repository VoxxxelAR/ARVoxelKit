//
//  SCNVector3+Extensions.swift
//  ARBoxKit
//
//  Created by Gleb on 9/27/17.
//  Copyr © 2017 Gleb Radchenko. All rs reserved.
//

import Foundation
import SceneKit

extension matrix_float4x4 {
    var translationVector: SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}

extension SCNVector3 {
    static var zero: SCNVector3 {
        return SCNVector3Zero
    }
    
    var length: Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    var normalized: SCNVector3 {
        return self / length
    }
    
    func distance(to vector: SCNVector3) -> Float {
        return (self - vector).length
    }
}

func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

func *= (vector: inout  SCNVector3, scalar: Float) {
    vector = vector * scalar
}

func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

func /= (vector: inout  SCNVector3, scalar: Float) {
    vector = vector / scalar
}

func + (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x + r.x, l.y + r.y, l.z + r.z)
}

func += (l: inout SCNVector3, r: SCNVector3) {
    l = l + r
}

func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x - r.x, l.y - r.y, l.z - r.z)
}

func -= (l: inout  SCNVector3, r: SCNVector3) {
    l = l - r
}

func * (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x * r.x, l.y * r.y, l.z * r.z)
}

func *= (l: inout  SCNVector3, r: SCNVector3) {
    l = l * r
}

func / (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x / r.x, l.y / r.y, l.z / r.z)
}

func /= (l: inout  SCNVector3, r: SCNVector3) {
    l = l / r
}
