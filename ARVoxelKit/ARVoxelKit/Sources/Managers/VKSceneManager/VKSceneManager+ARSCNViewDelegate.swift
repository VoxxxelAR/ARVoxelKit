//
//  VKSceneManager+ARSCNViewDelegate.swift
//  ARVoxelKit
//
//  Created by Vadym Sidorov on 9/30/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

//MARK: - ARSCNViewDelegate
extension VKSceneManager: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocus()
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        guard !state.isSurfaceSelected else { return }
        
        let surface = VKPlatformNode(anchor: planeAnchor, voxelSideLength: voxelSize)
        
        surfaces[planeAnchor] = surface
        node.addChildNode(surface)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let surface = surfaces[planeAnchor] else { return }
        
        updateQueue.async {
            surface.update(planeAnchor, animated: true)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        surfaces[planeAnchor] = nil
    }
}
