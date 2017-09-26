//
//  BKPlatformNode.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

open class BKPlatformNode: SCNNode, BoxDisplayable {
    var anchor: ARPlaneAnchor
    
    public init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        geometry = SCNBox(width: CGFloat(anchor.extent.x),
                          height: 0.05,
                          length: CGFloat(anchor.extent.z),
                          chamferRadius: 0)
        setupGeometry()
        applyColors()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func update(_ anchor: ARPlaneAnchor) {
        boxGeometry.width = CGFloat(anchor.extent.x)
        boxGeometry.length = CGFloat(anchor.extent.z)
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
}

