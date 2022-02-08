//
//  DetailViewController.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 30.11.2021.
//

import UIKit

class DetailViewController: UIViewController {
        
    @IBOutlet weak var statusUrlLabel: UILabel!
    @IBOutlet weak var linkView: LinkView!
    
    private let tableItem: TableItem

    init?(tableItem: TableItem, title: String = "Link details", coder: NSCoder) {
        self.tableItem = tableItem
        super.init(coder: coder)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        linkView.urlLabel.text = tableItem.nameUrl
        statusUrlLabel.text = tableItem.stateUrl.description
    }
    
    func openUrlButtonTapped() {
        guard let url = URL(string: linkView.urlLabel.text!) else { return }
        UIApplication.shared.open(url)
    }
}
