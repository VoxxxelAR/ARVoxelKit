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
    public var focusedSurface: VKSurfaceNode?
    
    public var selectedAnchor: ARPlaneAnchor?
    public var selectedSurface: VKSurfaceNode?
    
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
        case surfaceFocused(surface: VKSurfaceNode)
        case surfaceSelected(surface: VKSurfaceNode, anchor: ARPlaneAnchor)
        case voxelFocused(voxel: VKVoxelNode)
    }
}
