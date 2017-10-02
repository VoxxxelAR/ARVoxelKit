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
        
        let image = UIImage(named: "square_frame", in: Bundle.init(for: type(of: self)), compatibleWith: nil)
        BKBoxFace.all.forEach { (face) in
            let material = boxMaterial(for: face)
            material.diffuse.contents = image
        }
//        geometry?.firstMaterial?.diffuse.contents = image!
//        geometry?.firstMaterial?.isDoubleSided = true
//        geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        //applyColors()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        geometry = SCNBox()
        
        setupGeometry()
        applyColors()
    }
}

