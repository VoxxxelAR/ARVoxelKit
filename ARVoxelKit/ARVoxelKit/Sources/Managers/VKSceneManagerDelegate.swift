//
//  VKSceneManagerDelegate.swift
//  ARVoxelKit
//
//  Created by Gleb Radchenko on 9/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

public protocol VKSceneManagerDelegate: class {
    var voxelSize: CGFloat { get }
    
    func vkSceneManager(_ manager: VKSceneManager, shouldResetSessionFor state: VKARSessionState) -> Bool
    func vkSceneManager(_ manager: VKSceneManager, didUpdateState state: VKARSessionState)
    
    func vkSceneManager(_ manager: VKSceneManager, didFocus surface: VKPlatformNode)
    func vkSceneManager(_ manager: VKSceneManager, didDefocus surface: VKPlatformNode?)
    
    func vkSceneManager(_ manager: VKSceneManager, didFocus voxel: VKVoxelNode, face: VKVoxelFace)
    func vkSceneManager(_ manager: VKSceneManager, didDefocus voxel: VKVoxelNode?)
    
    func vkSceneManager(_ manager: VKSceneManager, countOfVoxelsIn scene: ARSCNView) -> Int
    func vkSceneManager(_ manager: VKSceneManager, voxelFor index: Int) -> VKVoxelNode
}

extension VKSceneManagerDelegate {
    public var voxelSize: CGFloat {
        return VKConstants.voxelSideLength
        
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, shouldResetSessionFor state: VKARSessionState) -> Bool {
        return true
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didUpdateState state: VKARSessionState) { }
    
    public func vkSceneManager(_ manager: VKSceneManager, didFocus surface: VKPlatformNode, face: VKVoxelFace) { }
    public func vkSceneManager(_ manager: VKSceneManager, didDefocus surface: VKPlatformNode?) { }
    
    public func vkSceneManager(_ manager: VKSceneManager, didFocus voxel: VKVoxelNode, face: VKVoxelFace) { }
    public func vkSceneManager(_ manager: VKSceneManager, didDefocus voxel: VKVoxelNode?) { }
    
    public func vkSceneManager(_ manager: VKSceneManager, countOfVoxelsIn scene: ARSCNView) -> Int { return 0 }
}
