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
    var boxSideLength: CGFloat
    
    public var currentState: BKBoxState = .normal
    public var isAnimating = false
    
    public init(anchor: ARPlaneAnchor, boxSideLength: CGFloat) {
        self.anchor = anchor
        self.boxSideLength = boxSideLength
        
        super.init()
        geometry = SCNBox(width: 0, height: 0.05, length: 0, chamferRadius: 0)
        
        setupGeometry()
        //applyColors()
        
        update(anchor, animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor, animated: Bool) {
        if isAnimating { return }
        
        let extendedX = floor(CGFloat(anchor.extent.x) / boxSideLength) * boxSideLength
        let extendedY = floor(CGFloat(anchor.extent.z) / boxSideLength) * boxSideLength
        
        let changes = {
            self.boxGeometry.width = extendedX
            self.boxGeometry.length = extendedY
            
            self.simdPosition = simd_float3(anchor.center.x, 0, anchor.center.z)
        }
        
        if !animated  {
            changes()
            isAnimating = false
        } else {
            isAnimating = true
            SCNTransaction.animate(with: 0.1, changes) {
                self.isAnimating = false
            }
        }
    }
}

