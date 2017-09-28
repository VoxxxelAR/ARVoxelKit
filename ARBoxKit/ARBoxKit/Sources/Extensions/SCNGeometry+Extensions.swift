//
//  SCNGeometry+Extensions.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

extension SCNBox {
    public convenience init(sideLength: CGFloat) {
        self.init(width: sideLength,
                  height: sideLength,
                  length: sideLength,
                  chamferRadius: sideLength / 10)
    }
}
