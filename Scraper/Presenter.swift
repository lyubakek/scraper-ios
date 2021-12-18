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
    private let safeQueue = DispatchQueue(label: "ThreadSafeCollection.queue", attributes: .concurrent)
    
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
    
    private var safeArrayLinksCount: Int {
        return safeQueue.sync {
            arrayLinks.count
        }
    }
    
    private var urlSet: Set<String> = []
    private func safeUrlSetInsert(_ url: String) {
        safeQueue.async(flags: .barrier) {
            self.urlSet.insert(url)
        }
    }
    private func safeUrlSetContains(_ member: String) -> Bool {
        return safeQueue.sync {
            urlSet.contains(member)
        }
    }
    
    /// Counts active threads
    private var blockCounter: Int = 0
    private func safeIncrement() {
        safeQueue.async(flags: .barrier) { [self] in
            blockCounter += 1
            print("increment \(blockCounter)")
        }
    }
    private func safeDecrement() {
        safeQueue.async(flags: .barrier) { [self] in
            blockCounter -= 1
            print("decrement \(blockCounter)")
        }
    }
    private var safeBlockCounter: Int {
        return safeQueue.sync {
            blockCounter
        }
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
    init() {}
    
    func start() {
        DispatchQueue.global(qos: .default).async {  [self] in
            guard textToFind != "" else {
                return
            }
            safeQueue.async(flags: .barrier) {
                print("safe append")
                arrayLinks.append(startUrl.absoluteString)
            }
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
                                safeQueue.async(flags: .barrier) {
                                    arrayLinks.append(contentsOf: parseManager.findUrlsInString(html))
                                }
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
    
    private func safeStopFunction() {
        safeQueue.async(flags: .barrier) {
            self.shouldStopMyFunction = true
        }
    }
    
    private var safeStopFunctionVar: Bool {
        return safeQueue.sync {
            shouldStopMyFunction
        }
    }
    
    func stop() {
        safeStopFunction()
    }
}
