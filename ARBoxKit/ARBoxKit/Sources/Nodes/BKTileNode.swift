//
//  BKTileNode.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

open class BKTileNode: SCNNode, BoxDisplayable {
    public var currentState: BKBoxState = .normal
}
