//
//  BKSceneManagerDelegate.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

public protocol BKSceneManagerDelegate: class {
    var voxelSize: CGFloat { get }
    
    func bkSceneManager(_ manager: BKSceneManager, shouldResetSessionFor state: BKARSessionState) -> Bool
    func bkSceneManager(_ manager: BKSceneManager, didUpdateState state: BKARSessionState)
    
    func bkSceneManager(_ manager: BKSceneManager, didFocus platform: BKPlatformNode, face: BKVoxelFace)
    func bkSceneManager(_ manager: BKSceneManager, didDefocus platform: BKPlatformNode?)
    
    func bkSceneManager(_ manager: BKSceneManager, didFocus box: BKVoxelNode, face: BKVoxelFace)
    func bkSceneManager(_ manager: BKSceneManager, didDefocus box: BKVoxelNode?)
    
    func bkSceneManager(_ manager: BKSceneManager, countOfBoxesIn scene: ARSCNView) -> Int
    func bkSceneManager(_ manager: BKSceneManager, boxFor index: Int) -> BKVoxelNode
}

extension BKSceneManagerDelegate {
    public var voxelSize: CGFloat {
        return BKConstants.voxelSideLength
        
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, shouldResetSessionFor state: BKARSessionState) -> Bool {
        return true
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, didUpdateState state: BKARSessionState) { }
    
    public func bkSceneManager(_ manager: BKSceneManager, didFocus platform: BKPlatformNode, face: BKVoxelFace) { }
    public func bkSceneManager(_ manager: BKSceneManager, didDefocus platform: BKPlatformNode?) { }
    
    public func bkSceneManager(_ manager: BKSceneManager, didFocus box: BKVoxelNode, face: BKVoxelFace) { }
    public func bkSceneManager(_ manager: BKSceneManager, didDefocus box: BKVoxelNode?) { }
    
    public func bkSceneManager(_ manager: BKSceneManager, countOfBoxesIn scene: ARSCNView) -> Int { return 0 }
}
