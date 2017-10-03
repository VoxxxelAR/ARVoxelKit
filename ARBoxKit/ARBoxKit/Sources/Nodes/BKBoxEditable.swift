//
//  BKBoxEditable.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 10/3/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

public protocol BKBoxEditable {
    
    init(color: UIColor)
    init(image: UIImage)
    init(colors: [UIColor], start: CGPoint, end: CGPoint)
    
    init(colors: [UIColor])
    init(images: [UIImage])
    init(gradients: [([UIColor], CGPoint, CGPoint)])
    
    func paint(with color: UIColor) 
    func paint(with image: UIImage)
    func paint(with colors: [UIColor], start: CGPoint, end: CGPoint)
    
    func paint(face: BKBoxFace, with color: UIColor)
    func paint(face: BKBoxFace, with image: UIImage)
    func paint(face: BKBoxFace, with colors: [UIColor], start: CGPoint, end: CGPoint)

}

extension BKBoxEditable where Self: BKBoxDisplayable {
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
    
    public func paint(face: BKBoxFace, with color: UIColor) {}
    public func paint(face: BKBoxFace, with image: UIImage) {}
    public func paint(face: BKBoxFace, with colors: [UIColor], start: CGPoint, end: CGPoint) {}
}
    
