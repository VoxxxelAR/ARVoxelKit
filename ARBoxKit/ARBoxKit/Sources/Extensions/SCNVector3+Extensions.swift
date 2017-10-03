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

extension SCNVector3: Hashable {
    public var hashValue: Int { return "\(x),\(y),\(z)".hashValue }
}

extension SCNVector3: Equatable {
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

public func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

public func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

public func *= (vector: inout  SCNVector3, scalar: Float) {
    vector = vector * scalar
}

public func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

public func /= (vector: inout  SCNVector3, scalar: Float) {
    vector = vector / scalar
}

public func + (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x + r.x, l.y + r.y, l.z + r.z)
}

public func += (l: inout SCNVector3, r: SCNVector3) {
    l = l + r
}

public func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x - r.x, l.y - r.y, l.z - r.z)
}

public func -= (l: inout  SCNVector3, r: SCNVector3) {
    l = l - r
}

public func * (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x * r.x, l.y * r.y, l.z * r.z)
}

public func *= (l: inout  SCNVector3, r: SCNVector3) {
    l = l * r
}

public func / (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3(l.x / r.x, l.y / r.y, l.z / r.z)
}

public func /= (l: inout  SCNVector3, r: SCNVector3) {
    l = l / r
}
