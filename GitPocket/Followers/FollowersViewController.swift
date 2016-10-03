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
    
    var myTestResult:[GithubUser] = []
    
    public override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(FollowersViewController.receivedGithubAccessToken), name: "TestName", object: nil)
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
            
            client.repos.getRepo("Yep", owner: "CatchChat").response({ (result, error) -> Void in
                if let repo = result {
                    print(repo.name)
                    print(repo.stargazersURL!)
                }
                
                if let requestError = error {
                    print(requestError.description)
                }
            })
            
            
            
            
            // Notification Implementation
//            var aggregatedresult:[GithubUser] = []
//            var recursiveBlock: (String, String, String) -> () = {(_, _, _) in }
//            recursiveBlock = { repo, owner, page in
//                client.stars.getStargazersFor(repo: repo, owner: owner, page: page).response({(nextPage, result, error) -> Void in
//                    if let users = result {
//                        print(users.count)
//                        self.myTestResult.appendContentsOf(users)
//                    }
//                    
//                    if let vpage = nextPage {
//                        print("Next page is:\(vpage)")
//                        if vpage == "1" {
//                            print("Finished")
//                            NSNotificationCenter.defaultCenter().postNotificationName("TestName", object: nil)
//                        } else {
//                            recursiveBlock(repo, owner, vpage)
//                        }
//                    }
//                })
//                
//            }
//
//            recursiveBlock("Yep", "CatchChat", "1")
            
            
            // Could not work because semaphore at main queue, and response at main queue, which cause block.
            
//            let semaphore = dispatch_semaphore_create(0)
//            var recursiveBlock: (String, String, String) -> () = {(_, _, _) in }
//            recursiveBlock = { repo, owner, page in
//                client.stars.getStargazersFor(repo: repo, owner: owner, page: page).response({(nextPage, result, error) -> Void in
//                    if let users = result {
//                        print(users.count)
//                        self.myTestResult.appendContentsOf(users)
//                    }
//                    
//                    if let vpage = nextPage {
//                        print("Next page is:\(vpage)")
//                        if vpage == "1" {
//                            print("Here")
//                            dispatch_semaphore_signal(semaphore)
//                        } else {
//                            recursiveBlock(repo, owner, vpage)
//                        }
//                    }
//                })
//                
//            }
//            
//            recursiveBlock("Yep", "CatchChat", "1")
//            let timeoutTime = dispatch_time(DISPATCH_TIME_NOW, Int64(100 * NSEC_PER_SEC))
//            print("Begin Wait")
//            if dispatch_semaphore_wait(semaphore, timeoutTime) != 0 {
//                print("time out happened")
//            }
//            print("Wait at here")
            
            // Yup, Success, 
            // 1. get all the results, then return back
            // 2. change to main thread!
//            client.stars.getAllStargazersFor(repo: "Yep", owner: "CatchChat"){
//                result, error in
//                
//                if let users = result {
//                    print(users.count)
//                }
//                
//                if let error = error {
//                    print(error)
//                }
//            }


//            client.stars.getAllStargazersFor(repo: "Yep", owner: "CatchChat", complitionHandler: { [unowned client] (result, error) -> Void in
//                if let users = result {
//                    print(users.count)
//                    
//                    let userAPIUrls = users.map { $0.url }
//                    client.users.getFullUsers(userAPIUrls, complitionHandler: { (fullyUsers) -> Void in
//                        if let fullyResults = fullyUsers {
//                            let blogers = fullyResults.filter { $0.blog != nil }
//                            for user in blogers {
//                                print(user)
//                            }
//                        }
//                    })
//                }
//                
//                if let error = error {
//                    print(error)
//                }
//            })
            
            client.users.getUser(username: "jindulys").response({ (user, error) -> Void in
                if let responseError = error {
                    print(responseError.description)
                }
                
                if let lys = user {
                    print(lys)
                }
            })
            
            client.searchRepo.searchRepoForTopic("leetcode", sort: .Stars, order: .Desc, conditionDict: [GitHubSearchCondition.Language: "swift", GitHubSearchCondition.Stars: ">1"]).response({ (nextPage, repos, error) -> Void in
                if let next = nextPage {
                    print(next)
                }
                
                if let result = repos {
                    for repo in result {
                        print(repo)
                    }
                }
                
                if let err = error {
                    print(err)
                }
            })
            
//            // TODO: How to more elegantly deal with recursive call. 
//            client.repos.getRepoFrom(owner: "onevcat").response({ (nextPage, result, error) -> Void in
//                if let page = nextPage {
//                    print("Next !!!! Page !!! is \(page)")
//                    client.repos.getRepoFrom(owner: "onevcat", page: page).response({ (page, result, error) -> Void in
//                        if let nextPage = page {
//                            print("Next Next !!!! Page !!! is \(nextPage)")
//                        }
//                        
//                        if let repos = result {
//                            print(repos.count)
//                            for i in repos {
//                                print(i.name)
//                                print(i.stargazersCount)
//                            }
//                        }
//                    })
//                }
//                
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
//            client.events.getReceivedEventsForUser("jindulys").response({ (nextPage, result, error) -> Void in
//                if let page = nextPage {
//                    print("next page\(page)")
//                }
//                
//                if let events = result {
//                    print(events.count)
//                    for i in events {
//                        print(i.actor)
//                        print(i.repo)
//                    }
//                }
//
//            })
        }
    }
    
    func receivedGithubAccessToken() {
        print(myTestResult.count)
        
        let blogs = myTestResult.filter { (user) -> Bool in
            return user.blog != nil
        }
        print(blogs.count)
        
        
    }
    
    public override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}


