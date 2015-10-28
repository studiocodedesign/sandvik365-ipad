//
//  PartsAndServicesViewController.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 25/08/15.
//  Copyright (c) 2015 Commind. All rights reserved.
//

import UIKit

class PartsAndServicesViewController: UIViewController, SelectionWheelDelegate {

    @IBOutlet weak var selectionWheel: SelectionWheel!
    
    var selectedPartsAndServices: PartsAndServices!
    var selectedSectionTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let json = JSONManager().readJSONFromFile() {
            selectionWheel.sectionTitles = selectedPartsAndServices.mainSectionTitles(json)
            selectionWheel.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSelectSection(sectionTitle: String) {
        selectedSectionTitle = sectionTitle
        performSegueWithIdentifier("ShowPartServiceSelectionViewController", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RoiSelectionViewController" {
            if let vc = segue.destinationViewController as? RoiSelectionViewController {
                //vc.selectedROICalculator = selectedPart.roiCalculator
                vc.navigationItem.title = String(format: "%@ | %@", self.navigationItem.title!, NSLocalizedString("ROI CALCULATOR", comment: ""))
            }
        }
        else if segue.identifier == "VideoViewController" {
            if let vc = segue.destinationViewController as? VideoViewController {
                vc.selectedBusinessType = selectedPartsAndServices.businessType
            }
        }
        else if segue.identifier == "ShowPartServiceSelectionViewController" {
            if let vc = segue.destinationViewController as? PartServiceSelectionViewController {
                vc.selectedPartsAndServices = selectedPartsAndServices
                vc.sectionTitle = selectedSectionTitle
                vc.navigationItem.title = String(format: "%@ | %@", self.navigationItem.title!, selectedSectionTitle)
            }
        }
    }

}
