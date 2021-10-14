//
//  ViewController.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 07.10.2021.
//
//    ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=
//    var allowedSymbols = [ "A","B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", ".", "_", "~", ":", "/", "?", "#", "[", "]", "@", "!", "$", "&", "(", ")", "*", "+", ",", ";", "=", "'"]


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
    @IBOutlet weak var maxUrlCoutTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let parseManager = ParseManager.init()
    
    var startUrl: URL!
    
    let cellReuseIdentifier = "cell"
    
    var urlArrayTest: [String] = ["https://example.com", "https://example.com/1", "https://example.com/2", "https://example.com/3", "https://example.com/4https://example.com/4"]
    
    
    var arrayLinks: [String] = []
    
    var baseUrl: URL!
    var threadCount: Int!
    var textResult: String!
    var maxUrlCount: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        startButton.isEnabled = false
        
        startUrlTextField.delegate = self
        threadCountTextField.delegate = self
        textResultTextField.delegate = self
        maxUrlCoutTextField.delegate = self
        
        startUrlTextField.text = "https://lun.ua/"
        threadCountTextField.text = "5"
        textResultTextField.text = "dog"
        maxUrlCoutTextField.text = "10"
        
        //        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ResultTableViewCell
        
        cell.urlLabel.text = self.resultArray[indexPath.row]
        cell.statusLabel.text = "OK"
        
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
        } else if textField == maxUrlCoutTextField {
            var urlCount = textField.text! as NSString
            urlCount = urlCount.replacingCharacters(in: range, with: string) as NSString
            print(urlCount)
        }
        
        if startUrlTextField != nil && threadCountTextField != nil && textResultTextField != nil && maxUrlCoutTextField != nil {
            startButton.isEnabled = true
        }
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == startUrlTextField {
            startUrl = URL(string: textField.text!)
            print("this is a start url " + "\(startUrl as Any)")
        } else if textField == threadCountTextField {
            threadCount = Int(textField.text!)
            print("this is how many threads can be " + "\(threadCount as Any)")
        } else if textField == textResultTextField {
            textResult = String(textField.text!)
            print("this is text to find " + "\(textResult as Any)")
        } else if textField == maxUrlCoutTextField {
            maxUrlCount = Int(textField.text!)
            print("this is url count when we can stop " + "\(maxUrlCount as Any)")
        }
        
        if startUrlTextField != nil && threadCountTextField != nil && textResultTextField != nil && maxUrlCoutTextField != nil {
            startButton.isEnabled = true
        }
        
    }

    
    var urlSet: Set<String> = []
    var resultArray: [String] = []
    var mySet = Set<String>()
    
    var urlArrayQueue: [String] = []
    
    
    
    func checkIfDataIsInSet() {
        
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        pauseButton.isEnabled = true
        print(#function)
        
        guard let textFieldString = startUrlTextField.text, let htmlString = parseManager.getDataFromUrl(textFieldString) else {
            return
        }
        resultArray.append(textFieldString)
        urlSet.insert(textFieldString)
        arrayLinks = parseManager.findUrlsInString(htmlString)
        
        var counter = 1
        while counter != 10 || arrayLinks.count == 0  {
            counter += 1
            let url = arrayLinks.removeFirst()
            if !urlSet.contains(url) {
                urlSet.insert(url)
                resultArray.append(url)
                if let urlCurrent = parseManager.getDataFromUrl(url) {
                    arrayLinks.append(contentsOf: parseManager.findUrlsInString(urlCurrent))
                }
                
                
                print(counter)
                print(arrayLinks.count)
            }
        }
        tableView.reloadData()
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
    
}

