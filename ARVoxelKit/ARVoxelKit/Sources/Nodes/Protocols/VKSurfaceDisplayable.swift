//
//  VKSurfaceDisplayable.swift
//  ARVoxelKit
//
//  Created by Vadym Sidorov on 10/7/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

public protocol VKSurfaceDisplayable: VKDisplayable {
    var surfaceGeometry: SCNPlane { get }
}

extension VKSurfaceDisplayable where Self: SCNNode {
    
    public var surfaceGeometry: SCNPlane {
        guard let surfaceGeometry = geometry as? SCNPlane else {
            fatalError("Geometry must be of SCNPlane type.")
        }
        
        return surfaceGeometry
    }
    
    func setupTransform() {
        self.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
    }
}

extension VKSurfaceDisplayable {
    
    public var surfaceMaterial: SCNMaterial {
        guard let material = surfaceGeometry.firstMaterial else {
            fatalError("Surface material is not set.")
        }
        
        return material
    }
    
    func setupGeometry() {
        surfaceGeometry.firstMaterial = SCNMaterial()
        surfaceGeometry.firstMaterial?.isDoubleSided = true
    }
    
    func updateSurfaceMaterial(with contents: AnyObject) {
        surfaceMaterial.diffuse.contents = contents
    }
    
    func updateSurfaceTransparency(with value: CGFloat) {
        surfaceMaterial.transparency = value
    }
}
