//
//  ResultTableViewCell.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 08.10.2021.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
