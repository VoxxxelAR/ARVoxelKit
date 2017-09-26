//
//  BKBoxNode.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/26/17.
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

open class BKBoxNode: SCNNode {
    open var boxGeometry: SCNBox {
        return geometry as! SCNBox
    }
    
    public init(sideLength: CGFloat) {
        super.init()
        geometry = SCNBox(width: sideLength,
                          height: sideLength,
                          length: sideLength,
                          chamferRadius: 0)
        setupGeometry()
        applyColors()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        geometry = SCNBox()
        setupGeometry()
        applyColors()
    }
    
    fileprivate func setupGeometry() {
        let top = SCNMaterial()
        let bottom = SCNMaterial()
        let left = SCNMaterial()
        let right = SCNMaterial()
        let front = SCNMaterial()
        let back = SCNMaterial()
        
        boxGeometry.materials = [front, right, back, left, top, bottom]
    }
    
    func applyColors() {
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
    
    func boxMaterial(for face: BKBoxFace) -> SCNMaterial {
        return boxGeometry.materials[face.rawValue]
    }
}

