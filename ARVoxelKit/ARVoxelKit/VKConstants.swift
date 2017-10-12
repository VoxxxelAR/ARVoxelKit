//
//  VKConstants.swift
//  ARVoxelKit
//
//  Created by Gleb Radchenko on 9/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

public struct VKConstants {
    public static var debug: Bool = true
    public static var voxelSideLength: CGFloat = 0.025
    
    public static var maxSurfaceWidth: CGFloat = 0.4
    public static var maxSurfaceLength: CGFloat = 0.4
    
    public static let defaultFaceColor = UIColor(red: 221 / 255, green: 73 / 255, blue: 80 / 255, alpha: 1)
    public static let defaultTileColor = UIColor(red: 85 / 255, green: 85 / 255, blue: 85 / 255, alpha: 1)
    public static let defaultPlatformColor = UIColor(red: 85 / 255, green: 85 / 255, blue: 85 / 255, alpha: 1)
    
    public static var defaultAnimationDuration: TimeInterval = 0.25
}
