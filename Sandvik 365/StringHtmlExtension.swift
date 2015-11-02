//
//  StringHtmlExtension.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 01/11/15.
//  Copyright © 2015 Commind. All rights reserved.
//

import Foundation

extension String {
    
    func stringBetweenStrongTag() -> String? {
        if let range = self.rangeOfString("(?i)(?<=<strong>)[^.]+(?=</strong>)", options:.RegularExpressionSearch) {
            return self.substringWithRange(range)
        }
        return nil
    }
    
    func stripHTML() -> String {
        return self.stringByReplacingOccurrencesOfString("<[^>]+>|&nbsp;", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }

}