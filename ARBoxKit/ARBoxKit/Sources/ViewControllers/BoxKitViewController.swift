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

open class BoxKitViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView! {
        didSet {
            sceneView.delegate = self
            sceneView.session.delegate = self
            
            sceneView.scene = SCNScene()
            
            sceneView.showsStatistics = true
            sceneView.automaticallyUpdatesLighting = true
            sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                      ARSCNDebugOptions.showFeaturePoints]
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        launchSession()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func launchSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        
        sceneView.session.run(configuration)
    }
    
    func resetSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension BoxKitViewController: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-.pi / 2, 1, 0, 0)
        
        planeNode.opacity = 0.1
        
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
}

extension BoxKitViewController: ARSessionDelegate {
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

