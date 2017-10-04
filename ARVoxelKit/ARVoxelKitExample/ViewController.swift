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
    
    @IBOutlet open var sceneView: ARSCNView! {
        didSet { sceneManager = VKSceneManager(with: sceneView) }
    }
    
    weak var statusView: UIView?
    weak var statusLabel: UILabel?
    
    var sceneManager: VKSceneManager!
    
    var focusedNode: VKVoxelDisplayable?
    var focusedFace: VKVoxelFace?
    var addingVoxel: VKVoxelNode?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.delegate = self
        addStatusLabel()
        
        setupGestures()
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        view.addGestureRecognizer(tap)
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
        
        if let surface = focusedNode as? VKSurfaceNode {
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
    
    func addVoxel() {
        guard let voxel = addingVoxel else { return }
        
        addingVoxel = nil
        voxel.apply([.color(content: VKConstants.defaultFaceColor), .transparency(value: 1)], animated: true)
        voxel.isInstalled = true
    }
    
    func removeVoxel() {
        guard let focusedVoxel = focusedNode as? VKVoxelNode else { return }
        focusedNode = nil
        
        focusedVoxel.apply(.transparency(value: 0), animated: true) {
            self.sceneManager.remove(focusedVoxel)
        }
        
        guard let addingVoxel = addingVoxel else { return }
        self.addingVoxel = nil
        
        addingVoxel.apply(.transparency(value: 0), animated: true) {
            addingVoxel.removeFromParentNode()
        }
    }
}

extension ViewController: VKSceneManagerDelegate {
    public func vkSceneManager(_ manager: VKSceneManager, didUpdateState state: VKARSessionState) {
        print(state)
        statusLabel?.text = state.hint
        statusView?.isHidden = state.hint.isEmpty
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didFocus surface: VKSurfaceNode, face: VKVoxelFace) {
        focusedNode = surface
        focusedFace = face
        
        surface.apply(.transparency(value: 1), animated: true)
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didDefocus surface: VKSurfaceNode?) {
        guard let node = focusedNode else { return }
        
        node.apply(.transparency(value: 0.5), animated: true)
        
        focusedNode = nil
        focusedFace = nil
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didFocus voxel: VKVoxelNode, face: VKVoxelFace) {
        focusedNode = voxel
        focusedFace = face
        
        let propotype = VKVoxelNode(color: .white)
        propotype.isInstalled = false
        
        propotype.apply(.transparency(value: 0.4), animated: false)
        manager.add(new: propotype, to: voxel, face: face)
        
        self.addingVoxel = propotype
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, didDefocus voxel: VKVoxelNode?) {
        focusedNode = nil
        focusedFace = nil
        
        guard let voxel = addingVoxel else { return }
        addingVoxel = nil
        
        voxel.apply(.transparency(value: 0), animated: true) {
            voxel.removeFromParentNode()
        }
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, countOfVoxelsIn scene: ARSCNView) -> Int {
        return 0
    }
    
    public func vkSceneManager(_ manager: VKSceneManager, voxelFor index: Int) -> VKVoxelNode {
        return VKVoxelNode()
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

