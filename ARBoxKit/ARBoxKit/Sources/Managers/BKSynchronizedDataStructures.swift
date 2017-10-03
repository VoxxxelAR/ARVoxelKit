//
//  BKSynchronizedDataStructures.swift
//  ARBoxKit
//
//  Created by Gleb on 10/3/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

public class BKSynchronizedContainer<T> {
    internal var queue = DispatchQueue(label: "bk-thread-safe-queue", attributes: .concurrent)
    internal var container: Array<T> = []
    
    public var count: Int {
        var result = 0
        queue.sync { result = self.container.count }
        return result
    }
    
    public var isEmpty: Bool {
        var result = false
        queue.sync { result = self.container.isEmpty }
        return result
    }
}

public class BKSynchronizedQueue<T>: BKSynchronizedContainer<T> {
    
    public func enqueue(_ element: T) {
        queue.async(flags: .barrier) {
            self.container.append(element)
        }
    }
    
    public func enqueue(_ elements: [T]) {
        queue.async(flags: .barrier) {
            self.container.append(contentsOf: elements)
        }
    }
    
    public func dequeue() -> T? {
        var element: T?
        queue.sync { element = self.container.removeFirst() }
        return element
    }
    
    public func dequeue(_ count: Int) -> [T] {
        return (0..<count).flatMap { _ in dequeue() }
    }
}

public class BKSynchronizedStack<T>: BKSynchronizedContainer<T> {
    
    public func push(_ element: T) {
        queue.async(flags: .barrier) {
            self.container.append(element)
        }
    }
    
    public func push(_ elements: [T]) {
        queue.async(flags: .barrier) {
            self.container.append(contentsOf: elements)
        }
    }
    
    public func pop() -> T? {
        var element: T?
        queue.sync { element = self.container.removeLast() }
        return element
    }
    
    public func pop(_ count: Int) -> [T] {
        return (0..<count).flatMap { _ in pop() }
    }
}

