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

typealias VKRenderingCommand = () -> Void

open class VKSceneManager: NSObject {
    
    public weak var scene: ARSCNView!
    public weak var delegate: VKSceneManagerDelegate?
    
    public internal(set) var voxelSize: CGFloat = VKConstants.voxelSideLength
    
    public internal(set) var state: VKARSessionState = .limitedInitializing {
        didSet { delegate?.vkSceneManager(self, didUpdateState: state) }
    }
    
    public internal(set) var focusContainer: VKSceneFocusContainer = .empty
    public internal(set) var surfaces: [ARPlaneAnchor: VKSurfaceNode] = [:]
    
    var updateQueue: DispatchQueue = DispatchQueue(label: "vk-update-queue", attributes: .concurrent)
    var renderingQueue: VKSynchronizedQueue<VKRenderingCommand> = VKSynchronizedQueue<VKRenderingCommand>()
    
    public init(with scene: ARSCNView) {
        self.scene = scene
        super.init()
        setup()
    }
    
    //MARK: - Setup
    func setup() {
        UIApplication.shared.isIdleTimerDisabled = true
        
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
            focusContainer.focusedVoxel = nil
            focusContainer.selectedAnchor = nil
            focusContainer.selectedSurface = nil
            
            resetSession()
        } else {
            guard let surface = focusContainer.selectedSurface else {
                debugPrint("VKSceneManager: Reloading, when surface not selected")
                return
            }
            
            updateQueue.async {
                let nodesToRemove: [VKVoxelNode] = surface.childs { $0.mutable }
                let removeCommands = nodesToRemove.flatMap { (node) in
                    return { DispatchQueue.main.async { node.removeFromParentNode() } }
                }
                
                self.renderingQueue.enqueue(removeCommands)
            }
            
            updateQueue.async {
                let countToAdd = self.delegate?.vkSceneManager(self, countOfVoxelesIn: self.scene) ?? 0
                
                (0..<countToAdd).forEach { (index) in
                    guard let nodeToAdd = self.delegate?.vkSceneManager(self, voxelFor: index) else { return }
                    
                    self.renderingQueue.enqueue {
                        DispatchQueue.main.async { surface.addChildNode(nodeToAdd) }
                    }
                }
            }
        }
    }
    
    public func setSelected(surface: VKSurfaceNode) {
        guard focusContainer.selectedSurface == nil else {
            debugPrint("VKSceneManager: surface already selected")
            return
        }
        
        guard let anchor = surfaces.first(where: { $0.value == surface })?.key else {
            debugPrint("VKSceneManager: Cannot select surface without ARPlaneAnchor")
            return
        }
        
        focusContainer.focusedSurface = nil
        focusContainer.selectedAnchor = anchor
        focusContainer.selectedSurface = surface
        state = .normal(true)
        
        removeSurfaces(except: surface, animated: true)
        
        renderingQueue.enqueue(surface.prepareCreateVoxeles())
        reloadSession()
    }
    
    public func add(new voxel: VKVoxelNode, to otherVoxel: VKVoxelNode, face: VKVoxelFace) {
        guard let surface = focusContainer.selectedSurface else {
            debugPrint("VKSceneManager: Adding, when surface not selected")
            return
        }
        
        guard otherVoxel.parent == surface else {
            debugPrint("VKSceneManager: Adding, when otherVoxel value not in surface hierarchy")
            return
        }
        
        let position = newPosition(for: voxel, attachedTo: face, of: otherVoxel)
        voxel.position = position
        
        add(new: voxel)
    }
    
    public func add(new voxel: VKVoxelNode) {
        guard let surface = focusContainer.selectedSurface else {
            debugPrint("VKSceneManager: Adding, when surface not selected")
            return
        }
        
        surface.addChildNode(voxel)
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
        switch state {
        case .normal(let surfaceSelected):
            surfaceSelected ? updateVoxelesFocus() : updateSurfacesFocus()
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
}

//MARK: - Voxel processing
extension VKSceneManager {
    
    func updateVoxelesFocus() {
        let predicate: (_ voxel: VKVoxelNode) -> Bool = { $0.isInstalled }
        guard let result = scene.hitTestNode(from: scene.center, predicate: predicate) else {
            defocusVoxelIfNeeded()
            return
        }
        
        defocusVoxelIfNeeded()
        focusContainer.focusedVoxel = result.0
        delegate?.vkSceneManager(self, didFocus: result.0, face: result.1)
    }
    
    func defocusVoxelIfNeeded() {
        guard let focusedVoxel = focusContainer.focusedVoxel else {
            return
        }
        
        focusContainer.focusedVoxel = nil
        delegate?.vkSceneManager(self, didDefocus: focusedVoxel)
    }
}

//MARK: - Surface processing
extension VKSceneManager {
    func updateSurfacesFocus() {
        guard let result = scene.hitTestNode(from: scene.center, nodeType: VKSurfaceNode.self) else {
            defocusSurfaceIfNeeded()
            return
        }
        
        defocusSurfaceIfNeeded()
        focusContainer.focusedSurface = result.0
        delegate?.vkSceneManager(self, didFocus: result.0, face: result.1)
    }
    
    func defocusSurfaceIfNeeded() {
        guard let focusedSurface = focusContainer.focusedSurface else {
            return
        }
        
        focusContainer.focusedSurface = nil
        delegate?.vkSceneManager(self, didDefocus: focusedSurface)
    }
    
    func removeSurfaces(except node: VKSurfaceNode?, animated: Bool) {
        let pairsToRemove = surfaces.filter { $0.value != node }
        
        pairsToRemove.forEach { (pair) in
            pair.value.removeFromParentNode()
            surfaces[pair.key] = nil
        }
    }
}

