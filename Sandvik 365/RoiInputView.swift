//
//  RoiNumberView.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 12/08/15.
//  Copyright (c) 2015 Commind. All rights reserved.
//

import UIKit
import NibDesignable

class RoiInputView: NibDesignable, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    func loadNumber(itemIndex: Int, roiInput: ROIInput) {
        self.textField.attributedText = RoiInputView.changeNSAttributedStringFontSize(roiInput.changeInput(itemIndex, change: .Load), fontSize: self.textField.font!.pointSize)
    }
    
    func increaseNumber(itemIndex: Int, roiInput: ROIInput) {
        self.textField.attributedText = RoiInputView.changeNSAttributedStringFontSize(roiInput.changeInput(itemIndex, change: .Increase), fontSize: self.textField.font!.pointSize)
    }
    
    func decreaseNumber(itemIndex: Int, roiInput: ROIInput) {
        self.textField.attributedText = RoiInputView.changeNSAttributedStringFontSize(roiInput.changeInput(itemIndex, change: .Decrease), fontSize: self.textField.font!.pointSize)
    }
    
    static func changeNSAttributedStringFontSize(attrString: NSAttributedString, fontSize: CGFloat) -> NSAttributedString {
        let mutString : NSMutableAttributedString = NSMutableAttributedString(attributedString: attrString);
        mutString.enumerateAttribute(NSFontAttributeName, inRange: NSMakeRange(0, mutString.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (value, range, stop) -> Void in
            if let oldFont = value as? UIFont {
                let newFont = oldFont.fontWithSize(fontSize)
                mutString.removeAttribute(NSFontAttributeName, range: range)
                mutString.addAttribute(NSFontAttributeName, value: newFont, range: range)
            }
        }
        return mutString
    }
}
