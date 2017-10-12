//
//  VKPaintable.swift
//  ARVoxelKit
//
//  Created by Vadym Sidorov on 10/7/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit

public enum VKPaintCommand {
    
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

public protocol VKPaintable {
    
    func apply(_ command: VKPaintCommand)
    func apply(_ command: VKPaintCommand, animated: Bool, completion: (() -> Void)?)
    
    func paint(with color: UIColor)
    func paint(with image: UIImage)
    func paint(with colors: [UIColor], start: CGPoint, end: CGPoint)
}

extension VKSurfaceDisplayable {
    
    public func apply(_ command: VKPaintCommand ) {
        apply(command, animated: false)
    }
    
    public func apply(_ command: VKPaintCommand, animated: Bool, completion: (() -> Void)? = nil) {
        let changes = {
            switch command {
            case .color(let content):
                self.paint(with: content)
            case .image(let content):
                self.paint(with: content)
            case .gradient(let contents, let start, let end):
                self.paint(with: contents, start: start, end: end)
            case .transparency(let value):
                self.updateSurfaceTransparency(with: value)
            default:
                debugPrint("Command: \(command) is not supported by instance of type: \(type(of: self))")
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
    
    public func paint(with color: UIColor) {
        let layer = ColoredLayer(color: color)
        updateSurfaceMaterial(with: layer)
    }
    
    public func paint(with image: UIImage) {
        let layer = TexturedLayer(image: image)
        updateSurfaceMaterial(with: layer)
    }
    
    public func paint(with colors: [UIColor], start: CGPoint, end: CGPoint) {
        let layer = GradientedLayer(colors: colors, start: start, end: end)
        updateSurfaceMaterial(with: layer)
    }
}
