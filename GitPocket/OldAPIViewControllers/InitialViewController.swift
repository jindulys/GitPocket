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

public class InitialViewController: UIViewController {
    var tableView: UITableView = UITableView()
    var netEngine: NetEngine?
    var events: [GithubEvent]?
    var hasToken: Bool = false
    var currentPage: Int = 1
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Recently Happened"
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "#2d8ed7")
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Add observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadView", name: Constants.NotificationKey.GithubAccessTokenRequestSuccess, object: nil)
        
        // Setup subviews
        
        setupViews()
        
        // New way to request
        Github.setupClientID("bf39a01edfbf0035cb42", clientSecret: "fd9c0462e830bc6936a217975b024e703d32adc0", scope: ["user", "repo"], redirectURI: "gitpocket://admin")
        Github.authenticate()
    }
    
    override public func viewDidAppear(animated: Bool) {
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
            self.tableView.registerClass(GithubFeedCell.self, forCellReuseIdentifier: "GithubFeedCell")
        } else {
            // Fallback on earlier versions
        }
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 90
        
        // Setup constraints
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        let views: NSDictionary = ["tableView": self.tableView]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views as! [String : AnyObject]))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views as! [String : AnyObject]))
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
                    self.events?.appendContentsOf(events)
                    self.tableView.reloadData()
                }
                self.tableView.endRefresing()
                self.currentPage = self.currentPage + 1
            })
        }
    }
    
    func mergeNewEvents(newEvent:[GithubEvent]) {
        guard let originalEvents = self.events else {
            self.events = newEvent
            return
        }
        var identicalIndex = -1
        for (index, value) in newEvent.enumerate() {
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
        
        arrayToMergeInto.appendContentsOf(originalEvents)
        self.events = arrayToMergeInto
    }
}


extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = self.events {
            return events.count
        } else {
            return 0
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        if #available(iOS 9.0, *) {
            let gitFeedCell = tableView.dequeueReusableCellWithIdentifier("GithubFeedCell") as! GithubFeedCell
            if let events = self.events {
                gitFeedCell.configureCellWithConfigureBlock(events[indexPath.row])
            }
            cell = gitFeedCell
        } else {
            // Fallback on earlier versions
            cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        }
        
        if (indexPath.row == self.events!.count/2) {
            self.loadMoreData()
        }
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
