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
  
  @IBOutlet weak var tokenLabel: UILabel!
  
  var netEngine: NetEngine?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "User"
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    self.netEngine = appDelegate.netEngine
    
    guard let token = NSUserDefaults.standardUserDefaults().valueForKey("Token") as? String else {
      self.netEngine?.requestOAuthAccess()
      return
    }
    self.tokenLabel!.text = token
    
    
    // Test events
    self.netEngine?.requestEventWithCompletionHandler({ (data, error) -> Void in
      print(data)
    })
    
  }
}
