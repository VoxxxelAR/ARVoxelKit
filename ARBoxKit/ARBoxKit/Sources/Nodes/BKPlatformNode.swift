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
    var updateInitialBoxes = false
    
    public init(anchor: ARPlaneAnchor, boxSideLength: CGFloat) {
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
            self.boxGeometry.width = min(BKConstants.maxSurfaceWidth, extendedX)
            self.boxGeometry.length = min(BKConstants.maxSurfaceLength, extendedZ)
            
            self.simdPosition = simd_float3(anchor.center.x, 0, anchor.center.z)
        }
        
        if !animated  {
            changes()
            isAnimating = false
            if updateInitialBoxes {
                updateBoxes(animated: animated)
            }
        } else {
            isAnimating = true
            SCNTransaction.animate(with: 0.1, changes) {
                self.isAnimating = false
                
                if self.updateInitialBoxes {
                    self.updateBoxes(animated: animated)
                }
            }
        }
    }
    
    func showBoxes(animated: Bool) {
        updateInitialBoxes = true
        
        let rowCount = Int(ceil(boxGeometry.length / boxSideLength))
        let columnCount = Int(ceil(boxGeometry.width / boxSideLength))
        
        let margin = boxSideLength / 2
        
        let y = margin + boxGeometry.height / 2
        DispatchQueue.concurrentPerform(iterations: rowCount) { (row) in
            let z = -boxGeometry.length / 2 + margin + CGFloat(row) * boxSideLength
            DispatchQueue.concurrentPerform(iterations: columnCount) { (column) in
                let x = -boxGeometry.width / 2 + margin + CGFloat(column) * boxSideLength
                
                let box = BKBoxNode(sideLength: boxSideLength)
                box.mutable = false
                box.position = SCNVector3(x, y, z)
                addChildNode(box)
            }
        }
    }
    
    func updateBoxes(animated: Bool) {
        var boxes: [BKBoxNode] = childs { !$0.mutable }
        
        let rowCount = Int(ceil(boxGeometry.length / boxSideLength))
        let columnCount = Int(ceil(boxGeometry.width / boxSideLength))
        
        let margin = boxSideLength / 2
        
        let y = margin + boxGeometry.height / 2
        
        (0..<rowCount).forEach { (row) in
            let z = -boxGeometry.length / 2 + margin + CGFloat(row) * boxSideLength
            (0..<columnCount).forEach { (column) in
                let x = -boxGeometry.width / 2 + margin + CGFloat(column) * boxSideLength
                
                if boxes.isEmpty {
                    let box = BKBoxNode(sideLength: boxSideLength)
                    box.mutable = false
                    box.position = SCNVector3(x, y, z)
                    addChildNode(box)
                } else {
                    let box = boxes.removeLast()
                    box.position = SCNVector3(x, y, z)
                }
            }
        }
    }
}

