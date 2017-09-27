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
    
    public var currentState: BKBoxState = .normal
    public var isAnimating = false
    
    public init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        geometry = SCNBox(width: 0, height: 0.05, length: 0, chamferRadius: 0)
        
        setupGeometry()
        applyColors()
        
        update(anchor, animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor, animated: Bool) {
        if isAnimating { return }
        
        let extendedX = ceil(CGFloat(anchor.extent.x) / BKConstants.voxelSideLength) * BKConstants.voxelSideLength
        let extendedY = ceil(CGFloat(anchor.extent.z) / BKConstants.voxelSideLength) * BKConstants.voxelSideLength
        
        if !animated  {
            boxGeometry.width = extendedX
            boxGeometry.length = extendedY
            
            simdPosition = simd_float3(anchor.center.x, 0, anchor.center.z)
            isAnimating = false
            return
        }
        
        isAnimating = true
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        SCNTransaction.animationDuration = 0.3
        
        boxGeometry.width = extendedX
        boxGeometry.length = extendedY
        
        simdPosition = simd_float3(anchor.center.x, 0, anchor.center.z)
        
        SCNTransaction.completionBlock = { [weak self] in
            self?.isAnimating = false
        }
        
        SCNTransaction.commit()
    }
}

