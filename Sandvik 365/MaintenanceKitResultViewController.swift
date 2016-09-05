//
//  MaintenanceKitResultViewController.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 01/09/16.
//  Copyright © 2016 Commind. All rights reserved.
//

import UIKit
import MessageUI

class MaintenanceOfferData {
    let maintenanceServiceKitParent: MaintenanceServiceKitParent
    var amount: Int
    
    init(maintenanceServiceKitParent: MaintenanceServiceKitParent, amount: Int){
        self.maintenanceServiceKitParent = maintenanceServiceKitParent
        self.amount = amount
    }
}

class MaintenanceKitResultViewController: UIViewController, ContactUsViewDelegate, RegionSelectorDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var contactUsView: ContactUsView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoView: MaintenanceKitInfoView!
    
    var addedExtraEquipmentData: [ExtraEquipmentData]? {
        didSet {
            setData()
        }
    }
    private var maintenanceOfferData = [MaintenanceOfferData]()
    private var regionSelector: RegionSelector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactUsView.delegate = self
    }
    
    func didSelectRegion() {
        if let regionSelector = self.regionSelector {
            regionSelector.removeFromSuperview()
            self.regionSelector = nil
        }
        self.contactUsView.didSelectRegion()
    }
    
    func showRegionAction(allRegions: [RegionData]) {
        regionSelector = RegionSelector(del: self, allRegions: allRegions)
        let constraints = regionSelector!.fillConstraints(self.view, topBottomConstant: 0, leadConstant: 0, trailConstant: 0)
        regionSelector!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(regionSelector!)
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    func didPressEmail(email: String) -> Bool {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Maintenance Kits Request – 365 APP")
        mail.setToRecipients([email])
        var html = "<!DOCTYPE html>"
        html = html + "<html>"
        html = html + "<body>"
/*  html = html + "<table><tr><td>My name is: </td><td><input type='text' name='name' placeholder='Please enter your name here'></td></tr>"
 html = html + "<br><tr><td>I work at : </td><td><input type='text' name='work' placeholder='Please enter your company here'></td></tr>"
 html = html + "<br><tr><td>Reach me at: </td><td><input type='text' name='phone' placeholder='Please enter your phone number and verify your e-mail address here'></td></tr></table>"*/
        html = html + "Thank you for using our Maintenance kits tool, please enter your contact information below and send the request. We will gladly come back to your shortly. Please note that you will need to have internet connection to send the request."
        html = html + "<br><br>My name is:"
        html = html + "<br>I work at :"
        html = html + "<br>Reach me at:"
        html = html + "<br><br>--- MACHINES & REQUESTED KITS ---<br>"
        html = html + "<br>Kits Part number and quantity:<br>"
        html = html + "<ul>"
        for data in self.maintenanceOfferData {
            html = html + "<li>"
            html = html + data.maintenanceServiceKitParent.description + " " + String(data.amount)
            html = html + "</li>"
        }
        html = html + "</ul>"
        
        if let addedExtraEquipmentData = self.addedExtraEquipmentData {
            html = html + "Machine(s) and serial number(s):<br>"
            html = html + "<ul>"
            for data in addedExtraEquipmentData {
                html = html + "<li>"
                html = html + (data.serviceKitData.model ?? "") + " " + data.serviceKitData.serialNo
                html = html + "</li>"
            }
            html = html + "</ul>"
        }
        
        html = html + "</body>"
        html = html + "</html>"
        mail.setMessageBody(html, isHTML: true)
        self.presentViewController(mail, animated: true, completion: nil)
        return true
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maintenanceOfferData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MaintenanceTableViewCell") as! MaintenanceTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.configureView(self.maintenanceOfferData[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        self.infoView.data = maintenanceOfferData[indexPath.row].maintenanceServiceKitParent
        self.infoView.hidden = false
    }
    
    private func setData() {
        if let alldata = MaintenanceServiceKitData.getAllData(), let input = self.addedExtraEquipmentData {
            self.maintenanceOfferData = [MaintenanceOfferData]()
            for obj in input {
                var alreadyCountedService = 0
                if let id = obj.serviceKitData.H1000ServiceKitNo where !id.isEmpty {
                    let amount = obj.hours / 1000
                    alreadyCountedService = amount
                    addMaintenanceKit(alldata, id: id, amount: amount)
                }
                
                if let id = obj.serviceKitData.H500ServiceKitNo where !id.isEmpty {
                    let amount = obj.hours / 500
                    addMaintenanceKit(alldata, id: id, amount: amount-alreadyCountedService)
                    alreadyCountedService = amount
                }
                if let id = obj.serviceKitData.H250ServiceKitNo where !id.isEmpty {
                    let amount = obj.hours / 250
                    addMaintenanceKit(alldata, id: id, amount: amount-alreadyCountedService)
                    alreadyCountedService = amount
                }
                if obj.workingConditionExtreme, let id = obj.serviceKitData.H125ServiceKitNo where !id.isEmpty {
                    let amount = obj.hours / 125
                    addMaintenanceKit(alldata, id: id, amount: amount-alreadyCountedService)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    private func addMaintenanceKit(allData: [String: MaintenanceServiceKitParent], id: String, amount: Int) {
        if let data = allData[id] {
            self.maintenanceOfferData.append(MaintenanceOfferData(maintenanceServiceKitParent: data, amount: max(0, amount)))
        }
    }
}
