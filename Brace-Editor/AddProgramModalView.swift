//
//  AddProgramModalView.swift
//  Brace-Editor
//
//  Created by Dan jarvis on 2/2/15.
//  Copyright (c) 2015 Dan jarvis. All rights reserved.
//

import UIKit

class AddingProgramModalView: UIViewController, UIScrollViewDelegate {
    
    var currentPage = 0
    @IBOutlet weak var readingModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleAlignmentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let optionsView = UINib(nibName: "OptionsView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as UIView
        scrollView.scrollsToTop = false
        view.addSubview(optionsView)
        
        // 1
        let blurEffect = UIBlurEffect(style: .Dark)
        // 2
        let blurView = UIVisualEffectView(effect: blurEffect)
        // 3
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.insertSubview(blurView, atIndex: 0)
        
        // 1
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        // 2
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.setTranslatesAutoresizingMaskIntoConstraints(false)
        // 3
        vibrancyView.contentView.addSubview(optionsView)
        // 4
        blurView.contentView.addSubview(vibrancyView)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal,
            toItem: optionsView, attribute: .CenterX, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal,
            toItem: optionsView, attribute: .CenterY, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .Height, relatedBy: .Equal, toItem: view,
            attribute: .Height, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .Width, relatedBy: .Equal, toItem: view,
            attribute: .Width, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: vibrancyView,
            attribute: .Height, relatedBy: .Equal,
            toItem: view, attribute: .Height,
            multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: vibrancyView,
            attribute: .Width, relatedBy: .Equal,
            toItem: view, attribute: .Width,
            multiplier: 1, constant: 0))
        
        view.addConstraints(constraints)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.contentSize = CGSizeMake(1272, 44)
        
        pageControl.currentPage = currentPage
        synchronizeViews(false)
    }
    
    @IBAction func pageControlPageDidChange(AnyObject) {
        synchronizeViews(false)
    }
    
    @IBAction func readingModeDidChange(segmentedControl: UISegmentedControl!) {
        
    }
    
    @IBAction func titleAlignmentDidChange(segmentedControl: UISegmentedControl!) {
        
    }
    
    private func synchronizeViews(scrolled: Bool) {
        let pageWidth = CGRectGetWidth(scrollView.bounds)
        var page: Int = 0
        var offset: CGFloat = 0
        
        if scrolled {
            offset = self.scrollView.contentOffset.x
            page = Int(offset / pageWidth)
            pageControl.currentPage = page
        } else {
            page = pageControl.currentPage
            offset = CGFloat(page) * pageWidth
            scrollView.setContentOffset(CGPointMake(offset, 0), animated: true)
        }
        
        if page != currentPage {
            currentPage = page
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if scrollView.dragging || scrollView.decelerating {
            synchronizeViews(true)
        }
    }
    
}