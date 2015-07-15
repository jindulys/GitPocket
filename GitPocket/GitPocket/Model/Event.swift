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
    case DeleteEvent = "DeleteEvent"
    case WatchEvent = "WatchEvent"
    case FollowEvent = "FollowEvent"
    case ForkEvent = "ForkEvent"
    case MemberEvent = "MemberEvent"
    
    init?(event:String) {
      switch event {
        case "CreatEvent":
          self = .CreateEvent
        case "DeleteEvent":
          self = .DeleteEvent
        case "WatchEvent":
          self = .WatchEvent
        case "FollowEvent":
          self = .FollowEvent
        case "ForkEvent":
          self = .ForkEvent
        case "MemberEvent":
          self = .MemberEvent
        default:
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


