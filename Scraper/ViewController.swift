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
    
    var startUrl: URL!
    
    var htmlString: String = " "
    
    let cellReuseIdentifier = "cell"
    
    var urlArrayTest: [String] = ["https://example.com", "https://example.com/1", "https://example.com/2", "https://example.com/3", "https://example.com/4https://example.com/4"]
    
    
    var arrayLinks: [URL] = []
    
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
        
        startUrlTextField.text = "https://stackoverflow.com/"
        threadCountTextField.text = "5"
        textResultTextField.text = "dog"
        maxUrlCoutTextField.text = "25"
        
//        tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayLinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ResultTableViewCell
        
        cell.urlLabel.text = self.arrayLinks[indexPath.row].absoluteString
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
    
    func getDataFromUrl() {
       
        guard  let myURLString = startUrlTextField.text else {
            print("text field is empty")
            return
        }
        
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        urlSet.insert(myURL)
        

        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            htmlString = myHTMLString
            
            print("HTML : \(myHTMLString)")
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func findUrlInString() {
        let input = htmlString
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))

        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            let url = input[range]
            
            if let urlCheck = URL(string: String(url)) {
                arrayLinks.append(urlCheck)
            }
            
            baseUrl = arrayLinks.first
            arrayLinks.removeFirst()
            print("url will be on next row")
            print(url)
        }
        print(arrayLinks)
    }
    
    var urlSet: Set<URL> = []
    var mySet = Set<String>()
    
    var urlArrayQueue: [String] = []

    func checkIfDataIsInSet() {
        
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        pauseButton.isEnabled = true
        print(#function)
        
        getDataFromUrl()
        findUrlInString()
        
        urlSet.insert(startUrl)

        
        
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

