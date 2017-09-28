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
    
    func bkSceneManager(_ manager: BKSceneManager, didFocus platform: BKPlatformNode, face: BKBoxFace)
    func bkSceneManager(_ manager: BKSceneManager, didDefocus platform: BKPlatformNode?)
    
    func bkSceneManager(_ manager: BKSceneManager, didFocus box: BKBoxNode, face: BKBoxFace)
    func bkSceneManager(_ manager: BKSceneManager, didDefocus box: BKBoxNode?)
    
    func bkSceneManager(_ manager: BKSceneManager, countOfBoxesIn scene: ARSCNView) -> Int
    func bkSceneManager(_ manager: BKSceneManager, boxFor index: Int) -> BKBoxNode
}

extension BKSceneManagerDelegate {
    public var voxelSize: CGFloat {
        return BKConstants.voxelSideLength
        
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, shouldResetSessionFor state: BKARSessionState) -> Bool {
        return true
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, didUpdateState state: BKARSessionState) { }
    
    public func bkSceneManager(_ manager: BKSceneManager, didFocus platform: BKPlatformNode, face: BKBoxFace) { }
    public func bkSceneManager(_ manager: BKSceneManager, didDefocus platform: BKPlatformNode?) { }
    
    public func bkSceneManager(_ manager: BKSceneManager, didFocus box: BKBoxNode, face: BKBoxFace) { }
    public func bkSceneManager(_ manager: BKSceneManager, didDefocus box: BKBoxNode?) { }
    
    public func bkSceneManager(_ manager: BKSceneManager, countOfBoxesIn scene: ARSCNView) -> Int { return 0 }
}
