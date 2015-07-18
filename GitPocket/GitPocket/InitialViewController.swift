//
//  InitialViewController.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-05.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UIViewController {
  var tableView: UITableView = UITableView()
  var netEngine: NetEngine?
  var events: [Event]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "User"
    
    // Set NetEngine
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    self.netEngine = appDelegate.netEngine
    
    guard let token = NSUserDefaults.standardUserDefaults().valueForKey("Token") as? String else {
      self.netEngine?.requestOAuthAccess()
      return
    }
    
    self.netEngine?.token = token
    
    // Setup subviews
    self.view.addSubview(self.tableView)
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0)
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    // add refresh button
    let button = UIBarButtonItem(title: "Continue", style: .Plain, target: self, action: "sayHello:")
    self.navigationItem.leftBarButtonItem = button
    
    // Setup constraints
    self.tableView.translatesAutoresizingMaskIntoConstraints = false
    let views: NSDictionary = ["tableView": self.tableView]
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views as! [String : AnyObject]))
    
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views as! [String : AnyObject]))
  }
  
  func sayHello(sender: UIBarButtonItem) {
    print("Just A say hello")
    self.netEngine?.requestEventWithCompletionHandler({ (events, error) -> Void in
      if let results = events {
        self.events = results
        self.tableView.reloadData()
      }
    })
  }
}


extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
    if let events = self.events {
      cell.textLabel?.text = events[indexPath.row].Description()
    }
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let events = self.events {
      return events.count
    } else {
      return 0
    }
  }
}
