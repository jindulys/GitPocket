//
//  User.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-06.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation

class User {
    
    var userName: String?
    var avatarURL: String?
    
    
    init(profileInfo:NSDictionary) {
        self.userName = profileInfo.value(forKey: "login") as? String
        self.avatarURL = profileInfo.value(forKey: "avatar_url") as? String
    }
    
    // class function to get a single user
    class func parseJSONDataIntoSingleUser(_ data: Data) -> User? {
        do {
            if let userDict = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                let newUser = User(profileInfo: userDict)
                return newUser
            }
            return nil
        } catch _ {
            return nil
        }
    }
    
    // class function to get a list of users
    class func parseJSONDataIntoUsers(_ data: Data) -> [User]?{
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                var users = [User]()
                
                if let results = jsonDict["items"] as? NSArray {
                    for user in results {
                        if let userProfile = user as? NSDictionary {
                            let newUser = User(profileInfo: userProfile)
                            users.append(newUser)
                        }
                    }
                }
                return users
            }
            return nil
        } catch _ {
            return nil
        }
    }
    
    
}
