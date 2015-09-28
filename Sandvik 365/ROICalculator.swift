//
//  ROICalculator.swift
//  Sandvik 365
//
//  Created by Karl Söderström on 10/08/15.
//  Copyright (c) 2015 Commind. All rights reserved.
//

import Foundation
import UIKit

enum ChangeInput{
    case Increase
    case Decrease
    case Load
}

class ROIInput {
    
    func total() -> Int {
        preconditionFailure("This method must be overridden")
    }
    
    func maxTotal() -> Double {
        preconditionFailure("This method must be overridden")
    }
    
    func originalTotal() -> [Int] {
        preconditionFailure("This method must be overridden")
    }
    
    func calculatedTotal() -> [Int] {
        preconditionFailure("This method must be overridden")
    }
    
    func allTitles() -> [String] {
        preconditionFailure("This method must be overridden")
    }
    
    //TODO CHANGE THIS:
    func changeInput(atIndex :Int, change : ChangeInput) -> NSAttributedString {
        preconditionFailure("This method must be overridden")
    }
    
    func setInput(atIndex :Int, stringValue :String) -> Bool {
        preconditionFailure("This method must be overridden")
    }
    
    func getInputAsString(atIndex :Int) -> String? {
        preconditionFailure("This method must be overridden")
    }
    
    func graphScale() -> CGFloat {
        preconditionFailure("This method must be overridden")
    }
}

class ROICalculator {
    let input: ROIInput
    
    init(input: ROIInput) {
        self.input = input
    }
}