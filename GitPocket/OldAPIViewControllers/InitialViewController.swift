//
//  InitialViewController.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-05.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit
import GithubPilot

open class InitialViewController: UIViewController {
    var tableView: UITableView = UITableView()
    var events: [GithubEvent]?
    var hasToken: Bool = false
    var currentPage: Int = 1
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Recently Happened"
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#2d8ed7")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // Add observer
        NotificationCenter.default.addObserver(self, selector:#selector(InitialViewController.reloadView), name: NSNotification.Name(rawValue: Constants.NotificationKey.GithubAccessTokenRequestSuccess), object: nil)
        
        // Setup subviews
        
        setupViews()
        
        // New way to request
        Github.setupClientID("bf39a01edfbf0035cb42", clientSecret: "fd9c0462e830bc6936a217975b024e703d32adc0", scope: ["user", "repo"], redirectURI: "gitpocket://admin")
        Github.authenticate()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add PullToRefresh
        self.tableView.addPullToRefresh(PullToRefresh()) { () -> () in
            
            if let client = Github.authorizedClient {
                client.events.getReceivedEventsForUser("jindulys", page: "1").response({ (nextpage, results, error) -> Void in
                    if let events = results {
                        self.mergeNewEvents(events)
                        self.tableView.reloadData()
                    }
                    self.tableView.endRefresing()
                })
            }
        }
        
        if hasToken {
            self.tableView.startRefreshing()
        }
    }
    
    func setupViews() {
        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0, 0, 0)
        if #available(iOS 9.0, *) {
            self.tableView.register(GithubFeedCell.self, forCellReuseIdentifier: "GithubFeedCell")
        } else {
            // Fallback on earlier versions
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 90
        
        // Setup constraints
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        let views: NSDictionary = ["tableView": self.tableView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views as! [String : AnyObject]))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views as! [String : AnyObject]))
    }
    
    func reloadView() {
        print("finish token getting")
        setupViews()
        self.view.setNeedsLayout()
        self.tableView.startRefreshing()
    }
    
    func loadMoreData() {
        print("Half way Loading more data!")
        print("Current Page: \(currentPage)")
        if let client = Github.authorizedClient {
            client.events.getReceivedEventsForUser("jindulys", page: String(self.currentPage)).response({ (nextPage, results, error) -> Void in
                if let events = results {
                    self.events?.append(contentsOf: events)
                    self.tableView.reloadData()
                }
                self.tableView.endRefresing()
                self.currentPage = self.currentPage + 1
            })
        }
    }
    
    func mergeNewEvents(_ newEvent:[GithubEvent]) {
        guard let originalEvents = self.events else {
            self.events = newEvent
            return
        }
        var identicalIndex = -1
        for (index, value) in newEvent.enumerated() {
            let currentID = value.id
            if currentID == originalEvents[0].id {
                identicalIndex = index
                break
            }
        }
        
        var arrayToMergeInto:[GithubEvent]
        if identicalIndex >= 0 {
            arrayToMergeInto = Array(newEvent[0..<identicalIndex])
        } else {
            // Merge all events
            arrayToMergeInto = newEvent
        }
        
        arrayToMergeInto.append(contentsOf: originalEvents)
        self.events = arrayToMergeInto
    }
}


extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = self.events {
            return events.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        if #available(iOS 9.0, *) {
            let gitFeedCell = tableView.dequeueReusableCell(withIdentifier: "GithubFeedCell") as! GithubFeedCell
            if let events = self.events {
                gitFeedCell.configureCellWithConfigureBlock(events[indexPath.row])
            }
            cell = gitFeedCell
        } else {
            // Fallback on earlier versions
            cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        }
        
        if (indexPath.row == self.events!.count/2) {
            self.loadMoreData()
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = events![indexPath.row]
        if let repo = event.repo  {
            
            if let client = Github.authorizedClient {
                client.repos.getAPIRepo(url: repo.url!).response({ (result, error) -> Void in
                    if let repo = result {
                        let webVC = WebViewController()
                        webVC.webURL = repo.htmlURL
                        self.navigationController?.pushViewController(webVC, animated: true)
                    }
                })
            }
        }
    }
}
