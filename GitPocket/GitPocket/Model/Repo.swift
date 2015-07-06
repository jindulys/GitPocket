//
//  Repo.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-06.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation

class Repo {
  var name: String?
  var owner: User?
  var language: String?
  var url: String?
  
  init(repoInfo:NSDictionary) {
    self.name = repoInfo.valueForKey("name") as? String
    
    if let userDict = repoInfo.valueForKey("owner") as? NSDictionary {
      self.owner = User(profileInfo: userDict)
    }
    
    self.language = repoInfo.valueForKey("language") as? String
    self.url = repoInfo.valueForKey("url") as? String
  }
}