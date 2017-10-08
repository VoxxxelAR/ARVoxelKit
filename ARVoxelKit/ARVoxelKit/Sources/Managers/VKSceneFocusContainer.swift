//
//  VKSceneFocusContainer.swift
//  ARVoxelKit
//
//  Created by Gleb Radchenko on 9/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

public struct VKSceneFocusContainer {
    public var focusedSurface: VKPlatformNode?
    
    public var selectedAnchor: ARPlaneAnchor?
    public var selectedSurface: VKPlatformNode?
    
    public var focusedVoxel: VKVoxelNode?
    
    public static let empty = VKSceneFocusContainer()
    
    var state: State {
        if let focusedVoxel = focusedVoxel {
            return .voxelFocused(voxel: focusedVoxel)
        }
        
        if let selectedSurface = selectedSurface, let anchor = selectedAnchor {
            return .surfaceSelected(surface: selectedSurface, anchor: anchor)
        }
        
        if let focusedSurface = focusedSurface {
            return .surfaceFocused(surface: focusedSurface)
        }
        
        return .empty
    }
    
    enum State {
        case empty
        case surfaceFocused(surface: VKPlatformNode)
        case surfaceSelected(surface: VKPlatformNode, anchor: ARPlaneAnchor)
        case voxelFocused(voxel: VKVoxelNode)
    }
}
