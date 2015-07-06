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
  let githubTokenURL = "https://github.com/login/oauth/access_token"
  
  func requestOAuthAccess() {
    let url = "\(githubOAuthURL)client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scope)"
    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
  }
  
  func requestTokenFromURL(url: NSURL){
    // get code from callback url
    let query = url.query
    let components = query?.componentsSeparatedByString("code=")
    let code = components?.last
    
    // generate query url
    let requestURL = "client_id=\(clientID)&client_secret=\(clientSecret)&code=\(code!)"
    
    // generate request
    let request = NSMutableURLRequest(URL: NSURL(string: githubTokenURL)!)
    request.HTTPMethod = "POST"
    let postData = requestURL.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
    let length = postData!.length
    request.setValue("\(length)", forHTTPHeaderField: "Content-Length")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = postData
    
    NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{
      (data, response, error) -> Void in
      
      if error != nil {
        print("Token couldn't been accessed")
      } else {
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
            case 200...204:
              print("Success")
              guard let tokenResponse = NSString(data:data!, encoding: NSASCIIStringEncoding) else {
                return
              }
              print(tokenResponse)
              let components = tokenResponse.componentsSeparatedByString("&")
              for component in components {
                let items = component.componentsSeparatedByString("=")
                var isToken = false
                for item in items {
                  if isToken {
                    NSUserDefaults.standardUserDefaults().setObject(item, forKey: "Token")
                    NSUserDefaults.standardUserDefaults().synchronize()
                  }
                  
                  if item == "access_token" {
                    isToken = true
                  }
                }
              }
            
            default:
              print("Response Error")
          }
        }
      }
    })!.resume()
    
    
  }
}
