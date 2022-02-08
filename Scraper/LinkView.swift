//
//  LinkView.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 07.02.2022.
//

import UIKit
 
@IBDesignable
class LinkView: UIView {
    
    @IBOutlet weak var currentLinkNameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var openUrlButton: UIButton!
        
    @IBAction func openUrlButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: urlLabel.text!) else { return }
        UIApplication.shared.open(url)
    }
    
    let nibName = "LinkView"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func setupViews() {
        let xibView = loadViewFromXib()
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
//        return nib.instantiate(withOwner: self, options: nil).first! as! UIView
    }
}
