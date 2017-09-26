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
        
        geometry = SCNBox(sideLength: sideLength)
        
        setupGeometry()
        applyColors()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        geometry = SCNBox()
        
        setupGeometry()
        applyColors()
    }
}

