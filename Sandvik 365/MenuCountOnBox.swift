//
//  MenuCountOnBox.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 07/01/16.
//  Copyright © 2016 Commind. All rights reserved.
//

import Foundation
import NibDesignable

protocol MenuCountOnBoxDelegate {
    func didTapMenuCountOnBox(partsAndServices: PartsAndServices, partService: PartService, subPartService: SubPartService, mainSectionTitle: String)
}

@IBDesignable class MenuCountOnBox: NibDesignable {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    var delegate: MenuCountOnBoxDelegate?
    
    private var partServiceContent: [PartServiceContent]?
    private var partsAndServices: PartsAndServices?
    private var mainSectiontTile: String?
    private var partService: PartService?
    private var subPartService: SubPartService?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        getParts()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getParts", name: JSONManager.newDataAvailableKey, object: nil)
    }
    
    func getParts() {
        if let partServiceContent = JSONManager.getJSONParts()?.partsServicesContent {
            //filter out countonboxes
            for pc in partServiceContent  {
                for ps in pc.partsServices {
                    if let subPartServices = ps.subPartsServices {
                        for sp in subPartServices {
                            sp.content.contentList = sp.content.contentList.flatMap({ $0 as? Content.CountOnBoxContent})
                        }
                        ps.subPartsServices = subPartServices.filter({ $0.content.contentList.count > 0})
                    }
                }
                pc.partsServices = pc.partsServices.filter({ $0.subPartsServices?.count > 0})
            }
            self.partServiceContent = partServiceContent
        }
        loadNewInfo()
    }
    
    func loadNewInfo() {
        if var partServicesContent = self.partServiceContent, let json = JSONManager.getJSONParts() {
            var count = 0
            while count < 1000 {
                //random buisnessType
                let bType = BusinessType.randomBusinessType()
                let ps = PartsAndServices(businessType: bType, json: json)
                let partServiceContent = partServicesContent[Int(arc4random_uniform(UInt32(partServicesContent.count)))]
                let partServices = partServiceContent.partsServices.filter({ ps.shouldPartServiceBeShown($0)})
                if partServices.count > 0 {
                    let rand = arc4random_uniform(UInt32(partServices.count))
                    let partService = partServices[Int(rand)]
                    if let subpartServices = partService.subPartsServices?.filter({ps.shouldSubPartServiceBeShown($0)}) where subpartServices.count > 0 {
                        let sub_rand = arc4random_uniform(UInt32(subpartServices.count))
                        let subpartService = subpartServices[Int(sub_rand)]
                        let countonBoxes = subpartService.content.contentList.flatMap(({ $0 as? Content.CountOnBoxContent}))
                        if countonBoxes.count > 0 {
                            let countonBox = countonBoxes[Int(arc4random_uniform(UInt32(countonBoxes.count)))]
                            if let number = countonBox.midText, let botText = countonBox.bottomText {
                                self.numberLabel.text = number
                                self.textLabel.text = botText
                                self.partsAndServices = ps
                                self.partService = partService
                                self.subPartService = subpartService
                                self.mainSectiontTile = partServiceContent.title
                                print("countonBoxes found " + String(count))
                                count = Int.max
                                return
                            }
                        } else { print("countonBoxes not found") }
                    }
                }
                else { print("subpartServices not found") }
                count++
            }
        }
    }
    
    @IBAction func tapAction(sender: AnyObject) {
        if let ps = self.partService, let pas = self.partsAndServices, let sps = self.subPartService, let title = self.mainSectiontTile {
            self.delegate?.didTapMenuCountOnBox(pas, partService: ps, subPartService: sps, mainSectionTitle: title)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}