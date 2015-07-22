//
//  GithubFeedCell.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-15.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit


class GithubFeedCell: UITableViewCell
{
  var avatarView: UIImageView = UIImageView()
  var userNameLabel: UILabel = UILabel()
  var actionLabel: UILabel = UILabel()
  var clientLabel: UILabel = UILabel()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupViews()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setupViews()
  }
  
  func configureCellWithConfigureBlock(event:Event) {
    // avatar view
    let avatarURL = NSURL(string: (event.actor?.avatarURL)!)
    let data = NSData(contentsOfURL: avatarURL!)
    self.avatarView.image = UIImage(data: data!)
    
    // user name
    self.userNameLabel.text = event.actor?.userName
    
    // user action
    self.actionLabel.text = event.type?.rawValue
    
    // repo name
    self.clientLabel.text = event.repo?.name
  }
  
  
  // Helper functions
  
  func setupViews() {
    avatarView.translatesAutoresizingMaskIntoConstraints = false
    avatarView.contentMode = .ScaleAspectFill
    self.contentView.addSubview(avatarView)
    
    // A common block could be called if multible labels have samiliar configuration.
    let setupLabel: (UILabel, Int, NSLineBreakMode)-> Void = { (label: UILabel, numOfLines: Int, lineBreakMode: NSLineBreakMode)  in
      label.translatesAutoresizingMaskIntoConstraints = false
      label.lineBreakMode = lineBreakMode
      label.textColor = UIColor.blackColor()
      label.backgroundColor = UIColor.clearColor()
      label.numberOfLines = numOfLines
      label.textAlignment = .Left
      self.contentView.addSubview(label)
    }
    
    userNameLabel.translatesAutoresizingMaskIntoConstraints = false
    userNameLabel.lineBreakMode = .ByTruncatingTail
    userNameLabel.textAlignment = .Left
    userNameLabel.textColor = UIColor.blackColor()
    userNameLabel.backgroundColor = UIColor.clearColor()
    userNameLabel.numberOfLines = 1
    self.contentView.addSubview(userNameLabel)
    
    actionLabel.translatesAutoresizingMaskIntoConstraints = false
    actionLabel.lineBreakMode = .ByTruncatingTail
    actionLabel.textAlignment = .Left
    actionLabel.numberOfLines = 1
    actionLabel.textColor = UIColor.blackColor()
    actionLabel.backgroundColor = UIColor.clearColor()
    self.contentView.addSubview(actionLabel)
    
    setupLabel(clientLabel, 0, .ByWordWrapping)
    
    // Setup Constraints
    createConstraints()
  }
  
  func createConstraints() {
    let contentView = self.contentView
    
    if #available(iOS 9.0, *) {
      
        // Avatar Constraints
        let avatarLeadingConstraint = avatarView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 10.0)
        avatarLeadingConstraint.identifier = "avatarLeadingConstraint"
        let avatarWidthConstraint = avatarView.widthAnchor.constraintEqualToConstant(60)
        avatarWidthConstraint.identifier = "avatarWidthConstraint"
        let avatarHeightConstraint = avatarView.heightAnchor.constraintEqualToConstant(60.0)
        avatarHeightConstraint.identifier = "avatarHeightConstraint"
        // To avoid unsatisfied constraints
        // http://stackoverflow.com/questions/25059443/what-is-nslayoutconstraint-uiview-encapsulated-layout-height-and-how-should-i
        avatarHeightConstraint.priority = 999
        let avatarTopConstraint = avatarView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 10.0)
        avatarTopConstraint.identifier = "avatarTopConstraint"
      
        // Username Label Constraints
        let usernameLeadingConstraint = userNameLabel.leadingAnchor.constraintEqualToAnchor(avatarView.trailingAnchor, constant: 15.0)
        usernameLeadingConstraint.identifier = "usernameLeadingConstraint"
        let usernameCenterXConstraint = userNameLabel.centerYAnchor.constraintEqualToAnchor(avatarView.centerYAnchor)
        usernameCenterXConstraint.identifier = "usernameCenterXConstraint"
        let usernameTrailingConstraint = userNameLabel.trailingAnchor.constraintLessThanOrEqualToAnchor(contentView.trailingAnchor, constant: -15.0)
        usernameTrailingConstraint.identifier = "usernameTrailingConstraint"
        let usernameHeightConstraint = userNameLabel.heightAnchor.constraintGreaterThanOrEqualToAnchor(avatarView.heightAnchor)
        usernameHeightConstraint.identifier = "usernameHeightConstraint"
      
        // Action Label Constraints
        let actionLeadingConstraint = actionLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15.0)
        actionLeadingConstraint.identifier = "actionLeadingConstraint"
        let actionTopConstraint = actionLabel.topAnchor.constraintEqualToAnchor(avatarView.bottomAnchor, constant: 10.0)
        actionTopConstraint.identifier = "actionTopConstraint"
        let actionTrailingConstraint = actionLabel.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15.0)
        actionTrailingConstraint.identifier = "actionTrailingConstraint"
      
        // Client Label Constraints 
        let clientLeadingConstraint = clientLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15.0)
        clientLeadingConstraint.identifier = "clientLeadingConstraint"
        let clientTrailingConstraint = clientLabel.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15.0)
        clientTrailingConstraint.identifier = "clientTrailingConstraint"
        let clientBottomConstraint = clientLabel.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10.0)
        clientBottomConstraint.identifier = "clientBottomConstraint"
        let clientTopConstraint = clientLabel.topAnchor.constraintEqualToAnchor(actionLabel.bottomAnchor, constant: 10.0)
        clientTopConstraint.identifier = "clientTopConstraint"
      
        NSLayoutConstraint.activateConstraints([avatarLeadingConstraint, avatarWidthConstraint, avatarHeightConstraint, avatarTopConstraint, usernameLeadingConstraint, usernameTrailingConstraint, usernameCenterXConstraint, usernameHeightConstraint, actionLeadingConstraint, actionTopConstraint, actionTrailingConstraint, clientLeadingConstraint, clientTrailingConstraint, clientBottomConstraint, clientTopConstraint])
      
    } else {
        // Fallback on earlier versions
      print("some stuff")
    }
  }
}

