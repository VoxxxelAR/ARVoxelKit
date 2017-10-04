//
//  ARSCNView+Extensions.swift
//  ARVoxelKit
//
//  Created by Gleb on 9/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

extension ARSCNView {
    
    func hitTestNode<T>(from point: CGPoint, predicate: ((_ candidate: T) -> Bool)? = nil) -> (T, VKVoxelFace)? {
        let options: [SCNHitTestOption: Any] = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]
        let results = hitTest(point, options: options)
        
        guard let predicate = predicate else {
            if let result = results.first(where: { $0.node is T }), let face = VKVoxelFace(rawValue: result.geometryIndex) {
                return (result.node as! T, face)
            }
            
            return nil
        }
        
        if let result = results.filter ({ $0.node is T }).first(where: { predicate($0.node as! T) }), let face = VKVoxelFace(rawValue: result.geometryIndex) {
            return (result.node as! T, face)
        }
        
        return nil
    }
    
    func hitTestNode<T>(from point: CGPoint, nodeType: T.Type, predicate: ((_ candidate: T) -> Bool)? = nil) -> (T, VKVoxelFace)? {
        return hitTestNode(from: point, predicate: predicate)
    }
    
    func findNodes<T: SCNNode>(in parent: SCNNode) -> [T] {
        return parent.childs()
    }
}

extension SCNNode {
    func childs<T: SCNNode>(_ test: ((T) -> Bool)? = nil) -> [T] {
        return childNodes(passingTest: { (node, stop) -> Bool in
            guard let passing = node as? T else {
                return false
            }
            
            return test?(passing) ?? true
        }) as! [T]
    }
}
