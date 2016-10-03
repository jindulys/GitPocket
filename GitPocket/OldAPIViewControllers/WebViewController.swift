//
//  WebViewController.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-26.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

open class WebViewController: UIViewController {
    open let webView: UIWebView = UIWebView()
    open var webURL: URLLiteralConvertible?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        let urlRequest = URLRequest(url: (webURL?.URL)! as URL)
        webView.loadRequest(urlRequest)
    }
    
    func setupViews() {
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            // webView constraints
            let webViewLeadingConstraint = webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
            
            let webViewTrailingConstraint = webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            
            let webViewTopConstraint = webView.topAnchor.constraint(equalTo: self.view.topAnchor)
            
            let webViewBottomConstraint = webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            NSLayoutConstraint.activate([webViewLeadingConstraint, webViewTopConstraint, webViewBottomConstraint, webViewTrailingConstraint])
        }
        
    }
}
