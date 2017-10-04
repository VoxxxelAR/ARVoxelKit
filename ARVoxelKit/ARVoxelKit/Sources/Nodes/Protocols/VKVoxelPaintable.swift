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

public enum VKVoxelPaintCommand {
    
    case color(content: UIColor)
    case faceColor(content: UIColor, face: VKVoxelFace)
    case colors(contents: [UIColor])
    
    case image(content: UIImage)
    case faceImage(content: UIImage, face: VKVoxelFace)
    case images(contents: [UIImage])
    
    case gradient(contents: [UIColor], start: CGPoint, end: CGPoint)
    case faceGradient(contents: [UIColor], start: CGPoint, end: CGPoint, face: VKVoxelFace)
    
    case transparency(value: CGFloat)
    case faceTransparency(value: CGFloat, face: VKVoxelFace)
    //etc
}

public protocol VKVoxelPaintable {
    
    func apply(_ command: VKVoxelPaintCommand)
    
    func paint(with color: UIColor)
    func paint(with image: UIImage)
    func paint(with colors: [UIColor], start: CGPoint, end: CGPoint)
    
    func paint(face: VKVoxelFace, with color: UIColor)
    func paint(face: VKVoxelFace, with image: UIImage)
    func paint(face: VKVoxelFace, with colors: [UIColor], start: CGPoint, end: CGPoint)
    //etc
}

extension VKVoxelPaintable where Self: VKVoxelDisplayable {
    
    public func apply(_ command: VKVoxelPaintCommand) {
        //TODO: - Complete this
        switch command {
        case .color(let content):
            paint(with: content)
        case .faceColor(let content, let face):
            paint(face: face, with: content)
        case .transparency(let value):
            updateVoxelTransparency(with: value)
        case .faceTransparency(let value, let face):
            updateVoxelTransparency(for: face, newValue: value)
        default:
            break
        }
    }
    
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
        let layer = ColoredLayer(color: color)
        updateVoxelMaterial(for: face, newContents: layer)
    }
    
    public func paint(face: VKVoxelFace, with image: UIImage) {
        let layer = TexturedLayer(image: image)
        updateVoxelMaterial(for: face, newContents: layer)
    }
    
    public func paint(face: VKVoxelFace, with colors: [UIColor], start: CGPoint, end: CGPoint) {
        let layer = GradientedLayer(colors: colors, start: start, end: end)
        updateVoxelMaterial(for: face, newContents: layer
        )
    }
}

