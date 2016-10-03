//
//  SearchRepoViewController.swift
//  GitPocket
//
//  Created by yansong li on 2016-04-16.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import UIKit

class SearchRepoViewController: UIViewController {
    
    var searchTitleField: UITextField?
    var searchOwnerField: UITextField?
    
    var searchButton: UIButton?
    var searchList: UITableView?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Search Repo"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#2d8ed7")
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.setUpViews()
        if #available(iOS 9.0, *) {
            self.buildConstraints()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setUpViews() -> Void {
        self.searchTitleField = UITextField(frame: CGRectZero)
        self.searchTitleField?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.searchTitleField!)
    }
    
    @available(iOS 9.0, *)
    func buildConstraints() -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = [];
        constraints.append((self.searchTitleField?.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor))!)
        constraints.append((self.searchTitleField?.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor))!)
        constraints.append((self.searchTitleField?.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor))!)
        constraints.append((self.searchTitleField?.heightAnchor.constraintEqualToConstant(40))!)
        NSLayoutConstraint.activateConstraints(constraints)
        return constraints
    }
}