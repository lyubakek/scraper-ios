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
    private var startUrl: URL!
    private var numberOfThreads: Int = 0
    private var textToFind: String = ""
    private var maxUrlCount: Int = 5
    
    private var arrayLinks: [String] = []
    
    private var arrayLinksLock = NSLock()
    
    func safeArrayLinksRemoveFirst() -> String {
        let link: String
        arrayLinksLock.lock()
        link = arrayLinks.removeFirst()
        arrayLinksLock.unlock()
        return link
    }
    
    func safeArrayLinksAppend(contentsOf array: [String]) {
        arrayLinksLock.lock()
        arrayLinks.append(contentsOf: array)
        arrayLinksLock.unlock()
    }
    
    func safeArrayLinksAppend(_ element: String) {
        arrayLinksLock.lock()
        arrayLinks.append(element)
        arrayLinksLock.unlock()
    }
    
    var safeArrayLinksCount: Int {
        let count: Int
        arrayLinksLock.lock()
        count = arrayLinks.count
        arrayLinksLock.unlock()
        return count
    }
    
    private var urlSet: Set<String> = []
    private var urlSetLock = NSLock()
    
    func safeUrlSetInsert(_ url: String) {
        urlSetLock.lock()
        urlSet.insert(url)
        urlSetLock.unlock()
    }
    
    func safeUrlSetContains(_ member: String) -> Bool {
        let contains: Bool
        urlSetLock.lock()
        contains = urlSet.contains(member)
        urlSetLock.unlock()
        return contains
    }
    
    let parseManager = ParseManager.init()
    
    //    let operationQueue = OperationQueue()
    
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
    
    func safeAppend(tableItem: TableItem) {
        DispatchQueue.main.async {
            self.arrayTableItems.append(tableItem)
        }
    }
    
    let queue = OperationQueue()
    
    init() {
        queue.maxConcurrentOperationCount = 4
    }
    
    func start() {
        DispatchQueue.global(qos: .default).async {  [self] in
            
            guard textToFind != "" && startUrl != nil else {
                return
            }
            
            safeArrayLinksAppend(startUrl.absoluteString)
            var counter = 0
            
            
            while counter != maxUrlCount || safeArrayLinksCount == 0  {
                counter += 1
                    
                    let url = safeArrayLinksRemoveFirst()
                let blockOperation = BlockOperation {
                    if !safeUrlSetContains(url) {
                        safeUrlSetInsert(url)
                        if let urlCurrent = parseManager.getDataFromUrl(url) {
                            var scanState: ScanState = .inProgress
                            if parseManager.findTextOnPage(textToFind, urlCurrent) {
                                scanState = .finishedScanning(true)
                            } else {
                                scanState = .finishedScanning(false)
                            }
                            let oneTableItem: TableItem = TableItem(nameUrl: url, stateUrl: scanState)
                            safeAppend(tableItem: oneTableItem)
                            safeArrayLinksAppend(contentsOf: parseManager.findUrlsInString(urlCurrent))
                            print("fsdsdfgsfsgf")
                        }
                    }
                    print(counter)
                    print(safeArrayLinksCount)
                }
                queue.addOperation(blockOperation)
            }
        }
    }
}



