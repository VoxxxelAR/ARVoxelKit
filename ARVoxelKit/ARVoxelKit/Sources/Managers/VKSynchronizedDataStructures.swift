//
//  VKSynchronizedDataStructures.swift
//  ARVoxelKit
//
//  Created by Gleb on 10/3/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

public class VKSynchronizedContainer<T> {
    internal var queue = DispatchQueue(label: "vk-thread-safe-container", attributes: .concurrent)
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

public class VKSynchronizedQueue<T>: VKSynchronizedContainer<T> {
    
    public func enqueue(_ element: T) {
        queue.async(flags: .barrier) {
            self.container.append(element)
        }
    }
    
    public func enqueue(_ elements: [T], clear: Bool = true) {
        queue.async(flags: .barrier) {
            if clear {
                self.container = elements
            } else {
                self.container.append(contentsOf: elements)
            }
        }
    }
    
    public func dequeue() -> T? {
        var element: T?
        if self.container.isEmpty { return nil }
        queue.sync {
            if self.container.isEmpty { return }
            element = self.container.removeFirst()
        }
        return element
    }
    
    public func dequeue(_ count: Int) -> [T] {
        return (0..<count).flatMap { _ in dequeue() }
    }
}

public class VKSynchronizedStack<T>: VKSynchronizedContainer<T> {
    
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
        queue.sync { element = self.container.popLast() }
        return element
    }
    
    public func pop(_ count: Int) -> [T] {
        return (0..<count).flatMap { _ in pop() }
    }
}

public class VKSynchronizedTable<T: Hashable> {
    internal var queue = DispatchQueue(label: "vk-thread-safe-table", attributes: .concurrent)
    internal var checkQueue = DispatchQueue(label: "vk-thread-safe-table-check-queue", attributes: .concurrent)
    
    var operationQueue = OperationQueue()
    
    var set: Set<T> = Set<T>()
    
    
    init() {
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    func append(_ elements: [T]) {
        operationQueue.addOperation {
            self.queue.sync { self.set = Set<T>(elements) }
        }
    }
    
    func receive(_ count: Int) -> [T] {
        return (0..<count).flatMap { _ in receive() }
    }
    
    func receive() -> T? {
        var value: T?
        queue.sync { value = set.popFirst() }
        return value
    }
}

