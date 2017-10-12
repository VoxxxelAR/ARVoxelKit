//
//  VKPlatformNode.swift
//  ARVoxelKit
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

open class VKPlatformNode: SCNNode, VKSurfaceDisplayable {
    
    var anchor: ARPlaneAnchor
    var voxelSideLength: CGFloat
    
    public var isAnimating = false
    
    var areTilesPrepared: Bool = false
    
    init(anchor: ARPlaneAnchor, voxelSideLength: CGFloat) {
        self.anchor = anchor
        self.voxelSideLength = voxelSideLength
        
        super.init()
        geometry = SCNPlane(width: 0, height: 0)
        
        setupTransform()
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
            
            if !self.areTilesPrepared {
                self.surfaceGeometry.width = min(VKConstants.maxSurfaceWidth, extendedX)
                self.surfaceGeometry.height = min(VKConstants.maxSurfaceLength, extendedZ)
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
    
    func prepareCreateTiles() {
        areTilesPrepared = true
        var positions = calculateTilesPositions()
        
        let renderBlock = {  [weak self] (node: SCNNode) in
            guard let wSelf = self else { return }
            guard let position = positions.popLast() else { return }
            
            let voxel = VKTileNode()
//            voxel.mutable = false
            voxel.position = position
            
            wSelf.addChildNode(voxel)
        }
        
        let actions = [SCNAction.wait(duration: 0.01), SCNAction.run(renderBlock, queue: .main)]
        let sequence = SCNAction.sequence(actions)
        let repeatAction = SCNAction.repeat(sequence, count: positions.count)
        
        runAction(repeatAction)
    }
    
    func calculateTilesPositions() -> [SCNVector3] {
        
        let nodeLength = surfaceGeometry.height
        let nodeWidth = surfaceGeometry.width
        
        let tileLength = voxelSideLength
        
        let rowCount = Int(ceil(nodeLength / tileLength))
        let columnCount = Int(ceil(nodeWidth / tileLength))
        
        let margin = tileLength / 2.0
        
        let z = CGFloat(0)
        
        var result: [SCNVector3] = []
        
        (0..<rowCount).forEach { (row) in
            let y = -nodeLength / 2 + margin + CGFloat(row) * tileLength
            (0..<columnCount).forEach { (column) in
                let x = -nodeWidth / 2 + margin + CGFloat(column) * tileLength
                result.append(SCNVector3(x, y, z))
            }
        }
        
        return result
    }
}

