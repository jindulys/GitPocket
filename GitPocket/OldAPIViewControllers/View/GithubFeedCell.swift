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
    var storedEvent: GithubEvent?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func configureCellWithConfigureBlock(_ event:GithubEvent) {
        //First clean the initial view
        self.avatarView.image = nil
        
        // avatar view
        let avatarURL = URL(string: (event.actor?.avatarURL)!)
        //let data = NSData(contentsOfURL: avatarURL!)
        self.avatarView.load(avatarURL!)
        
        // user name
        self.userNameLabel.text = event.actor?.login
        
        // user action
        self.actionLabel.text = event.type.rawValue
        
        // repo name
        self.clientLabel.text = event.repo?.name
        
        self.storedEvent = event
    }
    
    
    // Helper functions
    
    func setupViews() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 10.0
        avatarView.clipsToBounds = true
        self.contentView.addSubview(avatarView)
        
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(GithubFeedCell.avatarTapped(_:)))
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(tapAvatar)
        
        // A common block could be called if multible labels have samiliar configuration.
        let setupLabel: (UILabel, Int, NSLineBreakMode)-> Void = { (label: UILabel, numOfLines: Int, lineBreakMode: NSLineBreakMode)  in
            label.translatesAutoresizingMaskIntoConstraints = false
            label.lineBreakMode = lineBreakMode
            label.textColor = UIColor.black
            label.backgroundColor = UIColor.clear
            label.numberOfLines = numOfLines
            label.textAlignment = .left
            self.contentView.addSubview(label)
        }
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.lineBreakMode = .byTruncatingTail
        userNameLabel.textAlignment = .left
        userNameLabel.textColor = UIColor.black
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.numberOfLines = 1
        self.contentView.addSubview(userNameLabel)
        
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.lineBreakMode = .byTruncatingTail
        actionLabel.textAlignment = .left
        actionLabel.numberOfLines = 1
        actionLabel.textColor = UIColor.black
        actionLabel.backgroundColor = UIColor.clear
        self.contentView.addSubview(actionLabel)
        
        setupLabel(clientLabel, 0, .byWordWrapping)
        
        actorTag.borderColor = UIColor.red
        actorTag.borderWidth = 2.0
        actorTag.cornerRadis = 2.0
        
        // create a stackView for userNameLabel and tagView
        // TODO: For now only support one tag for user, like iOS, FrontEnd, etc.
        actorNameTagStackView.translatesAutoresizingMaskIntoConstraints = false
        actorNameTagStackView.addArrangedSubview(userNameLabel)
        actorNameTagStackView.addArrangedSubview(actorTag)
        actorNameTagStackView.backgroundColor = UIColor.blue
        
        actorNameTagStackView.axis = .vertical
        actorNameTagStackView.alignment = .leading
        actorNameTagStackView.distribution = .fillProportionally
        actorNameTagStackView.spacing = 20.0
        actorNameTagStackView.isLayoutMarginsRelativeArrangement = true
        self.contentView.addSubview(actorNameTagStackView)
        
        // create a stackview for userNameLabel and avatarview
        actorStackView.translatesAutoresizingMaskIntoConstraints = false
        actorStackView.addArrangedSubview(avatarView)
        actorStackView.addArrangedSubview(actorNameTagStackView)
        
        actorStackView.axis = .horizontal
        actorStackView.alignment = .center
        actorStackView.distribution = .fillProportionally
        actorStackView.spacing = 38.0
        actorStackView.isLayoutMarginsRelativeArrangement = true
        self.contentView.addSubview(actorStackView)
        
        // Setup Constraints
        createConstraints()
    }
    
    func createConstraints() {
        let contentView = self.contentView
        
        // actor stack view constraints
        let actorSVLeadingConstraint = actorStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0)
        actorSVLeadingConstraint.identifier = "actorSVLeadingConstraint"
        let actorSVTrailingConstraint = actorStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0)
        actorSVTrailingConstraint.identifier = "actorSVTrailingConstraint"
        let actorSVTopConstraint = actorStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0)
        actorSVTopConstraint.identifier = "actorSVTopConstraint"
        
        // Avatar Constraints
        let avatarWidthConstraint = avatarView.widthAnchor.constraint(equalToConstant: 60)
        avatarWidthConstraint.identifier = "avatarWidthConstraint"
        //avatarWidthConstraint.priority = 999
        let avatarHeightConstraint = avatarView.heightAnchor.constraint(equalToConstant: 60.0)
        avatarHeightConstraint.priority = 999
        avatarHeightConstraint.identifier = "avatarHeightConstraint"
        
        // Add ActorNameTag Constraints
        let actorNameTagConstraint = actorNameTagStackView.trailingAnchor.constraint(equalTo: actorStackView.trailingAnchor)
        actorNameTagConstraint.identifier = "actorNameTagConstraint"
        
        // Action Label Constraints
        let actionLeadingConstraint = actionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0)
        actionLeadingConstraint.identifier = "actionLeadingConstraint"
        let actionTopConstraint = actionLabel.topAnchor.constraint(equalTo: actorStackView.bottomAnchor, constant: 10.0)
        actionTopConstraint.identifier = "actionTopConstraint"
        let actionTrailingConstraint = actionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0)
        actionTrailingConstraint.identifier = "actionTrailingConstraint"
        
        // Client Label Constraints
        let clientLeadingConstraint = clientLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0)
        clientLeadingConstraint.identifier = "clientLeadingConstraint"
        let clientTrailingConstraint = clientLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0)
        clientTrailingConstraint.identifier = "clientTrailingConstraint"
        let clientBottomConstraint = clientLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0)
        clientBottomConstraint.identifier = "clientBottomConstraint"
        let clientTopConstraint = clientLabel.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: 10.0)
        clientTopConstraint.identifier = "clientTopConstraint"
        
        NSLayoutConstraint.activate([actorSVLeadingConstraint, actorSVTrailingConstraint, actorSVTopConstraint, avatarWidthConstraint, avatarHeightConstraint, actionLeadingConstraint, actionTopConstraint, actionTrailingConstraint, clientLeadingConstraint, clientTrailingConstraint, clientBottomConstraint, clientTopConstraint, actorNameTagConstraint])
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
    
    func avatarTapped(_ img: AnyObject) {
        print(self.storedEvent?.actor)
    }
}

