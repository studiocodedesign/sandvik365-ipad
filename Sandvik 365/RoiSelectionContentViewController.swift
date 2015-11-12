//
//  RoiPageContentViewController.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 11/08/15.
//  Copyright (c) 2015 Commind. All rights reserved.
//

import UIKit

protocol RoiSelectionContentViewControllerDelegate {
    func roiValueDidChange(itemIndex: Int, object :AnyObject)
}

class RoiSelectionContentViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var containerViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var spinnerScrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    var itemIndex: Int = 0
    var selectedROICalculator: ROICalculator!
    var roiContentView: RoiInputView!
    var toggleTimer: NSTimer?
    
    var delegate: RoiSelectionContentViewControllerDelegate?
    
    var contentOffsetLast: CGPoint?
    let swipeOffset: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numberView = RoiInputView(frame: containerView.bounds)
        containerView.addSubview(numberView)
        
        numberView.loadNumber(itemIndex, roiInput: selectedROICalculator.input)
        numberView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints(fillConstraints(numberView, toView: containerView))
        roiContentView = numberView;
        roiContentView.textField.delegate = self
        spinnerScrollView.contentSize = CGSizeMake(spinnerScrollView.frame.width, spinnerScrollView.frame.height*40)
        spinnerScrollView.contentOffset = CGPointMake(0, spinnerScrollView.contentSize.height/2)
        spinnerScrollView.delegate = self
        contentOffsetLast = spinnerScrollView.contentOffset
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))

        spinnerScrollView.addGestureRecognizer(recognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if !selectedROICalculator.input.setInput(itemIndex, stringValue: textField.text!) {
            let alertController = UIAlertController(title: "Wrong input", message: "Please enter a valid number", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            }
            alertController.addAction(okAction)
            
            roiContentView.loadNumber(itemIndex, roiInput: selectedROICalculator.input)//load old value
            // Present Alert Controller
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            roiContentView.loadNumber(itemIndex, roiInput: selectedROICalculator.input)//load new value
            if let delegate = self.delegate {
                delegate.roiValueDidChange(itemIndex, object: roiContentView.textField.attributedText!)
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        roiContentView.textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return selectedROICalculator.input.getInputAsString(itemIndex) != nil
    }
    
    func handleTap(recognizer: UIGestureRecognizer) {
        if let value = selectedROICalculator.input.getInputAsString(itemIndex) {
            roiContentView.textField.text = value
            roiContentView.textField.becomeFirstResponder()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let y = CGRectGetMaxY(containerView.frame)
        let diff = y - keyboardSize!.height
        containerViewCenterY.constant += diff
    }
    
    func keyboardWillHide(notification: NSNotification) {
        containerViewCenterY.constant = 0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        print(contentOffsetLast!.y)
        let dy = scrollView.contentOffset.y - contentOffsetLast!.y
        print(dy)
        if dy != 0 && scrollView.contentOffset.y > 0{
            
            if dy > swipeOffset {
                toggleUp()
                contentOffsetLast = scrollView.contentOffset
            }
            else if dy < -swipeOffset {
                toggleDown()
                contentOffsetLast = scrollView.contentOffset
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("DidEndDecelerating")
        scrollView.bounds.origin = CGPointMake(0, spinnerScrollView.contentSize.height/2)
        contentOffsetLast = scrollView.contentOffset
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        spinnerScrollView.bounds.origin = CGPointMake(0, spinnerScrollView.contentSize.height/2)
        contentOffsetLast = spinnerScrollView.contentOffset
    }
    
    private func fillConstraints(fromView: UIView, toView: UIView) -> [NSLayoutConstraint] {
        let topConstraint = NSLayoutConstraint(item: fromView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: toView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: fromView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: toView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: fromView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: toView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        let trailConstraint = NSLayoutConstraint(item: fromView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: toView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        return [topConstraint, bottomConstraint, trailConstraint, leadingConstraint]
    }
    
    @IBAction func toggleUp(sender: UIButton) {
        toggleTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("toggleUp"), userInfo: nil, repeats: true)
    }
    
    @IBAction func toggleDown(sender: UIButton) {
        toggleTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("toggleDown"), userInfo: nil, repeats: true)
    }
    
    @IBAction func toggleLeft(sender: UIButton) {
       
    }
    
    @IBAction func toggleRight(sender: UIButton) {
        
    }
    
    func toggleDown() {
        if let numberView = roiContentView{
            numberView.decreaseNumber(itemIndex, roiInput: selectedROICalculator.input)
            if let delegate = self.delegate {
                delegate.roiValueDidChange(itemIndex, object: numberView.textField.attributedText!)
            }
        }
        /*else if let productView = roiContentView as? RoiProductView{
            //productView.previousProduct(selectedROICalculator.input)
            if let delegate = self.delegate {
                delegate.roiValueDidChange(itemIndex, object: selectedROICalculator.input)
            }
        }*/
    }
    
    func toggleUp() {
        if let numberView = roiContentView{
            numberView.increaseNumber(itemIndex, roiInput: selectedROICalculator.input)
            if let delegate = self.delegate {
                delegate.roiValueDidChange(itemIndex, object: numberView.textField.attributedText!)
            }
        }
        /*else if let productView = roiContentView as? RoiProductView{
            //productView.nextProduct(selectedROICalculator.input)
            if let delegate = self.delegate {
                delegate.roiValueDidChange(itemIndex, object: selectedROICalculator.input)
            }
        }*/
    }
    
    @IBAction func releaseAction(sender: UIButton) {
        toggleTimer?.fire()
        toggleTimer?.invalidate()
        toggleTimer = nil
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
