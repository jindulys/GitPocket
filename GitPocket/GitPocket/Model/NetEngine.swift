//
//  NetEngine.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-05.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

class NetEngine {
  let clientID = "bf39a01edfbf0035cb42"
  let clientSecret = "fd9c0462e830bc6936a217975b024e703d32adc0"
  let githubOAuthURL = "https://github.com/login/oauth/authorize?"
  let redirectURI = "gitpocket://admin"
  let scope = "user,repo"
  
  func requestOAuthAccess() {
    let url = "\(githubOAuthURL)client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scope)"
    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
  }
}
