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
  
  var netEngine: NetEngine?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    self.netEngine = appDelegate.netEngine
    
    self.netEngine?.requestOAuthAccess()
  }
}
