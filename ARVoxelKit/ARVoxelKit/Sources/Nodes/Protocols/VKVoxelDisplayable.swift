//
//  VKVoxelDisplayable.swift
//  ARVoxelKit
//
//  Created by Vadym Sidorov on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit
import ARKit

public protocol VKVoxelDisplayable: VKDisplayable, VKVoxelPaintable {
    // var position: SCNVector3 { get }
    var voxelGeometry: SCNBox { get }
}

extension VKVoxelDisplayable where Self: VKVoxelNode {
    public var voxelGeometry: SCNBox {
        guard let voxelGeometry = geometry as? SCNBox else {
            fatalError("Geometry must be of SCNBox type.")
        }
        
        return voxelGeometry
    }
}

extension VKVoxelDisplayable {
    
    func setupGeometry() {  
        voxelGeometry.materials = createVoxelMaterials()
    }
    
    func createVoxelMaterials() -> [SCNMaterial] {
        return [SCNMaterial(),
                SCNMaterial(),
                SCNMaterial(),
                SCNMaterial(),
                SCNMaterial(),
                SCNMaterial()]
    }
    
    public func voxelMaterial(for face: VKVoxelFace) -> SCNMaterial {
        return voxelGeometry.materials[face.rawValue]
    }
    
    func updateVoxelMaterials(with contents: AnyObject) {
        VKVoxelFace.all.forEach { updateVoxelMaterial(for: $0, newContents: contents) }
    }
    
    func updateVoxelMaterials(with contents: [AnyObject]) {
        assert(contents.count == 6, "Wrong contents count: \(contents.count)")
        
        zip(voxelGeometry.materials, contents).forEach { (material, content) in
            material.diffuse.contents = content
        }
    }
    
    func updateVoxelMaterial(for face: VKVoxelFace, newContents contents: AnyObject) {
        voxelMaterial(for: face).diffuse.contents = contents
    }
    
    func updateVoxelTransparency(with value: CGFloat) {
        VKVoxelFace.all.forEach { updateVoxelTransparency(for: $0, newValue: value) }
    }
    
    func updateVoxelTransparency(for face: VKVoxelFace, newValue value: CGFloat) {
        voxelMaterial(for: face).transparency = value
    }
}

