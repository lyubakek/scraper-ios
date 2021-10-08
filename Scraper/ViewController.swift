//
//  ViewController.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 07.10.2021.
//

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
    
    let cellReuseIdentifier = "cell"
    
    var urlArrayTest: [String] = ["https://example.com", "https://example.com/1", "https://example.com/2", "https://example.com/3", "https://example.com/4"]
    
    var baseUrl: URL!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        startUrlTextField.delegate = self
        threadCountTextField.delegate = self
        textResultTextField.delegate = self
        maxUrlCoutTextField.delegate = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urlArrayTest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as UITableViewCell?)!
        
        cell.textLabel?.text = self.urlArrayTest[indexPath.row]
        
        return cell
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        print(#function)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        return true
    }

    func startButtonTapped() {
        startButton.isEnabled = false
        print(#function)
    }
    
    func stopButtonTapped() {
        stopButton.isEnabled = false
        print(#function)
    }
    
    func pauseButtonTapped() {
        pauseButton.isEnabled = false
        print(#function)
    }

}

