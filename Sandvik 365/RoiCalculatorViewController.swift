//
//  RoiCalculatorViewController.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 19/08/15.
//  Copyright (c) 2015 Commind. All rights reserved.
//

import UIKit

class RoiCalculatorViewController: UIViewController {

    var selectedROICalculator: ROICalculator!
    @IBOutlet var serviceButtons: [UIButton]!
    @IBOutlet weak var roiGraphView: RoiGraphView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var profitLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadServiceButtons()
        setBorderOnDetailButton()
        roiGraphView.selectedROIInput = selectedROICalculator.input
        setProfitLabel()
    }
    
    @IBAction func rampUpAction(sender: UIButton) {
        if let input = selectedROICalculator.input as? ROICrusherInput {
            controlCrusherServices(input, selectedService: .RampUp)
        }
        setProfitLabel()
    }
    
    @IBAction func conditionAction(sender: UIButton) {
        if let input = selectedROICalculator.input as? ROICrusherInput {
            controlCrusherServices(input, selectedService: .ConditionInspection)
        }
        setProfitLabel()
    }
    
    @IBAction func maintenanceAction(sender: UIButton) {
        if let input = selectedROICalculator.input as? ROICrusherInput {
            controlCrusherServices(input, selectedService: .MaintenancePlanning)
        }
        setProfitLabel()
    }
    
    @IBAction func protectiveAction(sender: UIButton) {
        //roiGraphView.setSelectedService(sender.selected, service: ROIService.Protective)
        setProfitLabel()
    }
    
    private func controlCrusherServices(input: ROICrusherInput, var selectedService: ROICrusherService) {

        if input.service == selectedService {
            selectedService = .None
        }
        
        switch selectedService {
        case .RampUp:
            for button in serviceButtons {
                button.selected = true
            }
        case .ConditionInspection:
            for button in serviceButtons {
                if button.tag == 0 {
                    button.selected = false
                }
                else {
                    button.selected = true
                }
            }
        case .MaintenancePlanning:
            for button in serviceButtons {
                if button.tag < 2 {
                    button.selected = false
                }
                else {
                    button.selected = true
                }
            }
            
        case .Protective: break
        case .None:
            for button in serviceButtons {
                button.selected = false
            }
        }
        
        
        input.service = selectedService
        roiGraphView.selectedROIInput = input
    }
    
    private func setProfitLabel()
    {
        let sum = selectedROICalculator.input.total()
        profitLabel.text = "$" + String(sum);
    }
    
    private func setBorderOnDetailButton() {
        var layer = self.detailButton.layer
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = self.detailButton.titleLabel?.textColor.CGColor
    }
    
    private func loadServiceButtons() {
        var size = serviceButtons[0].bounds.size
        size.width = size.height
        let color = UIColor(red: 0.890, green:0.431, blue:0.153, alpha:1.000)
        for button in serviceButtons {
            let borderimage = roundImage(size, fill: false, color: color)
            button.setImage(borderimage, forState: .Normal)
            let fillimage = roundImage(size, fill: true, color: color)
            button.setImage(fillimage, forState: .Highlighted)
            button.setImage(fillimage, forState: .Selected)
            /*if button.tag == 0 && selectedROICalculator.services.contains(ROIService.RampUp) {
                button.selected = true
            }
            else if button.tag == 1 && selectedROICalculator.services.contains(ROIService.ConditionInspection) {
                button.selected = true
            }
            else if button.tag == 2 && selectedROICalculator.services.contains(ROIService.MaintenancePlanning) {
                button.selected = true
            }
            else if button.tag == 3 && selectedROICalculator.services.contains(ROIService.Protective) {
                button.selected = true
            }*/
        }
    }
    
    private func roundImage(size: CGSize, fill: Bool, color: UIColor) -> UIImage? {
        var layer = CALayer()
        layer.frame = CGRectMake(0, 0, size.width, size.height)
        layer.cornerRadius = size.width/2
        layer.masksToBounds = true
        if fill {
            layer.backgroundColor = color.CGColor
        }
        else {
            layer.borderWidth = 1
            layer.borderColor = color.CGColor
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return roundedImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
