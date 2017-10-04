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
    
    public static var maxSurfaceWidth: CGFloat = 0.5
    public static var maxSurfaceLength: CGFloat = 0.5
    
    public static let defaultFaceColor: UIColor = UIColor(red: 51 / 255, green: 171 / 255, blue: 224 / 255, alpha: 1.0)
    public static var defaultAnimationDuration: TimeInterval = 0.25
}
