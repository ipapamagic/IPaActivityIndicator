//
//  IPaActivityIndicator.swift
//  IPaActivityIndicator
//
//  Created by IPa Chen on 2015/7/4.
//  Copyright (c) 2015年 A Magic Studio. All rights reserved.
//

import Foundation
import UIKit

@objc public class IPaActivityIndicator: UIView {
    static var workingIndicators = [UIView:IPaActivityIndicator]()
    lazy var indicator = UIActivityIndicatorView(activityIndicatorStyle:.whiteLarge)
    lazy var indicatorBlackView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    convenience init(view:UIView) {
        self.init(frame: view.bounds)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetting()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetting()
    }

    func initialSetting() {
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
        indicatorBlackView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        indicatorBlackView.layer.cornerRadius = 10
        indicatorBlackView.clipsToBounds = true
        indicator.translatesAutoresizingMaskIntoConstraints = false

        indicatorBlackView .addSubview(indicator)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[indicator]-30-|", options: [], metrics: nil, views: ["indicator":indicator])
        indicatorBlackView.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[indicator]-30-|", options: [], metrics: nil, views: ["indicator":indicator])
        indicatorBlackView.addConstraints(constraints)
        
        
        
        indicator.startAnimating()
        
        indicatorBlackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(indicatorBlackView)
        var constraint = NSLayoutConstraint(item: indicatorBlackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: indicatorBlackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.addConstraint(constraint)

        
    }
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let superview = superview {
            // remove old super view
            let currentIndicator = IPaActivityIndicator.workingIndicators[superview]
            if currentIndicator != nil && currentIndicator != self{
                //should not be here
                currentIndicator!.removeFromSuperview()
            }

        }
       
    }
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        // add to new super view
        if let superview = self.superview {
            IPaActivityIndicator.workingIndicators[superview] = self
        }
    }
    static func getActualInView(_ view:UIView) -> UIView? {
        var actualInView = view
        while (actualInView is UITableView) {
            if let inSuperView = actualInView.superview {
                actualInView = inSuperView
            }
            else {
                return nil
            }
        }
        return actualInView
    }
// MARK:static public function
    static public func show(_ inView:UIView) {
        guard let actualInView = getActualInView(inView) else {
            return
        }
        let indicator = IPaActivityIndicator(view:actualInView)
        DispatchQueue.main.async(execute: {
            
            indicator.translatesAutoresizingMaskIntoConstraints = false
            actualInView.addSubview(indicator)

            
            let viewsDict:[String:UIView] = ["view": indicator]
            actualInView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",options:[.alignAllTop,.alignAllBottom],metrics:nil,views:viewsDict))
            actualInView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",options:[.alignAllLeading,.alignAllTrailing],metrics:nil,views:viewsDict))
            
            
        })
        
    }
    static public func hide(_ fromView:UIView) {
        guard let actualFromView = getActualInView(fromView) else {
            return
        }
        DispatchQueue.main.async(execute: {
            if let indicator = IPaActivityIndicator.workingIndicators[actualFromView] {
                indicator.removeFromSuperview()
                IPaActivityIndicator.workingIndicators.removeValue(forKey: actualFromView)
            }
        })

    }
}