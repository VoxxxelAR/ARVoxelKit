//
//  BKSceneManager.swift
//  ARBoxKit
//
//  Created by Gleb on 9/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

typealias BKRenderingCommand = () -> Void

open class BKSceneManager: NSObject {
    
    public weak var scene: ARSCNView!
    weak var delegate: BKSceneManagerDelegate?
    
    public internal(set) var voxelSize: CGFloat = BKConstants.voxelSideLength
    
    public internal(set) var state: BKARSessionState = .limitedInitializing {
        didSet { delegate?.bkSceneManager(self, didUpdateState: state) }
    }
    
    public internal(set) var focusContainer: BKSceneFocusContainer = .empty
    public internal(set) var platforms: [ARPlaneAnchor: BKSurfaceNode] = [:]
    
    var updateQueue: DispatchQueue = DispatchQueue(label: "bk-update-queue", attributes: .concurrent)
    var renderingQueue: BKSynchronizedQueue<BKRenderingCommand> = BKSynchronizedQueue<BKRenderingCommand>()
    
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
        
        if BKConstants.debug {
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
        case .platformSelected, .boxFocused:
            options = [.resetTracking]
        default:
            options = [.resetTracking, .removeExistingAnchors]
            clearStoredData()
        }
        
        let configuration = state.configuration
        scene.session.run(configuration, options: options)
    }
    
    func clearStoredData() {
        platforms = [:]
        focusContainer = .empty
    }
}

//MARK: - Public API
extension BKSceneManager {
    public func reload(changePlatform: Bool) {
        if changePlatform {
            focusContainer.focusedBox = nil
            focusContainer.selectedAnchor = nil
            focusContainer.selectedPlatform = nil
            
            resetSession()
        } else {
            guard let platform = focusContainer.selectedPlatform else {
                debugPrint("BKSceneManager: Reloading, when platform not selected")
                return
            }
            
            updateQueue.async {
                let nodesToRemove: [BKVoxelNode] = platform.childs { $0.mutable }
                let removeCommands = nodesToRemove.flatMap { (node) in
                    return { DispatchQueue.main.async { node.removeFromParentNode() } }
                }
                
                self.renderingQueue.enqueue(removeCommands)
            }
            
            updateQueue.async {
                let countToAdd = self.delegate?.bkSceneManager(self, countOfBoxesIn: self.scene) ?? 0
                
                (0..<countToAdd).forEach { (index) in
                    guard let nodeToAdd = self.delegate?.bkSceneManager(self, boxFor: index) else { return }
                    
                    self.renderingQueue.enqueue {
                        DispatchQueue.main.async { platform.addChildNode(nodeToAdd) }
                    }
                }
            }
        }
    }
    
    public func setSelected(platform: BKSurfaceNode) {
        guard focusContainer.selectedPlatform == nil else {
            debugPrint("BKSceneManager: platform already selected")
            return
        }
        
        guard let anchor = platforms.first(where: { $0.value == platform })?.key else {
            debugPrint("BKSceneManager: Cannot select platform without ARPlaneAnchor")
            return
        }
        
        focusContainer.focusedPlatform = nil
        focusContainer.selectedAnchor = anchor
        focusContainer.selectedPlatform = platform
        state = .normal(true)
        
        removePlatforms(except: platform, animated: true)
        platform.updateState(newState: .normal, true, nil)
        
        renderingQueue.enqueue(platform.prepareCreateBoxes())
        reloadSession()
    }
    
    public func add(new box: BKVoxelNode, to otherBox: BKVoxelNode, face: BKVoxelFace) {
        guard let platform = focusContainer.selectedPlatform else {
            debugPrint("BKSceneManager: Adding, when platform not selected")
            return
        }
        
        guard otherBox.parent == platform else {
            debugPrint("BKSceneManager: Adding, when otherBox value not in platform hierarchy")
            return
        }
        
        let position = newPosition(for: box, attachedTo: face, of: otherBox)
        box.position = position
        
        add(new: box)
    }
    
    public func add(new box: BKVoxelNode) {
        guard let platform = focusContainer.selectedPlatform else {
            debugPrint("BKSceneManager: Adding, when platform not selected")
            return
        }
        
        platform.addChildNode(box)
    }
    
    public func remove(_ box: BKVoxelNode) {
        guard let platform = focusContainer.selectedPlatform else {
            debugPrint("BKSceneManager: Removing, when platform not selected")
            return
        }
        
        guard box.parent == platform else {
            debugPrint("BKSceneManager: Removing, when box value not in platform hierarchy")
            return
        }
        
        box.removeFromParentNode()
    }
}

//MARK: - Logic
extension BKSceneManager {
    func updateFocus() {
        switch state {
        case .normal(let platformSelected):
            platformSelected ? updateBoxesFocus() : updatePlatformsFocus()
        default:
            break
        }
    }
    
    func newPosition(for newNode: BKVoxelDisplayable, attachedTo face: BKVoxelFace, of node: BKVoxelDisplayable) -> SCNVector3 {
        var scalar: CGFloat = 0.0
        
        switch face {
        case .top, .bottom:
            scalar = (newNode.boxGeometry.height + node.boxGeometry.height) / 2
        case .back, .front:
            scalar = (newNode.boxGeometry.length + node.boxGeometry.length) / 2
        case .left, .right:
            scalar = (newNode.boxGeometry.width + node.boxGeometry.width) / 2
        }
        
        return node.position + face.normalizedVector3 * Float(scalar)
    }
}

//MARK: - Box processing
extension BKSceneManager {
    
    func updateBoxesFocus() {
        
        func unHighlightAll() {
            unHighlightBoxes()
            delegate?.bkSceneManager(self, didDefocus: focusContainer.focusedBox)
            focusContainer.focusedBox = nil
        }
        
        guard let result = scene.hitTestNode(from: scene.center, nodeType: BKVoxelNode.self) else {
            unHighlightAll()
            return
        }
        
        guard let box = result.node as? BKVoxelNode else {
            unHighlightAll()
            return
        }
        
        guard let face = BKVoxelFace(rawValue: result.geometryIndex) else {
            debugPrint("Wrong face index")
            unHighlightAll()
            return
        }
        
        switch focusContainer.state {
        case .boxFocused(let previousFocusedBox):
            previousFocusedBox.updateState(newState: .normal, true, nil)
        default:
            unHighlightBoxes(except: box)
        }
        
        focusContainer.focusedBox = box
        
        delegate?.bkSceneManager(self, didFocus: box, face: face)
    }
    
    func unHighlightBoxes(except node: BKVoxelNode? = nil) {
        guard let platform = focusContainer.selectedPlatform else { return }
        
        let boxes: [BKVoxelNode] = platform.childs { $0 != node }
        boxes.forEach { (box) in
            box.updateState(newState: .normal, true, nil)
        }
    }
}

//MARK: - Platform processing
extension BKSceneManager {
    func updatePlatformsFocus() {
        
        func unhHighlightAll() {
            unHighlightPlatforms()
            delegate?.bkSceneManager(self, didDefocus: focusContainer.focusedPlatform)
            focusContainer.focusedPlatform = nil
        }
        
        guard let result = scene.hitTestNode(from: scene.center, nodeType: BKSurfaceNode.self) else {
            unhHighlightAll()
            return
        }
        
        guard let platform = result.node as? BKSurfaceNode else {
            unhHighlightAll()
            return
        }
        
        guard let face = BKVoxelFace(rawValue: result.geometryIndex) else {
            debugPrint("Wrong face index")
            unhHighlightAll()
            return
        }
        
        switch focusContainer.state {
        case .platformFocused(let previousFocusedPlatform):
            previousFocusedPlatform.updateState(newState: .normal, true, nil)
        default:
            unHighlightPlatforms(except: platform)
        }
        
        focusContainer.focusedPlatform = platform
        
        delegate?.bkSceneManager(self, didFocus: platform, face: face)
    }
    
    func unHighlightPlatforms(except node: BKSurfaceNode? = nil) {
        platforms.values.forEach { (platform) in
            if platform == node { return }
            platform.updateState(newState: .normal, true, nil)
        }
    }
    
    func removePlatforms(except node: BKSurfaceNode?, animated: Bool) {
        let pairsToRemove = platforms.filter { $0.value != node }
        
        pairsToRemove.forEach { (anchor, platform) in
            platform.updateState(newState: .hidden, true) { [weak self] in
                guard let wSelf = self else { return }
                
                platform.removeFromParentNode()
                wSelf.platforms[anchor] = nil
            }
        }
    }
}

