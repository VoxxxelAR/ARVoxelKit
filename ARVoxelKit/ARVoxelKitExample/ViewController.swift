//
//  ViewController.swift
//  ARVoxelKitExample
//
//  Created by Gleb Radchenko on 10/4/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import ARVoxelKit

open class ViewController: UIViewController {
    
    let pinchScalingFactor: CGFloat = 0.1
    let minPlatformScale = SCNVector3(0.4, 0.4, 0.4)
    let maxPlatformScale = SCNVector3(6.0, 6.0, 6.0)
    
    let rotationFactor: CGFloat = 1.0
    
    @IBOutlet open var sceneView: ARSCNView! {
        didSet { sceneManager = VKSceneManager(with: sceneView) }
    }
    
    weak var statusView: UIView?
    weak var statusLabel: UILabel?
    
    var sceneManager: VKSceneManager!
    var lastPlatformScale = SCNVector3(1, 1, 1)
    var lastPlatformEulerAngles = SCNVector3(0, 0, 0)
    
    var focusedNode: VKDisplayable?
    var focusedFace: VKVoxelFace?
    var cursorVoxel: VKVoxelNode?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.delegate = self
        addStatusLabel()
        
        setupGestures()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        view.addGestureRecognizer(tap)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        view.addGestureRecognizer(pinch)
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(gesture:)))
        view.addGestureRecognizer(rotation)
        
        pinch.delegate = self
        rotation.delegate = self
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sceneManager?.launchSession()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneManager?.pauseSession()
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        guard let sceneManager = sceneManager else { return }
        guard let focusedNode = focusedNode else { return }
        
        if let surface = focusedNode as? VKPlatformNode {
            sceneManager.setSelected(surface: surface)
            surface.apply(.transparency(value: 0), animated: true)
            return
        }
        
        if gesture.location(in: view).x < view.bounds.midX {
            removeVoxel()
        } else {
            addVoxel()
        }
    }
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard let platformScale = sceneManager.focusContainer.selectedSurface?.scale else {
            print("Trying to perform pinch when platform not selected.")
            return
        }
        
        let gestureScale = Float(gesture.scale * ((gesture.scale - 1.0) * pinchScalingFactor + 1.0))
        var newPlatformScale = lastPlatformScale * gestureScale
        
        newPlatformScale = max(newPlatformScale, minPlatformScale)
        newPlatformScale = min(newPlatformScale, maxPlatformScale)
        
        switch gesture.state {
        case .began:
            lastPlatformScale = platformScale
        case .changed:
            sceneManager.focusContainer.selectedSurface?.scale = newPlatformScale
        default:
            lastPlatformScale = newPlatformScale
        }
    }
    
    @objc func handleRotation(gesture: UIRotationGestureRecognizer) {
        guard let platformEulerAngles = sceneManager.focusContainer.selectedSurface?.eulerAngles else {
            print("Trying to perform rotation when platform not selected.")
            return
        }
        
        let gestureRotation = Float(gesture.rotation * rotationFactor)
        var newPlatformEulerAngles = lastPlatformEulerAngles
        newPlatformEulerAngles.y -= gestureRotation
        
        switch gesture.state {
        case .began:
            lastPlatformEulerAngles = platformEulerAngles
        case .changed:
            sceneManager.focusContainer.selectedSurface?.eulerAngles = newPlatformEulerAngles
        default:
            lastPlatformEulerAngles = newPlatformEulerAngles
        }
    }
    
    func addVoxel() {
        guard let voxel = cursorVoxel else { return }
        
        cursorVoxel = nil
        voxel.apply([.color(content: VKConstants.defaultFaceColor), .transparency(value: 1)], animated: true)
        voxel.isInstalled = true
    }
    
    func removeVoxel() {
        guard let focusedVoxel = focusedNode as? VKVoxelNode else { return }
        focusedNode = nil
        
        focusedVoxel.apply(.transparency(value: 0), animated: true) {
            self.sceneManager.remove(focusedVoxel)
        }
        
        removeCursorVoxel()
    }
    
    func removeCursorVoxel() {
        guard let currentCursor = cursorVoxel else { return }
        cursorVoxel = nil
        
        currentCursor.removeFromParentNode()
    }
}

extension ViewController: VKSceneManagerDelegate {
    public func vkSceneManager(_ manager: VKSceneManager, didFocus node: VKDisplayable, face: VKVoxelFace) {
        
        focusedNode = node
        focusedFace = face
        
        if let surface = node as? VKPlatformNode {
            surface.apply(.transparency(value: 1), animated: true)
        } else if let tile = node as? VKTileNode {
            let prototype = VKVoxelNode(color: .white)
            prototype.isInstalled = false
            
            prototype.apply(.transparency(value: 0.4), animated: false)
            manager.add(new: prototype, to: tile)
            
            cursorVoxel = prototype
        } else if let voxel = node as? VKVoxelNode {
            let propotype = VKVoxelNode(color: .white)
            propotype.isInstalled = false
            
            propotype.apply(.transparency(value: 0.4), animated: false)
            manager.add(new: propotype, to: voxel, face: face)
            
            cursorVoxel = propotype
        }
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didDefocus node: VKDisplayable?) {
        focusedNode = nil
        focusedFace = nil
        
        if let surface = node as? VKPlatformNode {
            surface.apply(.transparency(value: 0.5), animated: true, completion: nil)
        }
        
        removeCursorVoxel()
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didUpdateState state: VKARSessionState) {
        statusLabel?.text = state.hint
        statusView?.isHidden = state.hint.isEmpty
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, countOfVoxelsIn scene: ARSCNView) -> Int {
        return 0
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, voxelFor index: Int) -> VKVoxelNode {
        return VKVoxelNode()
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - UI Setuping
extension ViewController {
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

