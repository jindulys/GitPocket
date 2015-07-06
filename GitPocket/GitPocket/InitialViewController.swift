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
  
  @IBOutlet weak var tableView: UITableView!
  var netEngine: NetEngine?
  var events: [Event]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "User"
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    self.netEngine = appDelegate.netEngine
    
    guard let token = NSUserDefaults.standardUserDefaults().valueForKey("Token") as? String else {
      self.netEngine?.requestOAuthAccess()
      return
    }
    
    self.tableView!.delegate = self
    self.tableView!.dataSource = self
    print(token)
    // Test events
    self.netEngine?.requestEventWithCompletionHandler({ (events, error) -> Void in
      if let results = events {
        self.events = results
        self.tableView!.reloadData()
      }
      
    })
    
  }
}

extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("testCell") as UITableViewCell!
    if let events = self.events {
      cell.textLabel?.text = events[indexPath.row].Description()
    }
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let events = self.events {
      return events.count
    }
    return 0
  }
}
