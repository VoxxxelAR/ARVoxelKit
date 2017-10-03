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
    
    var isBoxesPrepared: Bool = false
    
    init(anchor: ARPlaneAnchor, boxSideLength: CGFloat) {
        self.anchor = anchor
        self.boxSideLength = boxSideLength
        
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
        
        let extendedX = floor(CGFloat(anchor.extent.x) / boxSideLength) * boxSideLength
        let extendedZ = floor(CGFloat(anchor.extent.z) / boxSideLength) * boxSideLength
        
        let changes = {
            self.simdPosition = simd_float3(anchor.center.x, 0, anchor.center.z)
            
            if !self.isBoxesPrepared {
                self.boxGeometry.width = min(BKConstants.maxSurfaceWidth, extendedX)
                self.boxGeometry.length = min(BKConstants.maxSurfaceLength, extendedZ)
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
    
    func prepareCreateBoxes() -> [BKRenderingCommand] {
        isBoxesPrepared = true
        let positions = calculateBoxPositions()
        
        let boxLength = boxSideLength
        
        return positions.flatMap { (center) in
            return {
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else { return }
                    
                    let box = BKBoxNode(sideLength: boxLength)
                    box.mutable = false
                    box.position = center
                    
                    wSelf.addChildNode(box)
                }
            }
        }
    }
    
    func calculateBoxPositions() -> [SCNVector3] {
        
        let nodeLength = boxGeometry.length
        let nodeWidth = boxGeometry.width
        let boxLength = boxSideLength
        
        let rowCount = Int(ceil(nodeLength / boxLength))
        let columnCount = Int(ceil(nodeWidth / boxLength))
        let margin = boxLength / 2
        
        let y = margin + boxGeometry.height / 2
        
        var result: [SCNVector3] = []
        
        (0..<rowCount).forEach { (row) in
            let z = -nodeLength / 2 + margin + CGFloat(row) * boxLength
            (0..<columnCount).forEach { (column) in
                let x = -nodeWidth / 2 + margin + CGFloat(column) * boxLength
                result.append(SCNVector3(x, y, z))
            }
        }
        
        return result
    }
}

