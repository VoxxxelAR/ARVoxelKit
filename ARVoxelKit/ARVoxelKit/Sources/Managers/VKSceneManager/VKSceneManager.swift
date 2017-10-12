//
//  VKSceneManager.swift
//  ARVoxelKit
//
//  Created by Gleb on 9/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

open class VKSceneManager: NSObject {
    
    public weak var scene: ARSCNView!
    public weak var delegate: VKSceneManagerDelegate?
    
    public internal(set) var voxelSize: CGFloat = VKConstants.voxelSideLength
    
    public internal(set) var state: VKARSessionState = .limitedInitializing {
        didSet { delegate?.vkSceneManager(self, didUpdateState: state) }
    }
    
    public internal(set) var focusContainer: VKSceneFocusContainer = .empty
    public internal(set) var surfaces: [ARPlaneAnchor: VKPlatformNode] = [:]
    
    var updateQueue: DispatchQueue = DispatchQueue(label: "vk-update-queue", attributes: .concurrent)
    
    public init(with scene: ARSCNView) {
        self.scene = scene
        super.init()
        setup()
    }
    
    //MARK: - Setup
    func setup() {
        setupScene()
        setupCamera()
    }
    
    func setupScene() {
        scene.delegate = self
        scene.session.delegate = self
        
        scene.scene = SCNScene()
        scene.automaticallyUpdatesLighting = true
        
        scene.showsStatistics = true
        
        if VKConstants.debug {
            scene.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        }
    }
    
    func setupCamera() {
        guard let camera = scene.pointOfView?.camera else { return }
        
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    //MARK: - Session Managing
    public func launchSession() {
        clearStoredData()
        let configuration = state.configuration
        scene.session.run(configuration)
    }
    
    public func pauseSession() {
        scene.session.pause()
    }
    
    public func reloadSession() {
        let configuration = state.configuration
        scene.session.run(configuration)
    }
    
    public func resetSession() {
        var options: ARSession.RunOptions =  []
        
        switch focusContainer.state {
        case .surfaceSelected, .voxelFocused:
            options = [.resetTracking]
        default:
            options = [.resetTracking, .removeExistingAnchors]
            clearStoredData()
        }
        
        let configuration = state.configuration
        scene.session.run(configuration, options: options)
    }
    
    func clearStoredData() {
        surfaces = [:]
        focusContainer = .empty
    }
}

//MARK: - Public API
extension VKSceneManager {
    public func reload(changeSurface: Bool) {
        if changeSurface {
            focusContainer.focusedNode = nil
            focusContainer.selectedAnchor = nil
            focusContainer.selectedSurface = nil
            
            resetSession()
        } else {
            guard let surface = focusContainer.selectedSurface else {
                debugPrint("VKSceneManager: Reloading, when surface not selected")
                return
            }
            
            updateQueue.async {
                let nodesToRemove: [VKVoxelNode] = surface.childs()
                
                let removeCommands = nodesToRemove.flatMap { (node) in
                    return { DispatchQueue.main.async { node.removeFromParentNode() } }
                }
                
                surface.process(removeCommands)
            }
            
            updateQueue.async { [weak surface] in
                guard let wSurface = surface else { return }
                
                let countToAdd = self.delegate?.vkSceneManager(self, countOfVoxelsIn: self.scene) ?? 0
                let addCommands = (0..<countToAdd).map { (index) in
                    return { [weak self] in
                        guard let wSelf = self else { return }
                        guard let addingNode = wSelf.delegate?.vkSceneManager(wSelf, voxelFor: index) else { return }
                        
                        wSurface.addChildNode(addingNode)
                    }
                }
                
                wSurface.process(addCommands)
            }
        }
    }
    
    public func setSelected(surface: VKPlatformNode) {
        guard focusContainer.selectedSurface == nil else {
            debugPrint("VKSceneManager: surface already selected")
            return
        }
        
        guard let anchor = surfaces.first(where: { $0.value == surface })?.key else {
            debugPrint("VKSceneManager: Cannot select surface without ARPlaneAnchor")
            return
        }
        
        focusContainer.focusedNode = nil
        focusContainer.selectedAnchor = anchor
        focusContainer.selectedSurface = surface
        state = .normal(true)
        
        removeSurfaces(except: surface, animated: true)
        surface.createTiles()
        
        reloadSession()
    }
    
    public func add(new voxel: VKVoxelNode) {
        guard let surface = focusContainer.selectedSurface else {
            debugPrint("VKSceneManager: Adding, when surface not selected")
            return
        }
        
        surface.addChildNode(voxel)
    }
    
    public func add(new voxel: VKVoxelNode, to otherVoxel: VKVoxelNode, face: VKVoxelFace = .top) {
        guard let surface = focusContainer.selectedSurface else {
            debugPrint("VKSceneManager: Adding, when surface not selected")
            return
        }
        
        guard otherVoxel.parent == surface else {
            debugPrint("VKSceneManager: Adding, when node not in surface hierarchy")
            return
        }
        
        let position = newPosition(for: voxel, attachedTo: face, of: otherVoxel)
        voxel.position = position
        
        add(new: voxel)
    }
    
    public func add(new voxel: VKVoxelNode, to tile: VKTileNode) {
        guard let surface = focusContainer.selectedSurface else {
            debugPrint("VKSceneManager: Adding, when surface not selected")
            return
        }
        
        guard tile.parent == surface else {
            debugPrint("VKSceneManager: Adding, when tile not in surface hierarchy")
            return
        }
        
        let position = newPosition(for: voxel, attachedTo: tile)
        voxel.position = position
        
        add(new: voxel)
    }
    
    public func remove(_ voxel: VKVoxelNode) {
        guard let surface = focusContainer.selectedSurface else {
            debugPrint("VKSceneManager: Removing, when surface not selected")
            return
        }
        
        guard voxel.parent == surface else {
            debugPrint("VKSceneManager: Removing, when voxel value not in surface hierarchy")
            return
        }
        
        voxel.removeFromParentNode()
    }
}

//MARK: - Logic
extension VKSceneManager {
    func updateFocus() {
        switch state { case .normal: break default: return }
        
        switch focusContainer.state {
        case .surfaceFocused:
            fallthrough
        case .empty where !state.isSurfaceSelected:
            updateSceneContentsFocus(hitTestPredicate: { $0 is VKPlatformNode })
        case .voxelFocused, .tileFocused, .surfaceSelected:
            fallthrough
        case .empty where state.isSurfaceSelected:
            updateSceneContentsFocus(hitTestPredicate: { (node) -> Bool in
                if let voxel = node as? VKVoxelNode {
                    return voxel.isInstalled
                }
                
                return node is VKTileNode
            })
        default:
            break
        }
    }
    
    func newPosition(for newNode: VKVoxelDisplayable, attachedTo face: VKVoxelFace, of node: VKVoxelDisplayable) -> SCNVector3 {
        var scalar: CGFloat = 0.0
        
        switch face {
        case .top, .bottom:
            scalar = (newNode.voxelGeometry.height + node.voxelGeometry.height) / 2
        case .back, .front:
            scalar = (newNode.voxelGeometry.length + node.voxelGeometry.length) / 2
        case .left, .right:
            scalar = (newNode.voxelGeometry.width + node.voxelGeometry.width) / 2
        }
        
        return node.position + face.normalizedVector3 * Float(scalar)
    }
    
    func newPosition(for newNode: VKVoxelDisplayable, attachedTo node: VKSurfaceDisplayable) -> SCNVector3 {
        let scalar: CGFloat = (newNode.voxelGeometry.height) / 2
        
        return node.position + VKVoxelFace.front.normalizedVector3 * Float(scalar)
    }
}

//MARK: - Focus processing
extension VKSceneManager {
    
    func updateSceneContentsFocus(hitTestPredicate: @escaping (_ node: VKDisplayable) -> Bool) {
        guard let result = scene.hitTestNode(from: scene.center, predicate: hitTestPredicate) else {
            defocusNodeIfNeeded()
            return
        }
        
        defocusNodeIfNeeded()
        focusContainer.focusedNode = result.0
        delegate?.vkSceneManager(self, didFocus: result.0, face: result.1)
    }
    
    func defocusNodeIfNeeded() {
        guard let focusedNode = focusContainer.focusedNode else { return }
        focusContainer.focusedNode = nil
        delegate?.vkSceneManager(self, didDefocus: focusedNode)
    }
}

//MARK: - Surface processing
extension VKSceneManager {
    func removeSurfaces(except node: VKPlatformNode?, animated: Bool) {
        let pairsToRemove = surfaces.filter { $0.value != node }
        
        pairsToRemove.forEach { (pair) in
            pair.value.removeFromParentNode()
            surfaces[pair.key] = nil
        }
    }
}

