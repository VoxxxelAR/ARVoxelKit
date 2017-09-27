//
//  ARBoxKitTests.swift
//  ARBoxKitTests
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit
import XCTest
@testable import ARBoxKit

class ARBoxKitTests: XCTestCase {
    var manager: BKSceneManager!
    
    override func setUp() {
        super.setUp()
        manager = BKSceneManager(with: ARSCNView())
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //MARK: - BKSceneManager tests
    func testNewNodeCalculation() {
        let node = BKBoxNode(sideLength: 1)
        node.position = .zero
        
        let newNode = BKBoxNode(sideLength: 1)
        
        BKBoxFace.all.forEach { (face) in
            let position = manager.newPosition(for: newNode, attachedTo: face, of: node)
            XCTAssertEqual(position, face.normalizedVector3)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
