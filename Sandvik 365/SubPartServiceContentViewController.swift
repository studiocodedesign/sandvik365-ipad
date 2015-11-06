//
//  SubPartServiceContentViewController.swift
//  Sandvik 365
//
//  Created by Oskar Hakansson on 28/10/15.
//  Copyright © 2015 Commind. All rights reserved.
//

import UIKit

let didTapNotificationKey = "didTapNotificationKey"

class SubPartServiceContentViewController: UIViewController {

    var selectedPartsAndServices: PartsAndServices!
    var selectedContent: Content!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var paddingView: UIView!
    @IBOutlet var subContentView: UIView!
    @IBOutlet var stripeImageView: UIImageView!
    private let topConstant: CGFloat = 20
    private var alignCountOnBoxRight: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = UIImage(named: "sandvik_stripes_bg_mask") {
            let mask = CALayer()
            mask.frame = CGRectMake(0, 0, image.size.width, image.size.height)
            mask.contents = image.CGImage
            
            //stripeImageView.layer.masksToBounds = true
            stripeImageView.layer.mask = mask
        }
        
        if let view = self.view as? ViewWithBGImage {
            view.setImageBG(self.selectedPartsAndServices.businessType.backgroundImageName)
        }
        let content = selectedContent
        if var title = content.title {
            if let subtitle = content.subtitle {
                title += "\n" + subtitle
            }
            titleLabel.text = title.uppercaseString
        }
        var previousView: UIView = paddingView
        for obj in content.contentList {
            if let value = obj as? Content.Lead {
                previousView = addLead(value, images: content.images, prevView: previousView)
            }
            else if let value = obj as? Content.Body {
                previousView = addBody(value, prevView: previousView)
            }
            else if let value = obj as? Content.KeyFeatureListContent {
                previousView = addKeyFeatureList(value, prevView: previousView)
            }
            else if let value = obj as? Content.CountOnBoxContent {
                previousView = addColumns(value, prevView: previousView)
            }
            else if let value = obj as? Content.TabbedContent {
                previousView = addTabbedContent(value, prevView: previousView)
            }
        }

        let newbottomConstraint = NSLayoutConstraint(item: previousView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: subContentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -50)
        previousView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.deactivateConstraints([bottomConstraint])
        NSLayoutConstraint.activateConstraints([newbottomConstraint])
    }
    
    @IBAction func handleTap(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(didTapNotificationKey, object: self)
    }
    
    private func addViewAndConstraints(fromView: UIView, toView: UIView, topConstant: CGFloat) {
        
        let topConstraint = NSLayoutConstraint(item: fromView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: toView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: topConstant)
        let trailConstraint = NSLayoutConstraint(item: fromView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: subContentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -leadingConstraint.constant*2)
        let leadConstraint = NSLayoutConstraint(item: fromView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: subContentView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: leadingConstraint.constant)
        fromView.translatesAutoresizingMaskIntoConstraints = false
        subContentView.addSubview(fromView)
        
        NSLayoutConstraint.activateConstraints([topConstraint, trailConstraint, leadConstraint])
    }
    
    
    private func addLead(content: Content.Lead, images: [NSURL], prevView: UIView) -> UIView {
        var label = prevView
        
        if let text = content.text {
            label = genericTextLabel(text)
            addViewAndConstraints(label, toView: prevView, topConstant: topConstant)
        }
        for url in images {
            if let image = ImageCache.getImage(url) {
                var imgWidth:CGFloat = image.size.width
                var imgHeight:CGFloat = image.size.height
                let maxHeight:CGFloat = 200
                if imgHeight > maxHeight {
                    imgWidth = (maxHeight/image.size.height) * image.size.width
                    imgHeight = maxHeight
                }
                let imageView = UIImageView(image: image)
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                let view = UIView()
                let widthConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: imgWidth)
                let heightConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: imgHeight)
                let centerY = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                let centerX = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                let topConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(imageView)
                NSLayoutConstraint.activateConstraints([widthConstraint, centerX, centerY, heightConstraint, topConstraint])
                addViewAndConstraints(view, toView: label, topConstant: topConstant)
                label = view
            }
        }
        
        return label
    }
    
    private func addBody(content: Content.Body, var prevView: UIView) -> UIView {
        var label = prevView
        
        for titlesAndText in content.titlesAndText {
            if let title = titlesAndText.title {
                label = genericTitleLabel(title)
                addViewAndConstraints(label, toView: prevView, topConstant: topConstant)
            }
            if let text = titlesAndText.text {
                let prevLabel = label
                label = genericTextLabel(text)
                addViewAndConstraints(label, toView: prevLabel, topConstant: 0)
                prevView = label
            }
        }
        
        return label
    }
    
    private func addKeyFeatureList(content: Content.KeyFeatureListContent, var prevView: UIView) -> UIView {
        if let title = content.title {
            let label = genericTitleLabel(title)
            addViewAndConstraints(label, toView: prevView, topConstant: topConstant)
            prevView = label
        }
        let view = KeyFeatureList(frame: CGRectZero, keyFeatureList: content)
        addViewAndConstraints(view, toView: prevView, topConstant: topConstant)
        return view
    }
    
    private func addColumns(content: Content.CountOnBoxContent, prevView: UIView) -> UIView {
        let view = CountOnBox(frame: CGRectZero, countOnBox: content, alignRight: alignCountOnBoxRight)
        addViewAndConstraints(view, toView: prevView, topConstant: topConstant)
        alignCountOnBoxRight = !alignCountOnBoxRight
        return view
    }
    
    private func addTabbedContent(content: Content.TabbedContent, var prevView: UIView) -> UIView {
        var label = prevView
        
        if let tabs = content.tabs {
            for textTitle in tabs {
                if let title = textTitle.title {
                    label = genericTitleLabel(title)
                    addViewAndConstraints(label, toView: prevView, topConstant: topConstant)
                }
                if let text = textTitle.text {
                    let prevLabel = label
                    label = genericTextLabel(text)
                    addViewAndConstraints(label, toView: prevLabel, topConstant: 0)
                }
                prevView = label
            }
        }
        return label
    }
    
    private func genericTextLabel(string: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "AktivGroteskCorpMedium-Regular", size: 14.0)
        label.textColor = UIColor.whiteColor()
        
        label.text = string
        return label
    }
    
    private func genericTitleLabel(string: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "AktivGroteskCorpMedium-Regular", size: 16.0)
        label.textColor = UIColor(red: 0.082, green: 0.678, blue: 0.929, alpha: 1.000)
        
        label.text = string.uppercaseString
        return label
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
