//
//  GithubFeedCell.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-15.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation
import UIKit
import GithubPilot

@available(iOS 9.0, *)
class GithubFeedCell: UITableViewCell
{
    var avatarView: UIImageView = UIImageView()
    var userNameLabel: UILabel = UILabel()
    var actionLabel: UILabel = UILabel()
    var clientLabel: UILabel = UILabel()
    var actorStackView: UIStackView = UIStackView()
    
    var actorNameTagStackView: UIStackView = UIStackView()
    var actorTag: TagButton = TagButton(title: "UNKNOWN")
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    func configureCellWithConfigureBlock(event:GithubEvent) {
        //First clean the initial view
        self.avatarView.image = nil
        
        // avatar view
        let avatarURL = NSURL(string: (event.actor?.avatarURL)!)
        //let data = NSData(contentsOfURL: avatarURL!)
        self.avatarView.load(avatarURL!)
        
        // user name
        self.userNameLabel.text = event.actor?.login
        
        // user action
        self.actionLabel.text = event.type.rawValue
        
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
        
        actorTag.borderColor = UIColor.redColor()
        actorTag.borderWidth = 2.0
        actorTag.cornerRadis = 2.0
        
        // create a stackView for userNameLabel and tagView
        // TODO: For now only support one tag for user, like iOS, FrontEnd, etc.
        actorNameTagStackView.translatesAutoresizingMaskIntoConstraints = false
        actorNameTagStackView.addArrangedSubview(userNameLabel)
        actorNameTagStackView.addArrangedSubview(actorTag)
        actorNameTagStackView.backgroundColor = UIColor.blueColor()
        
        actorNameTagStackView.axis = .Vertical
        actorNameTagStackView.alignment = .Leading
        actorNameTagStackView.distribution = .FillProportionally
        actorNameTagStackView.spacing = 20.0
        actorNameTagStackView.layoutMarginsRelativeArrangement = true
        self.contentView.addSubview(actorNameTagStackView)
        
        // create a stackview for userNameLabel and avatarview
        actorStackView.translatesAutoresizingMaskIntoConstraints = false
        actorStackView.addArrangedSubview(avatarView)
        actorStackView.addArrangedSubview(actorNameTagStackView)
        
        actorStackView.axis = .Horizontal
        actorStackView.alignment = .Center
        actorStackView.distribution = .FillProportionally
        actorStackView.spacing = 38.0
        actorStackView.layoutMarginsRelativeArrangement = true
        self.contentView.addSubview(actorStackView)
        
        // Setup Constraints
        createConstraints()
    }
    
    func createConstraints() {
        let contentView = self.contentView
        
        // actor stack view constraints
        let actorSVLeadingConstraint = actorStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 10.0)
        actorSVLeadingConstraint.identifier = "actorSVLeadingConstraint"
        let actorSVTrailingConstraint = actorStackView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -15.0)
        actorSVTrailingConstraint.identifier = "actorSVTrailingConstraint"
        let actorSVTopConstraint = actorStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 6.0)
        actorSVTopConstraint.identifier = "actorSVTopConstraint"
        
        // Avatar Constraints
        let avatarWidthConstraint = avatarView.widthAnchor.constraintEqualToConstant(60)
        avatarWidthConstraint.identifier = "avatarWidthConstraint"
        //avatarWidthConstraint.priority = 999
        let avatarHeightConstraint = avatarView.heightAnchor.constraintEqualToConstant(60.0)
        avatarHeightConstraint.priority = 999
        avatarHeightConstraint.identifier = "avatarHeightConstraint"
        
        // Add ActorNameTag Constraints
        let actorNameTagConstraint = actorNameTagStackView.trailingAnchor.constraintEqualToAnchor(actorStackView.trailingAnchor)
        actorNameTagConstraint.identifier = "actorNameTagConstraint"
        
        // Action Label Constraints
        let actionLeadingConstraint = actionLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 15.0)
        actionLeadingConstraint.identifier = "actionLeadingConstraint"
        let actionTopConstraint = actionLabel.topAnchor.constraintEqualToAnchor(actorStackView.bottomAnchor, constant: 10.0)
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
        
        NSLayoutConstraint.activateConstraints([actorSVLeadingConstraint, actorSVTrailingConstraint, actorSVTopConstraint, avatarWidthConstraint, avatarHeightConstraint, actionLeadingConstraint, actionTopConstraint, actionTrailingConstraint, clientLeadingConstraint, clientTrailingConstraint, clientBottomConstraint, clientTopConstraint, actorNameTagConstraint])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //    print("ActorStackView Origin x:(\(actorStackView.frame.origin.x)) y:(\(actorStackView.frame.origin.y)) Size width:(\(actorStackView.frame.size.width)) height:(\(actorStackView.frame.size.height))\n")
        //
        //    print("actorNameTagStackView Origin x:(\(actorNameTagStackView.frame.origin.x)) y:(\(actorNameTagStackView.frame.origin.y)) Size width:(\(actorNameTagStackView.frame.size.width)) height:(\(actorNameTagStackView.frame.size.height))\n")
        //
        //    print("avatarView Origin x:(\(avatarView.frame.origin.x)) y:(\(avatarView.frame.origin.y)) Size width:(\(avatarView.frame.size.width)) height:(\(avatarView.frame.size.height))\n")
        //    
        //    print("userNameLabel Origin x:(\(userNameLabel.frame.origin.x)) y:(\(userNameLabel.frame.origin.y)) Size width:(\(userNameLabel.frame.size.width)) height:(\(userNameLabel.frame.size.height))\n")
        //    
        //    print("actorTag Origin x:(\(actorTag.frame.origin.x)) y:(\(actorTag.frame.origin.y)) Size width:(\(actorTag.frame.size.width)) height:(\(actorTag.frame.size.height))\n")
        //    
        //    print("--------*****************--------------")
    }
}

