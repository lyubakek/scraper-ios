//
//  DetailViewController.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 30.11.2021.
//

import UIKit

class DetailViewController: UIViewController {
        
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var statusUrlLabel: UILabel!
    
    var tableItem: TableItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        urlLabel.text = tableItem.nameUrl
        statusUrlLabel.text = tableItem.stateUrl.description
    }
}
