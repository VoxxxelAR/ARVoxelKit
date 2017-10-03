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
    @IBOutlet open var sceneView: ARSCNView!
    
    weak var statusView: UIView?
    weak var statusLabel: UILabel?
    
    var sceneManager: BKSceneManager?
    
    var focusedNode: SCNNode?
    var focusedFace: BKVoxelFace?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager = BKSceneManager(with: sceneView)
        sceneManager?.delegate = self
        setupUI()
        
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
    
    func setupUI() {
        if BKConstants.debug {
            addStatusLabel()
        }
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        guard let sceneManager = sceneManager else { return }
        
        if let platform = focusedNode as? BKSurfaceNode {
            sceneManager.setSelected(platform: platform)
        }
        
        if let box = focusedNode as? BKVoxelNode, let face = focusedFace {
            sceneManager.add(new: BKVoxelNode(), to: box, face: face)
        }
    }
}

extension BKViewController: BKSceneManagerDelegate {
    public func bkSceneManager(_ manager: BKSceneManager, didUpdateState state: BKARSessionState) {
        print(state)
        statusLabel?.text = state.hint
        statusView?.isHidden = state.hint.isEmpty
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, didFocus platform: BKSurfaceNode, face: BKVoxelFace) {
        
        focusedNode = platform
        focusedFace = face
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, didDefocus platform: BKSurfaceNode?) {
        focusedNode = nil
        focusedFace = nil
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, didFocus box: BKVoxelNode, face: BKVoxelFace) {
        focusedNode = box
        focusedFace = face
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, didDefocus box: BKVoxelNode?) {
        focusedNode = nil
        focusedFace = nil
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, countOfBoxesIn scene: ARSCNView) -> Int {
        return 0
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, boxFor index: Int) -> BKVoxelNode {
        return BKVoxelNode(sideLength: 1)
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



