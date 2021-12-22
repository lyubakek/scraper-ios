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
    
    private let safe = SafeManager.init()
    private let parseManager = ParseManager.init()
    
    private(set) var arrayTableItems: [TableItem] = [] {
        didSet {
            delegate?.updateUI()
        }
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
            safe.arrayLinksAppend(startUrl.absoluteString)
            
            var counter = 0
            while counter != maxUrlCount || safe.arrayLinksCount != 0 || safe.safeBlockCounter != 0 {
                if counter >= maxUrlCount {
                    break
                }
                if safe.stopFunctionVar == true {
                    break
                }
                guard let url = safe.arrayLinksRemoveFirst() else { continue }
                counter += 1
                
                let makeOperation = AlgorithmOperation(safe, parseManager, url, textToFind, counter, safeAppend: safeAppend)
                
                safe.decrement()
                queue.addOperation(makeOperation)
            }
        }
    }
    
    func stop() {
        safe.stopFunction()
    }
}

class AlgorithmOperation: Operation {
    
    let safe: SafeManager
    let parseManager: ParseManager
    var url: String
    let textToFind: String
    var counter: Int
    var safeAppend: (TableItem) -> Void
    
    init(_ safe: SafeManager, _ parseManager: ParseManager, _ url: String, _ textToFind: String, _ counter: Int, safeAppend: @escaping (TableItem) -> Void) {
        self.safe = safe
        self.parseManager = parseManager
        self.url = url
        self.textToFind = textToFind
        self.counter = counter
        self.safeAppend = safeAppend
    }
    
    override func main() {
        if isCancelled {
            return
        }
        safe.increment()
        print("This is start blockOperation at \(Thread.current)")
        if !safe.urlSetContains(url) {
            safe.urlSetInsert(url)
            parseManager.getDataFromUrl(url) { (result) in
                switch result {
                case .success(let html):
                    var scanState: ScanState = .inProgress
                    self.safe.arrayLinksAppend(contentsOf: self.parseManager.findUrlsInString(html))
                    
                    if self.parseManager.findTextOnPage(self.textToFind, html) {
                        scanState = .finishedScanning(true)
                    } else {
                        scanState = .finishedScanning(false)
                    }
                    let oneTableItem: TableItem = TableItem(nameUrl: self.url, stateUrl: scanState)
                    self.safeAppend(oneTableItem)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        if isCancelled {
            return
        }
        print(counter)
        print(safe.arrayLinksCount)
    }
}
