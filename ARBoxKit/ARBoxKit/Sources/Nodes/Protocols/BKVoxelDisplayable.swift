//
//  BKVoxelDisplayable.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit
import ARKit

public protocol BKVoxelDisplayable: class {
    var position: SCNVector3 { get }
    var boxGeometry: SCNBox { get }
    var currentState: BKVoxelState { get set }
}

extension BKVoxelDisplayable where Self: SCNNode {
    public var boxGeometry: SCNBox {
        guard let boxGeometry = geometry as? SCNBox else {
            fatalError("Geometry must be of SCNBox type.")
        }
        
        return boxGeometry
    }
}

extension BKVoxelDisplayable where Self: SCNNode {
    
    func updateTransparency(for faces: [BKVoxelFace], value: CGFloat,  _ animated: Bool, _ completion: (() -> Void)?) {
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
    
    func updateState(newState: BKVoxelState, _ animated: Bool, _ completion: (() -> Void)?) {
        if currentState.id == newState.id { return }
        
        switch newState {
        case .normal:
            setNormalState(animated, completion)
//        case .highlighted(let faces, let alpha):
//            setHighlightedState(faces: faces, alpha: alpha, animated, completion)
        case .hidden:
            setHiddenState(animated, completion)
        }
        
        currentState = newState
    }
    
    func setNormalState(_ animated: Bool, _ completion: (() -> Void)?) {
        updateTransparency(for: BKVoxelFace.all, value: 1, animated, completion)
    }
    
//    func setHighlightedState(faces: [BKVoxelFace], alpha: CGFloat, _ animated: Bool, _ completion: (() -> Void)?) {
//        updateTransparency(for: faces, value: alpha, animated, completion)
//    }
    
    func setHiddenState(_ animated: Bool, _ completion: (() -> Void)?) {
        updateTransparency(for: BKVoxelFace.all, value: 0, animated, completion)
    }
}

extension BKVoxelDisplayable {
    
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
    
    public func boxMaterial(for face: BKVoxelFace) -> SCNMaterial {
        return boxGeometry.materials[face.rawValue]
    }
    
    func updateBoxMaterials(with contents: AnyObject) {
        BKVoxelFace.all.forEach { updateBoxMaterial(for: $0, newContents: contents) }
    }
    
    func updateBoxMaterials(with contents: [AnyObject]) {
        assert(contents.count == 6, "Wrong contents count: \(contents.count)")
        
        zip(boxGeometry.materials, contents).forEach { (material, content) in
            material.diffuse.contents = content
        }
    }
    
    func updateBoxMaterial(for face: BKVoxelFace, newContents contents: AnyObject) {
        boxMaterial(for: face).diffuse.contents = contents
    }
    
    func updateMaterials(for faces: [BKVoxelFace], changes: (SCNMaterial) -> Void) {
        faces.forEach { changes(boxMaterial(for: $0)) }
    }
}

