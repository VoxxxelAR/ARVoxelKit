//
//  BKBoxNode.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit
import ARKit

open class BKBoxNode: SCNNode, BKBoxDisplayable, BKBoxEditable {
    public var currentState: BKBoxState = .normal
    var mutable: Bool = true
    
    init(sideLength: CGFloat) {
        super.init()
        geometry = SCNBox(sideLength: sideLength)
        setupGeometry()
    }
    
    public override convenience init() {
        self.init(color: BKConstants.defaultFaceColor)
    }
    
    public convenience required init(color: UIColor) {
        self.init(sideLength: BKConstants.voxelSideLength)
        paint(with: color)
    }
    
    public convenience required init(image: UIImage) {
        self.init(sideLength: BKConstants.voxelSideLength)
        paint(with: image)
    }

    public required convenience init(colors: [UIColor], start: CGPoint, end: CGPoint) {
        self.init(sideLength: BKConstants.voxelSideLength)
        paint(with: colors, start: start, end: end)
    }

    public required convenience init(colors: [UIColor]) {
        self.init(sideLength: BKConstants.voxelSideLength)
        
        let layers = colors.map { ColoredLayer(color: $0) }
        updateBoxMaterials(with: layers)
    }

    public required convenience init(images: [UIImage]) {
        self.init(sideLength: BKConstants.voxelSideLength)
        
        let layers = images.map { TexturedLayer(image: $0) }
        updateBoxMaterials(with: layers)
    }

    public required convenience init(gradients: [([UIColor], CGPoint, CGPoint)]) {
        self.init(sideLength: BKConstants.voxelSideLength)
        
        let layers = gradients.map { GradientedLayer(colors: $0.0, start: $0.1, end: $0.2) }
        updateBoxMaterials(with: layers)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        geometry = SCNBox()
        setupGeometry()
    }
}
