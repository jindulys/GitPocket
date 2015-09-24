//
//  PullToRefresh.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-29.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

protocol RefreshViewAnimator {
    func animateState(state: RefreshState)
}

class PullToRefresh: NSObject {
    let refreshView: UIView
    var action: (() -> ())?
    
    let animator: RefreshViewAnimator
    
    var KVOContext = "PullToRefreshKVOContext"
    let contentOffsetKeyPath = "contentOffset"
    var scrollViewDefaultInsets = UIEdgeInsetsZero
    weak var scrollView: UIScrollView? {
        didSet {
            oldValue?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
            if let scrollView = scrollView {
                scrollViewDefaultInsets = scrollView.contentInset
                scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
            }
        }
    }
    
    var previousContentOffset: CGPoint = CGPointZero
    var state: RefreshState = .Initial {
        didSet{
            animator.animateState(state)
            switch state {
            case .Loading:
                if let scrollView = scrollView where oldValue != .Loading {
                    scrollView.contentOffset = previousContentOffset
                    scrollView.bounces = false
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.top
                        scrollView.contentInset.top = insets
                        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets)
                        }, completion: { finished in
                            scrollView.bounces = true
                    })
                    action?()
                }
            case .Finished:
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.scrollView?.contentInset = self.scrollViewDefaultInsets
                    self.scrollView?.contentOffset.y = -self.scrollViewDefaultInsets.top
                    }, completion: nil)
            default: break
            }
        }
    }
    
    init(refreshView: UIView, animator: RefreshViewAnimator) {
        self.refreshView = refreshView
        self.animator = animator
    }
    
    override convenience init() {
        let refreshView = DefaultRefreshView()
        self.init(refreshView: refreshView, animator: DefaultViewAnimator(refreshView: refreshView))
    }
    
    deinit {
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            let offset = previousContentOffset.y + scrollViewDefaultInsets.top
            let refreshViewHeight = refreshView.frame.height
            switch offset{
            case 0 where state != .Loading: state = .Initial
            case -refreshViewHeight..<0 where (state != .Loading && state != .Finished):
                state = .Releasing(progress:-offset / refreshViewHeight)
            case -1000..<(-refreshViewHeight):
                if state == RefreshState.Releasing(progress:1.0) && (scrollView?.dragging == false) {
                    state = RefreshState.Loading
                } else if state != RefreshState.Loading && state != RefreshState.Finished {
                    state = .Releasing(progress:1.0)
                }
            default:
                break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        previousContentOffset.y = scrollView!.contentOffset.y
    }
    
    
    func startRefreshing() {
        if self.state != RefreshState.Initial {
            return
        }
        
        scrollView?.setContentOffset(CGPointMake(0, -refreshView.frame.height - scrollViewDefaultInsets.top), animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.27 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            self.state = RefreshState.Loading
        })
    }
    
    func endRefreshing() {
        if state == .Loading {
            state = .Finished
        }
    }
    
}

class DefaultRefreshView: UIView {
    var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 40)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.hidesWhenStopped  = false
        addSubview(activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = convertPoint(center, fromView: superview)
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if let superview = newSuperview {
            frame = CGRectMake(frame.origin.x, frame.origin.y, superview.frame.width, 40)
        }
    }
}

class DefaultViewAnimator: RefreshViewAnimator {
    let animateView: DefaultRefreshView
    
    init(refreshView:DefaultRefreshView) {
        animateView = refreshView
    }
    
    func animateState(state: RefreshState) {
        switch state {
        case .Initial:
            animateView.activityIndicator.stopAnimating()
        case .Releasing(let progress):
            var transform = CGAffineTransformIdentity
            transform = CGAffineTransformScale(transform, progress, progress);
            transform = CGAffineTransformRotate(transform, 3.14 * progress * 2);
            animateView.activityIndicator.transform = transform
        case .Loading:
            animateView.activityIndicator.startAnimating()
        default: break
        }
    }
}


enum RefreshState:Equatable, CustomStringConvertible {
    case Initial, Loading, Finished
    case Releasing(progress: CGFloat)
    
    var description: String {
        switch self {
        case .Initial: return "Initial"
        case .Loading: return "Loading"
        case .Finished: return "Finished"
        case .Releasing(let progress): return "Releasing:\(progress)"
        }
    }
}

func ==(a: RefreshState, b: RefreshState) -> Bool {
    switch(a, b) {
    case (.Initial, .Initial) : return true
    case (.Loading, .Loading) : return true
    case (.Releasing, .Releasing) : return true
    case (.Finished, .Finished) : return true
    default: return false
    }
}
