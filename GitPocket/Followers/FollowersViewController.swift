//
//  FollowersViewController.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-15.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import UIKit

public class FollowersViewController: UIViewController {
    
    public override func viewDidAppear(animated: Bool) {
        print("View Did Appear")
        if let client = Github.authorizedClient {
            print("Exist Client")
            
            client.users.getUser(username: "jindulys").response({ (githubUser, error) -> Void in
                if let user = githubUser {
                    print(user.name)
                } else {
                    print(error?.description)
                }
            })
        }
    }
}