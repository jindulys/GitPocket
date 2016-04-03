//
//  WebViewController.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-26.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

public class WebViewController: UIViewController {
    public let webView: UIWebView = UIWebView()
    public var webURL: URLLiteralConvertible?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        let urlRequest = NSURLRequest(URL: (webURL?.URL)!)
        webView.loadRequest(urlRequest)
    }
    
    func setupViews() {
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            // webView constraints
            let webViewLeadingConstraint = webView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor)
            
            let webViewTrailingConstraint = webView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor)
            
            let webViewTopConstraint = webView.topAnchor.constraintEqualToAnchor(self.view.topAnchor)
            
            let webViewBottomConstraint = webView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor)
            NSLayoutConstraint.activateConstraints([webViewLeadingConstraint, webViewTopConstraint, webViewBottomConstraint, webViewTrailingConstraint])
        }
        
    }
}
