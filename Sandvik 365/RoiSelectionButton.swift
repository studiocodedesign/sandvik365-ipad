//
//  RoiSelectionButton.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 14/08/15.
//  Copyright (c) 2015 Commind. All rights reserved.
//

import UIKit
import NibDesignable

class RoiSelectionButton: NibDesignable {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var dot: UIImageView!
    @IBOutlet weak var lineHeightConstraint: NSLayoutConstraint!
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSelectionDot()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSelectionDot()
    }
    
    func setSelected(index: Int, text: String) {
        button.hidden = false
        label.hidden = false
        if index % 2 == 0 {
            lineHeightConstraint.constant = 0
        }
        else {
            line.hidden = false
        }
        fillDot()
    }
    
    func setUnselected() {
        dot.backgroundColor = UIColor.clearColor()
    }
    
    private func setupSelectionDot() {
        dot.layer.cornerRadius = dot.bounds.width/2
        dot.layer.masksToBounds = true
        dot.layer.borderColor = UIColor(red: 0.082, green:0.678, blue:0.929, alpha:1.000).CGColor
        dot.layer.borderWidth = 2
    }
    
    private func fillDot() {
        dot.backgroundColor = UIColor(red: 0.082, green:0.678, blue:0.929, alpha:1.000)
    }
}
