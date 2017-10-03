//
//  BKSceneFocusContainer.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

public struct BKSceneFocusContainer {
    public var focusedPlatform: BKSurfaceNode?
    
    public var selectedAnchor: ARPlaneAnchor?
    public var selectedPlatform: BKSurfaceNode?
    
    public var focusedBox: BKVoxelNode?
    
    public static let empty = BKSceneFocusContainer()
    
    var state: State {
        if let focusedBox = focusedBox {
            return .boxFocused(box: focusedBox)
        }
        
        if let selectedPlatform = selectedPlatform, let anchor = selectedAnchor {
            return .platformSelected(platform: selectedPlatform, anchor: anchor)
        }
        
        if let focusedPlatform = focusedPlatform {
            return .platformFocused(platform: focusedPlatform)
        }
        
        return .empty
    }
    
    enum State {
        case empty
        case platformFocused(platform: BKSurfaceNode)
        case platformSelected(platform: BKSurfaceNode, anchor: ARPlaneAnchor)
        case boxFocused(box: BKVoxelNode)
    }
}
