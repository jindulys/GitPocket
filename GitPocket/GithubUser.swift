//
//  User.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-16.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

public class GithubUser {
    /// The user's login name
    public let login: String
    /// The user's id
    public let id: Int32
    public let avatarURL: String
    public let url: String
    public let name: String
    public let htmlURL: String
    public let type: String
    public let followersURL: String?
    public let followingURL: String?
    public let gistsURL: String?
    public let starredURL: String?
    public let subscriptionsURL: String?
    public let organizationsURL: String?
    public let reposURL: String?
    public let eventsURL: String?
    public let receivedEventsURL: String?
    public let siteAdmin: Bool?
    public let company: String?
    public let blog: String?
    public let location: String?
    public let email: String?
    public let hireable: Bool?
    public let bio: String?
    public let publicRepos: Int?
    public let publicGists: Int?
    public let followers: Int?
    public let following: Int?
    public let createdAt: String?
    public let updatedAt: String?
    
    init(login: String, id: Int32, avatarURL: String, url: String, name: String, htmlURL: String, type: String, followersURL: String? = nil, followingURL: String? = nil, gistsURL: String? = nil, starredURL: String? = nil, subscriptionsURL: String? = nil, organizationsURL: String? = nil, reposURL: String? = nil, eventsURL: String? = nil, receivedEventsURL: String? = nil, siteAdmin: Bool? = nil, company: String? = nil, blog: String? = nil, location: String? = nil, email: String? = nil, hireable: Bool? = nil, bio: String? = nil, publicRepos: Int? = nil, publicGists: Int? = nil, followers: Int? = nil, following: Int? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
        self.login        = login
        self.id           = id
        self.avatarURL    = avatarURL
        self.url          = url
        self.name         = name
        self.htmlURL      = htmlURL
        self.type         = type
        self.followersURL = followersURL
        self.followingURL = followingURL
        self.gistsURL     = gistsURL
        self.starredURL = starredURL
        self.subscriptionsURL = subscriptionsURL
        self.organizationsURL = organizationsURL
        self.reposURL = reposURL
        self.eventsURL = eventsURL
        self.receivedEventsURL = receivedEventsURL
        self.siteAdmin = siteAdmin
        self.company = company
        self.blog = blog
        self.location = location
        self.email = email
        self.hireable = hireable
        self.bio = bio
        self.publicRepos = publicRepos
        self.publicGists = publicGists
        self.followers = followers
        self.following = following
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}