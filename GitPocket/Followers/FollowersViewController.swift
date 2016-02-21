//
//  FollowersViewController.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-15.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation
import UIKit
import GithubPilot

public class FollowersViewController: UIViewController {
    
    public override func viewDidAppear(animated: Bool) {
        print("View Did Appear")
        if let client = Github.authorizedClient {
            print("Exist Client")
            
//            client.users.getUser(username: "onevcat").response({ (githubUser, error) -> Void in
//                if let user = githubUser {
//                    print(user.description)
//                } else {
//                    print(error?.description)
//                }
//            })
//            
//            client.users.getAuthenticatedUser().response({ user, requestError in
//                if let me = user {
//                    print(me.description)
//                } else {
//                    print(requestError?.description)
//                }
//            })
//            
//            client.users.getAllUsers("1209").response({ (httpResponse, users, requestError) -> Void in
//                if let response = httpResponse {
//                    print("Since   :\(response)")
//                }
//                if let result = users {
//                    for user in result {
//                        print(user.description)
//                    }
//                } else {
//                    print(requestError?.description)
//                }
//            })
//            
//            client.repos.getAuthenticatedUserRepos().response({ (result, error) -> Void in
//                if let repos = result {
//                    print(repos.count)
//                    for i in repos {
//                        print(i.name)
//                        print(i.stargazersCount)
//                    }
//                }
//                
//                if let requestError = error {
//                    print(requestError.description)
//                }
//            })
//            
//            client.repos.getRepo("Yep", owner: "CatchChat").response({ (result, error) -> Void in
//                if let repo = result {
//                    print(repo.name)
//                }
//                
//                if let requestError = error {
//                    print(requestError.description)
//                }
//            })
            
            client.repos.getRepoFrom(owner: "onevcat").response({ (nextPage, result, error) -> Void in
                if let page = nextPage {
                    print("Next !!!! Page !!! is \(page)")
                    client.repos.getRepoFrom(owner: "onevcat", page: page).response({ (page, result, error) -> Void in
                        if let nextPage = page {
                            print("Next Next !!!! Page !!! is \(nextPage)")
                        }
                        
                        if let repos = result {
                            print(repos.count)
                            for i in repos {
                                print(i.name)
                                print(i.stargazersCount)
                            }
                        }
                    })
                }
                
                if let repos = result {
                    print(repos.count)
                    for i in repos {
                        print(i.name)
                        print(i.stargazersCount)
                    }
                }
                
                if let requestError = error {
                    print(requestError.description)
                }
            })
        }
    }
}