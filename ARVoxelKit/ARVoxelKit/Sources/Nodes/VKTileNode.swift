//
//  VKTileNode.swift
//  ARVoxelKit
//
//  Created by Vadym Sidorov on 10/8/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

public class VKTileNode: SCNNode, VKSurfaceDisplayable {
    
    init(sideLength: CGFloat) {
        super.init()
        geometry = SCNPlane(width: sideLength, height: sideLength)
        
        setupGeometry()
    }
    
    public override convenience init() {
        self.init(color: VKConstants.defaultFaceColor)
    }
    
    public convenience required init(color: UIColor) {
        self.init(sideLength: VKConstants.voxelSideLength)
        paint(with: color)
    }
    
    public convenience required init(image: UIImage) {
        self.init(sideLength: VKConstants.voxelSideLength)
        paint(with: image)
    }
    
    public required convenience init(colors: [UIColor], start: CGPoint, end: CGPoint) {
        self.init(sideLength: VKConstants.voxelSideLength)
        paint(with: colors, start: start, end: end)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        geometry = SCNPlane()
        setupGeometry()
    }
}
