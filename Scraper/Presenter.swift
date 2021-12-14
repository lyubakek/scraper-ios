//
//  Presenter.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 23.10.2021.
//

import Foundation

protocol PresenterDelegate: class {
    func updateUI()
}

class Presenter {
    weak var delegate: PresenterDelegate?
    private var startUrl: URL = URL(string: "https://lun.ua/")!
    private var numberOfThreads: Int = 5 {
        didSet {
            queue.maxConcurrentOperationCount = numberOfThreads
        }
    }
    private var textToFind: String = "lun"
    private var maxUrlCount: Int = 50
    private var arrayLinks: [String] = []
    
    //TODO: - Modify lock so it only locks when there are no writing actions. See: Dispatch Barrier
    private var arrayLinksLock = NSLock()
    private func safeArrayLinksRemoveFirst() -> String? {
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
    private func safeArrayLinksAppend(contentsOf array: [String]) {
        arrayLinksLock.lock()
        arrayLinks.append(contentsOf: array)
        arrayLinksLock.unlock()
    }
    private func safeArrayLinksAppend(_ element: String) {
        arrayLinksLock.lock()
        arrayLinks.append(element)
        arrayLinksLock.unlock()
    }
    private var safeArrayLinksCount: Int {
        let count: Int
        arrayLinksLock.lock()
        count = arrayLinks.count
        arrayLinksLock.unlock()
        return count
    }
    
    private var urlSet: Set<String> = []
    private var urlSetLock = NSLock()
    private func safeUrlSetInsert(_ url: String) {
        urlSetLock.lock()
        urlSet.insert(url)
        urlSetLock.unlock()
    }
    private func safeUrlSetContains(_ member: String) -> Bool {
        let contains: Bool
        urlSetLock.lock()
        contains = urlSet.contains(member)
        urlSetLock.unlock()
        return contains
    }
    
    /// Counts active threads
    private var blockCounter: Int = 0
    private var blockCounterLock = NSLock()
    private func safeIncrement() {
        blockCounterLock.lock()
        blockCounter += 1
        print("increment \(blockCounter)")
        blockCounterLock.unlock()
    }
    private func safeDecrement() {
        blockCounterLock.lock()
        blockCounter -= 1
        print("decrement \(blockCounter)")
        blockCounterLock.unlock()
    }
    private var safeBlockCounter: Int {
        let counter: Int
        blockCounterLock.lock()
        counter = blockCounter
        blockCounterLock.unlock()
        return counter
    }
    
    private let parseManager = ParseManager.init()
    private(set) var arrayTableItems: [TableItem] = [] {
        didSet {
            delegate?.updateUI()
        }
    }
    
    func set(numberOfThreads: Int) {
        self.numberOfThreads = numberOfThreads
    }
    func set(stringToFind: String) {
        self.textToFind = stringToFind
    }
    func set(maxUrlCount: Int) {
        self.maxUrlCount = maxUrlCount
    }
    func set(startUrl: URL) {
        self.startUrl = startUrl
    }
    
    private func safeAppend(tableItem: TableItem) {
        DispatchQueue.main.async {
            self.arrayTableItems.append(tableItem)
        }
    }
    
    private let queue = OperationQueue()
    private init() {}
    
    func start() {
        DispatchQueue.global(qos: .default).async {  [self] in
            guard textToFind != "" else {
                return
            }
            safeArrayLinksAppend(startUrl.absoluteString)
            var counter = 0
            while counter != maxUrlCount || safeArrayLinksCount != 0 || safeBlockCounter != 0 {
                if counter >= maxUrlCount {
                    break
                }
                if safeStopFunctionVar == true {
                    break
                }
                guard let url = safeArrayLinksRemoveFirst() else { continue }
                counter += 1
                let blockOperation = BlockOperation {
                    safeIncrement()
                    print("This is start blockOperation at \(Thread.current)")
                    if !safeUrlSetContains(url) {
                        safeUrlSetInsert(url)
                        parseManager.getDataFromUrl(url) { (result) in
                            switch result {
                            case .success(let html):
                                var scanState: ScanState = .inProgress
                                safeArrayLinksAppend(contentsOf: parseManager.findUrlsInString(html))
                                if parseManager.findTextOnPage(textToFind, html) {
                                    scanState = .finishedScanning(true)
                                } else {
                                    scanState = .finishedScanning(false)
                                }
                                let oneTableItem: TableItem = TableItem(nameUrl: url, stateUrl: scanState)
                                safeAppend(tableItem: oneTableItem)
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                    print(counter)
                    print(safeArrayLinksCount)
                }
                blockOperation.completionBlock = { safeDecrement() }
                queue.addOperation(blockOperation)
            }
        }
    }
    
    private var shouldStopMyFunction: Bool = false
    private var shouldStopMyFunctionLock = NSLock()
    
    private func safeStopFunction() {
        shouldStopMyFunctionLock.lock()
        shouldStopMyFunction = true
        shouldStopMyFunctionLock.unlock()
    }
    
    private var safeStopFunctionVar: Bool {
        let stop: Bool
        shouldStopMyFunctionLock.lock()
        stop = shouldStopMyFunction
        shouldStopMyFunctionLock.unlock()
        return stop
    }
    
    func stop() {
        safeStopFunction()
    }
}
