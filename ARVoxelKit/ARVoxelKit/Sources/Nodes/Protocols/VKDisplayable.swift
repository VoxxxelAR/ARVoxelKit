//
//  VKDisplayable.swift
//  ARVoxelKit
//
//  Created by Vadym Sidorov on 10/8/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

public protocol VKDisplayable: class, VKPaintable {
    var position: SCNVector3 { get }
}
