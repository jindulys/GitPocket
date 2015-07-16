//
//  Event.swift
//  GitPocket
//
//  Created by yansong li on 2015-07-06.
//  Copyright © 2015 yansong li. All rights reserved.
//

import Foundation

class Event {
  
  // https://developer.github.com/v3/activity/events/types/
  enum EventType: String {
    case CreateEvent = "CreateEvent"
    case CommitCommentEvent = "CommitCommmentEvent"
    case DeleteEvent = "DeleteEvent"
    case DeploymentEvent = "DeploymentEvent"
    case DeploymentStatusEvent = "DeploymentStatusEvent"
    case DownloadEvent = "DownloadEvent"
    case FollowEvent = "FollowEvent"
    case ForkEvent = "ForkEvent"
    case ForkApplyEvent = "ForkApplyEvent"
    case GistEvent = "GistEvent"
    case GollumEvent = "GollumEvent"
    case IssueCommentEvent = "IssueCommentEvent"
    case IssuesEvent = "IssuesEvent"
    case MemberEvent = "MemberEvent"
    case MembershipEvent = "MembershipEvent"
    case PageBuildEvent = "PageBuildEvent"
    case PublicEvent = "PublicEvent"
    case PullRequestEvent = "PullRequestEvent"
    case PullRequestReviewCommentEvent = "PullRequestReviewCommentEvent"
    case PushEvent = "PushEvent"
    case ReleaseEvent = "ReleaseEvent"
    case RepositoryEvent = "RepositoryEvent"
    case StatusEvent = "StatusEvent"
    case TeamAddEvent = "TeamAddEvent"
    case WatchEvent = "WatchEvent"
    
    init?(event:String) {
      switch event {
        case "CreateEvent":
          self = .CreateEvent
        case "CommitCommentEvent":
          self = .CommitCommentEvent
        case "DeleteEvent":
          self = .DeleteEvent
        case "DeploymentEvent":
          self = .DeploymentEvent
        case "DeploymentStatusEvent":
          self = .DeploymentStatusEvent
        case "DownloadEvent":
          self = .DownloadEvent
        case "FollowEvent":
          self = .FollowEvent
        case "ForkEvent":
          self = .ForkEvent
        case "ForkApplyEvent":
          self = .ForkApplyEvent
        case "GistEvent":
          self = .GistEvent
        case "GollumEvent":
          self = .GollumEvent
        case "IssueCommentEvent":
          self = .IssueCommentEvent
        case "IssuesEvent":
          self = .IssuesEvent
        case "MemberEvent":
          self = .MemberEvent
        case "MembershipEvent":
          self = .MembershipEvent
        case "PageBuildEvent":
          self = .PageBuildEvent
        case "PublicEvent":
          self = .PublicEvent
        case "PullRequestEvent":
          self = .PullRequestEvent
        case "PullRequestReviewCommentEvent":
          self = .PullRequestReviewCommentEvent
        case "PushEvent":
          self = .PushEvent
        case "ReleaseEvent":
          self = .ReleaseEvent
        case "RepositoryEvent":
          self = .RepositoryEvent
        case "StatusEvent":
          self = .StatusEvent
        case "TeamAddEvent":
          self = .TeamAddEvent
        case "WatchEvent":
          self = .WatchEvent
        default:
          print("There has \(event)")
          return nil
      }
    }
  }
  
  var type: EventType?
  var actor: User?
  var repo: Repo?
  
  init(eventInfo: NSDictionary) {
    
    if let typeName = eventInfo.valueForKey("type") as? String {
      self.type = EventType(event: typeName)
    }
    
    if let actor = eventInfo.valueForKey("actor") as? NSDictionary {
      self.actor = User(profileInfo: actor)
    }
    
    if let repo = eventInfo.valueForKey("repo") as? NSDictionary {
      self.repo = Repo(repoInfo: repo)
    }
    
  }
  
  // class function to get a list of event
  class func parseJSONDataIntoEvents(data: NSData) -> [Event]? {
    do {
      if let events = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSArray {
        
        var finalEvent = [Event]()
        for event in events {
          if let eventDict = event as? NSDictionary {
            let newEvent = Event(eventInfo: eventDict)
            finalEvent.append(newEvent)
          }
        }
        return finalEvent
      }
      return nil
    } catch _ {
      return nil
    }
  }
  
  
  
  // Helper function
  func Description() -> String {
    return "Type:\(type!.rawValue) User:\(actor!.userName!) Repo:\(repo!.name!)"
  }
  
  
}


