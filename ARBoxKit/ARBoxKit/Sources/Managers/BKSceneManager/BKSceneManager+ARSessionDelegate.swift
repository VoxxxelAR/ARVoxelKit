//
//  BKSceneManager+ARSessionDelegate.swift
//  ARBoxKit
//
//  Created by Vadym Sidorov on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

//MARK: - ARSessionDelegate
extension BKSceneManager: ARSessionDelegate {
    func updateState(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        switch trackingState {
        case .normal
            where frame.anchors.isEmpty:
            state = .normalEmptyAnchors
        case .normal:
            state = .normal(focusContainer.selectedPlatform != nil)
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
            updateSession()
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        state = .failed(error)
        
        let shouldReset = delegate?.bkSceneManager(self, shouldResetSessionFor: state) ?? true
        if shouldReset {
            updateSession()
        }
    }
}
