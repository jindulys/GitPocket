//
//  InitialViewController.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-05.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit

public class InitialViewController: UIViewController {
    var tableView: UITableView = UITableView()
    var netEngine: NetEngine?
    var events: [Event]?
    var hasToken: Bool = false
    var currentPage: Int = 1
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "User"
        
        // Add observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadView", name: kGitPocketSuccessfullyGetTokenKey, object: nil)
        
        // Setup subviews
        
        setupViews()
        
        // Set NetEngine
        self.netEngine = NetEngine.SharedInstance
        
        guard let token = NSUserDefaults.standardUserDefaults().valueForKey("Token") as? String else {
            self.netEngine?.requestOAuthAccess()
            return
        }
        hasToken = true
        self.netEngine?.token = token
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Add PullToRefresh
        self.tableView.addPullToRefresh(PullToRefresh()) { () -> () in
            self.netEngine?.requestEventWithCompletionHandler({ (events, error) -> Void in
                if let results = events {
                    self.mergeNewEvents(results)
                    self.tableView.reloadData()
                }
                self.tableView.endRefresing()
            })
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
        
        self.netEngine?.requestEventWithPage(++currentPage) { (events, error) -> Void in
            if let results = events {
                self.events?.appendContentsOf(results)
                self.tableView.reloadData()
            }
            self.tableView.endRefresing()
        }
    }
    
    func mergeNewEvents(newEvent:[Event]) {
        guard let originalEvents = self.events else {
            self.events = newEvent
            return
        }
        var identicalIndex = -1
        for (index, value) in newEvent.enumerate() {
            if let currentID = value.eventID {
                if currentID == originalEvents[0].eventID! {
                    identicalIndex = index
                    break
                }
            }
        }
        
        var arrayToMergeInto:[Event]
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
            repo.getRepoFullInfoWithCompletionHander(){
                [unowned self] in
                if let repoURL = repo.homeURL {
                    dispatch_async(dispatch_get_main_queue()) {
                        let webVC = WebViewController()
                        webVC.webURL = repoURL
                        self.navigationController?.pushViewController(webVC, animated: true)
                    }
                }
            }
        }
    }
}
