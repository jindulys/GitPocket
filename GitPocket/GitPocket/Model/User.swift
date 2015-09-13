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
        self.userName = profileInfo.valueForKey("login") as? String
        self.avatarURL = profileInfo.valueForKey("avatar_url") as? String
    }
    
    // class function to get a single user
    class func parseJSONDataIntoSingleUser(data: NSData) -> User? {
        do {
            if let userDict = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                let newUser = User(profileInfo: userDict)
                return newUser
            }
            return nil
        } catch _ {
            return nil
        }
    }
    
    // class function to get a list of users
    class func parseJSONDataIntoUsers(data: NSData) -> [User]?{
        do {
            if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
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
