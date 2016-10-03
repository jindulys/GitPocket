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
    func animateState(_ state: RefreshState)
}

class PullToRefresh: NSObject {
    let refreshView: UIView
    var action: (() -> ())?
    
    let animator: RefreshViewAnimator
    
    var KVOContext = "PullToRefreshKVOContext"
    let contentOffsetKeyPath = "contentOffset"
    var scrollViewDefaultInsets = UIEdgeInsets.zero
    weak var scrollView: UIScrollView? {
        didSet {
            oldValue?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
            if let scrollView = scrollView {
                scrollViewDefaultInsets = scrollView.contentInset
                scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .initial, context: &KVOContext)
            }
        }
    }
    
    var previousContentOffset: CGPoint = CGPoint.zero
    var state: RefreshState = .initial {
        didSet{
            animator.animateState(state)
            switch state {
            case .loading:
                if let scrollView = scrollView , oldValue != .loading {
                    scrollView.contentOffset = previousContentOffset
                    scrollView.bounces = false
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        let insets = self.refreshView.frame.height + self.scrollViewDefaultInsets.top
                        scrollView.contentInset.top = insets
                        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -insets)
                        }, completion: { finished in
                            scrollView.bounces = true
                    })
                    action?()
                }
            case .finished:
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            let offset = previousContentOffset.y + scrollViewDefaultInsets.top
            let refreshViewHeight = refreshView.frame.height
            switch offset{
            case 0 where state != .loading: state = .initial
            case -refreshViewHeight..<0 where (state != .loading && state != .finished):
                state = .releasing(progress:-offset / refreshViewHeight)
            case -1000..<(-refreshViewHeight):
                if state == RefreshState.releasing(progress:1.0) && (scrollView?.isDragging == false) {
                    state = RefreshState.loading
                } else if state != RefreshState.loading && state != RefreshState.finished {
                    state = .releasing(progress:1.0)
                }
            default:
                break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        previousContentOffset.y = scrollView!.contentOffset.y
    }
    
    
    func startRefreshing() {
        if self.state != RefreshState.initial {
            return
        }
        
        scrollView?.setContentOffset(CGPoint(x: 0, y: -refreshView.frame.height - scrollViewDefaultInsets.top), animated: true)
        let delayTime = DispatchTime.now() + Double(Int64(0.27 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.state = RefreshState.loading
        })
    }
    
    func endRefreshing() {
        if state == .loading {
            state = .finished
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
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 40)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.hidesWhenStopped  = false
        addSubview(activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = convert(center, from: superview)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let superview = newSuperview {
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: superview.frame.width, height: 40)
        }
    }
}

class DefaultViewAnimator: RefreshViewAnimator {
    let animateView: DefaultRefreshView
    
    init(refreshView:DefaultRefreshView) {
        animateView = refreshView
    }
    
    func animateState(_ state: RefreshState) {
        switch state {
        case .initial:
            animateView.activityIndicator.stopAnimating()
        case .releasing(let progress):
            var transform = CGAffineTransform.identity
            transform = transform.scaledBy(x: progress, y: progress);
            transform = transform.rotated(by: 3.14 * progress * 2);
            animateView.activityIndicator.transform = transform
        case .loading:
            animateView.activityIndicator.startAnimating()
        default: break
        }
    }
}


enum RefreshState:Equatable, CustomStringConvertible {
    case initial, loading, finished
    case releasing(progress: CGFloat)
    
    var description: String {
        switch self {
        case .initial: return "Initial"
        case .loading: return "Loading"
        case .finished: return "Finished"
        case .releasing(let progress): return "Releasing:\(progress)"
        }
    }
}

func ==(a: RefreshState, b: RefreshState) -> Bool {
    switch(a, b) {
    case (.initial, .initial) : return true
    case (.loading, .loading) : return true
    case (.releasing, .releasing) : return true
    case (.finished, .finished) : return true
    default: return false
    }
}
