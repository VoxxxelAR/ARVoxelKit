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

open class BKViewController: UIViewController {
    
    var platforms: [ARPlaneAnchor: BKPlatformNode] = [:]
    
    @IBOutlet open var sceneView: ARSCNView! {
        didSet {
            sceneView.delegate = self
            session.delegate = self
            
            sceneView.scene = SCNScene()
            
            sceneView.showsStatistics = true
            sceneView.automaticallyUpdatesLighting = true
            sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                      ARSCNDebugOptions.showFeaturePoints]
        }
    }
    
    var session: ARSession {
        return sceneView.session
    }
    
    var updateQueue: DispatchQueue = DispatchQueue(label: "ARBoxKit-scene-update-queue")
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        setupCamera()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        launchSession()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
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
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        
        session.run(configuration)
    }
    
    func resetSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension BKViewController: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            
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
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    }
    
    // MARK: - ARSessionObserver
    
    public func sessionWasInterrupted(_ session: ARSession) {
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        resetSession()
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        resetSession()
    }
}

