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
    var startUrl: URL!
    var numberOfThreads: Int = 0
    var textToFind: String = ""
    var maxUrlCount: Int = 5
    
    var arrayLinks: [String] = []
    
    var urlSet: Set<String> = []
    var resultArray: [String] = []
    
    let parseManager = ParseManager.init()
    
    
    var arrayTableItems: [TableItem] = [] {
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
    
    func start() {
        
        guard textToFind != "" && startUrl != nil else {
            return
        }
        
        arrayLinks.append(startUrl.absoluteString)
        var counter = 0
        while counter != maxUrlCount || arrayLinks.count == 0  {
            counter += 1
            let url = arrayLinks.removeFirst()
            if !urlSet.contains(url) {
                urlSet.insert(url)
                resultArray.append(url)
                if let urlCurrent = parseManager.getDataFromUrl(url) {
                    var scanState: ScanState = .inProgress
                    
                    if parseManager.findTextOnPage(textToFind, urlCurrent) {
                        scanState = .finishedScanning(true)
                    } else if !parseManager.findTextOnPage(textToFind, urlCurrent) {
                        scanState = .finishedScanning(false)
                    } else {
                        scanState = .notStartedScanning
                    }
                    
                    let oneTableItem: TableItem = TableItem(nameUrl: url, stateUrl: scanState)
                    
                    arrayTableItems.append(oneTableItem)
                    arrayLinks.append(contentsOf: parseManager.findUrlsInString(urlCurrent))
                }
                print(counter)
                print(arrayLinks.count)
            }
        }
    }
}

