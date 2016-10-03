//
//  UIScrollView+PullToRefresh.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-30.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC
var associatedObjectHandle: UInt8 = 0

extension UIScrollView {
    var pullToRefresh: PullToRefresh? {
        get {
            return objc_getAssociatedObject(self, &associatedObjectHandle) as? PullToRefresh
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addPullToRefresh(_ pullToRefresh: PullToRefresh, action:@escaping ()->()) {
        if self.pullToRefresh != nil {
            self.removePullToRefresh(self.pullToRefresh!)
        }
        
        self.pullToRefresh = pullToRefresh
        pullToRefresh.scrollView = self
        pullToRefresh.action = action
        
        let view = pullToRefresh.refreshView
        view.frame = CGRect(x: 0, y: -view.frame.size.height, width: self.frame.size.width, height: view.frame.size.height)
        self.addSubview(view)
        self.sendSubview(toBack: view)
    }
    
    func removePullToRefresh(_ pullToRefresh: PullToRefresh) {
        self.pullToRefresh?.refreshView.removeFromSuperview()
        self.pullToRefresh = nil
    }
    
    func startRefreshing() {
        pullToRefresh?.startRefreshing()
    }
    
    func endRefresing() {
        pullToRefresh?.endRefreshing()
    }
}
