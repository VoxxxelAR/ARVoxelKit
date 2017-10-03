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
    public var currentState: BKBoxState = .normal
    var mutable: Bool = true
    
    public override convenience init() {
        self.init(sideLength: BKConstants.voxelSideLength)
    }
    
    init(sideLength: CGFloat) {
        super.init()
        geometry = SCNBox(sideLength: sideLength)
        setupGeometry()
        
        let blue = UIColor(red: 51 / 255, green: 171 / 255, blue: 224 / 255, alpha: 1.0)
        let layer = ColoredLayer(color: blue)
        layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        BKBoxFace.all.enumerated().forEach { (index, face) in
            let material = boxMaterial(for: face)
            material.diffuse.contents = layer
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        geometry = SCNBox()
        setupGeometry()
    }
}

