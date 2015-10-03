//
//  SideBarViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 3/10/15.
//  Copyright © 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class SidebarViewController: UIViewController {
    
    var menuViewController: UIViewController!
    var mainViewController: UIViewController!
    
    var overlappedWidth: CGFloat!
    var scrollView: UIScrollView!
    var firstTime = true
    
    required init?(coder aDecoder: NSCoder) {
        assert(false)
        super.init(coder: aDecoder)
    }
    
    init(menuViewController: UIViewController, mainViewController: UIViewController, overlappedWidth: CGFloat) {
        self.menuViewController = menuViewController
        self.mainViewController = mainViewController
        self.overlappedWidth = overlappedWidth
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        setupScrollView()
        setupViewControllers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTime {
            firstTime = false
            closeMenuAnimated(false)
        }
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView])
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView])
        NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func setupViewControllers() {
        addViewController(menuViewController)
        addViewController(mainViewController)
        
        addShadowToView(mainViewController.view)
        
        let views = ["menu": menuViewController.view, "main": mainViewController.view, "outer": view]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "|[menu][main(==outer)]|", options: [.AlignAllTop, .AlignAllBottom], metrics: nil, views: views)
        let menuWidthConstraint = NSLayoutConstraint(
            item: menuViewController.view,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0, constant: -overlappedWidth)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[main(==outer)]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints + [menuWidthConstraint])
        
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
    }
    
    func openMenuAnimated(animated: Bool) {

        scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: animated)
    }
    
    func closeMenuAnimated(animated: Bool) {
        
        scrollView.setContentOffset(CGPoint(x: menuViewController.view.frame.width, y: 0.0), animated: animated)
    }
    
    func menuBarIsOpen() -> Bool {
        
        return scrollView.contentOffset.x == 0
    }
    
    func toggleMenuAnimated(animated: Bool) {
        if menuBarIsOpen() {
            closeMenuAnimated(animated)
        } else {
            openMenuAnimated(animated)
        }
    }
    
    func viewTapped(tapReconizer: UITapGestureRecognizer) {
        closeMenuAnimated(true)
    }
    
    private func addViewController(viewController: UIViewController) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(viewController.view)
        addChildViewController(viewController)
        viewController.didMoveToParentViewController(self)
    }
    
    private func addShadowToView(destView: UIView) {
        destView.layer.shadowPath = UIBezierPath(rect: destView.bounds).CGPath
        destView.layer.shadowRadius = 2.5
        destView.layer.shadowOffset = CGSize(width: 0, height: 0)
        destView.layer.shadowOpacity = 1.0
        destView.layer.shadowColor = UIColor.blackColor().CGColor
    }
}

extension SidebarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let tapLocation = touch.locationInView(view)
        let tapWasInArea = tapLocation.x >= view.bounds.width - overlappedWidth
        
        return menuBarIsOpen() && tapWasInArea
    }
}

extension SidebarViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
            mainViewController.view.userInteractionEnabled = false
        } else if scrollView.contentOffset.x == menuViewController.view.frame.width {
            mainViewController.view.userInteractionEnabled = true
        }
        
    }
}
