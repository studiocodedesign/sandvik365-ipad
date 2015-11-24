//
//  PartServiceContent.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 17/11/15.
//  Copyright © 2015 Commind. All rights reserved.
//

import Foundation
import Fuzi

class PartServiceContent {
    let title: String
    var partsServices: [PartService] = []
    
    init(title: String){
        self.title = title
    }
}

class PartService {
    let title: String
    let description: String
    let productTagUUIDs: [String]?
    var content: Content? = nil
    var subPartsServices: [SubPartService]? = nil
    
    init(title: String, description: String, productTagUUIDs: [String]?){
        self.title = title
        self.description = description
        self.productTagUUIDs = productTagUUIDs
    }
}

class SubPartService {
    let title: String
    let content: Content
    let productTagUUIDs: [String]?
    
    init(title: String, content: NSDictionary, productTagUUIDs: [String]?){
        self.title = title
        self.content = Content(content: content)
        self.productTagUUIDs = productTagUUIDs
    }
    
}

class Content {
    var title: String? = nil
    var subtitle: String? = nil
    var contentList: [AnyObject] = []
    var images: [NSURL] = []
    
    init(content: NSDictionary){
        if let title = content.objectForKey("title") as? String {
            self.title = title.stripHTML()
            if let subtitle = content.objectForKey("subTitle") as? String {
                self.subtitle = subtitle.stripHTML()
            }
        }
        if let html = content.objectForKey("content") as? [NSDictionary] {
            for part in html {
                if let type = part.objectForKey("type") as? String {
                    if type == "lead", let value = part.objectForKey("value") as? [NSDictionary] {
                        contentList.append(Lead(content: value))
                    }
                    else if type == "body", let value = part.objectForKey("value") as? [NSDictionary] {
                        contentList.append(Body(content: value))
                    }
                    else if type == "key-feature-list", let value = part.objectForKey("value") as? NSDictionary {
                        contentList.append(KeyFeatureListContent(content: value))
                    }
                    else if type == "columns", let value = part.objectForKey("value") as? [NSDictionary] {
                        contentList.append(CountOnBoxContent(content: value))
                    }
                    else if type == "tabbed-content", let value = part.objectForKey("value") as? NSDictionary {
                        contentList.append(TabbedContent(content: value))
                    }
                }
            }
        }
        
        if let images = content.objectForKey("images") as? NSDictionary, let heroImage = images.objectForKey("hero") as? String {
            if let imageUrl = NSURL(string: heroImage) {
                self.images.append(imageUrl)
            }
        }
    }
    
    class CountOnBoxContent {
        var title: String? = nil
        var topText: String? = nil
        var midText: String? = nil
        var bottomText: String? = nil
        
        init(content: [NSDictionary]){
            for part in content {
                if let type = part.objectForKey("type") as? String {
                    if type.caseInsensitiveCompare("body") == .OrderedSame, let title = part.objectForKey("value") as? String {
                        self.title = title.stripHTML()
                    }
                    else if type.caseInsensitiveCompare("content") == .OrderedSame, let countonList  = part.objectForKey("value") as? [NSDictionary] {
                        for counton in countonList {
                            if let value = counton.objectForKey("value") as? NSDictionary {
                                if let config = value.objectForKey("config") as? NSDictionary {
                                    if let columns = config.objectForKey("columns") as? [NSDictionary] {
                                        //print("columns count", columns.count) //can it be more than one?
                                        if let rows = columns.first?.objectForKey("rows") as? [NSDictionary] {
                                            setTexts(rows)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        private func setTexts(rows: [NSDictionary]) {
            if rows.count == 3 {
                self.topText = textFromObj(rows[0])
                self.midText = textFromObj(rows[1])
                self.bottomText = textFromObj(rows[2])
            }
            else if rows.count == 2 {
                //check which should be where
                let firstSize = rows[0].objectForKey("size") as? Int
                let nextSize = rows[1].objectForKey("size") as? Int
                if nextSize >= firstSize {
                    self.topText = textFromObj(rows[0])
                    self.midText = textFromObj(rows[1])
                }
                else {
                    self.midText = textFromObj(rows[0])
                    self.bottomText = textFromObj(rows[1])
                }
            }
            else if rows.count == 1 {
                self.midText = textFromObj(rows[0])
            }
        }
        
        private func textFromObj(obj: NSDictionary) -> String? {
            if let string = obj.objectForKey("text") as? String {
                return string.stripHTML()
            }
            return nil
        }
    }
    
    class KeyFeatureListContent {
        var title: String? = nil
        var texts: [TitleAndText]? = nil
        
        init(content: NSDictionary) {
            if let title = content.objectForKey("title") as? String {
                self.title = title.stripHTML()
            }
            if let featureList = content.objectForKey("config") as? [String] {
                self.texts = []
                for feature in featureList {
                    do {
                        let doc = try HTMLDocument(string: feature)
                        let title = doc.firstChild(xpath: "//p/strong")?.stringValue
                        let text = doc.firstChild(xpath: "//following-sibling::text()[normalize-space()]")?.stringValue
                        if title != nil && text != nil {
                            self.texts!.append(TitleAndText(title: title!, text: text!))
                        }
                    } catch {
                        print("failed to parse html")
                    }
                }
            }
        }
    }
    
    class TabbedContent {
        var tabs: [TitleAndText]? = nil
        
        init(content: NSDictionary) {
            if let tabs = content.objectForKey("config") as? [NSDictionary] {
                self.tabs = []
                for tab in tabs {
                    if let title = tab.objectForKey("text") as? String {
                        if let content = tab.objectForKey("content") as? [NSDictionary] {
                            var string: String = ""
                            for text in content {
                                if let t = text.objectForKey("text") as? String {
                                    string += t
                                    //TODO can it loop ?
                                }
                            }
                            self.tabs!.append(TitleAndText(title: title, text: string))
                        }
                    }
                }
            }
        }
    }
    
    class Lead {
        let titleOrTextOrList: [TitleTextOrList]
        
        init(content: [NSDictionary]) {
            self.titleOrTextOrList = Content.parseTitleTextList(content)
        }
    }
    
    class Body {
        let titleOrTextOrList: [TitleTextOrList]
        init(content: [NSDictionary]) {
            self.titleOrTextOrList = Content.parseTitleTextList(content)
        }
    }
    
    private static func parseTitleTextList(content: [NSDictionary]) -> [TitleTextOrList] {
        var titleOrTextOrList: [TitleTextOrList] = []
        for part in content {
            if let type = part.objectForKey("element") as? String {
                if type == "p", let value = part.objectForKey("html") as? String {
                    titleOrTextOrList.append(.Text(value.stripHTML()))
                }
                else if ["h1", "h2", "h3", "h4", "h5", "h6"].contains(type), let value = part.objectForKey("html") as? String {
                    titleOrTextOrList.append(.Title(value.stripHTML()))
                }
                else if type == "ul", let value = part.objectForKey("items") as? [String] {
                    var titleText = [TitleAndText]()
                    for string in value {
                        do {
                            let doc = try HTMLDocument(string: string)
                            let title = doc.firstChild(xpath: "//em")?.stringValue
                            var text: String? = nil
                            if title != nil {
                                text = doc.firstChild(xpath: "//following-sibling::text()[normalize-space()]")?.stringValue
                            }
                            else {
                                text = doc.firstChild(xpath: "//text()")?.stringValue
                            }
                            if text != nil {
                                titleText.append(TitleAndText(title: title, text: text!))
                            }
                        } catch {
                            print("failed to parse list html")
                        }
                    }
                    if titleText.count > 0 {
                        titleOrTextOrList.append(.List(titleText))
                    }
                }
            }
        }
        return titleOrTextOrList
    }
    
    enum TitleTextOrList {
        case Title(String)
        case Text(String)
        case List([TitleAndText])
    }
    
    class TitleAndText {
        var title: String? = nil
        var text: String? = nil
        
        init(title: String?, text: String){
            if title != nil {
                self.title = title!.stripHTML()
            }
            self.text = text.stripHTML()
        }
    }
}
