//
//  BKSessionState.swift
//  ARBoxKit
//
//  Created by Gleb Radchenko on 9/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

public enum BKARSessionState {
    
    case normal(Bool)
    case normalEmptyAnchors
    case notAvailable
    case limitedExcessiveMotion
    case limitedInsufficientFeatures
    case limitedInitializing
    
    case interrupted
    case interruptionEnded
    case failed(Error)
    
    var isPlatformSelected: Bool {
        switch self {
        case .normal(let selected):
            return selected
        default:
            return false
        }
    }
    
    var configuration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        
        switch self {
        case .normal(let platformSelected):
            if !platformSelected {
                configuration.planeDetection = .horizontal
            }
        default:
            configuration.planeDetection = .horizontal
        }
        
        return configuration
    }
    
    public var hint: String {
        switch self {
        case .normal(let platformSelected):
            return platformSelected ? "" : "Select platform"
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
