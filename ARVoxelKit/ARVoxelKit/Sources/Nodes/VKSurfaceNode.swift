//
//  VKSurfaceNode.swift
//  ARVoxelKit
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

open class VKSurfaceNode: SCNNode, VKVoxelDisplayable {
    
    var anchor: ARPlaneAnchor
    var voxelSideLength: CGFloat
    
    public var currentState: VKVoxelState = .normal
    public var isAnimating = false
    
    var isVoxelesPrepared: Bool = false
    
    init(anchor: ARPlaneAnchor, voxelSideLength: CGFloat) {
        self.anchor = anchor
        self.voxelSideLength = voxelSideLength
        
        super.init()
        geometry = SCNBox(width: 0, height: 0.001, length: 0, chamferRadius: 0)
        
        setupGeometry()
        update(anchor, animated: true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor, animated: Bool) {
        if isAnimating { return }
        
        let extendedX = floor(CGFloat(anchor.extent.x) / voxelSideLength) * voxelSideLength
        let extendedZ = floor(CGFloat(anchor.extent.z) / voxelSideLength) * voxelSideLength
        
        let changes = {
            self.simdPosition = simd_float3(anchor.center.x, 0, anchor.center.z)
            
            if !self.isVoxelesPrepared {
                self.voxelGeometry.width = min(VKConstants.maxSurfaceWidth, extendedX)
                self.voxelGeometry.length = min(VKConstants.maxSurfaceLength, extendedZ)
            }
        }
        
        if !animated  {
            changes()
        } else {
            isAnimating = true
            let completion = { self.isAnimating = false }
            SCNTransaction.animate(with: 0.1, changes, completion)
        }
    }
    
    func prepareCreateVoxeles() -> [VKRenderingCommand] {
        isVoxelesPrepared = true
        let positions = calculateVoxelPositions()
        
        return positions.flatMap { (center) in
            return {
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else { return }
                    
                    let voxel = VKVoxelNode()
                    voxel.mutable = false
                    voxel.position = center
                    
                    wSelf.addChildNode(voxel)
                }
            }
        }
    }
    
    func calculateVoxelPositions() -> [SCNVector3] {
        
        let nodeLength = voxelGeometry.length
        let nodeWidth = voxelGeometry.width
        let voxelLength = voxelSideLength
        
        let rowCount = Int(ceil(nodeLength / voxelLength))
        let columnCount = Int(ceil(nodeWidth / voxelLength))
        let margin = voxelLength / 2
        
        let y = margin + voxelGeometry.height / 2
        
        var result: [SCNVector3] = []
        
        (0..<rowCount).forEach { (row) in
            let z = -nodeLength / 2 + margin + CGFloat(row) * voxelLength
            (0..<columnCount).forEach { (column) in
                let x = -nodeWidth / 2 + margin + CGFloat(column) * voxelLength
                result.append(SCNVector3(x, y, z))
            }
        }
        
        return result
    }
}

