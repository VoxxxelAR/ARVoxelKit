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

public protocol BKSceneManagerDelegate: class {
    var voxelSize: CGFloat { get }
    
    func bkSceneManager(_ manager: BKSceneManager, shouldResetSessionFor state: BKARSessionState) -> Bool
    func bkSceneManager(_ manager: BKSceneManager, stateUpdated newState: BKARSessionState)
}

extension BKSceneManagerDelegate {
    public var voxelSize: CGFloat {
        return BKConstants.voxelSideLength
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, shouldResetSessionFor state: BKARSessionState) -> Bool {
        return true
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, stateUpdated newState: BKARSessionState) { }
}

open class BKSceneManager: NSObject {
    public var voxelSize: CGFloat {
        didSet {
            guard abs(voxelSize - oldValue) > 0.01 else { return }
            //TODO: - Update scene
        }
    }
    
    public var state: BKARSessionState = .limitedInitializing {
        didSet {
            delegate?.bkSceneManager(self, stateUpdated: state)
        }
    }
    
    public var platformState: BKPointerState = .empty
    public var platforms: [ARPlaneAnchor: BKPlatformNode] = [:]
    
    var updateQueue: DispatchQueue = DispatchQueue(label: "ARBoxKit-scene-update-queue")
    
    public weak var scene: ARSCNView!
    var session: ARSession {
        return scene.session
    }
    
    weak var delegate: BKSceneManagerDelegate?
    
    init(with scene: ARSCNView) {
        self.scene = scene
        self.voxelSize = BKConstants.voxelSideLength
        
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
        session.delegate = self
        
        scene.scene = SCNScene()
        scene.automaticallyUpdatesLighting = true
        
        if BKConstants.debug {
            scene.showsStatistics = true
            scene.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                  ARSCNDebugOptions.showFeaturePoints]
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
        let configuration = state.configuration
        session.run(configuration)
    }
    
    public func pauseSession() {
        session.pause()
    }
    
    public func resetSession() {
        let configuration = state.configuration
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

//MARK: - Logic
extension BKSceneManager {
    func updateFocus() {
        switch state {
        case .normal(let platformState):
            switch platformState {
            case .empty, .focused:
                updatePlatformsFocus()
            case .selected:
                updateTilesFocus()
                updateBoxesFocus()
            }
        default:
            break
        }
    }
    
    func newPosition(for newNode: BoxDisplayable, attachedTo face: BKBoxFace, of node: BoxDisplayable) -> SCNVector3 {
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
        guard let result = scene.hitTestNode(from: scene.center, nodeType: BKBoxNode.self) else {
            return
        }
    }
}

//MARK: - Tile processing
extension BKSceneManager {
    func updateTilesFocus() {
        guard let result = scene.hitTestNode(from: scene.center, nodeType: BKTileNode.self) else {
            return
        }
    }
}

//MARK: - Platform processing
extension BKSceneManager {
    func updatePlatformsFocus() {
        guard let result = scene.hitTestNode(from: scene.center, nodeType: BKPlatformNode.self) else {
            unHighlightPlatforms()
            return
        }
        
        guard let platform = result.node as? BKPlatformNode else { return }
        
        guard let face = BKBoxFace(rawValue: result.geometryIndex) else {
            debugPrint("Wrong face index")
            return
        }
        
        switch platformState {
        case .focused(let currentFocusedPlatform):
            currentFocusedPlatform.updateState(newState: .normal, true, nil)
        default:
            unHighlightPlatforms(except: platform)
        }
        
        platform.updateState(newState: .highlighted(face: [face], alpha: 0.2), true, nil)
        platformState = .focused(platform: platform)
    }
    
    func unHighlightPlatforms(except node: BKPlatformNode? = nil) {
        platforms.values.forEach { (platform) in
            if platform == node { return }
            platform.updateState(newState: .normal, true, nil)
        }
    }
}

//MARK: - ARSCNViewDelegate
extension BKSceneManager: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocus()
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
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

public enum BKARSessionState {
    case normal(BKPointerState)
    case normalEmptyAnchors
    case notAvailable
    case limitedExcessiveMotion
    case limitedInsufficientFeatures
    case limitedInitializing
    
    case interrupted
    case interruptionEnded
    case failed(Error)
    
    var configuration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        switch self {
        case .normal(let platformState):
            switch platformState {
            case .selected:
                break
            default:
                configuration.planeDetection = .horizontal
            }
        default:
            configuration.planeDetection = .horizontal
        }
        
        return configuration
    }
    
    public var hint: String {
        switch self {
        case .normal(let platformState):
            switch platformState {
            case .selected:
                return ""
            default:
                return "Select platform"
            }
        case .normalEmptyAnchors:
            return "Move the device around to detect horizontal surfaces."
        case .notAvailable:
            return "Tracking unavailable."
        case .limitedExcessiveMotion:
            return "Tracking limited - Move the device more slowly."
        case .limitedInsufficientFeatures:
            return "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
        case .limitedInitializing:
            return "Initializing AR session."
        case .interrupted:
            return "Session was interrupted"
        case .interruptionEnded:
            return "Session interruption ended"
        case .failed(let error):
            return "Session failed: \(error.localizedDescription)"
        }
    }
}

//MARK: - ARSessionDelegate
extension BKSceneManager: ARSessionDelegate {
    func updateState(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            state = .normalEmptyAnchors
        case .normal:
            state = .normal(platformState)
        case .notAvailable:
            state = .notAvailable
        case .limited(.excessiveMotion):
            state = .limitedExcessiveMotion
        case .limited(.insufficientFeatures):
            state = .limitedInsufficientFeatures
        case .limited(.initializing):
            state = .limitedInitializing
        }
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: frame.camera.trackingState)
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else { return }
        updateState(for: frame, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    public func sessionWasInterrupted(_ session: ARSession) {
        state = .interrupted
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        state = .interruptionEnded
        
        let shouldReset = delegate?.bkSceneManager(self, shouldResetSessionFor: state) ?? true
        if shouldReset {
            resetSession()
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        state = .failed(error)
        
        let shouldReset = delegate?.bkSceneManager(self, shouldResetSessionFor: state) ?? true
        if shouldReset {
            resetSession()
        }
    }
}
