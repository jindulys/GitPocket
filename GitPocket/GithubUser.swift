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
    public let publicRepos: Int32?
    public let publicGists: Int32?
    public let followers: Int32?
    public let following: Int32?
    public let createdAt: String?
    public let updatedAt: String?
    
    init(login: String, id: Int32, avatarURL: String, url: String, name: String, htmlURL: String, type: String, followersURL: String? = nil, followingURL: String? = nil, gistsURL: String? = nil, starredURL: String? = nil, subscriptionsURL: String? = nil, organizationsURL: String? = nil, reposURL: String? = nil, eventsURL: String? = nil, receivedEventsURL: String? = nil, siteAdmin: Bool? = nil, company: String? = nil, blog: String? = nil, location: String? = nil, email: String? = nil, hireable: Bool? = nil, bio: String? = nil, publicRepos: Int32? = nil, publicGists: Int32? = nil, followers: Int32? = nil, following: Int32? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
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

public class GithubUserSerializer: JSONSerializer {
    public init() {}
    public func serialize(value: GithubUser) -> JSON {
        let retVal = [
            "login": Serialization._StringSerializer.serialize(value.login),
            "id": Serialization._Int32Serializer.serialize(value.id),
            "avatar_url": Serialization._StringSerializer.serialize(value.avatarURL),
            "url": Serialization._StringSerializer.serialize(value.url),
            "name": Serialization._StringSerializer.serialize(value.name),
            "html_url": Serialization._StringSerializer.serialize(value.htmlURL),
            "type": Serialization._StringSerializer.serialize(value.type),
            "followers_url": NullableSerializer(Serialization._StringSerializer).serialize(value.followersURL),
            "following_url": NullableSerializer(Serialization._StringSerializer).serialize(value.followingURL),
            "gists_url": NullableSerializer(Serialization._StringSerializer).serialize(value.gistsURL),
            "starred_url": NullableSerializer(Serialization._StringSerializer).serialize(value.starredURL),
            "subscriptions_url": NullableSerializer(Serialization._StringSerializer).serialize(value.subscriptionsURL),
            "organizations_url": NullableSerializer(Serialization._StringSerializer).serialize(value.organizationsURL),
            "repos_url": NullableSerializer(Serialization._StringSerializer).serialize(value.reposURL),
            "events_url": NullableSerializer(Serialization._StringSerializer).serialize(value.eventsURL),
            "received_events_url": NullableSerializer(Serialization._StringSerializer).serialize(value.receivedEventsURL),
            "site_admin": NullableSerializer(Serialization._BoolSerializer).serialize(value.siteAdmin),
            "company": NullableSerializer(Serialization._StringSerializer).serialize(value.company),
            "blog": NullableSerializer(Serialization._StringSerializer).serialize(value.blog),
            "location": NullableSerializer(Serialization._StringSerializer).serialize(value.location),
            "email": NullableSerializer(Serialization._StringSerializer).serialize(value.email),
            "hireable": NullableSerializer(Serialization._BoolSerializer).serialize(value.hireable),
            "bio": NullableSerializer(Serialization._StringSerializer).serialize(value.bio),
            "public_repos": NullableSerializer(Serialization._Int32Serializer).serialize(value.publicRepos),
            "public_gists": NullableSerializer(Serialization._Int32Serializer).serialize(value.publicGists),
            "followers": NullableSerializer(Serialization._Int32Serializer).serialize(value.followers),
            "following": NullableSerializer(Serialization._Int32Serializer).serialize(value.following),
            "created_at": NullableSerializer(Serialization._StringSerializer).serialize(value.createdAt),
            "updated_at": NullableSerializer(Serialization._StringSerializer).serialize(value.updatedAt)
        ]
        return .Dictionary(retVal)
    }
    
    public func deserialize(json: JSON) -> GithubUser {
        switch json {
            default:
                fatalError("JSON Type Error")
        }
    }
}
