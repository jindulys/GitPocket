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
    var homeURL: String?
    
    init(repoInfo:NSDictionary) {
        self.name = repoInfo.value(forKey: "name") as? String
        
        if let userDict = repoInfo.value(forKey: "owner") as? NSDictionary {
            self.owner = User(profileInfo: userDict)
        }
        
        self.language = repoInfo.value(forKey: "language") as? String
        self.url = repoInfo.value(forKey: "url") as? String
    }
    
    func getRepoFullInfoWithCompletionHander(_ completionHandler:(()->Void)? = nil) {
        
        if let repoURL = self.url {
            NetEngine.SharedInstance.requestTokenURL(repoURL, completionHandler: { (dict, error) -> Void in
                if error != nil {
                    print("error")
                }
                
                if let infoDict = dict {
                    self.homeURL = infoDict.value(forKey: "html_url") as? String
                    if let ch = completionHandler {
                        ch()
                    }
                }
            })
        }
    }
}
