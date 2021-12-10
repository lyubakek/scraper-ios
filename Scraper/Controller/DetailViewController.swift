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
    @IBOutlet weak var openUrlButton: UIButton!
    
    var tableItem: TableItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Link details"

        urlLabel.text = tableItem.nameUrl
        statusUrlLabel.text = tableItem.stateUrl.description
    }
    
    @IBAction func openUrlButtonTapped(_ sender: Any) {
        guard let url = URL(string: urlLabel.text!) else { return }
        UIApplication.shared.open(url)
    }
}
