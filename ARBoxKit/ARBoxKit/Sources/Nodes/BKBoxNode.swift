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
        
        let blue = UIColor(red: 51 / 255, green: 171 / 255, blue: 224 / 255, alpha: 1.0)
        let image = UIImage(named: "pattern_1", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        
        let differentLayers: [CALayer] = [TexturedLayer(image: image),
                                          ColoredLayer(color: blue),
                                          GradientedLayer(colors: [.white, blue]),
                                          ColoredLayer(color: blue),
                                          GradientedLayer(colors: [.white, blue]),
                                          TexturedLayer(image: image)]
        
        differentLayers.forEach { $0.frame = CGRect(x: 0,
                                                    y: 0,
                                                    width: 200,
                                                    height: 200) }
        
        BKBoxFace.all.enumerated().forEach { (index, face) in
            let material = boxMaterial(for: face)
            material.diffuse.contents = differentLayers[index]
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        geometry = SCNBox()
        setupGeometry()
    }
}

