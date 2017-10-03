//
//  BKBoxNode.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit
import ARKit

open class BKBoxNode: SCNNode, BoxDisplayable, BKBoxEditable {
    public var currentState: BKBoxState = .normal
    var mutable: Bool = true
    
    init(sideLength: CGFloat, materials: [SCNMaterial]) {
        super.init()
        geometry = SCNBox(sideLength: sideLength)
        boxGeometry.materials = materials
    }
    
    public override convenience init() {
        let layer = ColoredLayer(color: BKConstants.defaultFaceColor)
        layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        let materials = createBoxMaterials(with: layer)
        self.init(sideLength: BKConstants.voxelSideLength, materials: materials)
    }
    
    public required convenience init(color: UIColor) {
        let materials = createBoxMaterials(with: color)
        self.init(sideLength: BKConstants.voxelSideLength, materials: materials)
    }
    
    public required convenience init(image: UIImage) {
        let materials = createBoxMaterials(with: image)
        self.init(sideLength: BKConstants.voxelSideLength, materials: materials)
    }

    public required convenience init(colors: [UIColor], start: CGPoint, end: CGPoint) {
        let gradient = GradientedLayer(colors: colors, start: start, end: end)
        let materials = createBoxMaterials(with: gradient)
        self.init(sideLength: BKConstants.voxelSideLength, materials: materials)
    }

    public required convenience init(colors: [UIColor]) {
        let materials = createBoxMaterials(with: colors)
        self.init(sideLength: BKConstants.voxelSideLength, materials: materials)
    }

    public required convenience init(images: [UIImage]) {
        let materials = createBoxMaterials(with: images)
        self.init(sideLength: BKConstants.voxelSideLength, materials: materials)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        geometry = SCNBox()
        setupGeometry()
    }
}

extension BKBoxNode {
    
    public func paint(with color: UIColor) {
        
    }
    
    public func paint(with image: UIImage) {
        
    }
    
    public func paint(with colors: [UIColor], start: CGPoint, end: CGPoint) {
        
    }
    
    public func paint(face: BKBoxFace, with color: UIColor) {
    
    }
    
    public func paint(face: BKBoxFace, with image: UIImage) {
        
    }
    
    public func paint(face: BKBoxFace, with colors: [UIColor], start: CGPoint, end: CGPoint) {
    
    }
}

