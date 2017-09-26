//
//  BKBoxProtocols.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit
import ARKit

public enum BKBoxFace: Int {
    case front = 0, right, back, left, top, bottom
    
    static var all: [BKBoxFace] {
        return [front, right, back, left, top, bottom]
    }
}

public protocol BoxDisplayable: class {
    var boxGeometry: SCNBox { get }
}

extension BoxDisplayable where Self: SCNNode {
    public var boxGeometry: SCNBox {
        guard let boxGeometry = geometry as? SCNBox else {
            fatalError("Geometry must be of SCNBox type.")
        }
        
        return boxGeometry
    }
}

extension BoxDisplayable {
    
    func setupGeometry() {
        let top = SCNMaterial()
        let bottom = SCNMaterial()
        let left = SCNMaterial()
        let right = SCNMaterial()
        let front = SCNMaterial()
        let back = SCNMaterial()
        
        boxGeometry.materials = [front, right, back, left, top, bottom]
    }
    
    public func applyColors() {
        //MARK: - For debug use
        let colors: [UIColor] = [.green, //front
            .red, //right
            .blue, //back
            .yellow, //left
            .purple, //top
            .gray] //bottom
        
        BKBoxFace.all.forEach { (face) in
            let material = boxMaterial(for: face)
            let color = colors[face.rawValue]
            
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
        }
    }
    
    public func boxMaterial(for face: BKBoxFace) -> SCNMaterial {
        return boxGeometry.materials[face.rawValue]
    }
}

