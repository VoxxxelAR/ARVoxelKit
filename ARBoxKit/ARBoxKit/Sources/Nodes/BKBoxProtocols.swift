//
//  BKBoxProtocols.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit
import ARKit

public enum BKBoxState {
    case normal
    case highlighted(face: [BKBoxFace], alpha: CGFloat)
    case hidden
    
    var id: Int {
        switch self {
        case .normal: return 0
        case .highlighted: return 1
        case .hidden: return 2
        }
    }
}

public enum BKBoxFace: Int {
    case front = 0, right, back, left, top, bottom
    
    static var all: [BKBoxFace] {
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

public protocol BKBoxDisplayable: class {
    var position: SCNVector3 { get }
    
    var boxGeometry: SCNBox { get }
    var currentState: BKBoxState { get set }
}

extension BKBoxDisplayable where Self: SCNNode {
    public var boxGeometry: SCNBox {
        guard let boxGeometry = geometry as? SCNBox else {
            fatalError("Geometry must be of SCNBox type.")
        }
        
        return boxGeometry
    }
}

extension BKBoxDisplayable where Self: SCNNode {
    
    func updateTransparency(for faces: [BKBoxFace], value: CGFloat,  _ animated: Bool, _ completion: (() -> Void)?) {
        let changes: () -> Void = {
            self.updateMaterials(for: faces) { (material) in
                material.transparency = value
            }
        }
        
        if !animated {
            changes()
            completion?()
        } else {
            SCNTransaction.animate(with: 0.1, timingFunction: .easeIn, changes, completion)
        }
    }
    
    func updateState(newState: BKBoxState, _ animated: Bool, _ completion: (() -> Void)?) {
        if currentState.id == newState.id { return }
        
        switch newState {
        case .normal:
            setNormalState(animated, completion)
        case .highlighted(let faces, let alpha):
            setHighlightedState(faces: faces, alpha: alpha, animated, completion)
        case .hidden:
            setHiddenState(animated, completion)
        }
        
        currentState = newState
    }
    
    func setNormalState(_ animated: Bool, _ completion: (() -> Void)?) {
        updateTransparency(for: BKBoxFace.all, value: 1, animated, completion)
    }
    
    func setHighlightedState(faces: [BKBoxFace], alpha: CGFloat, _ animated: Bool, _ completion: (() -> Void)?) {
        updateTransparency(for: faces, value: alpha, animated, completion)
    }
    
    func setHiddenState(_ animated: Bool, _ completion: (() -> Void)?) {
        updateTransparency(for: BKBoxFace.all, value: 0, animated, completion)
    }
}

extension BKBoxDisplayable {
    
    func setupGeometry() {
        boxGeometry.materials = createBoxMaterials()
    }
    
    func createBoxMaterials() -> [SCNMaterial] {
        let top = SCNMaterial()
        let bottom = SCNMaterial()
        let left = SCNMaterial()
        let right = SCNMaterial()
        let front = SCNMaterial()
        let back = SCNMaterial()
        
        return [front, right, back, left, top, bottom]
    }
    
    public func boxMaterial(for face: BKBoxFace) -> SCNMaterial {
        return boxGeometry.materials[face.rawValue]
    }
    
    func updateBoxMaterials(with contents: AnyObject) {
        BKBoxFace.all.forEach { updateBoxMaterial(for: $0, newContents: contents) }
    }
    
    func updateBoxMaterials(with contents: [AnyObject]) {
        assert(contents.count == 6, "Wrong contents count: \(contents.count)")
        
        zip(boxGeometry.materials, contents).forEach { (material, content) in
            material.diffuse.contents = content
        }
    }
    
    func updateBoxMaterial(for face: BKBoxFace, newContents contents: AnyObject) {
        boxMaterial(for: face).diffuse.contents = contents
    }
    
    func updateMaterials(for faces: [BKBoxFace], changes: (SCNMaterial) -> Void) {
        faces.forEach { changes(boxMaterial(for: $0)) }
    }
}

