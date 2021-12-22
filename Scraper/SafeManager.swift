//
//  SafeManager.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 19.12.2021.
//

import Foundation
import UIKit

class SafeManager {
    
    private var arrayLinks: [String] = []
    
    private let safeQueue = DispatchQueue(label: "ThreadSafeCollection.queue", attributes: .concurrent)
    init() {}
    
    private var arrayLinksLock = NSLock()
    func arrayLinksRemoveFirst() -> String? {
        let link: String?
        arrayLinksLock.lock()
        if arrayLinks.count == 0 {
            link = nil
        } else {
            link = arrayLinks.removeFirst()
        }
        arrayLinksLock.unlock()
        return link
    }
    func arrayLinksAppend(contentsOf array: [String]) {
        safeQueue.async(flags: .barrier) {
            self.arrayLinks.append(contentsOf: array)
        }
    }
    func arrayLinksAppend(_ element: String) {
        safeQueue.async(flags: .barrier) {
            self.arrayLinks.append(element)
        }
    }
    var arrayLinksCount: Int {
        return safeQueue.sync {
            arrayLinks.count
        }
    }
    
    private var urlSet: Set<String> = []
    func urlSetInsert(_ url: String) {
        safeQueue.async(flags: .barrier) {
            self.urlSet.insert(url)
        }
    }
    func urlSetContains(_ member: String) -> Bool {
        return safeQueue.sync {
            urlSet.contains(member)
        }
    }
    
    /// Counts active threads
    private var blockCounter: Int = 0
    func increment() {
        safeQueue.async(flags: .barrier) { [self] in
            blockCounter += 1
            print("increment \(blockCounter)")
        }
    }
    func decrement() {
        safeQueue.async(flags: .barrier) { [self] in
            blockCounter -= 1
            print("decrement \(blockCounter)")
        }
    }
    var safeBlockCounter: Int {
        return safeQueue.sync {
            blockCounter
        }
    }
    
    private var shouldStopMyFunction: Bool = false
    func stopFunction() {
        safeQueue.async(flags: .barrier) {
            self.shouldStopMyFunction = true
        }
    }
    var stopFunctionVar: Bool {
        return safeQueue.sync {
            shouldStopMyFunction
        }
    }
}
