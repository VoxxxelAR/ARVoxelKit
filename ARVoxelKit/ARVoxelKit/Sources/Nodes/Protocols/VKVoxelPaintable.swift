//
//  VKVoxelEditable.swift
//  ARVoxelKit
//
//  Created by Vadym Sidorov on 10/3/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

public protocol VKVoxelPaintable {
    
    func paint(with color: UIColor) 
    func paint(with image: UIImage)
    func paint(with colors: [UIColor], start: CGPoint, end: CGPoint)
    
    func paint(face: VKVoxelFace, with color: UIColor)
    func paint(face: VKVoxelFace, with image: UIImage)
    func paint(face: VKVoxelFace, with colors: [UIColor], start: CGPoint, end: CGPoint)

}

extension VKVoxelPaintable where Self: VKVoxelDisplayable {
    public func paint(with color: UIColor) {
        let layer = ColoredLayer(color: color)
        updateVoxelMaterials(with: layer)
    }
    
    public func paint(with image: UIImage) {
        let layer = TexturedLayer(image: image)
        updateVoxelMaterials(with: layer)
    }
    
    public func paint(with colors: [UIColor], start: CGPoint, end: CGPoint) {
        let layer = GradientedLayer(colors: colors, start: start, end: end)
        updateVoxelMaterials(with: layer)
    }
    
    public func paint(face: VKVoxelFace, with color: UIColor) {
        voxelGeometry.materials[face.rawValue].diffuse.contents = color
    }
    
    public func paint(face: VKVoxelFace, with image: UIImage) {
        voxelGeometry.materials[face.rawValue].diffuse.contents = image
    }
    
    public func paint(face: VKVoxelFace, with colors: [UIColor], start: CGPoint, end: CGPoint) {
        let gradient = GradientedLayer(colors: colors, start: start, end: end)
        voxelGeometry.materials[face.rawValue].diffuse.contents = gradient
    }
}

