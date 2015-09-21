//
//  Parts.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 25/08/15.
//  Copyright (c) 2015 Commind. All rights reserved.
//

import Foundation

enum PartType {
    case BulkMaterialHandling
    case ConveyorComponents
    case CrusherAndScreening
    case None
    
    static let allValues = [BulkMaterialHandling, ConveyorComponents, CrusherAndScreening, None]
    
    static let videos = [BulkMaterialHandling : "Sandvik365_Extern_150813"]
    
    static func atIndex(index: Int) -> PartType {
        if index < PartType.allValues.count {
            return PartType.allValues[index]
        }
        return PartType.None
    }
    
    func videoURL() -> NSURL? {
        if let videoName = PartType.videos[self] {
            let path = NSBundle.mainBundle().pathForResource(videoName, ofType:"m4v")
            let url = NSURL.fileURLWithPath(path!)
            return url
        }
        return nil
    }
    
    
}

class Part {
    let partType: PartType
    let roiCalculator: ROICalculator
    
    init(partType: PartType, roiCalculator: ROICalculator)
    {
        self.partType = partType
        self.roiCalculator = roiCalculator
    }
}