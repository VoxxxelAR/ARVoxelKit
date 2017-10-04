//
// ARVoxelKitTests.swift
//  ARVoxelKitTests
//
//  Created by Gleb Radchenko on 9/26/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit
import XCTest
@testable import ARVoxelKit

class ARBoxKitTests: XCTestCase {
    var manager: VKSceneManager!
    
    override func setUp() {
        super.setUp()
        manager = VKSceneManager(with: ARSCNView())
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //MARK: - VKSceneManager tests
    func testNewNodeCalculation() {
        let node = VKVoxelNode(sideLength: 1)
        node.position = .zero
        
        let newNode = VKVoxelNode(sideLength: 1)
        
        VKVoxelFace.all.forEach { (face) in
            let position = manager.newPosition(for: newNode, attachedTo: face, of: node)
            XCTAssertEqual(position, face.normalizedVector3)
        }
    }
    
    func testSynchronizedQueue() {
        let e = expectation(description: "Adding to queue async")
        
        let queue = VKSynchronizedQueue<Int>()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 12) {
            if queue.count == 400 {
                e.fulfill()
            } else {
                XCTAssert(false, "Wrong queue count: \(queue.count)")
            }
        }
        
        DispatchQueue.concurrentPerform(iterations: 20) { (i) in
            DispatchQueue.concurrentPerform(iterations: 20) { (j) in
                queue.enqueue(j)
            }
        }
        
        waitForExpectations(timeout: 20) { (error) in
            XCTAssertNil(error, error?.localizedDescription ?? "")
        }
    }
    
    func testSynchronizedStack() {
        let e = expectation(description: "Adding to stack async")
        
        let stack = VKSynchronizedStack<Int>()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 12) {
            if stack.count == 400 {
                e.fulfill()
            } else {
                XCTAssert(false, "Wrong queue count: \(stack.count)")
            }
        }
        
        DispatchQueue.concurrentPerform(iterations: 400) { (j) in
            stack.push(j)
        }
        
        waitForExpectations(timeout: 20) { (error) in
            XCTAssertNil(error, error?.localizedDescription ?? "")
        }
    }
}
