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
    
    public var selectedAnchor: ARPlaneAnchor?
    public var selectedSurface: VKPlatformNode?
    
    public var focusedNode: VKDisplayable?
    
    public static let empty = VKSceneFocusContainer()
    
    var state: State {
        if let voxel = focusedNode as? VKVoxelNode {
            return .voxelFocused(voxel: voxel)
        }
        
        if let tile = focusedNode as? VKTileNode {
            return .tileFocused(tile: tile)
        }
        
        if let selectedSurface = selectedSurface, let anchor = selectedAnchor {
            return .surfaceSelected(surface: selectedSurface, anchor: anchor)
        }
        
        if let surface = focusedNode as? VKPlatformNode {
            return .surfaceFocused(surface: surface)
        }
        
        return .empty
    }
    
    enum State {
        case empty
        case surfaceSelected(surface: VKPlatformNode, anchor: ARPlaneAnchor)
        case surfaceFocused(surface: VKPlatformNode)
        case tileFocused(tile: VKTileNode)
        case voxelFocused(voxel: VKVoxelNode)
    }
}
