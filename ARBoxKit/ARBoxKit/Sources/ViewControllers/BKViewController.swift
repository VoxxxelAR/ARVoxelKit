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

public enum BKPointerState {
    case empty
    case focused(platform: BKPlatformNode)
    case selected(platform: BKPlatformNode, anchor: ARPlaneAnchor)
}

open class BKViewController: UIViewController {
    @IBOutlet open var sceneView: ARSCNView!
    
    weak var statusView: UIView?
    weak var statusLabel: UILabel?
    
    var sceneManager: BKSceneManager?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager = BKSceneManager(with: sceneView)
        sceneManager?.delegate = self
        setupUI()
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
}

extension BKViewController: BKSceneManagerDelegate {
    public func bkSceneManager(_ manager: BKSceneManager, boxFor index: Int) -> BKBoxNode {
        return BKBoxNode(sideLength: 1)
    }
    
    public func bkSceneManager(_ manager: BKSceneManager, stateUpdated newState: BKARSessionState) {
        print(newState)
        statusLabel?.text = newState.hint
        statusView?.isHidden = newState.hint.isEmpty
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



