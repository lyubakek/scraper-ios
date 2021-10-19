//
//  ViewController.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 07.10.2021.

import UIKit
import Foundation
import CoreData

@objcMembers
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var startUrlTextField: UITextField!
    @IBOutlet weak var threadCountTextField: UITextField!
    @IBOutlet weak var textResultTextField: UITextField!
    @IBOutlet weak var maxUrlCountTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let parseManager = ParseManager.init()
    
//    var tableItem = TableItem.init(nameUrl: "this is url", stateUrl: true)
        
    let cellReuseIdentifier = "cell"
        
    var arrayLinks: [String] = []
    
    var startUrl: URL!
    var threadCount: Int!
    var textResult: String!
    var maxUrlCount: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        startButton.isEnabled = false
        
        startUrlTextField.delegate = self
        threadCountTextField.delegate = self
        textResultTextField.delegate = self
        maxUrlCountTextField.delegate = self
        
        startUrlTextField.text = "https://lun.ua/"
        threadCountTextField.text = "5"
        textResultTextField.text = "lun"
        maxUrlCountTextField.text = "10"
        
        //        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayTableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ResultTableViewCell
        
        cell.urlLabel.text = self.arrayTableItems[indexPath.row].nameUrl?.description
        //        cell.statusLabel.text = self.tableItem.stateUrl?.description
//        cell.statusLabel.text = self.arrayTableItems[indexPath.row].stateUrl?.description
        
        switch arrayTableItems[indexPath.row].stateUrl {
        case .finishedScanning(let value):
            cell.statusLabel.text = value ? "found" : "not found"
        case .errorScan:
            cell.statusLabel.text = "error"
        case .notStartedScanning:
            cell.statusLabel.text = "not started"
        default:
            cell.statusLabel.text = "in progress"
        }
        
        
        return cell
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(#function)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == startUrlTextField {
            var newTextUrl = textField.text! as NSString
            newTextUrl = newTextUrl.replacingCharacters(in: range, with: string) as NSString
            //            startUrl = URL(string: newTextUrl as String)
            print(newTextUrl)
        } else if textField == threadCountTextField {
            var threads = textField.text! as NSString
            threads = threads.replacingCharacters(in: range, with: string) as NSString
            print(threads)
        } else if textField == textResultTextField {
            var findText = textField.text! as NSString
            findText = findText.replacingCharacters(in: range, with: string) as NSString
            print(findText)
        } else if textField == maxUrlCountTextField {
            var urlCount = textField.text! as NSString
            urlCount = urlCount.replacingCharacters(in: range, with: string) as NSString
            print(urlCount)
        }
        
        if startUrlTextField != nil && threadCountTextField != nil && textResultTextField != nil && maxUrlCountTextField != nil {
            startButton.isEnabled = true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == startUrlTextField, let urlValue = textField.text.flatMap({URL(string: $0)}) {
            startUrl = urlValue
            print("this is a start url " + "\(startUrl as Any)")
        } else if textField == threadCountTextField, let text = textField.text, let intValue = Int(text) {
            threadCount = intValue
            print("this is how many threads can be " + "\(threadCount as Any)")
        } else if textField == textResultTextField, let text = textField.text {
            textResult = text
            print("this is text to find " + "\(textResult as Any)")
        } else if textField == maxUrlCountTextField, let text = textField.text, let intValue = Int(text) {
            maxUrlCount = intValue
            print("this is url count when we can stop " + "\(maxUrlCount as Any)")
        }
        
        if startUrlTextField != nil && threadCountTextField != nil && textResultTextField != nil && maxUrlCountTextField != nil {
            startButton.isEnabled = true
        }
    }
    
    var urlSet: Set<String> = []
    var resultArray: [String] = []
    
    var arrayTableItems: [TableItem] = []

    @IBAction func startButtonTapped(_ sender: Any) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        pauseButton.isEnabled = true
        print(#function)
        
        guard let textFieldString = startUrlTextField.text, let findText = textResultTextField.text else {
            return
        }
        
        //        guard let textFieldString = startUrlTextField.text, let htmlString = parseManager.getDataFromUrl(textFieldString), let findText = textResultTextField.text else {
        //            return
        //        }
        //        resultArray.append(textFieldString)
        //        urlSet.insert(textFieldString)
        //        arrayLinks = parseManager.findUrlsInString(htmlString)
        //        print("max URL count is \(String(describing: maxUrlCount))")
        
        arrayLinks.append(textFieldString)
        var counter = 0
        while counter != maxUrlCount || arrayLinks.count == 0  {
            counter += 1
            let url = arrayLinks.removeFirst()
            if !urlSet.contains(url) {
                urlSet.insert(url)
                resultArray.append(url)
                if let urlCurrent = parseManager.getDataFromUrl(url) {
//                    let oneTableItem: TableItem = TableItem(nameUrl: url, stateUrl: parseManager.findTextOnPage(findText, urlCurrent))
                    var scanState: ScanState = .inProgress

                    if parseManager.findTextOnPage(findText, urlCurrent) {
                        scanState = .finishedScanning(true)
                    } else if !parseManager.findTextOnPage(findText, urlCurrent) {
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
        tableView.reloadData()
        
        for item in arrayTableItems {
            print("\(String(describing: item.nameUrl))")
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        stopButton.isEnabled = false
        startButton.isEnabled = true
        print(#function)
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        pauseButton.isEnabled = false
        startButton.isEnabled = true
        stopButton.isEnabled = true
        print(#function)
    }
    
    @IBAction func clearButtonTapped(_sender: Any) {
        clearAllTextFields()
    }
    
    func clearAllTextFields() {
        startUrlTextField.text = ""
        threadCountTextField.text = ""
        textResultTextField.text = ""
        maxUrlCountTextField.text = ""
    }
}

