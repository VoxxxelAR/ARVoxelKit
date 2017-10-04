//
//  Layers.swift
//  ARVoxelKit
//
//  Created by Gleb on 10/3/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import CoreGraphics

class BorderedLayer: CALayer {
    override var frame: CGRect {
        didSet { borderWidth = frame.width / 20 }
    }
    
    override init() {
        super.init()
        frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        borderColor = UIColor.black.cgColor
        shouldRasterize = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ColoredLayer: BorderedLayer {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(color: UIColor) {
        super.init()
        backgroundColor = color.cgColor
    }
}

class TexturedLayer: BorderedLayer {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(image: UIImage) {
        super.init()
        
        contents = image.cgImage
        contentsGravity = kCAGravityResizeAspectFill
        masksToBounds = true
        shouldRasterize = true
    }
}

class GradientedLayer: CAGradientLayer {
    
    override var frame: CGRect {
        didSet { borderWidth = frame.width / 20 }
    }
    
    init(colors: [UIColor]) {
        super.init()
        frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        borderColor = UIColor.black.cgColor
        
        self.colors = colors.flatMap { $0.cgColor }
        shouldRasterize = true
    }
    
    convenience init(colors: [UIColor], start: CGPoint = .zero, end: CGPoint) {
        self.init(colors: colors)
        
        startPoint = start
        endPoint = end
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
