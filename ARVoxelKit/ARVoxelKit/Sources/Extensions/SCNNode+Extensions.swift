//
//  SCNNode+Extensions.swift
//  ARVoxelKit
//
//  Created by Gleb on 10/12/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import SceneKit

typealias VKRenderingCommand = () -> Void

extension SCNNode {
    func process(_ commands: [VKRenderingCommand], wait duration: TimeInterval = 0.01) {
        var commands = commands
        
        let renderBlock = { (node: SCNNode) in
            guard let command = commands.popLast() else {  return }
            command()
        }
        
        let actions = [SCNAction.wait(duration: duration), SCNAction.run(renderBlock, queue: .main)]
        let sequence = SCNAction.sequence(actions)
        let repeatAction = SCNAction.repeat(sequence, count: commands.count)
        
        runAction(repeatAction)
    }
}
