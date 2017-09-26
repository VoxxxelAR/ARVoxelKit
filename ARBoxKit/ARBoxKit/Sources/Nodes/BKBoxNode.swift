//
//  BKBoxNode.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit
import ARKit

open class BKBoxNode: SCNNode, BoxDisplayable {
    
    public init(sideLength: CGFloat) {
        super.init()
        geometry = SCNBox(width: sideLength,
                          height: sideLength,
                          length: sideLength,
                          chamferRadius: 0)
        setupGeometry()
        applyColors()
        String
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
}

