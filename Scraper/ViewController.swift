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
    
    let presenter = Presenter.init()
            
    static let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.delegate = self
        startButton.isEnabled = false
        stopButton.isEnabled = false
        pauseButton.isEnabled = false
        
        startUrlTextField.delegate = self
        threadCountTextField.delegate = self
        textResultTextField.delegate = self
        maxUrlCountTextField.delegate = self
        
        startUrlTextField.text = "https://lun.ua/"
        threadCountTextField.text = "5"
        textResultTextField.text = "lun"
        maxUrlCountTextField.text = "50"
                
        tableView.delegate = self
        tableView.dataSource = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.arrayTableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellReuseIdentifier, for: indexPath) as! ResultTableViewCell
        cell.urlLabel.text = presenter.arrayTableItems[indexPath.row].nameUrl?.description
        cell.statusLabel.text = presenter.arrayTableItems[indexPath.row].stateUrl.description
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
        
        if startUrlTextField != nil
            && threadCountTextField != nil
            && textResultTextField != nil
            && maxUrlCountTextField != nil {
            startButton.isEnabled = true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == startUrlTextField, let urlValue = textField.text.flatMap({URL(string: $0)}) {
            let startUrl = urlValue
            presenter.set(startUrl: urlValue)
            print("this is a start url " + "\(startUrl as Any)")
        } else if textField == threadCountTextField, let text = textField.text, let intValue = Int(text) {
            let threadCount = intValue
            presenter.set(numberOfThreads: intValue)
            print("this is how many threads can be " + "\(threadCount as Any)")
        } else if textField == textResultTextField, let text = textField.text {
            let textResult = text
            presenter.set(stringToFind: text)
            print("this is text to find " + "\(textResult as Any)")
        } else if textField == maxUrlCountTextField, let text = textField.text, let intValue = Int(text) {
            let maxUrlCount = intValue
            presenter.set(maxUrlCount: intValue)
            print("this is url count when we can stop " + "\(maxUrlCount as Any)")
        }
        
        if startUrlTextField != nil
            && threadCountTextField != nil
            && textResultTextField != nil
            && maxUrlCountTextField != nil {
            startButton.isEnabled = true
        }
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        startUrlTextField.resignFirstResponder()
        textResultTextField.resignFirstResponder()
        threadCountTextField.resignFirstResponder()
        maxUrlCountTextField.resignFirstResponder()
        startButton.isEnabled = false
        stopButton.isEnabled = true
        pauseButton.isEnabled = true
        print(#function)
        
        presenter.start()
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        stopButton.isEnabled = false
        startButton.isEnabled = true
        print(#function)
        
        presenter.stop()
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        pauseButton.isEnabled = false
        startButton.isEnabled = true
        stopButton.isEnabled = true
        print(#function)
        let alert = UIAlertController(title: "Pause Button", message: "Pause is under development.", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.present(alert, animated: true, completion: nil)
        pauseButton.isEnabled = true
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        clearAllTextFields()
    }
    
    func clearAllTextFields() {
        startUrlTextField.text = ""
        threadCountTextField.text = ""
        textResultTextField.text = ""
        maxUrlCountTextField.text = ""
    }
}

extension ViewController: PresenterDelegate {
    func updateUI() {
        tableView.reloadData()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
