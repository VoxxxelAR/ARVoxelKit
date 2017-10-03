//
//  BKVoxelEditable.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 10/3/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

public protocol BKVoxelPaintable {
    
    init(color: UIColor)
    init(image: UIImage)
    init(colors: [UIColor], start: CGPoint, end: CGPoint)
    
    init(colors: [UIColor])
    init(images: [UIImage])
    init(gradients: [([UIColor], CGPoint, CGPoint)])
    
    func paint(with color: UIColor) 
    func paint(with image: UIImage)
    func paint(with colors: [UIColor], start: CGPoint, end: CGPoint)
    
    func paint(face: BKVoxelFace, with color: UIColor)
    func paint(face: BKVoxelFace, with image: UIImage)
    func paint(face: BKVoxelFace, with colors: [UIColor], start: CGPoint, end: CGPoint)

}

extension BKVoxelPaintable where Self: BKVoxelDisplayable {
    public func paint(with color: UIColor) {
        let layer = ColoredLayer(color: color)
        updateBoxMaterials(with: layer)
    }
    
    public func paint(with image: UIImage) {
        let layer = TexturedLayer(image: image)
        updateBoxMaterials(with: layer)
    }
    
    public func paint(with colors: [UIColor], start: CGPoint, end: CGPoint) {
        let layer = GradientedLayer(colors: colors, start: start, end: end)
        updateBoxMaterials(with: layer)
    }
    
    public func paint(face: BKVoxelFace, with color: UIColor) {
        boxGeometry.materials[face.rawValue].diffuse.contents = color
    }
    
    public func paint(face: BKVoxelFace, with image: UIImage) {
        boxGeometry.materials[face.rawValue].diffuse.contents = image
    }
    
    public func paint(face: BKVoxelFace, with colors: [UIColor], start: CGPoint, end: CGPoint) {
        let gradient = GradientedLayer(colors: colors, start: start, end: end)
        boxGeometry.materials[face.rawValue].diffuse.contents = gradient
    }
}
    
