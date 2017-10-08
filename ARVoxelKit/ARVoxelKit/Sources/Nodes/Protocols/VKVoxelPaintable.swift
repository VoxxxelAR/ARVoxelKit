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

public protocol VKVoxelPaintable: VKPaintable {
    
    func apply(_ commands: [VKPaintCommand])
    
    func paint(face: VKVoxelFace, with color: UIColor)
    func paint(face: VKVoxelFace, with image: UIImage)
    func paint(face: VKVoxelFace, with colors: [UIColor], start: CGPoint, end: CGPoint)
    //etc
}

extension VKVoxelDisplayable {
    
    public func apply(_ command: VKPaintCommand) {
        apply(command, animated: false)
    }
    
    public func apply(_ commands: [VKPaintCommand]) {
        apply(commands, animated: false)
    }
    
    public func apply(_ command: VKPaintCommand, animated: Bool, completion: (() -> Void)? = nil) {
        let changes = {
            //TODO: - Complete this
            switch command {
            case .color(let content):
                self.paint(with: content)
            case .faceColor(let content, let face):
                self.paint(face: face, with: content)
            case .transparency(let value):
                self.updateVoxelTransparency(with: value)
            case .faceTransparency(let value, let face):
                self.updateVoxelTransparency(for: face, newValue: value)
            default:
                break
            }
        }
        
        if animated {
            SCNTransaction.animate(with: VKConstants.defaultAnimationDuration, changes, completion)
        } else {
            changes()
            completion?()
        }
    }
    
    public func apply(_ commands: [VKPaintCommand], animated: Bool, completion: (() -> Void)? = nil) {
        let changes = { commands.forEach { self.apply($0, animated: false) } }
        
        if animated {
            SCNTransaction.animate(with: VKConstants.defaultAnimationDuration, changes, completion)
        } else {
            changes()
            completion?()
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
        updateVoxelMaterial(for: face, newContents: layer)
    }
}
