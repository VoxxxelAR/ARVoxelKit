//
//  BKSceneManager+ARSCNViewDelegate.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 9/30/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

//MARK: - ARSCNViewDelegate
extension BKSceneManager: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocus()
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        switch state {
        case .normal(let platformSelected):
            if platformSelected { return }
        default: break
        }
        let platform = BKPlatformNode(anchor: planeAnchor, boxSideLength: voxelSize)
        
        platforms[planeAnchor] = platform
        node.addChildNode(platform)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let platform = platforms[planeAnchor] else { return }
        
        updateQueue.async {
            platform.update(planeAnchor, animated: true)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        platforms[planeAnchor] = nil
    }
}
