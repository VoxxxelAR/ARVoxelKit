//
//  BoxKitViewController.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

public enum BKViewControllerState {
    case sessionInitializing
    case sessionPrepared
    case sessionPaused
    case sessionError(message: String)
    
    case platformSelection
    
    case working
    
    var sessionConfiguration: ARWorldTrackingConfiguration {
        switch self {
        case .working:
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.worldAlignment = .gravityAndHeading
            
            return configuration
        default:
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.worldAlignment = .gravityAndHeading
            
            return configuration
        }
    }
}

public enum BKPlatformState {
    case empty
    case focused(platform: BKPlatformNode)
    case selected(platform: BKPlatformNode, anchor: ARPlaneAnchor)
}

open class BKViewController: UIViewController {
    
    public var platforms: [ARPlaneAnchor: BKPlatformNode] = [:]
    public var state: BKViewControllerState = .sessionInitializing
    public var platformState: BKPlatformState = .empty
    
    @IBOutlet open var sceneView: ARSCNView!
    
    weak var statusView: UIView?
    weak var statusLabel: UILabel?
    
    var session: ARSession {
        return sceneView.session
    }
    
    var updateQueue: DispatchQueue = DispatchQueue(label: "ARBoxKit-scene-update-queue")
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        setupScene()
        setupCamera()
        
        if BKConstants.debug {
            addStatusLabel()
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        launchSession()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        state = .sessionPaused
        session.pause()
    }
    
    func setupUI() {
        
    }
    
    func setupScene() {
        sceneView.delegate = self
        session.delegate = self
        
        sceneView.scene = SCNScene()
        
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                  ARSCNDebugOptions.showFeaturePoints]
    }
    
    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    func launchSession() {
        let configuration = state.sessionConfiguration
        state = .sessionInitializing
        
        session.run(configuration)
        
        switch platformState {
        case .empty, .focused:
            state = .platformSelection
        case .selected:
            state = .working
        }
    }
    
    func resetSession() {
        let configuration = state.sessionConfiguration
        state = .sessionInitializing
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        switch platformState {
        case .empty, .focused:
            state = .platformSelection
        case .selected:
            state = .working
        }
    }
    
    func updateState(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        var message: String = ""
        
        switch platformState {
        case .empty, .focused:
            state = .platformSelection
            message = "Platform selection"
        case .selected:
            state = .working
            message = ""
        }
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            message = "Move the device around to detect horizontal surfaces."
        case .normal:
            break
        case .notAvailable:
            message = "Tracking unavailable."
            state = .sessionError(message: message)
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
        case .limited(.initializing):
            message = "Initializing AR session."
            state = .sessionInitializing
        }
        
        statusLabel?.text = message
        statusView?.isHidden = message.isEmpty
    }
}

//MARK: - Logic
extension BKViewController {
    public func updateFocus() {
        switch state {
        case .platformSelection:
            updatePlatformsFocus()
        case .working:
            return
        default:
            break
        }
    }
}

//MARK: - Box processing
extension BKViewController {
    
}

//MARK: - Tile processing
extension BKViewController {
    
}

//MARK: - Platform processing
extension BKViewController {
    func updatePlatformsFocus() {
        guard let result = sceneView.hitTestNode(from: sceneView.center, nodeType: BKPlatformNode.self) else {
            unhilghlightAllPlatforms()
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
            unhilghlightAllPlatforms(except: platform)
        }
        
        platform.updateState(newState: .highlighted(face: [face], alpha: 0.2), true, nil)
        platformState = .focused(platform: platform)
    }
    
    func unhilghlightAllPlatforms(except node: BKPlatformNode? = nil) {
        platforms.values.forEach { (platform) in
            if platform == node { return }
            platform.updateState(newState: .normal, true, nil)
        }
    }
}

//MARK: - UI Setuping
extension BKViewController {
    func addStatusLabel() {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(view)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont(name: "HelveticeNeue", size: 15)
        label.numberOfLines = 0
        label.text = "Initializing AR session"
        
        view.contentView.addSubview(label)
        
        [view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
         view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
         label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
         label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
         label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
         label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
         label.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
         label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)].forEach { $0.isActive = true }
        
        label.sizeToFit()
        
        statusLabel = label
        statusView = view
    }
}

extension BKViewController: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocus()
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let platform = BKPlatformNode(anchor: planeAnchor)
        
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

extension BKViewController: ARSessionDelegate {
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
        statusLabel?.text = "Session was interrupted"
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        statusLabel?.text = "Session interruption ended"
        resetSession()
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        let message = "Session failed: \(error.localizedDescription)"
        statusLabel?.text = message
        state = .sessionError(message: message)
        resetSession()
    }
}

