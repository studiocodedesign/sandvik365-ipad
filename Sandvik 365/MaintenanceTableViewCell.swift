//
//  MaintenanceTableViewCell.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 02/09/16.
//  Copyright © 2016 Commind. All rights reserved.
//

class MaintenanceTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    @IBAction func decreaseAmountAction(sender: UIButton) {
        if var v = (amount.text != nil) ? Int(amount.text!) : 0 {
            v = v - 1
            amount.text = String(max(v, 0))
        }
    }
    
    @IBAction func increaseAmountAction(sender: UIButton) {
        if var v = (amount.text != nil) ? Int(amount.text!) : 0 {
            v = v + 1
            amount.text = String(v)
        }
    }
    
    func configureView(data: MaintenanceOfferData) {
        self.name.text = data.maintenanceServiceKitParent.description
        self.amount.text = String(data.amount)
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        }
        else {
            self.backgroundColor = UIColor.clearColor()
        }
    }
}